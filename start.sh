# This script assumes that you have already setup a guest account with proper
# permissions and set the login shell to automatically attach to the tmux
# socket.
sudo usermod guest --shell /usr/sbin/tmux-login

# Establish a new tmux session
# -s {Session Name}
# new Create a new session
# -S {Path to socket}
# -d Create the session without attaching yet.
tmux -S /home/guest/.tmux-session/session new -s guest -d

# Set group on socket to allow guest to attach
sudo chgrp guest /home/guest/.tmux-session/session

# Generate a new password
password=$(openssl rand --base64 18)

# Set the guest users password to a new value
echo "guest:$password" | sudo chpasswd
echo "The password for the guest connection is"
echo $password

# Pause so that the password can be read. Interrupt here leaves system in state where guest can
# connect while host is not connected to tmux session.
read

# Attach to the session
tmux -S /home/guest/.tmux-session/session attach

# Once host has disconnected from the session
#   Kill any processes from the guests, this closes the ssh connection
#   Reset the guest password
sudo pkill -u guest
password=$(openssl rand --base64 18)
echo "guest:$password" | sudo chpasswd
sudo usermod guest --shell /usr/sbin/nologin
