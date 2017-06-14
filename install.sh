#! /bin/bash -f
#
# This should run on only one machine (the first listed in the containment.sh
# parameters).  It installs the epel rpm, then installs the required python
# packages from that rpm, then installs ansible and ceph-ansible.
#
source /tmp/parameters
wget ${download_node} 2>&1 | tee /tmp/downloads
z=`grep Saving /tmp/downloads | sed 's/.*: .//' | sed 's/.$//'`
latestversion=`python /tmp/parsePackages.py ${z} ceph-ansible`
lastansible=`python /tmp/parsePackages.py ${z} ansible`
sudo yum install -y /tmp/${epel_release} 
sudo yum install -y PyYAML python-httplib2 python-jinja2 python-keyczar python-paramiko python-passlib sshpass
sudo rpm -ivh ${download_node}${lastansible}
sudo yum install ansible -y
sudo rpm -ivh ${download_node}${latestversion}
sudo yum install ceph-ansible -y
sudo rpm -qa | grep ansible 
