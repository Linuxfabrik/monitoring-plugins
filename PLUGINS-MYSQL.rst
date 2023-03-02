Notes on all mysql Plugins
==========================

PyMySQL
-------

If you are running the mysql-\* plugins in the source variant on RHEL 7+, you can install the Python MySQL Connector with ``pip install pymysql``.


Authentication
--------------

Specifying a password on the command line should be considered insecure. To avoid giving the password on the command line, use an option file. For example, on Unix, you can list your credentials in the [client] section of the ``.my.cnf`` file in your home directory: 

.. code-block:: text

    [client]
    password = linuxfabrik

To keep the password safe, the file should not be accessible to anyone but yourself. To ensure this, set the file access mode to ``400`` or ``600``. For example: 

.. code-block:: bash

    chmod 0400 .my.cnf

To name from the command line a specific option file containing the password, use the ``--defaults-file=file_name`` option, where ``file_name`` is the full path name to the file. For example: 

.. code-block:: bash

    ./mysql-aria --defaults-file=/var/spool/icinga2/.my.cnf


Locations
---------

Recommendations where to store credentials:

1. ``$HOME/.my.cnf`` file, where ``$HOME`` is the home directory of the user running the plugins, for example ``/var/spool/icinga2/.my.cnf``
2. ``/etc/my.cnf.d/icinga.cnf``, where ``icinga.cnf`` is the name of your monitoring software

Not recommended:

* ``/etc/my.cnf.d/client.cnf``
* ``/etc/my.cnf``


Option File Examples
--------------------

The name of the group/section defaults to ``client`` and can be changed using the ``--defaults-group`` parameter of the mysql-\* monitoring plugins.

Minimal working example to connect to localhost:

.. code-block:: text

    [client]
    user = root
    password = linuxfabrik

Full fledged example with all supported options: 

.. code-block:: text

    [client]
    user = root
    password = linuxfabrik
    host = 127.0.0.1
    port = 3306

    # Database to use, None to not use a particular one.
    database = 

    # Use a unix socket rather than TCP/IP
    unix_socket = /var/lib/mysql/mysql.sock

    # When the client has multiple network interfaces, specify
    # the interface from which to connect to the host. Argument can be
    # a hostname or an IP address.
    bind_address = 

    # Charset to use.
    charset = 

    # The path name of the Certificate Authority (CA) certificate file in PEM format.
    # The file contains a list of trusted SSL Certificate Authorities. 
    ssl-ca = 
    # The path name of the directory that contains trusted SSL Certificate Authority (CA)
    # certificate files in PEM format.
    ssl-capath = 
    # The path name of the server SSL public key certificate file in PEM format. 
    ssl-cert = 
    # The path name of the server SSL private key file in PEM format. For better security,
    # use a certificate with an RSA key size of at least 2048 bits. 
    ssl-key = 
    # The list of permissible ciphers for connection encryption. If no cipher in the list is
    # supported, encrypted connections do not work. 
    ssl-cipher = 
