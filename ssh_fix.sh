#!/usr/bin/expect -f
spawn ssh-add /home/presto/presto_files/ssh_setup/priv_key
expect "Enter passphrase for /home/presto/presto_files/ssh_setup/priv_key:"
send "\n"; #if there is any passphrase then replace it with send "passkey\n"
expect "Identity added: /home/presto/presto_files/ssh_setup/priv_key (myname@machine)" #myname@machine to be replaced by the name you are authenticated in jumpserver. 
interact
