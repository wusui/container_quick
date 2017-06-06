#! /bin/bash -fv
#
# This should run on only one machine (the first listed in the containment.sh
# parameters).  It installs the epel rpm, then installs the required python
# packages from that rpm, then installs ansible and ceph-ansible.
#
epel_release=${epel_release:-'epel-release-latest-7.noarch.rpm'}
download_node=${download_node:-'http://download-node-02.eng.bos.redhat.com/rcm-guest/ceph-drops/auto/rhscon-2-rhel-7-compose/latest-RHSCON-2-RHEL-7/compose/Installer/x86_64/os/Packages/'}
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
