#!/bin/bash

echo "Ubuntu configuration"

sudo apt install -y chrony

sudo systemctl enable --now chronyd || true

sudo systemctl enable ssh

echo "Finished Ubuntu configuration."