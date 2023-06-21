#!/usr/bin/env bash

python3 -m venv --system-site-packages pyinstaller
source pyinstaller/bin/activate

pip install --upgrade pip

pip install --upgrade wheel
pip install --upgrade setuptools
pip install pyinstaller

# install any libraries specific for the project
pip install --requirement ../../requirements.txt
