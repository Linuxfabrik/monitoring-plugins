# Overview
Checks network IO for all interfaces. We only consider inferfaces that have a MAC-Address, therefore we ignore `lo`.

Hints and Recommendations:
* `--count=5` (the default) while checking every minute means that the check reports a warning if the `tx_rate` or `rx_rate` was above a threshold in the last 5 minutes.
* If there is an increase in either drops or errors, the check returns a warning for the time duration specified with `--timespan=15` (default: 15min)

todo...

