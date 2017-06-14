#! /bin/bash -f
#
# Make sure docker is installed and running.  This should end up being
# performed on all sites
#
source /tmp/parameters
yum install docker -y
service docker start
sed -i -e "s|.*INSECURE_REGISTRY=.*|INSECURE_REGISTRY='--insecure-registry ${brew_dir}'|" /etc/sysconfig/docker
service docker restart
