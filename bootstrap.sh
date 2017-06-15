#!/bin/bash

# Python 3.5
sudo yum install python35{,-pip}

# LogiX
mkdir -p /home/hadoop/wheels/
aws s3 cp s3://done-vyasa/conf/logix-0.1.0-py3-none-any.whl \
    /home/hadoop/wheels/

pip-3.5 install --user /home/hadoop/wheels/logix-0.1.0-py3-none-any.whl

# access
aws s3 cp --recursive s3://done-vyasa/conf/keys/ /home/hadoop/.ssh/
cat /home/hadoop/.ssh/*.pub >> /home/hadoop/.ssh/authorized_keys
