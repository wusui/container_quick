# Container_quick -- a script to rapidly bring up a containerized ceph instance

## Usage

Usage: ./containment.sh node1 node2 node3

This script will bring up 3 mons (1 on each node), 9 osds (3 on each node) and a container node (on node1). 
 
Prior to running this, make sure that there are no previous [mons] or [osds] sections in /etc/ansible/hosts on the container node.  If this is run on a newly installed node, there should not be an /etc/ansible/hosts file.

Also, there should be a copy of the latest epel repo in the local directory (currently use epel-release-latest-7.noarch.rpm extracted from http://dl.fedoraproject.org/pub/epel)

## Tunable values (bash variables):

* epel_release: name of the local epl file to use -- defaults to 'epel-release-latest-7.noarch.rpm'
* download_node: url of the package diretory -- defaults to 'http://download-node-02.eng.bos.redhat.com/rcm-guest/ceph-drops/auto/rhscon-2-rhel-7-compose/latest-RHSCON-2-RHEL-7/compose/Installer/x86_64/os/Packages/'
* brew_dir: directory containg brew rhceph image -- defaults to 'brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhceph'
* docker_candidate: docker candidate -- defaults to 'ceph-2-rhel-7-docker-candidate-20170516014056'
* automatically_do_everything: If true, docker pull, ansible-playbook and ceph -s test are done automatically -- defaults to true.  Set this to false if you want to edit yml files before running the playbook.
