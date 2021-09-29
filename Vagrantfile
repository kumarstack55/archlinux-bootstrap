# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"

  # OS上のホスト名を設定する。
  config.vm.hostname = "ho-hiy-arc-1"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true

    # VirtualBox の物理ホスト名を設定する。
    vb.name = "v-ho-hiy-arc-1"

    # 解像度をより広くするためにメモリ量を増やす。
    vb.customize [ "modifyvm", :id, "--vram", "16" ]

    # Customize the amount of memory on the VM:
    #vb.memory = "1024"
  end

  config.vm.provision "shell", inline: <<-SHELL
    if type git >/dev/null 2>&1; then
      sudo pacman -S --noconfirm git
    fi

    cd /tmp
    if [[ ! -d archlinux-bootstrap ]]; then
      git clone https://github.com/kumarstack55/archlinux-bootstrap
    fi
    cd ./archlinux-bootstrap
    git pull

    if type ansible >/dev/null 2>&1; then
      sudo pacman -S --noconfirm ansible
    fi

    cd ./playbooks/bootstrap
    ansible-playbook -i inventory site.yml --diff
  SHELL
end
