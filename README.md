# Container_quick -- a script to rapidly bring up a containerized ceph instance

## Usage

Usage: ./containment.sh node1 node2 node3

## Installation

Install this script in a local directory

git clone http://github.com/wusui/container_quick
cd container_quick

## Description

Run this script from a node that can ssh to the three nodes listed in the parameters.  In the Octo Lab, for instance, this should be run from magna002.

This script will bring up 3 mons (1 on each node), 9 osds (3 on each node) and a container node (on node1).  It automatically performs the steps documented in https://docs.google.com/document/d/1a7Hh8NU5HmZ86y5bqSXldgnulL5HuMAMJA3fIL9bDxk/edit
 
This works best on freshly installed magna machines.  If run on a previously installed system, make sure that there are no [mons] or [osds] sections in /etc/ansible/hosts on the container node.

This script will copy the latest epel repo into the container_quick directory.

## Tunable values (bash variables):

* epel_url: address of where to extract the epel rpm from -- defaults to 'https://dl.fedoraproject.org/pub/epel'
* epel_release: name of the local epel file to use -- defaults to 'epel-release-latest-7.noarch.rpm'
* download_node: url of the package diretory -- defaults to 'http://download-node-02.eng.bos.redhat.com/rcm-guest/ceph-drops/auto/rhscon-2-rhel-7-compose/latest-RHSCON-2-RHEL-7/compose/Installer/x86_64/os/Packages/'
* brew_dir: directory containg brew rhceph image -- defaults to 'brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhceph'
* docker_candidate: docker candidate -- defaults to 'ceph-2-rhel-7-docker-candidate-20170516014056'
* automatically_do_everything: If true, docker pull, ansible-playbook and ceph -s test are done automatically -- defaults to true.  Set this to false if you want to edit yml files before running the playbook.
