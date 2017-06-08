#! /bin/bash -f
#
# Make sure docker is installed and running.  This should end up being
# performed on all sites
#
yum install docker -y
service docker start
sed -i -e "s|.*INSECURE_REGISTRY=.*|INSECURE_REGISTRY='--insecure-registry brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888'|" /etc/sysconfig/docker
service docker restart
