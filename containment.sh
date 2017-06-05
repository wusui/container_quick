#! /bin/bash -fv

#
# Remotely run a script that is in this directory.
#
do_setup() {
    scp $2.sh $1:/tmp
    ssh $1 sudo chmod 0777 /tmp/$2.sh
    ssh $1 sudo /tmp/$2.sh
}

export epel_release=${epel_release:-'epel-release-latest-7.noarch.rpm'}
#
# cephnodes -- list of sites passed to this script
# first -- first site in cephnodes
#
cephnodes=$*
zarray=($*)
first=${zarray[0]}

rm -rf /tmp/ahosts
scp ${first}:/etc/ansible/hosts /tmp/ahosts
if [ -f /tmp/ahosts ]; then
    mchk=`grep "\[mons\]" /tmp/ahosts | wc -l`
    if [ $mchk -gt 0 ]; then
        echo "Remove [mons] and [osds] entries from /etc/ansible/hosts on $first"
        exit -1
    fi
fi

#
# Run setup.sh on all sites
#
for x in $cephnodes
do 
    do_setup $x setup 
done

#
# Makes sure that you can ssh between all sites.
#
for x in $cephnodes
do 
    echo "ssh-keygen -f /home/ubuntu/.ssh/id_rsa -N ''" | ssh $x
done
rm -fr /tmp/pubkeys
for x in $cephnodes
do 
    echo "cat /home/ubuntu/.ssh/id_rsa.pub" | ssh -t -y $x >> /tmp/pubkeys
done
for x in $cephnodes
do 
    scp /tmp/pubkeys $x:/tmp
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
scp ${epel_release} $first:/tmp
do_setup $first install

#
# Remotely edit ansible yml files and add ceph information to the
# ansible hosts file
#
scp editansible.sh $first:/tmp
ssh $first sudo chmod 0777 /tmp/editansible.sh
ssh $first /tmp/editansible.sh
rm -rf /tmp/anshostsinfo
echo '[mons]' > /tmp/anshostsinfo
for x in $cephnodes
do
echo "  $x" >> /tmp/anshostsinfo
done
echo '[osds]' >> /tmp/anshostsinfo
for x in $cephnodes
do
echo "  $x" >> /tmp/anshostsinfo
done
scp /tmp/anshostsinfo $first:/tmp
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
rm -rf /tmp/done.msg
echo "********************************************************************"> /tmp/done.msg
echo "Finished with the setup of containers.">> /tmp/done.msg
echo "Go to ${first} and cd to /usr/share/ceph-ansible Then run">> /tmp/done.msg
echo "">> /tmp/done.msg
echo "sudo docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhceph:ceph-2-rhel-7-docker-candidate-20170516014056">> /tmp/done.msg
echo "">> /tmp/done.msg
echo "followed by:">> /tmp/done.msg
echo "">> /tmp/done.msg
echo "ansible-playbook --skip-tags=with_pkg site-docker.yml">> /tmp/done.msg
>> /tmp/done.msg
cat /tmp/done.msg
