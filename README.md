# Container_quick -- a script to rapidly bring up a containerized ceph instance

## Usage

Usage: ./containment.sh node1 node2 node3

## Installation

Install this script in a local directory (home directory on magna002, for example).

git clone http://github.com/wusui/container_quick;
cd container_quick

## Description

Make sure that you can passwordlessly ssh to the three nodes listed in the parameters.

This script will bring up 3 mons (1 on each node), 9 osds (3 on each node) and a container node (on node1).  It automatically performs the steps documented in https://docs.google.com/document/d/1a7Hh8NU5HmZ86y5bqSXldgnulL5HuMAMJA3fIL9bDxk/edit
 
This works best on freshly installed magna machines.  If run on a previously installed system, make sure that there are no [mons] or [osds] sections in /etc/ansible/hosts on the container node.

If there is an epel rpm file in the current directory with the name specified by the epel_release tunable, then we will use that.  Otherwise, an epel file will be downloaded.

## Security

The subscription password is not set by default.  To set this password, export subscription_password=<password>.  For example, to set the password to 'aardvark', run the following command:

export subscription_password=aardvark

An error message is displayed if subscription_password is not set.

## Tunable values (bash variables):

* epel_url: address of where to extract the epel rpm from -- defaults to 'https://dl.fedoraproject.org/pub/epel'
* epel_release: name of the local epel file to use -- defaults to 'epel-release-latest-7.noarch.rpm'
* download_node: url of the package diretory -- defaults to 'http://download-node-02.eng.bos.redhat.com/rcm-guest/ceph-drops/auto/rhscon-2-rhel-7-compose/latest-RHSCON-2-RHEL-7/compose/Installer/x86_64/os/Packages/'
* brew_dir: directory containg brew rhceph image -- defaults to 'brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888'
* docker_candidate: docker candidate -- defaults to 'ceph-2-rhel-7-docker-candidate-20170516014056'
* automatically_do_everything: If true, docker pull, ansible-playbook and ceph -s test are done automatically -- defaults to true.  Set this to false if you want to edit yml files before running the playbook.
* subscription_user: subscription manager user -- defaults to 'qa@redhat.com'
* subscription_password: subscription manager password -- defaults to 'unknown'
* subscription_pool: subscription manager pool -- defaults to '8a85f9823e3d5e43013e3ddd4e2a0977'
