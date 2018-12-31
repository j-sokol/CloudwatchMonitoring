#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

printf "\nCurrent directory $CURRENT_DIR \n"

VIRTUALENV_PATH=${1:-/tmp/lambda_env}
DESTINATION_PATH=${2:-$CURRENT_DIR/deployment}
REQUIREMENTS_PATH=${3-$CURRENT_DIR/requirements.txt}


printf "\nCleaning up $VIRTUALENV_PATH \n"
rm -rf $VIRTUALENV_PATH
mkdir -p $VIRTUALENV_PATH


printf "\nCleaning up $DESTINATION_PATH \n"
rm -rf $DESTINATION_PATH
mkdir -p $DESTINATION_PATH

printf "\nCreating virtualenv in $VIRTUALENV_PATH \n"

python3.6 -m venv $VIRTUALENV_PATH
cd $VIRTUALENV_PATH && source bin/activate
pip3 install -r $REQUIREMENTS_PATH

printf "\nCopying python source code from $CURRENT_DIR to $DESTINATION_PATH \n"
cp -p $CURRENT_DIR/* $DESTINATION_PATH/


printf "\nCopying python dependecies to $DESTINATION_PATH \n"
for dir in lib/python3.6/site-packages/
do 
if [ -d $dir ] ; then
	cp -R -p $dir/* $DESTINATION_PATH/;
  fi
done

# We need to somehow set right permission on files inside the lambda package
chmod -R 777 $DESTINATION_PATH