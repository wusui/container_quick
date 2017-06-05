# Container_quick -- a script to rapidly bring up a containerized ceph instance

Usage: ./containment.sh node1 node2 node3

This script will bring up 3 mons (1 on each node), 9 osds (3 on each node) and a container node (on node1). 
 
Prior to running this, make sure that there are no previous [mons] or [osds] sections in /etc/ansible/hosts on the container node.

Also, there should be a copy of the latest epel repo in the local directory (currently use epel-release-latest-7.noarch.rpm extracted from http://dl.fedoraproject.org/pub/epel)

Tunable values (exported bash variables):
    epel_release: name of the local epl file to use -- defaults to 'epel-release-latest-7.noarch.rpm'
    lastansible: latest version of ansible -- defaults to '2.2.3.0-1'
    latestversion: latest ceph-ansible version number -- defaults to '2.2.8-1'

