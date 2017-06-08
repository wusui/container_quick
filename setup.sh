#! /bin/bash -f
#
# enable rpms using the subscription managers.
#
# make sure that the firewall is set correctly.
#
# start ntpd
#
sed -i -e 's,^hostname *=.*,hostname = subscription.rhn.stage.redhat.com,;s,baseurl *=.*,baseurl= http://cdn.stage.redhat.com,' /etc/rhsm/rhsm.conf
subscription-manager register --username=qa@redhat.com --password=redhatqa
subscription-manager attach --pool=8a85f9823e3d5e43013e3ddd4e2a0977
subscription-manager repos --disable='*'
subscription-manager repos --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rpms
systemctl enable firewalld
systemctl start firewalld
systemctl status firewalld
firewall-cmd --zone=public --add-port=6789/tcp
firewall-cmd --zone=public --add-port=6789/tcp --permanent
firewall-cmd --zone=public --add-port=6800-7300/tcp
firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent
firewall-cmd --zone=public --add-port=7480/tcp
firewall-cmd --zone=public --add-port=7480/tcp --permanent 
hostname -s
yum install ntp -y
systemctl enable ntpd
systemctl start ntpd
systemctl status ntpd
