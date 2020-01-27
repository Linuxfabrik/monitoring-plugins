This checks needs a MySQL driver to access a MySQL/MariaDB database. We recommend that you use PIP to install "MySQL Connector". 

`python -m pip install mysql-connector` or just `pip install mysql-connector`.


If you just want to check if MySQL/MariaDB is listening on its port, use the `network-port-tcp` check. Otherwise use a read-only database user, locked down to address of the monitoring server, and only with SELECT permissions on the databases you want to connect to and monitor.


Currently
from mysqltuner:
* only performance options ported
* validation / comparison is needed

from check_mysql / mysqltuner:
* connections via sockets are not supported
* only login with username / password (not via SSL/TLS)
* no option file support
* currently no slave check via "show slave status"

Inspired by
* check_mysql from monitoring-plugins.org.
* MySQLTuner (https://github.com/major/MySQLTuner-perl)