
# Table of Contents

1.  [Introduction](#org1a0222c)
2.  [Setup](#orgc70c52b)


<a id="org1a0222c"></a>

# Introduction

This repository is a collection of shell scripts and configuration
files used to manage AWS EMR clusters (tested on small clusters).


<a id="orgc70c52b"></a>

# Setup

-   `common/` has utilities, and common variables used in the scripts.

-   AWS account specific variables are defined in `common/conf`, however
    it is not included in the source tree due to security reasons.  A
    template `common/conf` is shown below:
    
        # Amazon EC2 options
        declare SUBNET="SubnetId=<my-subnet>"
        declare KEYS="KeyName=<mykey>"
        
        # Amazon S3 config
        declare BUCKET=<my-bucket>
        declare LOG_BUCKET=<my-log-bucket>/elasticmapreduce

-   Other configuration files are available under `etc/`.
    -   Cluster configuration is in `etc/cluster-conf.json`
    -   Instance configurations are in `etc/instance-groups-*.json`

