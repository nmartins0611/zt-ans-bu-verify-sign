#!/bin/bash

systemctl stop systemd-tmpfiles-setup.service
systemctl disable systemd-tmpfiles-setup.service

# # Install collection(s)
# ansible-galaxy collection install ansible.eda
# ansible-galaxy collection install community.general
# ansible-galaxy collection install ansible.windows
# ansible-galaxy collection install microsoft.ad

# # ## setup rhel user
touch /etc/sudoers.d/rhel_sudoers
echo "%rhel ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/rhel_sudoers
cp -a /root/.ssh/* /home/$USER/.ssh/.
chown -R rhel:rhel /home/$USER/.ssh


#Runs bash with commands between '_' as nobody if possible
$RUNAS bash<<_
echo 2: \$USER
awx -k settings modify AWX_TASK_ENV '{ "HOME": "/var/lib/awx", "GIT_SSL_NO_VERIFY": "True" }' --conf.host https://localhost --conf.username admin --conf.password ansible123!
curl -k -H "Content-Type: application/json" -d '{"name":"ansible-sign-demo"}' -u student:learn_ansible https://gitea:8443/api/v1/user/repos
mkdir /home/rhel/ansible-sign-demo
cd /home/rhel/ansible-sign-demo
git init
git config --global user.name "student user"
git config http.sslVerify false
cat << EOF > /home/rhel/ansible-sign-demo/README.md
# This repo will be used to demonstrate usage of ansible-sign tool
## and how to validate signed projects in automation controller
EOF
git add README.md; git commit -m "Initial Commit"
git remote add origin https://gitea:8443/student/ansible-sign-demo.git
git config credential.helper store
touch /home/rhel/.git-credentials
echo 'https://student:learn_ansible@gitea%3a8443' >> /home/rhel/.git-credentials
git push -u origin master
git config --global user.name "Instruqt"
git config --global user.email student@localhost
_

echo 3: $USER
