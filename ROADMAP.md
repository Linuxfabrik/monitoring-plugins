# Roadmap

## When Linuxfabrik drops support for an operating system.

An operating system reaching its end of life produces two different dates. One is when that release loses its packages. The other is when the project may raise the minimum Python version every plugin has to run on. They are rarely the same day.

We build packages for an **OS release** until six months after its vendor stops shipping updates free of charge: Maintenance Support for RHEL, LTS for Debian, Standard Support for Ubuntu, General Support for SLE. Paid extensions (RHEL ELS, Ubuntu Pro / ESM, SUSE LTSS) do not count. The six months give administrators one more maintenance window after the vendor date.

**The minimum Python version** is the oldest system Python among the releases still supported. Several releases usually share one interpreter, and that interpreter may only be dropped once the last of them is gone. The longest-lived carrier sets the date. Until then the plugin code stays compatible with it.

An example as of 2026-08: Python 3.9 is the oldest system Python used in production. RHEL 9 ships it and is supported by Red Hat until 2032-05-31, longer than any other release carrying 3.9, so the project requires Python 3.9 until 2032-11-30 (RHEL 8 and SLE 15 are the exceptions to "system Python": both default to Python 3.6, but their packages are built against the `python39` and `python311` modules, which is what places them in those groups).

* 2027-02-28: Debian 11 (py39)
* 2027-10-01: Ubuntu 22.04 (py310)
* 2028-05-31: SLE 16 (py313)
* 2028-12-31: Debian 12 (py311)
* 2029-11-30: RHEL 8 (py39)
* 2029-11-30: Ubuntu 24.04 (py312)
* 2030-12-31: Debian 13 (py313)
* 2031-10-31: Ubuntu 26.04 (py314)
* 2032-01-31: SLE 15 (py311)
* 2032-11-30: RHEL 9 (py39)
* **2032-11-30: raise the project minimum from py39 to py312**
* 2035-11-30: RHEL 10 (py312)

How to read the list: Each date is the day we drop building the packages for that release, six months after its vendor date. The interpreter in parentheses is the one that release carries.

The MP project may only raise its own minimum python version once the last release carrying the current interpreter is gone. Those points are called out in the list as their own entry, and they are the moments at which `lockfiles/py3xx/`, the matching CI entries and any compatibility shims for the abandoned interpreter can be removed.

Sources:

* RHEL: https://endoflife.date/rhel
* Debian: https://endoflife.date/debian
* Ubuntu: https://endoflife.date/ubuntu
* SLES: https://endoflife.date/sles
