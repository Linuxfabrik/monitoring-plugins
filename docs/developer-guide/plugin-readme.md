# README Structure

Each plugin README follows a fixed structure. Use [check-plugins/example/README.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/example/README.md) as the reference template for the structure, and [check-plugins/php-fpm-status/README.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/php-fpm-status/README.md) as the reference for the level of detail and especially for troubleshooting depth that a Linux system engineer expects. The sections are:

1. **Overview**: *what* the plugin does, starting with its main purpose and including at least the `DESCRIPTION` text. Subsections:

    * **Important Notes** (optional, first if present): operational edge cases the admin must know before deploying ("Requires sudo", "Only works with Redis 3.0+", "First run returns OK with 'Waiting for more data.'", counters reset after a reboot). No implementation details.
    * **Data Collection**: how data is gathered (shell command, API, psutil, ...), filtering options, SQLite usage, non-blocking measurement.

2. **Fact Sheet**: only applicable rows from this closed list, in this order; other facts go into the Overview. Separator `|----|----|`.

    | Fact | Value |
    |----|----|
    | Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/example>. Notification / event plugins: `Notification Plugin Download` / `Event Plugin Download`. |
    | Nagios/Icinga Check Name              | `check_example` (SEO for the Nagios-style name). Underscores, never dashes. |
    | Check Interval Recommendation         | Every minute, Every 5/15/30 minutes, Every hour, Every 4/8/12 hours, Every day, Every week |
    | Can be called without parameters      | Yes/No |
    | Runs on                               | Cross-platform (default) / Linux (only for Linux-specific APIs: `/proc`, `systemd`, `dmesg`, `dnf`/`apt`/`yum`, `journalctl`, ...) / Windows. A missing `.windows` file does not mean Linux-only. |
    | Compiled for Windows                  | Yes (when `.windows` file exists) / No (runs with Python interpreter). A bare "No" for Linux-only, notification and event plugins. |
    | Requirements                          | command-line tool `foo`; User with higher permissions |
    | 3rd Party Python modules              | `module-name` |
    | Handles Periods                       | Yes (alerts only after `--count` consecutive threshold violations) |
    | Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-<plugin-name>.db`. Everything kept between runs, SQLite included; no second label. `in_memory=True` databases get no row. |

3. **Help**: the full `--help` output in a code block, regenerated via `tools/update-readmes`.
4. **Usage Examples**: realistic invocations with output, at least one OK case, and both variants if `--lengthy` exists.
5. **States**: precisely *when* which state is returned (e.g. "WARN if the percentage value is >= `--warning`"), including `--always-ok`, consecutive-run requirements and first-run/reboot edge cases.
6. **Perfdata / Metrics**: table with Name, Type, Description; types `Bytes`, `Number`, `Percentage`, `Seconds`. Use the vendor's official metric descriptions where possible.
7. **Troubleshooting** (optional): one `### <short heading>` subsection per problem, ordered from most common to most obscure.

    * Heading: a short, complete error string in backticks; for long errors or placeholders (`host:port`, `<pattern>`, `/path/to/file`) a short descriptive heading with the literal string in backticks on its own line below. Never both.
    * Then the fix in flowing prose. Lead with the cause only when it is known and specific; never pad with a filler cause or invent one.
    * No **Cause:** / **Solution:** labels.
    * Alert-state problems without an error string (a threshold crossed, a first-run baseline) get a descriptive heading and a short numbered runbook.

    Reference implementations: [`lynis`](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/lynis/README.md) for the error → cause-then-solution shape, and [`php-fpm-status`](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/php-fpm-status/README.md) for alert-state runbooks.

8. **Credits, License**: always present.
