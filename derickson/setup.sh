#!/bin/sh

set -e

#
# set up repo
#
echo "[MongoDB]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64
gpgcheck=0
enabled=1" | tee -a /etc/yum.repos.d/mongodb.repo

#wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
curl -o apache-maven-3.1.0.tar.gz http://mirror.metrocast.net/apache/maven/maven-3/3.1.0/binaries/apache-maven-3.1.0-bin.tar.gz
tar xvf apache-maven-3.1.0.tar.gz

mkdir /home/ec2-user/bin
cd /home/ec2-user/bin
ln -s /home/ec2-user/apache-maven-3.1.0/bin/mvn
ln -s /home/ec2-user/apache-maven-3.1.0/bin/mvnDebug
ln -s /home/ec2-user/apache-maven-3.1.0/bin/mvn-jpp
ln -s /home/ec2-user/apache-maven-3.1.0/bin/mvnyjp


#
# install stuff
#
yum -y update
yum -y install emacs
yum -y install mongo-10gen-server
yum -y install xorg-x11-xauth.x86_64 xorg-x11-server-utils.x86_64
yum -y install git
yum -y install java-devel


service iptables stop

#
# set up fs
#
mkdir /big
mkfs.ext4 /dev/xvdb
echo '/dev/xvdb /big ext4 defaults,auto,noatime,noexec 0 0' | tee -a /etc/fstab
mount /big
mkdir -p /big/data/journal /big/log
chown mongod:mongod /big /big/data /big/data/journal /big/log


#
# limits
#
# /etc/security/limits.conf
# * soft nofile 64000
# * hard nofile 64000
# * soft nproc 32000
# * hard nproc 32000
# /etc/security/limits.d/90-nproc.conf
# * soft nproc 32000
# * hard nproc 32000
#
cd ~/
cp /etc/security/limits.conf temp
sed '
/End of file/ i\
\* soft nofile 64000\
\* hard nofile 64000\
\* soft nproc 32000\
\* hard nproc 32000
'<temp >/etc/security/limits.conf
rm temp
cp /etc/security/limits.d/90-nproc.conf temp
sed '
s/\*          soft    nproc     1024/\* soft nproc 32000\
\* hard nproc 32000/'<temp >/etc/security/limits.d/90-nproc.conf
rm temp


#
# set readahead
#
blockdev --setra 32 /dev/xvdb
echo 'ACTION=="add", KERNEL=="xvdb", ATTR{bdi/read_ahead_kb}="16"' >>/etc/udev/rules.d/85-ebs.r
blockdev --getra /dev/xvdb


#
# config mongo
#
#sudo vi /etc/mongod.conf
#dbpath = /big/data
#logpath = /big/log/mongod.log
cd ~/
cp /etc/mongod.conf temp
cat temp | sed 's/\/var\/log\/mongo\/mongod\.log/\/big\/log\/mongod\.log/' | sed 's/dbpath=\/var\/lib\/mongo/dbpath = \/big\/data/' >/etc/mongod.conf
rm temp

#
# ready to go!
#
service mongod start
chkconfig mongod on

#
# mms install
#
cd ~/
yum install python-setuptools
wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py
wget https://mms.mongodb.com/settings/mmsAgent/44ae8d4693b7e97c3fd2912bef670c38/mms-monitoring-agent-Bootcamp-Sep13.tar.gz
python ez_setup.py
wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
python get-pip.py
pip install pymongo
wget https://mms.mongodb.com/settings/mmsAgent/44ae8d4693b7e97c3fd2912bef670c38/mms-monitoring-agent-Bootcamp-Sep13.tar.gz
tar -zxvf mms-monitoring-agent-Bootcamp-Sep13.tar.gz 
chown -R ec2-user:ec2-user mms-agent
nohup python mms-agent/agent.py >>mms-agent/agent.log  2>&1 &


yum -y install munin-node
/etc/init.d/munin-node start
chkconfig munin-node on
ln -s /usr/share/munin/plugins/iostat /etc/munin/plugins/iostat
ln -s /usr/share/munin/plugins/iostat_ios /etc/munin/plugins/iostat_ios

#sudo vi /etc/munin/munin-node.conf 
#allow ^.*$
cd ~/
cp /etc/munin/munin-node.conf temp
sed '/allow \^127/ i\
allow \^\.\*\$
'<temp >/etc/munin/munin-node.conf
rm temp


#sudo vi /etc/munin/plugin-conf.d/munin-node
#[iostat]
#env.SHOW_NUMBERED 1
echo "
[iostat]
env.SHOW_NUMBERED 1" | tee -a /etc/munin/plugin-conf.d/munin-node


sudo /etc/init.d/munin-node restart

#
# YCSB install
#
##cd ~/
##mkdir code
##cd code
##git clone https://github.com/brianfrankcooper/YCSB
##chown -R ec2-user:ec2-user YCSB
##cd YCSB
##mvn clean package


## TODO ------








