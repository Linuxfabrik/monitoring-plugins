#!/usr/bin/env bash
#
python3 -m venv --system-site-packages pyinstaller
source pyinstaller/bin/activate

pip install --upgrade pip

pip install --upgrade wheel
pip install --upgrade setuptools
pip install pyinstaller

# install any libraries specific for the project:
pip install argparse
pip install beautifulsoup4
pip install certifi
pip install cffi
pip install colorama
pip install counter
pip install datetime
pip install jinja2
pip install lxml
pip install netifaces
pip install path
pip install psutil
pip install pymysql
pip install pysmbclient
pip install pyspnego
pip install python-keystoneclient
pip install python-swiftclient
pip install smbprotocol
pip install uuid
pip install vici
pip install xmltodict
