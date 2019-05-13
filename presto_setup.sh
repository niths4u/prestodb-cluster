#!/bin/bash -x
node_type=$1
node_id=$2
node_ssh_fix=$3
rm -rf presto_settings
cp -rf ./presto_files/presto_base presto_settings
cp -rf ./presto_files/presto_${node_type}/etc presto_settings
cp -rf ./presto_settings/etc/node.properties.template ./presto_settings/etc/node.properties
sed -i "s/<to_be_changed>/${node_id}/g" ./presto_settings/etc/node.properties
cp -rf ./presto_files/catalog ./presto_settings/etc/
if (( $3 == "TRUE" ))
then
eval $(ssh-agent)
./presto_files/ssh_fix.sh
ssh -4 -fN -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3"  -L  localhost:5432:dbserverhostname:5432 jumpserverusername@jumpserver
fi
/home/presto/presto_settings/bin/launcher run
