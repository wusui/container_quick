#! /bin/bash -fv
latestversion='2.2.8-1'
sudo yum install -y /tmp/epel-release-latest-7.noarch.rpm 
sudo yum install -y PyYAML python-httplib2 python-jinja2 python-keyczar python-paramiko python-passlib sshpass
sudo rpm -ivh http://download-node-02.eng.bos.redhat.com/rcm-guest/ceph-drops/auto/rhscon-2-rhel-7-compose/latest-RHSCON-2-RHEL-7/compose/Installer/x86_64/os/Packages/ansible-2.2.3.0-1.el7.noarch.rpm
sudo yum install ansible -y
sudo rpm -ivh http://download-node-02.eng.bos.redhat.com/rcm-guest/ceph-drops/auto/rhscon-2-rhel-7-compose/latest-RHSCON-2-RHEL-7/compose/Installer/x86_64/os/Packages/ceph-ansible-${latestversion}.el7scon.noarch.rpm
sudo yum install ceph-ansible -y
sudo rpm -qa | grep ansible 
