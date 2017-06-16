#!/bin/bash

# Python 3.5
sudo yum -y install python35{,-{devel,pip}} htop

# LogiX
mkdir -p /home/hadoop/wheels/
aws s3 cp s3://done-vyasa/conf/logix-0.1.0-py3-none-any.whl \
    /home/hadoop/wheels/
aws s3 cp s3://done-vyasa/conf/python-site-packages.tar.gz \
    /home/hadoop/wheels/

tar -xzf /home/hadoop/wheels/python-site-packages.tar.gz
pip-3.5 install --user /home/hadoop/wheels/logix-0.1.0-py3-none-any.whl

# access
aws s3 cp --recursive s3://done-vyasa/conf/keys/ /home/hadoop/.ssh/
cat /home/hadoop/.ssh/*.pub >> /home/hadoop/.ssh/authorized_keys
