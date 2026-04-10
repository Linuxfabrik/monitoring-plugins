# Check xml

## Overview

Fetches an XML document via HTTP(S) and checks for a matching string using XPath expressions. Supports namespace prefixes (important for testing WSDL responses) and HTTP Basic Authentication. If `--expect` is omitted, the check simply verifies that the XPath expression returns a non-empty result.

**Data Collection:**

* Fetches the XML document from the given `--url` via HTTP(S)
* Evaluates the `--xpath` expression against the parsed XML using lxml
* Namespace prefix-to-URI mappings can be provided via `--namespace` (repeatable)
* Supports HTTP Basic Authentication via `--username` and `--password`


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/xml> |
| Nagios/Icinga Check Name              | `check_xml` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--url` and `--xpath` are required) |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `lxml` |


## Help

```text
usage: xml [-h] [-V] [--always-ok] [--expect EXPECT] [--insecure]
           [--namespace NAMESPACES] [--no-proxy] [--password PASSWORD]
           [--timeout TIMEOUT] --url URL [--username USERNAME] --xpath XPATH

Fetches an XML document via HTTP(S) and checks for a matching string using
XPath expressions. Supports namespace prefixes and HTTP Basic Authentication.
Alerts when the expected value is not found or does not match.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --expect EXPECT       Expected string at the XPath location. If omitted,
                        just checks whether the XPath exists.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --namespace NAMESPACES
                        Namespace prefix-to-URI mapping for XPath expressions.
                        Can be specified multiple times. Example: `--
                        namespace="prefix1:https://schemas.xmlsoap.org/prefix1
                        /"`.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   HTTP Basic Auth password.
  --timeout TIMEOUT     Network timeout in seconds. Default: 7 (seconds)
  --url URL             XML endpoint URL.
  --username USERNAME   HTTP Basic Auth username.
  --xpath XPATH         XPath expression to query. Must point to a single
                        value (attribute or node content). Lists/arrays are
                        not supported.
```


## Usage Examples

Check if node `/note/heading` exists in XML:

```bash
./xml --url=https://www.w3schools.com/xml/note.xml --xpath=/note/heading
```

Output:

```text
Everything is ok.
```

Search for string "emi" in XML tag `<note><heading>`:

```bash
./xml --url=https://www.w3schools.com/xml/note.xml --xpath=/note/heading --expect=emi
```

Output:

```text
Everything is ok, "emi" found in result "Reminder".
```

Search for a string in a WSDL definition (namespace prefixes required):

```bash
./xml --url='https://www.xignite.com/xCurrencies.asmx?wsdl' \
    --xpath=/wsdl:definitions/wsdl:documentation \
    --namespace=wsdl:http://schemas.xmlsoap.org/wsdl/ \
    --expect='exchange information'
```

Output:

```text
Everything is ok, "exchange information" found in result "Provide real-time currency foreign exchange information and calculations.".
```


## States

* OK if the XPath expression returns a result and the expected string (if given) is found.
* WARN if the XPath expression returns an empty result.
* WARN if the expected string is not found in the XPath result.
* UNKNOWN on XML parsing errors, wrong namespace syntax, XPath errors, or text search within non-text tags.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich/Switzerland](https://www.linuxfabrik.ch); originally written by Simon Wunderlin and adapted by Dominik Riva, Universitaetsspital Basel/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
