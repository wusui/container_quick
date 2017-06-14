#! /bin/bash -f
#
# Modify the yml files in /usr/share/ceph-ansible to work for the downstream
# nodes.
#
source /tmp/parameters
d=/usr/share/ceph-ansible
sudo chown ubuntu:ubuntu ${d}
sudo chown ubuntu:ubuntu ${d}/*
sudo chown ubuntu:ubuntu ${d}/group_vars
sudo chown ubuntu:ubuntu ${d}/group_vars/*
cp ${d}/site-docker.yml.sample ${d}/site-docker.yml
cp ${d}/group_vars/all.yml.sample ${d}/group_vars/all.yml
cp ${d}/group_vars/osds.yml.sample ${d}/group_vars/osds.yml
cp ${d}/group_vars/mons.yml.sample ${d}/group_vars/mons.yml
mkdir ~/ceph-ansible-keys
chmod 0777 ~/ceph-ansible-keys
sed -i -e 's|#.*fetch_directory: .*|fetch_directory: ~/ceph-ansible-keys|' ${d}/group_vars/all.yml
sed -i -e 's|#.*monitor_interface: .*|monitor_interface: eno1|' ${d}/group_vars/all.yml
sed -i -e 's|#public_network: .*|public_network: 10.8.128.0/21|' ${d}/group_vars/all.yml
sed -i -e 's|#ceph_docker_image: .*|ceph_docker_image: rhceph|' ${d}/group_vars/all.yml
sed -i -e "s|#ceph_docker_image_tag: .*|ceph_docker_image_tag: ${docker_candidate}|" ${d}/group_vars/all.yml
sed -i -e 's|#journal_size: .*|journal_size: 100|' ${d}/group_vars/all.yml
sed -i -e 's|#docker: false|docker: true|' ${d}/group_vars/all.yml
sed -i -e 's|#ceph_docker_registry: .*|ceph_docker_registry: brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888|' ${d}/group_vars/all.yml
sed -i -e "s|#mon_containerized_deployment: .*|mon_containerized_deployment: 'true'|" ${d}/group_vars/mons.yml
sed -i -e "s|#ceph_mon_docker_interface: .*|ceph_mon_docker_interface: eno1|" ${d}/group_vars/mons.yml
sed -i -e "s|#ceph_mon_docker_subnet: .*|ceph_mon_docker_subnet: 10.8.128.0/21|" ${d}/group_vars/mons.yml
sed -i -e 's|#osd_containerized_deployment: false|osd_containerized_deployment: true|' ${d}/group_vars/osds.yml
sed -i -e "s|^#devices:$|devices:|" ${d}/group_vars/osds.yml
sed -i -e "s|#.*/dev/sdb|  - /dev/sdb|" ${d}/group_vars/osds.yml
sed -i -e "s|#.*/dev/sdc|  - /dev/sdc|" ${d}/group_vars/osds.yml
sed -i -e "s|#.*/dev/sdd|  - /dev/sdd|" ${d}/group_vars/osds.yml
sed -i -e 's|^#ceph_osd_docker_devices:.*|ceph_osd_docker_devices: "{{ devices }}"|' ${d}/group_vars/osds.yml
