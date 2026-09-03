# endoflife.date Fixtures

Every `*-version` plugin runs the same `lib.version.check_eol()`, so the
endoflife.date answer shapes are covered once here rather than in thirty
places. The files are real `https://endoflife.date/api/mysql.json` entries
from `lib/endoflifedate.py`; where a constellation does not occur in the
MySQL data, the field carrying it is taken verbatim from the product that
does have it, and only the dates a case hangs on are pinned to 1999 / 2099 /
2100 so no assertion ages.

Field shapes counted across all 470 products of the API (8444 cycles):
`eol` is a date 7316x, `false` 653x, `true` 475x; `support` a date 2305x,
`false` 417x, `true` 189x, absent 5533x; `extendedSupport` a date 476x,
`false` 537x, `true` 95x; `latest` absent 2163x; `cycle` without a single
digit 166x. The published `product-schema.json` documents `eol` as "date or
`false`" and does not mention `true`, which the data nonetheless carries.

| Fixture | Origin |
|----|----|
| `eol-date-in-the-future.json` | mysql 8.0, eol/support pinned to 2099/2100 so the calendar cannot flip the case |
| `eol-date-in-the-past.json` | mysql 8.0, eol/support pinned to 1999/2000 |
| `eol-true.json` | android 4.3 (eol: true, 475 cycles carry this) |
| `eol-false.json` | adonisjs 7 (eol: false, 653 cycles carry this) |
| `support-true.json` | amazon-cdk 2 (support: true, 189 cycles) |
| `support-false.json` | apache-groovy 2.5 (support: false, 417 cycles) |
| `support-ended-eol-ahead.json` | mysql 8.0, support pinned to 1999 and eol to 2100 |
| `support-absent.json` | adonisjs 5 shape (no support key at all, the majority of cycles) |
| `extended-support-date.json` | amazon-aurora-mysql 3 (extendedSupport: date, 476 cycles), dates pinned |
| `extended-support-true.json` | amazon-aurora-mysql 8.4 (extendedSupport: true, 95 cycles) |
| `extended-support-false.json` | amazon-aurora-mysql 1 (extendedSupport: false, 537 cycles) |
| `latest-absent.json` | alibaba-ack 1.34 shape (no latest key, 2163 cycles in 74 products) |
| `link-null.json` | akeneo-pim 1.2 (link: null, 425 cycles) |
| `lts-date.json` | bootstrap 5 (lts: a date rather than a bool, 108 cycles) |
| `cycle-without-digits.json` | aws-lambda "provided" (cycle with no digit at all, 166 cycles in the API) |
| `version-newer-than-every-cycle.json` | mysql 5.7 and 5.6 only, so an installed 8.0.45 is above everything listed |
| `version-older-than-every-cycle.json` | mysql 9.7 and 9.6 only, so an installed 8.0.45 is below everything listed |
| `version-between-listed-cycles.json` | mysql 8.4 and 5.7, the 8.0 cycle in between is missing |
