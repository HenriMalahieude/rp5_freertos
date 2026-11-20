Commands for ssh enabling on raspberry pi os (using Ubuntu 26):

1. `touch /run/media/user/bootfs/ssh`
2. `echo "user:$(openssl passwd -6)" > /run/media/user/bootfs/userconf.txt
