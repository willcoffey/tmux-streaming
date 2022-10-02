# What's This?
---
A simple way to share a terminal screen over ssh. No ssh keys required, nothing more than ssh 
needed by viewer. I'm not confident about the security considerations for this, I think it should be
ok so long as the `-r` read only option for `tmux` is good but it's not just a read only stream.

# Setup
---
Tested on `Debian GNU/Linux 11` and `tmux 3.1c`

## 1. Create custom shell for automatically attaching tmux
---
Save the following to `/usr/sbin/tmux-login` with `-rwxr-xr-x 1 root root` permissions.

```sh
#!/usr/bin/bash
exec /usr/sbin/tmux -S /home/guest/.tmux-session/session attach -r
```
`-S /home/guest/.tmux-session/session` is the path to the unix socket tmux creates.

`-r`  signifies the client is read-only (only keys bound to the detach-client or switch-client
      commands have any effect). Without this the guest can fully interact with the session.
## 2. Create a guest user
---
```sh
sudo useradd guest -ms /usr/sbin/nologin
```
`-m` Generates a home directory

`-s /usr/sbin/nologin` Sets the login shell to disable logging in as guest. `start.sh` sets the 
login shell to `/usr/sbin/tmux-login` which enables login and disables it again once complete.

### 2.1 Allow password login for guest user if needed.
---
Add the follwing lines to `/etc/ssh/sshd_config` 
```
Match User guest
  PasswordAuthentication yes
Match all
```

restart ssh server

`sudo service sshd restart`

## 3. Create `.tmux-session` directory
---
```sh
sudo mkdir /home/guest/.tmux-session
sudo chown HOST /home/guest/.tmux-session
sudo chgrp guest /home/guest/.tmux-session
```

## 4. Run the `start.sh` script to do the following: 
  - Create new tmux session in `/home/guest/.tmux-session/session`. If a session already exists
    it won't be overwritten.
  - Generates a new password for the guest user, display it, and wait for enter. (if you cancel the
    script at this point the guest account could ssh in and attach to session)
  - Attach to the session.
  - Wait for host to detach or close the session
  - Kill all processes from guest user
  - Generate a new random password for the guest user.
  - Set guest user to nologin shell

## 5. Have Client Connect
---
Client should `ssh guest@example.com`, provide them with the password generated by the script. 
DO NOT ssh to the guest account from within the host shell. Guest can disconnect using tmux
detach shortcut key.

# Notes
---
Check out the `script` and `scriptreplay` tools for creating recordings of sessions.

The terminal won't resize to the guest terminal, the host will need to manually resize it either by
resizing terminal window or running tmux command `resize-window -x 80 -y 24`. 

`resize-window -A` will automatically resize the tmux window back to hosts dimensions.


# To Do
---
MOTD on guest login, explain how to disconnect.
script recording options
