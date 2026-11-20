# Plugin Output

Print to STDOUT only, never to STDERR (Icinga/Nagios does not capture it). Structure:

```text
message | perfdata
detailed line 1
detailed line 2 | more_perfdata
```

The first line is used for notifications, the web interface and SMS; everything after the first newline is "long output" for detail views.

* A short, concise first line within 80 chars if possible (`msg_header`), details in further lines (`msg_body`).
* Perfdata follows a pipe (`|`), also on subsequent lines. Never use `|` in the text itself; `lib.base.oao()` replaces stray pipes.
* Don't print "OK".
* Print "\[WARNING\]" or "\[CRITICAL\]" next to a specific item using `lib.base.state2str()`.
* If possible give a help text to solve the problem.
* Multiple items checked: print "Everything is ok." or "There are warnings." / "There are errors." (or the most important output) in the first line, optionally followed by the items.
* Nothing checked because of the parameters: "Nothing checked.", or better name what the filters dropped ("2 version locks and 1 exclusion in place, filtered out by `--match` or `--ignore`."). Prefix "Everything is ok." only once nothing else affects the state. References: `rpm-versionlock`, `deb-versionlock`.
* Wrong username or password: print "Failed to authenticate."
* Short units without white space: bits `human.bits2human()`, bytes `human.bytes2human()`, throughput `human.bytes2human() + '/s'`, network "Rx/s" / "Tx/s" with `human.bps2human()`, numbers `human.number2human()`, percentage `93.2%`, "R/s", "W/s", "IO/s", durations `human.seconds2human()`, temperatures `7.3C`, `45F`.
* ISO dates ("yyyy-mm-dd", "yyyy-mm-dd hh:mm:ss") and human-readable periods ("Up 3d 4h", "1.5s").


## Verbose Output

With `-v` / `--verbose`, up to three stackable levels: 0 single-line summary, 1 (`-v`) single line with more detail, 2 (`-v -v`) multi-line debug info (commands, API endpoints), 3 (`-v -v -v`) extensive diagnostics. Most plugins use `--lengthy` instead.


## Verbosity parameter convention: `--lengthy` and `--brief`

The two knobs are **orthogonal**: `--lengthy` **adds** columns to every row, `--brief` **hides** rows within the thresholds (only WARN/CRIT remain), both together hide OK rows and widen the rest.

* **Perfdata is always complete**; both only reshape the message.
* **Alerting is unaffected**; hidden items still drive the state.
* **When `--brief` hides everything**, print only the summary header ("Everything is ok. (thresholds)"), not an empty table.
* **Always combinable**; never mutually exclusive in `argparse`.
* **Support `--brief`** whenever the default output can grow unbounded (hundreds of mounts, thousands of DHCP scopes, hundreds of HAProxy backends). References: `check-plugins/disk-usage`, `check-plugins/dhcp-scope-usage`.
* The `--brief` **help text** states the filter semantic and that perfdata and alerting are unaffected.


## Plugin Performance Data, Perfdata

Format, space-separated, UOM = Unit of Measurement: `'label'=value[UOM];[warn];[crit];[min];[max]`

* Labels may contain anything except `=` and `'`.
* **Prefer `snake_case` labels** (`active_processes`), per-instance as `<instance>_<metric>` (`sda_read_bytes`, `www_saturation`), as in `procs` and `disk-io`. This eases Grafana regex and InfluxDB tag matching and makes quotes unnecessary. Sanitize names with `re.sub(r'\W+', '_', name)`.
* Quotes around the label are required only if it contains spaces.
* The first 19 characters of a label should be unique (RRD limitation).
* `value`, `min` and `max` match `[-0-9.]` and share the same UOM; `min` / `max` are not required for `%`.
* `warn` and `crit` use the range format (see [Threshold and Ranges](parameters.md#threshold-and-ranges)).
* Trailing unfilled semicolons may be dropped.
* UOM: none (a number of things), `s` (also `us`, `ms`), `%`, `B` (also `KB`, `MB`, `TB`; bytes preferred, they are exact), `c` (continuous counter, do not use).

**Do not use continuous counters** (`c`). Compute the delta between two runs in the plugin, store the previous measurement with `lib.db_sqlite`, and emit an absolute value with a real unit ([#320](https://github.com/Linuxfabrik/monitoring-plugins/issues/320)). This spares Grafana `non_negative_difference()`, keeps aggregations and legend tables correct, and preserves the unit. The `example` plugin implements the pattern with `lib.db_sqlite.per_second_deltas()`.

Prefer percentages over absolute values, so systems of different size compare. Never emit already-aggregated values such as Apache's lifetime average "137.5 kB/request" (a flat line); calculate them in the plugin or discard them.
