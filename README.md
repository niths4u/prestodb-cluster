# prestodb cluster
* using docker to setup presto cluster
* This code helps to setup presto cluster using docker from base ubuntu 18.04 
* It also provides sample connection to mysql , postgresql , sqlserver
* It also helps proivides ssh tunneling for jumpbox in case a db server requires jumpserver to connect

# prestodb cluster

* Is a simple set of commands for launching multiple node [Presto](https://prestosql.io/) cluster on docker container.
* This code helps to setup presto cluster using docker from base ubuntu 18.04 
* It also provides sample connection to mysql , postgresql , sqlserver
* It has set of commands that does ssh tunneling for jumpbox in case a db server requires jumpserver to connect with passkey phrase along with setting passwordless authentication



# Build Network
First need to build a network with below command

```
$ docker network create presto_net;
```

## docker-compose.yml

You can launch multiple node docker presto cluster with below yaml file. `command` is required to pass node id information which must be unique in a cluster.

Very Important : Keep adding worker0 , worker1 , worker2 etc as per your need. Here only 2 workers are kept. Everytime you add a new worker , make sure to change the worker<number> and also the port . For eg a new worker 2 will have name worker2 and port 9093:9091 and also the command will contain worker2. The last parameter TRUE is meant if there is any ssh jumpserver configuration needed . This will automatically setup tunneling if we provide privatekey and passphrase appropriately. The steps are explained under ssh settings section below

```Dockerfile
version: '3.5'
services:
  coordinator:
    build: .
    volumes:
     - .:/home/presto/presto_files
    stdin_open: true
    tty: true
    container_name: "coordinator"
    command: ./presto_files/presto_setup.sh coordinator coordinator TRUE ( 
    ports:
     - "9090:9090"

  worker0:
    build: .
    volumes:
     - .:/home/presto/presto_files
    stdin_open: true
    tty: true
    container_name: "worker0"
    command: ./presto_files/presto_setup.sh worker worker0 TRUE
    ports:
     - "9091:9091"


  worker1:
    build: .
    volumes:
     - .:/home/presto/presto_files
    stdin_open: true
    tty: true
    container_name: "worker1"
    command: ./presto_files/presto_setup.sh worker worker1 TRUE
    ports:
     - "9092:9091"
networks:
  default:
    external:
      name: presto_net
```

# Run  ( Always run from the source folder ) 

```
$ docker-compose up -d
```

# Docker presto settings : presto_setup.sh
In order to have jumpserver configuration make sure to copy the private key of the user that is authenticated to connect without password into ssh_setup folder under the name priv_key. Also if there is any passphrase then put that passphrase in ssh_setup folder. If you are not using passphrase , then simply comment the line which has "./presto_files/ssh_fix.sh"
```
#!/bin/bash -x
node_type=$1
node_id=$2
node_ssh_fix=$3     ### To be used if there is any jumpserver required
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

```

# SSH settings ssh_fix.sh
Very Important : if people are using passphrase , then put the passphrase in send"asdasdasdsad\n" and also make sure to put the exact name in which you have authenticated in jumpserver instead of myname@machine. For eg , if you are authenticated with username tom@cat.com then put the line as 
```
expect "Identity added: /home/presto/presto_files/ssh_setup/priv_key (tom@cat.com)"
```
Easiest way is to run ssh manually and see the exact commands that are comming in the terminal and use that in the below script.

```
#!/usr/bin/expect -f
spawn ssh-add /home/presto/presto_files/ssh_setup/priv_key
expect "Enter passphrase for /home/presto/presto_files/ssh_setup/priv_key:"
send "\n"; #if there is any passphrase then replace it with send "passkey\n"
expect "Identity added: /home/presto/presto_files/ssh_setup/priv_key (myname@machine)" #myname@machine to be replaced by the name you are authenticated in jumpserver. 
interact
```

# Presto Coordinator 
this folder contains coordinator related files and also some dummy catalogs for quick reference

# Presto Worker
this folder contains coordinator related files and also some dummy catalogs for worker reference


# Code Architecture
The code first creates the docker file

Then it mounts the current folder into the docker folder named presto_files

Then runs the presto_setup.sh which basically creates a file insider docker named presto_settings and copy all necessary files from presto_base and presto_coordinator/worker to setup presto inside docker.

# Some useful commands ( assuming docker is running only this presto setup ) 
docker-compose ps # to see if all nodes are runnings

docker-compose logs # to see logs while running the presto docker setup

docker-compose exec coordinator /bin/bash #to connect to a coordinator

docker-compose down # to remove all docker within this

# Connecting to Presto sql
```
docker-compose exec coordinator /bin/bash
/home/presto/presto_settings/presto --server localhost:9090
select * from testpostgresql.public.tb1 limit 10; ##Assuming testpostgresql.properties is having all proper connection settings and there is a table named tb1
```

# LICENSE

[Apache v2 License](https://github.com/Lewuathe/docker-presto-cluster/blob/master/LICENSE)
