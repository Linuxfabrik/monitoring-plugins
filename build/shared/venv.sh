#!/usr/bin/env bash

python3.9 -m venv --system-site-packages pyinstaller
source pyinstaller/bin/activate

python3.9 -m pip install pip==24.3.1
python3.9 -m pip install wheel==0.45.1
python3.9 -m pip install setuptools==50.3.2
python3.9 -m pip install pyinstaller==6.11.1

# install any libraries specific for the project
python3.9 -m pip install --requirement=/repos/monitoring-plugins/requirements.txt
