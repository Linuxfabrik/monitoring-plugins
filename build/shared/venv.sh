#!/usr/bin/env bash

python3 -m venv --system-site-packages pyinstaller
source pyinstaller/bin/activate

python3 -m pip install --upgrade pip
python3 -m pip install --upgrade wheel
python3 -m pip install --upgrade setuptools
python3 -m pip install pyinstaller

# install any libraries specific for the project
python3 -m pip install --requirement=/repos/monitoring-plugins/requirements.txt
