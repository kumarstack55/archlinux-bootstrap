#!/bin/bash

set -eux

test_executable_exists() {
  local cmd="$1"; shift
  type "$cmd" >/dev/null 2>&1
}

ansible_hostname=$(uname -n)

# 部分アップグレードにならないよう、アップデートする。
# https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported
sudo pacman -Syu --noconfirm

# リポジトリ取得と Ansible プレイブック実行のため、パッケージを導入する。
if ! test_executable_exists git; then
  sudo pacman -S --noconfirm git
fi
if ! test_executable_exists ansible-playbook; then
  sudo pacman -S --noconfirm ansible
fi

# リポジトリを得る。
cd /tmp
if ! test -d /tmp/archlinux-bootstrap; then
  git clone https://github.com/kumarstack55/archlinux-bootstrap
fi
cd ./archlinux-bootstrap/playbooks/bootstrap

# プレイブックを実行する。
ansible-playbook \
  -i inventory site.yml \
  --extra-vars "hostname=$ansible_hostname" \
  --diff
