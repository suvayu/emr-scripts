#!/bin/bash

# Python 3.5
sudo yum -y install python35{,-{devel,pip}} htop

# deps
declare DEPSDIR=/home/hadoop/deps
mkdir -p $DEPSDIR
aws s3 sync s3://done-vyasa/deps/ $DEPSDIR/ --exclude="*" \
    --include="*.whl" --include="*.jar"

sudo python3.5 -m pip install -U pip
sudo python3.5 -m pip install $DEPSDIR/logix-0.1.1.dev4-py3-none-any.whl

function install_deps(){
    while [[ ! -f /etc/yum.repos.d/Bigtop.repo ]]; do
        sleep 5;
    done
    sudo yum install -y hadoop-libhdfs
}

install_deps &

# access
declare SSHDIR=/home/hadoop/.ssh
aws s3 sync s3://done-vyasa/conf/keys/ $SSHDIR/
aws s3 cp s3://done-vyasa/conf/ssh_config $SSHDIR/config

chmod 444 $SSHDIR/config
cat $SSHDIR/*.pub >> $SSHDIR/authorized_keys

# instead use `ssh -A hadoop@cluster` to login
# # distribute private key across the cluster
# chmod 400 $SSHDIR/emr-id-rsa

# scripts
declare BIN=/home/hadoop/bin
mkdir $BIN
aws s3 sync s3://done-vyasa/conf/scripts/ $BIN
aws s3 sync s3://done-vyasa/job-scripts/ $BIN
chmod +x $BIN/*

echo >> /home/hadoop/.bashrc
cat $BIN/bashrc >> /home/hadoop/.bashrc
rm -f $BIN/bashrc

## fails, because when bootstrap runs, the cluster is not setup yet!
# # HDFS directories
# hdfs dfs -mkdir /data/
