Check graylog-status
====================

Overview
--------

This check gets Graylog status information of all nodes in the cluster.

We recommend to run this check every 5 minutes.


Installation and Usage
----------------------

.. code-block:: bash



States
------

Alerts if

* 


Perfdata
--------

* 


Hints and Recommendations
-------------------------

For security reasons, using a username and password based authentication is undesirable. To prevent having to use the clear text credentials, Graylog allows to create access tokens which can be used for authentication instead.

So you should create a "graylog-monitoring" user with a strong password and an access token called "icinga" for this user. Use this access token for authentication.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
