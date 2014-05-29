# @@@ START COPYRIGHT @@@
#
# (C) Copyright 2007-2014 Hewlett-Packard Development Company, L.P.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
# @@@ END COPYRIGHT @@@
#

##############################################################
# Set / Calculate standard environmental values
# Note: Do NOT put local customizations here. See sqf/LocalSettingsTemplate.sh
##############################################################
# Adding build-time dependencies:
#  * Add environment variable in the last section of this file.
#  * Talk to the infra team about getting the tool/library/etc installed on build/test machines.
#  * Add an entry in sqf/LocalSettingsTemplate.sh to make path configurable.
##############################################################

# Trafodion version (also update file ../sql/common/copyright.h)
export TRAFODION_VER_MAJOR=0
export TRAFODION_VER_MINOR=7
export TRAFODION_VER_UPDATE=0
export TRAFODION_VER="${TRAFODION_VER_MAJOR}.${TRAFODION_VER_MINOR}.${TRAFODION_VER_UPDATE}"

##############################################################
# Trafodion authentication:
#    Set TRAFODION_ENABLE_AUTHENTICATION to YES to enable
# authentication in the Trafodion environment.
# LDAP configuration must also be setup--see 
# $MY_SQROOT/sql/scripts/traf_authentication_config for details.
##############################################################
export TRAFODION_ENABLE_AUTHENTICATION=NO


# default SQ_IC to TCP if it is not set in sqenv.sh. Values are
# IBV for infiniband, TCP for tcp
export SQ_IC=${SQ_IC:-TCP}
export MPI_IC_ORDER=$SQ_IC

# use sock
#export SQ_TRANS_SOCK=1

if [[ -z "$SQ_VERBOSE" ]]; then
  SQ_VERBOSE=0
fi
# temp variable for 64 bit cluster testing
# export SQ_WDT_KEEPALIVETIMERVALUE=900
#envvar to limit the number of memory arenas
export MALLOC_ARENA_MAX=1

# set this to 0 to use GNU compiler
export SQ_USE_INTC=0

if [ "$SQ_BUILD_TYPE" = "release" ]; then
  SQ_BTYPE=
else
  SQ_BTYPE=d
fi
export SQ_BTYPE
export SQ_MBTYPE=$SQ_MTYPE$SQ_BTYPE

# To enable code coverage, set this to 1
if [ -z "$SQ_COVERAGE" ]; then
  SQ_COVERAGE=0
elif [ $SQ_COVERAGE -eq 1 ]; then
  if [ "$SQ_VERBOSE" == "1" ]; then
    echo "*****************************"
    echo "*  Code coverage turned on  *"
    echo "*****************************"
    echo
  fi
fi
export SQ_COVERAGE

# Set default build parallelism
# Can be overridden on make commandline
cpucnt=`grep processor /proc/cpuinfo | wc -l`
#     no number means unlimited, and will swamp the system
export MAKEFLAGS="-j$cpucnt"

CLUSTNAME=`echo $CLUSTERNAME`
if [ -n "${CLUSTNAME}" ]; then
  export MY_ROOT=/opt/hp
  export TOOLSDIR=${TOOLSDIR:-/home/tools}
  export MY_UDR_ROOT=/home/udr
else
  export MY_ROOT=/opt/home
  export TOOLSDIR=${TOOLSDIR:-/opt/home/tools}
  export MY_UDR_ROOT=$PWD
fi

export MY_MPI_ROOT=$MY_ROOT

# JDK - Using 1.7, but also need 1.6 to create back-compatible jar
# Use JAVA_HOME if set, else look for installed openjdk, finally toolsdir
# Likewise for JAVAJDK16
if [[ -z "$JAVA_HOME" && -d /usr/lib/jvm/java-1.7.0-openjdk.x86_64/ ]]
then
  export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk.x86_64"
elif [[ -z "$JAVA_HOME" ]]
then
  export JAVA_HOME="${TOOLSDIR}/jdk1.7.0_09_64"
fi
if [[ -z "$JAVAJDK16" && -d /usr/lib/jvm/java-1.6.0-openjdk.x86_64 ]]
then
  export JAVAJDK16="/usr/lib/jvm/java-1.6.0-openjdk.x86_64"
elif [[ -z "$JAVAJDK16" ]]
then
  export JAVAJDK16="${TOOLSDIR}/jdk1.6.37_64"
fi


export SQ_PDSH=/usr/bin/pdsh
export SQ_PDCP=/usr/bin/pdcp
export TAR_DOWNLOAD_ROOT=$HOME/sqllogs
export CACERTS_DIR=$HOME/cacerts

# Get redhat major version
# Examples:
# Red Hat Enterprise Linux Server release 6.3 (Santiago)
# CentOS release 6.5 (Final)
export RH_MAJ_VERS=$(sed -r 's/^.* release ([0-9]+).[0-9]+ .*/\1/' /etc/redhat-release)

export MY_SQROOT=$PWD
export SQ_HOME=$PWD
export NVTHOME=$MY_SQROOT/transporter

# check for workstation env
# want to make sure SQ_VIRTUAL_NODES is set in the shell running sqstart
# so we can determine if we are on a workstation or not
if [[ -e ${MY_SQROOT}/etc/ms.env ]] ; then
   VIRT_NODES=`awk '/SQ_VIRTUAL_NODES=/ { fields=split($0,virt,"=");  if ( fields == 2 ) { virtnodes=virt[2];}} END {print  virtnodes}' < $MY_SQROOT/etc/ms.env`
   if [[ -n "$VIRT_NODES" ]] ; then
      export SQ_VIRTUAL_NODES="$VIRT_NODES"
   fi
fi

export MY_MPI_ROOT="$MY_SQROOT"
export MPI_ROOT="$MY_SQROOT/opt/hpmpi"


#set up the seapilot path before adding the seaquest path elements
if [[ -f seapilot/sp_path.sh ]]; then
  pushd seapilot >/dev/null
  source $MY_SQROOT/seapilot/sp_path.sh
  popd >/dev/null
fi

if [[ -f postulo/pos_env.sh ]]; then
  pushd postulo >/dev/null
  source $MY_SQROOT/postulo/pos_env.sh
  popd >/dev/null
fi

unset MPI_CC
export MPI_CXX=g++

export PATH=$MPI_ROOT/bin:$MY_SQROOT/export/bin"$SQ_MBTYPE":$MY_SQROOT/sql/scripts:$MY_SQROOT/tools:$MY_SQROOT/trafci/bin:$PATH
# The guiding principle is that the user's own software is preferred over anything else;
# system customizations are likewise preferred over default software.

  CC_LIB_RUNTIME=/usr/lib
  VARLIST=""


# need these to link

MPILIB=linux_amd64


#-------------------------------------------------------------------------------
# Setup for Hadoop integration
#
# The section below is meant to be customized for an installation, other
# parts of this file should not be dependent on a specific installation
#
# Set the following environment variables, based on the Hadoop distro:
#-------------------------------------------------------------------------------

# Native libraries and include directories (the latter needed only to build from source)

# DRIZZLE_LIB_DIR          directory of drizzle client lib libdrizzle.so
# DRIZZLE_INC_DIR          directory with header files for drizzle client lib
# HADOOP_LIB_DIR           directory of HDFS library libhdfs.so
# HADOOP_INC_DIR           directory with header files for libhdfs
# THRIFT_LIB_DIR           directory of Thrift library libthrift.so
# THRIFT_INC_DIR           directory with header files for thrift
# LOC_JVMLIBS              directory of the JNI C++ DLL libjvm.so

# Elements of the CLASSPATH for Trafodion

# HADOOP_JAR_DIRS          directories with Hadoop jar files to be included
# HADOOP_JAR_FILES         individual Hadoop entries for the class path
# HBASE_JAR_FILES          individual HBase entries for the class path
# HIVE_JAR_DIRS            directories with Hive jar files to be included
# HIVE_JAR_FILES           individual Hive entries for the class path

# Configuration directories

# HADOOP_CNF_DIR           directory with Hadoop configuration files
# HBASE_CNF_DIR            directory with HBase config file hbase-site.xml
# HIVE_CNF_DIR             directory with Hive config file hive-site.xml

# ---+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
if [ "$SQ_MTYPE" == 64 ]; then
  export LOC_JVMLIBS=$JAVA_HOME/jre/lib/amd64/server
else
  export LOC_JVMLIBS=$JAVA_HOME/jre/lib/i386/server
fi

# native library directories and include directories common to all platforms
export DRIZZLE_LIB_DIR=$TOOLSDIR/libdrizzle-5.1.4/libdrizzle/.libs
export DRIZZLE_INC_DIR=$TOOLSDIR/libdrizzle-5.1.4

ls /usr/lib/hadoop/hadoop-*cdh4*.jar >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # we are on a cluster with Cloudera installed
  # -------------------------------------------

  # native library directories and include directories
  export HADOOP_LIB_DIR=/usr/lib64
  export HADOOP_INC_DIR=/usr/include

  ### Thrift not supported on Cloudera yet (so use TOOLSDIR download)
  export THRIFT_LIB_DIR=$TOOLSDIR/thrift-0.9.0/lib
  export THRIFT_INC_DIR=$TOOLSDIR/thrift-0.9.0/include

  # directories with jar files and list of jar files
  # (could try to reduce the number of jars in the classpath)
  export HADOOP_JAR_DIRS="/usr/lib/hadoop
                          /usr/lib/hadoop/lib"
  export HADOOP_JAR_FILES="/usr/lib/hadoop/client/hadoop-hdfs-*.jar"
  export HBASE_JAR_FILES="/usr/lib/hbase/hbase-*-security.jar
                          /usr/lib/hbase/lib/zookeeper.jar
                          /usr/lib/hbase/lib/protobuf-*.jar"
  export HIVE_JAR_DIRS="/usr/lib/hive/lib"
  export HIVE_JAR_FILES="/usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-core.jar"

  # suffixes to suppress in the classpath (set this to ---none--- to add all files)
  export SUFFIXES_TO_SUPPRESS="-sources.jar -tests.jar"

  # Configuration directories

  export HADOOP_CNF_DIR=/etc/hadoop/conf
  export HBASE_CNF_DIR=/etc/hbase/conf
  export HIVE_CNF_DIR=/etc/hive/conf

elif [ -e /usr/lib/hadoop/*HDP* ]; then
  # we are on a cluster with Hortonworks installed
  # ----------------------------------------------

  # native library directories and include directories
  export HADOOP_LIB_DIR=/usr/lib/hadoop/lib/native/Linux-*-${SQ_MTYPE}
  export HADOOP_INC_DIR=/build-not-supported-on-Hortonworks-yet

  ### Thrift not supported on Hortonworks yet (so use TOOLSDIR download)
  export THRIFT_LIB_DIR=$TOOLSDIR/thrift-0.9.0/lib
  export THRIFT_INC_DIR=$TOOLSDIR/thrift-0.9.0/include

  # directories with jar files and list of jar files
  export HADOOP_JAR_DIRS="/usr/lib/hadoop
                          /usr/lib/hadoop/lib
                          $TOOLSDIR/hadoop-2.0.0-cdh4.2.0/share/hadoop/hdfs"
  export HADOOP_JAR_FILES=
  export HBASE_JAR_FILES="/usr/lib/hbase/hbase-*-security.jar
                          /usr/lib/hbase/lib/zookeeper.jar
                          /usr/lib/hbase/lib/protobuf-*.jar"
  export HIVE_JAR_DIRS="/usr/lib/hive/lib"

  # Configuration directories

  export HADOOP_CNF_DIR=/etc/hadoop/conf
  export HBASE_CNF_DIR=/etc/hbase/conf
  export HIVE_CNF_DIR=/etc/hive/conf

elif [ -d /opt/mapr ]; then
  # we are on a MapR system
  # ----------------------------------------------------------------
 
  # We tried this with MapR 3.1, which has hadoop-0.20.2, hbase-0.94.13, hive-0.12 
  if [ -r /opt/mapr/hadoop/hadoopversion ]; then
    MAPR_HADOOP_VERSION=`cat /opt/mapr/hadoop/hadoopversion`
    MAPR_HADOOPDIR=/opt/mapr/hadoop/hadoop-${MAPR_HADOOP_VERSION}
  else
    MAPR_HADOOPDIR=`echo /opt/mapr/hadoop/hadoop-*`
  fi
  if [ -r /opt/mapr/hbase/hbaseversion ]; then
    MAPR_HBASE_VERSION=`cat /opt/mapr/hbase/hbaseversion`
    MAPR_HBASEDIR=/opt/mapr/hbase/hbase-${MAPR_HBASE_VERSION}
  else
    MAPR_HBASEDIR=`echo /opt/mapr/hbase/hbase-*`
  fi
  if [ -r /opt/mapr/hive/hiveversion ]; then
    MAPR_HIVE_VERSION=`cat /opt/mapr/hive/hiveversion`
    MAPR_HIVEDIR=/opt/mapr/hive/hive-${MAPR_HIVE_VERSION}
  else
    MAPR_HIVEDIR=`echo /opt/mapr/hive/hive-*`
  fi

  ### Thrift not supported on MapR (so use TOOLSDIR download)
  export THRIFT_LIB_DIR=$TOOLSDIR/thrift-0.9.0/lib
  export THRIFT_INC_DIR=$TOOLSDIR/thrift-0.9.0/include

  # native library directories and include directories
  export HADOOP_LIB_DIR=$MAPR_HADOOPDIR/lib/native/Linux-amd64-64
  export HADOOP_INC_DIR=/build-not-supported-on-MapR-yet
 
  # directories with jar files and list of jar files
  export HADOOP_JAR_DIRS="$MAPR_HADOOPDIR/lib
                          $TOOLSDIR/hadoop-2.0.0-cdh4.2.0/share/hadoop/hdfs"
  export HADOOP_JAR_FILES=
  export HBASE_JAR_FILES="$MAPR_HBASEDIR/hbase-*.jar
                          $MAPR_HBASEDIR/lib/zookeeper.jar
                          $MAPR_HBASEDIR/lib/protobuf-*.jar"
  
  # Configuration directories
  
  export HADOOP_CNF_DIR=$MAPR_HADOOPDIR/conf
  export HBASE_CNF_DIR=$MAPR_HBASEDIR/conf
  export HIVE_CNF_DIR=$MAPR_HIVEDIR/conf

  # HBase-trx jar with some modifications to work with MapR HBase 0.94.13
  export HBASE_TRX_JAR=hbase_mapr-trx-0.94.13.jar

elif [ -d $TOOLSDIR/hadoop-2.0.0-cdh4.2.0 ]; then
  # we are on a development system or cluster with a tools directory
  # ----------------------------------------------------------------

  # native library directories and include directories
  export HADOOP_LIB_DIR=$TOOLSDIR/hadoop-2.0.0-cdh4.2.0/lib/native
  export HADOOP_INC_DIR=$TOOLSDIR/hadoop-2.0.0-cdh4.2.0/include
  export THRIFT_LIB_DIR=$TOOLSDIR/thrift-0.9.0/lib
  export THRIFT_INC_DIR=$TOOLSDIR/thrift-0.9.0/include

  # directories with jar files and list of jar files
  export HADOOP_JAR_DIRS="$TOOLSDIR/hadoop-2.0.0-cdh4.2.0/share/hadoop/common
                          $TOOLSDIR/hadoop-2.0.0-cdh4.2.0/share/hadoop/common/lib
                          $TOOLSDIR/hadoop-2.0.0-cdh4.2.0/share/hadoop/hdfs"
  export HADOOP_JAR_FILES=
  export HBASE_JAR_FILES="$TOOLSDIR/hbase-0.94.6-cdh4.4.0/hbase-*-security.jar
                          $TOOLSDIR/hbase-0.94.6-cdh4.4.0/lib/zookeeper-*.jar"
  export HIVE_JAR_DIRS="$TOOLSDIR/hive-0.9.0-bin/lib"
  export HIVE_JAR_FILES="$TOOLSDIR/hadoop-2.0.0-cdh4.2.0/share/hadoop/mapreduce/hadoop-mapreduce-client-core-*.jar"

  # suffixes to suppress in the classpath (set this to ---none--- to add all files)
  export SUFFIXES_TO_SUPPRESS="-sources.jar -tests.jar"

  # Configuration directories

  export HADOOP_CNF_DIR=$MY_SQROOT/sql/local_hadoop/hadoop/etc/hadoop
  export HBASE_CNF_DIR=$MY_SQROOT/sql/local_hadoop/hbase/conf
  export HIVE_CNF_DIR=$MY_SQROOT/sql/local_hadoop/hive/conf

fi

# Common for local workstations, Cloudera, Hortonworks and MapR

export HBASE_TRXDIR=$MY_SQROOT/export/lib
# Some distros require a custom HBase-trx jar
export HBASE_TRX_JAR=${HBASE_TRX_JAR:-hbase-trx-0.94.6.jar}

export ZOOKEEPER_DIR=$TOOLSDIR/zookeeper-3.4.5
export MPICH_ROOT=$TOOLSDIR/dest-mpich-3.0.4

export PROTOBUFS=/usr

# ---+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# end of customization variables

# for debugging
export LD_BIND_NOW=true

export MPI_TMPDIR=$PWD/tmp
if [ -d $MPI_TMPDIR ]; then
  if [ "$SQ_VERBOSE" == "1" ]; then
    echo "Pre-existing directory found for MPI_TMPDIR: $MPI_TMPDIR"
    echo
  fi
else
  if [ "$SQ_VERBOSE" == "1" ]; then
    echo "Creating directory for MPI_TMPDIR: $MPI_TMPDIR"
    echo
  fi
  mkdir $MPI_TMPDIR
fi

# Add man pages
export MANPATH=$MANPATH:$MY_SQROOT/export/share/man

# Control lunmgr verbosity
export SQ_LUNMGR_VERBOSITY=1

# 32 bit workaround
#export OLDGETBUF=1
# Control SQ default startup behavior (c=cold, w=warm, if removed sqstart will autocheck)
export SQ_STARTUP=r

# Alternative logging capability in monitor
export SQ_MON_ALTLOG=1

# Monitor sync thread responsiveness timeout
# default 15 mins
export SQ_MON_SYNC_TIMEOUT=900


# Check the state of the node with the cluster manager during regroup
export SQ_WDT_CHECK_CLUSTER_STATE=0

# Perl libraries used by Seaquest (e.g. sqgen components)
export PERL5LIB=$MY_SQROOT/export/lib

# Define the location of the harness config files
export SP_HEALTH_HARNESS1ONECFG=$MY_SQROOT/seapilot/export/conf/vili/vili_1_one.cfg
export SP_HEALTH_HARNESS5ONECFG=$MY_SQROOT/seapilot/export/conf/vili/vili_5_one.cfg
export SP_HEALTH_HARNESSBLONECFG=$MY_SQROOT/seapilot/export/conf/vili/vili_baseline_one.cfg
export SP_HEALTH_HARNESS1ALLCFG=$MY_SQROOT/seapilot/export/conf/vili/vili_1_all.cfg
export SP_HEALTH_HARNESS5ALLCFG=$MY_SQROOT/seapilot/export/conf/vili/vili_5_all.cfg
export SP_HEALTH_HARNESSBLALLCFG=$MY_SQROOT/seapilot/export/conf/vili/vili_baseline_all.cfg

# Enable SQ_PIDMAP if you want to get a record of process activity.
# This can be useful in troubleshooting problems.  There is an overhead cost
# incurred each time a process is started so do not enable this if performance
# is critical.
# Log process start/end messages in $MY_SQROOT/tmp/monitor.map
export SQ_PIDMAP=1

#Enable RMS (SQL Run time statistics)
export SQ_START_RMS=1

# Enable QVP (Query Validation Process).
export SQ_START_QVP=1

# Set to 1 to enable QMM (Query Matching Monitor process for MVQR).
export SQ_START_QMM=0

# SSD provider scripts
export LMP_POLL_FREQ=60
export LSP_POLL_FREQ=60
export SMP_POLL_FREQ=60
export SSP_POLL_FREQ=60

# Compression provider scripts
export CSP_POLL_FREQ=60
export CMP_POLL_FREQ=10

# need this to use new phandle
export SQ_NEW_PHANDLE=1

unset SQ_SEAMONSTER

export ENABLE_EMBEDDED_ARKCMP=1

# make sure we get HUGE pages in cores
echo "0x73" > /proc/$$/coredump_filter

# Introducing seapilot environment variables
# this will be needed to build and run the
# seapilot environment.
if [[ -f seapilot/spenv.sh ]]; then
  pushd seapilot >/dev/null
  source $MY_SQROOT/seapilot/spenv.sh
  popd >/dev/null
fi

# After changing the values below, you must source in the appropriate
# sqXXenvY.sh and run sqgen
unset SQ_SONAR_SEAPILOT
export SQ_SONAR_SEAPILOT=0
unset SQ_START_PROBLEM_MANAGEMENT
export SQ_START_PROBLEM_MANAGEMENT=1

# The "unset SQ_EVLOG_NONE" command below does nothing when followed by the
# "export SQ_EVLOG_NONE" command. It comes into play when SeaPilot is
# enabled, in which case "export SQ_EVLOG_NONE" will be deleted from this
# script and "unset SQ_EVLOG_NONE" will remain, to clean up shells where
# "export SQ_EVLOG_NONE" was executed prior to enabling SeaPilot. The
# "unset SQ_SEAPILOT_SUSPENDED" command serves the same purpose for the
# reverse situation; that is, to clean up shells where
# "export SQ_SEAPILOT_SUSPENDED" was executed prior to disabling SeaPilot.
# The "unset SQ_EVLOG_TMP" and "unset SQ_EVLOG_STDERR" commands serve the
# same purpose as "unset SQ_EVLOG_NONE".
#
# Change the SQ_EVLOG_NONE export to SQ_EVLOG_STDERR to have events go to
# STDERR. Alternatively, change the SQ_EVLOG_NONE export to SQ_EVLOG_TMP
# to use the temporary EVLOG logging mechanism.
unset SQ_SEAPILOT_SUSPENDED
unset SQ_SEAPILOT_PERF_SUSPENDED
unset SQ_EVLOG_NONE
unset SQ_EVLOG_TMP
unset SQ_EVLOG_STDERR
export SQ_EVLOG_NONE=1
export SQ_SEAPILOT_SUSPENDED=0
export SQ_SEAPILOT_PERF_SUSPENDED=0


function ckillall {
  # echo "In the ckillall function"
  export SQ_PS1=$PS1
  $MY_SQROOT/sql/scripts/ckillall
  unset SQ_PS1
}
export -f ckillall

. tools/sqtools.sh

#######################
# BUILD Tools/Libraries
######################

# Standard tools expected to be installed and found in PATH
export ANT="/usr/bin/ant"
if [[ ! -e $ANT ]]
then
  ANT="${TOOLSDIR}/bin/ant"
fi
export AR=ar
export FLEX=flex
export CXX=g++

# Non-standard or newer version tools
export BISON="${TOOLSDIR}/bison_3_linux/bin/bison"     # Need 1.3 version or later
export LLVM="${TOOLSDIR}/dest-llvm-3.2"
export UDIS86="${TOOLSDIR}/udis86-1.7.2"
export ICU="${TOOLSDIR}/icu4.4"
export QT_TOOLKIT="${TOOLSDIR}/Qt-4.8.5-64"

#######################
# Developer Local over-rides  (see sqf/LocalSettingsTemplate.sh)
######################
if [[ -r ~/.trafodion ]]
then
  [[ $SQ_VERBOSE == 1 ]] && echo "Sourcing local settings file ~/.trafodion"
  source ~/.trafodion
fi
# PROTOBUFS may include local over-rides
export PROTOBUFS_LIB=$PROTOBUFS/lib
export PROTOBUFS_INC=$PROTOBUFS/include

######################
# Library Path may include local over-rides
export LD_LIBRARY_PATH=$CC_LIB:$MPI_ROOT/lib/$MPILIB:$MY_SQROOT/export/lib"$SQ_MBTYPE":$LOC_JVMLIBS:$HWMSLIBS:${SP_EXPORT_LIB}:.

######################
# Class Path calculation may include local over-rides

# check for previous invocation of this script
PREV_SQ_CLASSPATH=$SQ_CLASSPATH
SQ_CLASSPATH=

# set up SQ_CLASSPATH for use with Base clients and libhdfs
# From the HBase manual: Minimally, a client of HBase needs the hbase, hadoop,
# log4j, commons-logging, commons-lang, and ZooKeeper jars in its CLASSPATH connecting to a cluster
# Hortonworks seems to have a hadoop-client.jar

# expand jar files in list of directories
for d in $HADOOP_JAR_DIRS
  do
    HADOOP_JAR_FILES="$HADOOP_JAR_FILES $d/*.jar"
  done

for d in $HIVE_JAR_DIRS
  do
    HIVE_JAR_FILES="$HIVE_JAR_FILES $d/*.jar"
  done

# assemble all of them into a classpath
for j in $HBASE_JAR_FILES $HADOOP_JAR_FILES $HIVE_JAR_FILES
do
  if [ -f $j ]; then

    # eliminate jars with unwanted suffixes
    SUPPRESS_FILE=0
    for s in $SUFFIXES_TO_SUPPRESS
      do
        if [ ${j%${s}} != $j ]; then
          SUPPRESS_FILE=1
        fi
      done

    # finally, add the jar to the classpath
    if [ $SUPPRESS_FILE -eq 0 ]; then
      SQ_CLASSPATH=$SQ_CLASSPATH:$j
    fi
  fi
done

# remove the leading colon from the classpath
SQ_CLASSPATH=${SQ_CLASSPATH#:}

# add Hadoop and HBase config dirs to classpath
SQ_CLASSPATH=$SQ_CLASSPATH:$HADOOP_CNF_DIR:$HBASE_CNF_DIR:$HIVE_CNF_DIR
SQ_CLASSPATH=$SQ_CLASSPATH:${HBASE_TRXDIR}:${HBASE_TRXDIR}/${HBASE_TRX_JAR}:$MY_SQROOT/export/lib/trafodion-UDR-${TRAFODION_VER}.jar:$MY_SQROOT/export/lib/trafodion-HBaseAccess-${TRAFODION_VER}.jar:$MY_SQROOT/export/lib/jdbcT2.jar

# check whether we executed this script previously

# take anything from the existing classpath, but not the part that was
# added by previous invocations of this script (assuming it produced
# the same classpath).

# Note: this will produce unwanted classpath entries if you do the
# following: a) source in this file, b) prepend to the classpath and
# c) source this file in again
USER_CLASSPATH=${CLASSPATH#${SQ_CLASSPATH}}
USER_CLASSPATH=${USER_CLASSPATH#:}

# Check whether the environment changed from a previous execution of this
# script.
if [ -n "$PREV_SQ_CLASSPATH" -a \
     "$PREV_SQ_CLASSPATH" != "$SQ_CLASSPATH" ]; then
  cat <<EOF
The environment changed from a previous execution of this script.
This is not supported. To change environments, do the following:
  sqstop
  <make any changes, e.g. update Hadoop, HBase, MySQL>
  start a new shell and source in sqenv.sh
  rm \$MY_SQROOT/etc/ms.env
  sqgen
  start a new shell and source in sqenv.sh
  sqstart
EOF
fi

if [ -n "$USER_CLASSPATH" ]; then
  # new info, followed by the original classpath
  export CLASSPATH="${SQ_CLASSPATH}:${USER_CLASSPATH}"
else
  export CLASSPATH="${SQ_CLASSPATH}"
fi
export CLASSPATH="${CLASSPATH}:"

####################
# Check/Report on key variables
###################

# Check that existing JAVA_HOME is suitable
REQ_VER="javac 1.7."
if [[ -n "$JAVA_HOME" ]]; then
  THIS_JVM_VER="$($JAVA_HOME/bin/javac -version 2>&1 > /dev/null)"
  if [[ "${THIS_JVM_VER:0:10}" != "$REQ_VER" ]]; then
    echo "Warning: Your existing JAVA_HOME is not version 1.7."
    echo "  Your JAVA_HOME = $JAVA_HOME"
    echo "  Required java version = $REQ_VER"
  fi
fi

# Check variables that should refer to real directories
VARLIST="MY_SQROOT $VARLIST JAVA_HOME PERL5LIB MPI_TMPDIR"

if [[ "$SQ_VERBOSE" == "1" ]]; then
  echo "Checking variables reference existing directories ..."
fi
for AVAR in $VARLIST; do
  AVALUE="$(eval "echo \$$AVAR")"
  if [[ "$SQ_VERBOSE" == "1" ]]; then
    printf '%s =\t%s\n' $AVAR $AVALUE
  fi
  if [[ ! -d $AVALUE ]]; then
    echo
    echo "*** WARNING: $AVAR directory not found: $AVALUE"
    echo
  fi
done

if [[ "$SQ_VERBOSE" == "1" ]]; then
  printf "\nPATH="
  echo $PATH | sed -e's/:/ /g' | fmt -w2 | xargs printf '\t%s\n'
  echo
  printf "\nLD_LIBRARY_PATH="
  echo $LD_LIBRARY_PATH | sed -e's/:/ /g' | fmt -w2 | xargs printf '\t%s\n'
  echo
  printf "\nCLASSPATH=\n"
  echo $CLASSPATH | sed -e's/:/ /g' | fmt -w2 | xargs printf '\t%s\n'
  echo
fi