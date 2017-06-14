#! /bin/bash -f

#
# Remotely run a script that is in this directory.
#

do_setup() {
    scp $2.sh $1:/tmp
    ssh $1 sudo chmod 0777 /tmp/$2.sh
    ssh $1 sudo /tmp/$2.sh
}

#
# cephnodes -- list of sites passed to this script
# first -- first site in cephnodes
#
cephnodes=$*
zarray=($*)
first=${zarray[0]}

epel_url=${epel_url:-'https://dl.fedoraproject.org/pub/epel'}
epel_release=${epel_release:-'epel-release-latest-7.noarch.rpm'}
brew_dir=${brew_dir:-'brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhceph'}
download_node=${download_node:-'http://download-node-02.eng.bos.redhat.com/rcm-guest/ceph-drops/auto/rhscon-2-rhel-7-compose/latest-RHSCON-2-RHEL-7/compose/Installer/x86_64/os/Packages/'}
docker_candidate=${docker_candidate:-'ceph-2-rhel-7-docker-candidate-20170516014056'}
automatically_do_everything=${automatically_do_everything:-'true'}
subscription_user=${subscription_user:-'qa@redhat.com'}
subscription_password=${subscription_password:-'unknown'}
subscription_pool=${subscription_pool:-'8a85f9823e3d5e43013e3ddd4e2a0977'}

if [ ! -f ${epel_release} ]; then
    wget ${epel_url}/${epel_release}
fi

scp ${epel_release} ${first}:/tmp
echo "sudo rm -rf /etc/ansible/hosts" | ssh $first 2> /dev/null
ssh $first ls /var/log/ansible.log 2> /dev/null
if [ $? -ne 0 ]; then
    ssh $first sudo touch /var/log/ansible.log
    ssh $first sudo chmod 0666 /var/log/ansible.log
fi
rm -rf local_temp
mkdir local_temp

echo "epel_url=${epel_url}" > local_temp/paramters
echo "epel_release=${epel_release}" >> local_temp/parameters
echo "brew_dir=${brew_dir}" >> local_temp/parameters
echo "download_node=${download_node}" >> local_temp/parameters
echo "docker_candidate=${docker_candidate}" >> local_temp/parameters
echo "automatically_do_everything=${automatically_do_everything}" >> local_temp/parameters
echo "subscription_user=${subscription_user}" >> local_temp/parameters
echo "subscription_password=${subscription_password}" >> local_temp/parameters
echo "subscription_pool=${subscription_pool}" >> local_temp/parameters

#
# Run setup.sh on all sites
#
for x in $cephnodes
do 
    scp local_temp/parameters $x:/tmp/parameters
    do_setup $x setup 
done

#
# Makes sure that you can ssh between all sites.
#
for x in $cephnodes
do
    for y in $cephnodes
    do
       echo "sudo sed -i \"/ ubuntu@$x/d\"" /home/ubuntu/.ssh/authorized_keys | ssh $y
    done
done
for x in $cephnodes
do 
    echo "/usr/bin/ssh-keygen -f /home/ubuntu/.ssh/id_rsa -N ''" | ssh $x
done
for x in $cephnodes
do 
    echo "cat /home/ubuntu/.ssh/id_rsa.pub" | ssh -t -y $x >> local_temp/pubkeys
done
for x in $cephnodes
do 
    scp local_temp/pubkeys $x:/tmp/pubkeys
    echo "cat /tmp/pubkeys >> /home/ubuntu/.ssh/authorized_keys" | ssh $x
done
for x in $cephnodes
do
    for y in $cephnodes
    do
        ssh $x ssh -oStrictHostKeyChecking=no $y hostname -s
    done
done

#
# Remotely run install.sh on the administrative site.
#
scp parsePackages.py ${first}:/tmp
do_setup $first install

#
# Remotely edit ansible yml files and add ceph information to the
# ansible hosts file
#
scp editansible.sh $first:/tmp
ssh $first sudo chmod 0777 /tmp/editansible.sh
ssh $first /tmp/editansible.sh
echo '[mons]' > local_temp/anshostsinfo
for x in $cephnodes
do
echo "  $x" >> local_temp/anshostsinfo
done
echo '[osds]' >> local_temp/anshostsinfo
for x in $cephnodes
do
echo "  $x" >> local_temp/anshostsinfo
done
scp local_temp/anshostsinfo $first:/tmp
echo "sudo chown ubuntu:ubuntu /etc/ansible/hosts" | ssh $first
echo "cat /tmp/anshostsinfo >> /etc/ansible/hosts" | ssh $first
echo "sudo chown root:root /etc/ansible/hosts" | ssh $first

#
# Make sure that docker is running on all sites
#
for x in $cephnodes
do 
    do_setup $x dockerset
done

#
#  Print instructions for the user to run containers.
#
rm -rf local_temp/done.msg 2> /dev/null
echo "********************************************************************"> local_temp/done.msg
echo "Finished with the setup of containers.">> local_temp/done.msg
echo "Go to ${first} and cd to /usr/share/ceph-ansible Then run">> local_temp/done.msg
echo "">> local_temp/done.msg
echo "sudo docker pull ${brew_dir}:${docker_candidate}">> local_temp/done.msg
echo "">> local_temp/done.msg
echo "followed by:">> local_temp/done.msg
echo "">> local_temp/done.msg
echo "ansible-playbook --skip-tags=with_pkg site-docker.yml" >> local_temp/done.msg
>> local_temp/done.msg
if [ $automatically_do_everything == 'true' ]; then
    echo "sudo docker pull ${brew_dir}:${docker_candidate}" | ssh $first
    echo "cd /usr/share/ceph-ansible; ansible-playbook --skip-tags=with_pkg site-docker.yml" | ssh $first
    sleep 60
    echo "sudo docker exec ceph-mon-${first} ceph -s" | ssh $first
else
    cat local_temp/done.msg
fi
rm -rf local_temp 2> /dev/null
