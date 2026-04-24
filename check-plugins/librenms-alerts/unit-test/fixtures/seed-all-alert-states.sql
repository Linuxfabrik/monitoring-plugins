-- Seeds six devices covering every LibreNMS AlertState value the plugin
-- has to reason about (see lib/librenms.py get_state() and
-- LibreNMS/Enum/AlertState.php):
--
--   0 = CLEAR / RECOVERED
--   1 = ACTIVE
--   2 = ACKNOWLEDGED
--   3 = WORSE
--   4 = BETTER
--   5 = CHANGED
--
-- ACTIVE, WORSE, BETTER and CHANGED are open/notifiable alerts and
-- must map to WARN/CRIT. ACKNOWLEDGED and CLEAR must map to OK.
-- The fixture is loaded on top of the current LibreNMS schema, so
-- it only covers the rows and columns the plugin actually reads.

-- Start from a clean slate so the fixture is idempotent. LibreNMS
-- may have created a default localhost device and alert_rule on
-- first run; we do not want them to interfere with the fixture.
DELETE FROM alerts;
DELETE FROM alert_rules;
DELETE FROM devices;

INSERT INTO devices
    (hostname, sysName, os, type, uptime, hardware,
     status, status_reason, disable_notify)
VALUES
    ('dev-active',    'dev-active',    'linux', 'server', 3600, 'Box A', 1, '', 0),
    ('dev-worse',     'dev-worse',     'linux', 'server', 3600, 'Box B', 1, '', 0),
    ('dev-better',    'dev-better',    'linux', 'server', 3600, 'Box C', 1, '', 0),
    ('dev-changed',   'dev-changed',   'linux', 'server', 3600, 'Box D', 1, '', 0),
    ('dev-acked',     'dev-acked',     'linux', 'server', 3600, 'Box E', 1, '', 0),
    ('dev-recovered', 'dev-recovered', 'linux', 'server', 3600, 'Box F', 1, '', 0);

INSERT INTO alert_rules
    (severity, extra, disabled, name, query, builder)
VALUES
    ('critical', '{}', 0, 'High load', '', '');

-- Join by hostname so the fixture does not depend on auto-increment values.
INSERT INTO alerts (device_id, rule_id, state, alerted, open, info)
SELECT d.device_id, r.id, x.state, x.alerted, x.open, ''
FROM (
    SELECT 'dev-active'    AS hostname, 1 AS state, 1 AS alerted, 1 AS open UNION ALL
    SELECT 'dev-worse',     3, 1, 1 UNION ALL
    SELECT 'dev-better',    4, 1, 1 UNION ALL
    SELECT 'dev-changed',   5, 1, 1 UNION ALL
    SELECT 'dev-acked',     2, 1, 0 UNION ALL
    SELECT 'dev-recovered', 0, 0, 0
) AS x
JOIN devices AS d ON d.hostname = x.hostname
JOIN alert_rules AS r ON r.name = 'High load';
