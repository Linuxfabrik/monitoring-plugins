Check graylog-memory-usage
==========================

Overview
--------

This check 

We recommend to run this check every minute.


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
* License: The Unlicense, see LICENSE file.
