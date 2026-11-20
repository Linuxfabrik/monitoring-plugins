# Parameters, Option Processing

Nagios-compatible reserved options, not to be used for other purposes: `-a, --authentication` (authentication password), `-C, --community` (SNMP community), `-c, --critical` (critical threshold), `-h, --help`, `-H, --hostname`, `-l, --logname` (login name), `-p, --password`, `-p, --port` (network port), `-t, --timeout`, `-u, --url`, `-u, --username`, `-V, --version`, `-v, --verbose`, `-w, --warning` (warning threshold).

Every plugin supports at least:

* `--help` (`-h`): short usage, then all options with their defaults, ending with a link to the online documentation. Within 80 characters width. Exits with `STATE_UNKNOWN` (3).
* `--version` (`-V`): plugin name and `__version__`. Exits with `STATE_UNKNOWN` (3).

The documentation link comes from `lib.args`:

```python
    parser = argparse.ArgumentParser(
        description=DESCRIPTION,
        epilog=lib.args.epilog(__file__),
        formatter_class=lib.args.HelpFormatter,
    )
```

`lib.args.epilog()` derives the URL from the file name, `lib.args.HelpFormatter` keeps it on one line. Notification and event plugins name their family, e.g. `lib.args.epilog(__file__, section='notification-plugins')`.

No positional arguments. All other options are long parameters only, words separated by `-`. Recommended names: `--activestate`, `--alarm-duration`, `--always-ok`, `--argument`, `--authtype`, `--brief`, `--cache-expire`, `--command`, `--community`, `--config`, `--count`, `--critical` (also `--critical-count`, `-cpu`, `-maxchildren`, `-mem`, `-pattern`, `-regex`, `-slowreq`, `-steal`), `--database`, `--datasource`, `--date`, `--device`, `--donor`, `--filename`, `--filter`, `--full`, `--hide-ok`, `--hostname`, `--icinga-callback` (also `--icinga-password`, `-service-name`, `-url`, `-username`), `--idsite`, `--ignore`, `--input`, `--insecure`, `--instance`, `--interface`, `--interval`, `--ipv6`, `--key`, `--latest`, `--lengthy`, `--loadstate`, `--match`, `--message`, `--message-key`, `--metric`, `--mib`, `--mibdir`, `--mode`, `--module`, `--mount`, `--no-kthreads`, `--no-match-severity`, `--no-perfdata`, `--no-proxy`, `--no-summary`, `--node`, `--only-dirs`, `--only-files`, `--password`, `--path`, `--pattern`, `--per-cpu`, `--perfdata`, `--perfdata-key`, `--period`, `--port`, `--portname`, `--prefix`, `--privlevel`, `--response`, `--service`, `--severity`, `--snmp-version`, `--starttype`, `--state`, `--state-key`, `--status`, `--substate`, `--suppress-lines`, `--task`, `--team`, `--test`, `--timeout`, `--timerange`, `--token`, `--trigger`, `--type`, `--unit`, `--unitfilestate`, `--url`, `--username`, `--version`, `--virtualenv`, `--warning` (with the same suffixes as `--critical`).

Usual [parameter types](https://docs.python.org/3/library/argparse.html): `type=float`, `type=int`, `type=lib.args.csv`, `type=lib.args.float_or_none`, `type=lib.args.int_or_none`, `type=str` (default), `choices=[...]`, and `action='store_true'` / `'store_false'` for switches.

**Threshold parameters** (`--warning`, `--critical`) in new plugins use `type=str` to support [Nagios range expressions](https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT) (`80`, `10:`, `~:50`, `@10:20`), evaluated with `lib.base.get_state(value, args.WARN, args.CRIT, _operator='range')`. See the `example` plugin and [Threshold and Ranges](#threshold-and-ranges).

Hints:

* `csv` type for complex tuples: `--input='Name, Value, Warn, Crit'` gives `['Name', 'Value', 'Warn', 'Crit']`.
* `append` action for repeating parameters (the `default` must be a list): `--input=a --input=b` gives `['a', 'b']`. Combined with `csv`, a two-dimensional list.
* For `append` defaults, leave `default=None` in `add_argument()` and fill in the default list after `parse_args()` if the value is still `None` (see <https://bugs.python.org/issue16399>).
* An `append` parameter with a non-empty default list gets an `--extend-<name>` companion that appends instead of replacing (see `example`).
* Stay backwards compatible: keep renamed or dropped parameters, silently ignored, with `help=argparse.SUPPRESS`, so hosts can be updated before the monitoring server.
* Tolerate unknown parameters with `parser.parse_known_args()`, so a new parameter in the service definition does not turn not-yet-updated hosts UNKNOWN.


## Parameter Help Text Format

Help texts are consistent across all plugins. Each property goes on its own line (implicit string concatenation), in this order:

1. Purpose (what the parameter does)
2. List semantics of an `append` parameter with a default list ("Replaces the default list, ..." / "..., appended to ...")
3. Data type or format (if not obvious)
4. Regex or case-sensitivity note (if applicable)
5. Repeating note (if applicable)
6. Nagios range support (if applicable)
7. Example (if helpful)
8. Default value (always last, always present if there is one)

Standard help texts live in `lib.args.HELP_TEXTS`; use `lib.args.help('--parameter-name')` wherever possible, write plugin-specific ones inline in the same format, or prefix the standard one:

```python
parser.add_argument(
    '--url',
    help='GitLab health URL endpoint. ' + lib.args.help('--url'),
    dest='URL',
    default=DEFAULT_URL,
)
```

* Use `%(default)s`, never a hardcoded value. For `append` defaults, join the `DEFAULT_X` constant. No default for `store_true` / `store_false` switches (`--always-ok`, `--insecure`, `--no-perfdata`, `--no-proxy`, `--lengthy`).
* "Replaces the default list, use `--extend-<name>` to append to it." / "..., appended to the default or the `--<name>` list."
* Defaults and examples go on their own lines.
* "Can be specified multiple times." for `action='append'` (not "(repeating)").
* "Supports Nagios ranges." when the value goes through `lib.base.get_state()`.
* Always state "Case-insensitive." or "Case-sensitive."
* "Uses Python regular expressions." when the parameter accepts a regex.
* End every help text with a period; a closing `Default: %(default)s` needs none, and neither does a closing code example (`` Example: `--warning=80` ``), where a copied period would end up in the value.
* Identical parameters across plugins get identical help texts.
* The developer-only `--test` is mapped to `argparse.SUPPRESS` in `lib.args` (accepted, but hidden from `--help`, READMEs and baskets). Declare it with `help=lib.args.help('--test')`, never inline.


## Threshold and Ranges

The range syntax (`start:end`, `~`, `@`, inclusive/exclusive) is documented in [THRESHOLDS.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/THRESHOLDS.md). In a plugin, keep `type=str` and evaluate with the library, never with a per-plugin range parser:

```python
item_state = lib.base.get_state(value, args.WARN, args.CRIT, _operator='range')
state = lib.base.get_worst(state, item_state)
```

References with multiple metrics and per-row worst-state aggregation: `check-plugins/procs/procs` and `example`. Example `--warning 2:100 --critical 1:150`:

```text
val   0   1   2 .. 100 101 .. 150 151
-w   WA  WA  OK     OK  WA     WA  WA
-c   CR  OK  OK     OK  OK     OK  CR
=>   CR  WA  OK     OK  WA     WA  CR
```

Single-bound ranges (`--warning 190: --critical 200:`) aggregate the same way.

Ranges cover every bound the operator picks (a percentage, count, age, temperature). A parameter naming a fixed classification boundary defined outside the plugin keeps a plain numeric type with a direct comparison, e.g. a CVSS base score, where range syntax would mean nothing. Reference: `--critical-cvss` in [wordpress-security-scan](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/wordpress-security-scan/README.md). Say so in the README, so the missing range support reads as a decision.
