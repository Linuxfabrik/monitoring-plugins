#!/usr/bin/env python3
# -*- coding: utf-8; py-indent-offset: 4 -*-
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

"""Create the CycloneDX SBOM of a Windows build of the monitoring plugins.

Nuitka compiles the plugins without the metadata of the packages it bundles, so no
scanner finds anything in the ZIP or MSI. This script lists what the build ships:

* the Python distributions, from the Nuitka compilation reports (`--report`)
* Nuitka itself, whose runtime is compiled into every executable
* CPython and the C libraries it bundles (OpenSSL, SQLite, libffi, ...), from the
  SBOM python.org publishes for the CPython Windows installer of that version,
  limited to those whose binaries are in the compiled tree
* the Microsoft Visual C++ runtime

Versions of the shipped binaries are read from their version resources and must
match the reports and the python.org SBOM, otherwise the script fails.

Usage:
    create-windows-sbom.py --version 8.2.0 --iteration 1 \\
        --compiled <dir> --reports <dir> --output <file>

Needs `cyclonedx-python-lib[json-validation]` (.github/cyclonedx/requirements.txt).
"""

import argparse
import datetime
import json
import pathlib
import re
import sys
import urllib.request
import uuid
import xml.etree.ElementTree as ET  # nosec B405

__version__ = '2026112401'

COMPONENT_NAME = 'linuxfabrik-monitoring-plugins'
PYTHON_ORG_SBOM_URL = (
    'https://www.python.org/ftp/python/{version}/python-{version}-amd64.exe.spdx.json'
)
REPO_URL = 'https://github.com/Linuxfabrik/monitoring-plugins'

# Every package of the python.org SBOM of the CPython Windows installer, mapped to a
# file whose presence in the compiled tree shows that the package ships with the
# plugins. Packages with a PyPI purl (pip and the libraries pip vendors) are handled
# separately: they ship only if pip itself is a bundled distribution. A package that
# is not listed here makes the script fail, so a new one gets a decision instead of
# silently going missing. Verified against the SBOMs of CPython 3.13.x.
PYTHON_ORG_FILES = {
    # bzip2 is linked statically into _bz2.pyd
    'bzip2': '_bz2.pyd',
    'CPython': 'python3*.dll',
    # expat is linked statically into pyexpat.pyd
    'expat': 'pyexpat.pyd',
    # HACL* (hashlib's built-in hashes) and libb2 (blake2) are built into the DLL
    'hacl-star': 'python3*.dll',
    'libb2': 'python3*.dll',
    'libffi': 'libffi-*.dll',
    # mpdecimal is linked statically into _decimal.pyd
    'mpdecimal': '_decimal.pyd',
    'openssl': 'libssl-*.dll',
    'sqlite': 'sqlite3.dll',
    # Tcl/Tk come only with tkinter, which no plugin uses
    'tcl-core': '_tkinter.pyd',
    'tk': '_tkinter.pyd',
    # xz (liblzma) is linked statically into _lzma.pyd
    'xz': '_lzma.pyd',
    # zlib is built into the DLL
    'zlib': 'python3*.dll',
}

# python.org versions that must equal the version resource of a shipped DLL.
DLL_VERSION_CHECKS = {
    'openssl': 'libssl-*.dll',
    'sqlite': 'sqlite3.dll',
}


def fail(msg):
    print(f'❌ {msg}', file=sys.stderr)
    sys.exit(1)


def find_one(compiled, pattern):
    """Return the single file in `compiled` that matches `pattern`, or None."""
    # python3.dll is the stable-ABI forwarder, python3XX.dll the interpreter
    matches = [
        p for p in compiled.glob(pattern) if p.name.lower() != 'python3.dll'
    ] or list(compiled.glob(pattern))
    if len(matches) > 1:
        fail(f'More than one file matches {pattern} in {compiled}: {matches}')
    return matches[0] if matches else None


def product_version(path):
    """Return the `ProductVersion` string of a PE file's version resource."""
    data = path.read_bytes()
    key = 'ProductVersion'.encode('utf-16-le')
    pos = data.find(key)
    if pos == -1:
        return None
    pos += len(key)
    # the key is NUL-terminated and the value is padded to a 32-bit boundary
    while data[pos : pos + 2] == b'\x00\x00':
        pos += 2
    end = pos
    while data[end : end + 2] != b'\x00\x00':
        end += 2
    return data[pos:end].decode('utf-16-le').strip()


def purl_pypi(name, version):
    # https://github.com/package-url/purl-spec/blob/main/types-doc/pypi-definition.md
    return f'pkg:pypi/{re.sub(r"[-_.]+", "-", name).lower()}@{version}'


def read_reports(reports):
    """Return the bundled distributions and the Nuitka and Python versions."""
    files = sorted(reports.glob('*.xml'))
    if not files:
        fail(f'No Nuitka compilation reports in {reports}')
    distributions, nuitka, python = {}, set(), set()
    for f in files:
        # the reports are written by Nuitka in the same build, not untrusted input
        root = ET.parse(f).getroot()  # nosec B314
        nuitka.add(root.get('nuitka_version'))
        python.add(root.find('python').get('python_version'))
        for d in root.iterfind('distributions/distribution'):
            name, version = d.get('name'), d.get('version')
            if distributions.get(name, version) != version:
                fail(f'{name} comes in {distributions[name]} and {version}')
            distributions[name] = version
    if len(nuitka) != 1 or len(python) != 1:
        fail(f'The reports differ in Nuitka {nuitka} or Python {python}')
    return distributions, nuitka.pop(), python.pop()


def python_org_components(compiled, python_version, distributions):
    """Return the components of the python.org SBOM that ship with the build."""
    url = PYTHON_ORG_SBOM_URL.format(version=python_version)
    # a fixed https:// URL, no user-controlled scheme
    with urllib.request.urlopen(url, timeout=60) as response:  # nosec B310
        spdx = json.load(response)

    packages = {}
    for pkg in spdx['packages']:
        refs = {r['referenceType']: r['referenceLocator'] for r in pkg['externalRefs']}
        if refs.get('purl', '').startswith('pkg:pypi/'):
            # pip and what pip vendors
            if 'pip' in distributions:
                fail('pip is bundled, decide how to list its vendored packages')
            continue
        name = pkg['name']
        if name not in PYTHON_ORG_FILES:
            fail(f'{url} lists "{name}", add it to PYTHON_ORG_FILES')
        # The Windows build takes its C libraries from cpython-source-deps; a
        # second entry of the same name is the copy in the CPython tree (mpdecimal
        # in Modules/_decimal/libmpdec), which the Windows build does not use.
        if name in packages:
            if 'cpython-source-deps' in packages[name]['downloadLocation']:
                continue
            if 'cpython-source-deps' not in pkg['downloadLocation']:
                fail(f'{url} lists "{name}" twice, none from cpython-source-deps')
        packages[name] = {**pkg, 'cpe': refs.get('cpe23Type')}

    components = []
    for name, pkg in sorted(packages.items(), key=lambda i: i[0].lower()):
        if not find_one(compiled, PYTHON_ORG_FILES[name]):
            continue
        if name in DLL_VERSION_CHECKS:
            dll = find_one(compiled, DLL_VERSION_CHECKS[name])
            shipped = product_version(dll)
            if shipped != pkg['versionInfo']:
                fail(f'{dll.name} is {shipped}, {url} says {pkg["versionInfo"]}')
        component = {
            'type': 'library',
            'name': name,
            'version': pkg['versionInfo'],
        }
        if pkg['cpe']:
            component['cpe'] = pkg['cpe']
        if pkg.get('licenseConcluded', 'NOASSERTION') != 'NOASSERTION':
            component['licenses'] = [{'expression': pkg['licenseConcluded']}]
        components.append(component)
    return components


def build_sbom(
    version,
    iteration,
    compiled,
    distributions,
    nuitka_version,
    python_version,
    properties=None,
    timestamp=None,
):
    """Return the SBOM as a dict.

    `nuitka_version` may be None if unknown. `timestamp` is the build time, by
    default now.
    """
    if timestamp is None:
        timestamp = datetime.datetime.now(datetime.timezone.utc)
    dll = find_one(compiled, 'python3*.dll')
    if not dll:
        fail(f'No python3*.dll in {compiled}')
    shipped = product_version(dll)
    if shipped != python_version:
        fail(f'{dll.name} is {shipped}, the build used Python {python_version}')

    components = [
        {
            'type': 'library',
            'name': name,
            'version': distributions[name],
            'purl': purl_pypi(name, distributions[name]),
        }
        for name in sorted(distributions, key=str.lower)
    ]
    nuitka = {'type': 'library', 'name': 'Nuitka'}
    if nuitka_version:
        nuitka['version'] = nuitka_version
        nuitka['purl'] = purl_pypi('nuitka', nuitka_version)
    components.append(nuitka)
    components += python_org_components(compiled, python_version, distributions)
    vcruntime = find_one(compiled, 'vcruntime140.dll')
    if vcruntime:
        components.append(
            {
                'type': 'library',
                'name': 'Microsoft Visual C++ Redistributable',
                'supplier': {'name': 'Microsoft Corporation'},
                'version': product_version(vcruntime),
            }
        )
    for c in components:
        c['bom-ref'] = f'{c["name"]}@{c.get("version", "unknown")}'

    name = f'lfmp-{version}-{iteration}.windows.x86_64'
    root_ref = f'{COMPONENT_NAME}@{version}'
    sbom = {
        'bomFormat': 'CycloneDX',
        'specVersion': '1.6',
        # stable for a build, so a rerun produces the same file
        'serialNumber': uuid.uuid5(uuid.NAMESPACE_URL, f'{REPO_URL}/{name}').urn,
        'version': 1,
        'metadata': {
            'timestamp': timestamp.strftime('%Y-%m-%dT%H:%M:%SZ'),
            'tools': {
                'components': [
                    {
                        'type': 'application',
                        'name': 'create-windows-sbom.py',
                        'version': __version__,
                    },
                ],
            },
            'component': {
                'type': 'application',
                'bom-ref': root_ref,
                'name': COMPONENT_NAME,
                'version': version,
                'description': f'Linuxfabrik Monitoring Plugins, {name}',
                'supplier': {
                    'name': 'Linuxfabrik GmbH',
                    'url': ['https://www.linuxfabrik.ch'],
                },
                'licenses': [{'license': {'id': 'Unlicense'}}],
                'purl': f'pkg:github/linuxfabrik/monitoring-plugins@v{version}',
                'externalReferences': [{'type': 'vcs', 'url': REPO_URL}],
            },
        },
        'components': components,
        'dependencies': [
            {'ref': root_ref, 'dependsOn': [c['bom-ref'] for c in components]},
        ],
    }
    if properties:
        sbom['metadata']['properties'] = [
            {'name': k, 'value': v} for k, v in properties.items()
        ]
    return sbom


def validate(sbom):
    # imported here, so that --help works without the library
    from cyclonedx.schema import SchemaVersion
    from cyclonedx.validation.json import JsonStrictValidator

    error = JsonStrictValidator(SchemaVersion.V1_6).validate_str(json.dumps(sbom))
    if error is not None:
        fail(f'The SBOM is not valid CycloneDX 1.6: {error}')


def write(sbom, output):
    validate(sbom)
    output.write_text(json.dumps(sbom, indent=2) + '\n', encoding='utf-8')
    print(f'✅ {output}: {len(sbom["components"])} components')


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('--compiled', required=True, type=pathlib.Path)
    parser.add_argument('--iteration', required=True)
    parser.add_argument('--output', required=True, type=pathlib.Path)
    parser.add_argument('--reports', required=True, type=pathlib.Path)
    parser.add_argument('--version', required=True)
    args = parser.parse_args()

    distributions, nuitka_version, python_version = read_reports(args.reports)
    sbom = build_sbom(
        args.version,
        args.iteration,
        args.compiled,
        distributions,
        nuitka_version,
        python_version,
    )
    write(sbom, args.output)


if __name__ == '__main__':
    main()
