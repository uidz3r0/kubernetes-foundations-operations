#!/bin/bash

echo "Rocky Linux configuration"

sudo setenforce 0

sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo systemctl enable --now chronyd

sudo systemctl enable sshd

echo "Finished Rocky configuration."