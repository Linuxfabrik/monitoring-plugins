# Thresholds and Ranges

How Linuxfabrik plugins interpret `--warning` / `--critical` ranges.

The format follows the [Nagios Plugin Development
Guidelines](https://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT):

* Simple value `N`: a range from 0 to `N` inclusive. `N` must not be
  negative, which would put the start above the end. Write `-10:0` for a
  range below zero.
* `start:end`: start and end point inclusive on a numeric scale, with
  possibly negative or positive infinity.
* Empty value after `:`: positive infinity.
* `~`: negative infinity.
* `@`: inverts the whole expression. A range prefixed with `@` alerts
  when the value is *inside* the range (endpoints included).

A range the plugin cannot read, `1,5` or a bare `-10`, is reported and the
check goes UNKNOWN. It is never guessed into a threshold that alerts on
everything.

Examples:

| -w, -c    | OK if result is     | WARN/CRIT if        |
| --------- | ------------------- | ------------------- |
| 10        | in (0..10)          | not in (0..10)      |
| -10:0     | in (-10..0)         | not in (-10..0)     |
| 10:       | in (10..inf)        | not in (10..inf)    |
| :         | in (0..inf)         | not in (0..inf)     |
| ~:10      | in (-inf..10)       | not in (-inf..10)   |
| 10:20     | in (10..20)         | not in (10..20)     |
| @10:20    | not in (10..20)     | in (10..20)         |
| @~:20     | not in (-inf..20)   | in (-inf..20)       |
| @         | not in (0..inf)     | in (0..inf)         |
