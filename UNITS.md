# Human Readable Numbers

How Linuxfabrik plugins convert values to human-readable strings in the
check output and, where applicable, in perfdata labels.

Byte sizes use IEC binary prefixes (KiB, MiB, GiB, …), because the
alternative K/M/G is ambiguous between 1024 and 1000. The `K` and `M`
symbols are reused across contexts (Thousand vs Kilobyte vs Minute, Million
vs Month), so the *Type* column is always the disambiguator when reading
plugin output.

Months and years in the time scale are calendar approximations (30 days and
365 days). Plugin code uses these as display heuristics, not for date
math.

| Value             | Symbol   | Origin       | Type              | Description |
| ----------------- | -------- | ------------ | ----------------- | --------------------------------- |
| 1000\^1           | K        | common usage | Number            | Thousand |
| 1000\^2           | M        | SI Symbol    | Number            | Million (short scale) |
| 1000\^3           | G        | SI Symbol    | Number            | Billion (short scale) |
| 1000\^4           | T        | SI Symbol    | Number            | Trillion (short scale) |
| 1000\^5           | P        | SI Symbol    | Number            | Quadrillion (short scale) |
| 1000\^6           | E        | SI Symbol    | Number            | Quintillion (short scale) |
| 1000\^7           | Z        | SI Symbol    | Number            | Sextillion (short scale) |
| 1000\^8           | Y        | SI Symbol    | Number            | Septillion (short scale) |
| 1024\^0           | B        |              | Bytes             | Bytes |
| 1024\^1           | KiB      | IEC unit     | Bytes             | Kibibytes |
| 1024\^2           | MiB      | IEC unit     | Bytes             | Mebibytes |
| 1024\^3           | GiB      | IEC unit     | Bytes             | Gibibytes |
| 1024\^4           | TiB      | IEC unit     | Bytes             | Tebibytes |
| 1024\^5           | PiB      | IEC unit     | Bytes             | Pebibytes |
| 1024\^6           | EiB      | IEC unit     | Bytes             | Exbibytes |
| 1024\^7           | ZiB      | IEC unit     | Bytes             | Zebibytes |
| 1024\^8           | YiB      | IEC unit     | Bytes             | Yobibytes |
| 1000\^1           | KB       |              | Bytes             | Kilobytes |
| 1000\^2           | MB       |              | Bytes             | Megabytes |
| 1000\^3           | GB       |              | Bytes             | Gigabytes |
| 1000\^4           | TB       |              | Bytes             | Terabytes |
| 1000\^5           | PB       |              | Bytes             | Petabytes |
| 1000\^6           | EB       |              | Bytes             | Exabytes |
| 1000\^7           | ZB       |              | Bytes             | Zetabytes |
| 1000\^8           | YB       |              | Bytes             | Yottabytes |
| 1000\^1           | Kbps     |              | Bits per Second   | Kilobits |
| 1000\^2           | Mbps     |              | Bits per Second   | Megabits |
| 1000\^3           | Gbps     |              | Bits per Second   | Gigabits |
| 1000\^4           | Tbps     |              | Bits per Second   | Terabits |
| 1000\^5           | Pbps     |              | Bits per Second   | Petabits |
| 1000\^6           | Ebps     |              | Bits per Second   | Exabits |
| 1000\^7           | Zbps     |              | Bits per Second   | Zetabits |
| 1000\^8           | Ybps     |              | Bits per Second   | Yottabits |
| 1e-12             | ps       |              | Time              | Picoseconds |
| 1e-9              | ns       |              | Time              | Nanoseconds |
| 1e-6              | us       |              | Time              | Microseconds |
| 1e-3              | ms       |              | Time              | Milliseconds |
| 1..59             | s        |              | Time              | Seconds |
| 60                | m        |              | Time              | Minutes |
| 60\*60            | h        |              | Time              | Hours |
| 60\*60\*24        | D        |              | Time              | Days |
| 60\*60\*24\*7     | W        |              | Time              | Weeks |
| 60\*60\*24\*30    | M        |              | Time              | Months (approximate, 30 days) |
| 60\*60\*24\*365   | Y        |              | Time              | Years (approximate, 365 days) |
