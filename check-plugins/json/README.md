# Check "json" - Overview
This check parses a json array from a file or url and simply returns the message, state and perfdata from the json.


# Installation and Usage

```bash
./json --url http://example.com/json.out
./json --filename /tmp/json.out
./json --help
```


# States

* Exits with the state from the json array.


# Perfdata

Returns the perfdata from the json array.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
