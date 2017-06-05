#! /bin/bash -fv

do_setup() {
    scp $2.sh $1:/tmp
    ssh $1 sudo chmod 0777 /tmp/$2.sh
    ssh $1 sudo /tmp/$2.sh
}

cephnodes=$*
first=
for x in $cephnodes
do
    if [ ${#first} -eq 0 ]; then    
        first=$x   
    fi
done
for x in $cephnodes
do 
    do_setup $x setup 
done
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
scp epel-release-latest-7.noarch.rpm $first:/tmp
do_setup $first install
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
for x in $cephnodes
do 
    do_setup $x dockerset
done
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
