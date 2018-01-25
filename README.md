
# Table of Contents

1.  [Introduction](#org7220fc3)
2.  [Setup](#org4e3396b)
    1.  [The bootstrap script](#orgdfe0328)
3.  [Launching a cluster](#org0edc9f2)
4.  [Archiving Spark logs](#org510415a)
5.  [Spark history server](#org2bc5e9e)
    1.  [Standalone Spark setup locally](#org70a4156)
6.  [Broadcasting commands to all nodes](#org88ed71c)


<a id="org7220fc3"></a>

# Introduction

This repository is a collection of shell scripts and configuration
files used to manage AWS EMR clusters (tested on small clusters).


<a id="org4e3396b"></a>

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
    
    *Note*: You might need to replace a few `<my-bucket>` in the
    bootstrap script, and the conf files.

-   Other configuration files are available under `etc/`.
    -   Cluster configuration is in `etc/cluster-conf.json`
    -   Instance configurations are in `etc/instance-groups-*.json`
    -   `etc/bootstrap.sh` has placeholder names for S3 buckets which
        should be edited before using the launching script.

-   AWS credentials are expected to be in the usual place
    (`$HOME/.aws/`).


<a id="orgdfe0328"></a>

## The bootstrap script

-   **Dependencies**: It sets up the cluster by making the dependencies
    provided under `<my-bucket>/deps/`.  However in the case of Python
    dependencies, they need to be explicitly installed using `pip`
    during bootstrap.  `jar` dependencies are automatically added to the
    `classpath` in the cluster configuration.
-   **User management**: The bootstrap script also enables a simple SSH
    public key based user management scheme by copying the public keys
    from `<my-bucket>/conf/keys/`.
-   **Utilities**: Finally it copies a few useful scripts into the `PATH`.


<a id="org0edc9f2"></a>

# Launching a cluster

    $ ./launch-cluster --name <project-name> --cluster-type SPARK \
          --instance-groups etc/instance-groups-min.json \
          --conf etc/cluster-conf.json

After starting a cluster, you can get the cluster public dns like this:

    $ aws emr describe-cluster --cluster-id <cluster-id> | grep PublicDns

Then you can login to the cluster using your SSH keys.  If you use the
`-A` switch, that forwards your current set of keys to the cluster,
making it easier for you to use SSH to interact with other computers
outside the cluster.

The cluster can be terminated like this:

    $ aws emr terminate-clusters --cluster-ids <cluster-id>


<a id="org510415a"></a>

# Archiving Spark logs

On EMR, the Spark logs reside on HDFS, and are destroyed when the
cluster is terminated.  You can archive the logs of a currently
running cluster for future reference to S3 (under the log bucket)
using the script `archive-spark-logs`.  You may run this script either
from the workstation where you used `launch-cluster` to launch the
cluster, or from an interactive terminal on the cluster; the script
detects the location and does the "right thing".  If multiple clusters
are running, the script will prompt you to choose a cluster from a
menu.

The archived logs can be retrieved later using `emr-get-logs` by
providing the cluster id.


<a id="org2bc5e9e"></a>

# Spark history server

You can start a Spark history server using `history-server` by
pointing to the downloaded logs.  This requires a local standalone
installation of Spark.  You can point to the installation by setting
`$SPARK_HOME`.

    $ history-server start <log-dir>
    $ history-server stop


<a id="org70a4156"></a>

## Standalone Spark setup locally

Without going into too many details, you can setup spark like this:

    function __hadoop_init()
    {
        export HADOOP_VER=2.7.3
        export HADOOP_HOME=~/build/hadoop-${HADOOP_VER}
        export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH
        export PATH=$HADOOP_HOME/bin:$PATH
        export CLASSPATH=`$HADOOP_HOME/bin/hdfs classpath --glob`
    }
    
    function __spark_init()
    {
        PYSPARK_PYTHON=$1
        # __hbase_init
        __hadoop_init
        export SPARK_HOME=~/build/spark
        if [[ -z $PYSPARK_PYTHON || ! $PYSPARK_PYTHON =~ .*python.* ]]; then
    	PYSPARK_PYTHON=python3
        fi
        export PYSPARK_PYTHON
        # parenthesis necessary for filename glob expansion
        local py4j=(${SPARK_HOME}/python/lib/py4j*.zip)
        export PYTHONPATH="${SPARK_HOME}/python/lib/pyspark.zip:$PYTHONPATH"
        export PYTHONPATH="$py4j:$PYTHONPATH"
        export PATH=$SPARK_HOME/bin:$PATH
    }


<a id="org88ed71c"></a>

# Broadcasting commands to all nodes

If you have logged into the cluster with SSH with the `-A` flag
enabled, you can execute a command across all nodes of the cluster (or
IOW, broadcast a command) using the `broadcast` command.

    $ broadcast <mycmd> <with> <arguments>

