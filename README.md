# archlinux-bootstrap

OS導入作業を支援するリポジトリです。

ほとんどの作業を `bootstrap.sh` や Ansible のプレイブックで行うので、
Arch Linux のインストール作業を繰り返しても苦にならないことを目指します。

## システム構成

このリポジトリの利用想定として、次の方針、方針に基づく構成を想定します。

### サーバ構成設計の方針

* 大方針
    * シンプルにデザインする。
* 仮想マシンのサイジング
    * インストールに必要な最小構成をそのまま使う。
        * メモリは 1024MB とする。理由: ArchLinux 選択時のVirtualBox の初期値 1024MB を 512MB に変えたときインストール過程で失敗したため。
        * ストレージは 8GB とする。VirtualBox の初期値を利用する。
            * なお、Arch Linux 導入直後で 1.7GB 程度消費したので不足しない。
* ストレージのパーティション構成
    * 利用者は、スワップ使ってたら気づける位の人を想定しておく。
        * 利用ソフトウェアはスワップを使うほどのメモリ使用はない想定とする。
        * 念のため、緩衝材として 512MB のスワップを確保はする。
* 仮想マシンのネットワーク構成
    * 維持に必要なNICを若い番号にする。インターネット接続がより若い番号とする。
* OSソフトウェア選定
    * ブートローダーは GRUB を選ぶ。他と比べて最もカバー範囲が広いため。
    * ネットワーク管理は systemd で行う。管理対象のパッケージを増やさないため。
* ソフトウェア選定
    * よく使うパッケージを入れておく。

### 仮想化ホスト、仮想マシン

* 仮想化ホスト
    * jp106キーボード
    * VirtualBox
* 仮想マシン
    * VM: vm-archlinux
        * CPU: 1
        * メモリ: 1024MB
        * ストレージ
            * 8GB
                * MBR
                * sda1, 512MB, swap
                * sda2, (残りすべて), linux
        * ネットワーク
            * アダプター1: NAT
            * アダプター2: ホストオンリーアダプター

### ネットワーク構成: 手動インストールの場合

```
    GitHub
    |
    Internet
    |
    Gateway
    |
   -o---o-------------------o-
        |                   |
        |                   NAT Router
        |                   |
        |                   enp0s8 (DHCP)
        VirtualBox Host     Virtual Machine
        |                   enp0s3 (DHCP)
        |                   |
       -o-------------------o- 192.168.56.0/24
                               Virtual Box Host Only Network
```

* Arch Linux のローカルのユーザとして `local_user_name` を作ります。
* ユーザのSSH公開鍵として `local_user_github_user_id` の公開鍵を設定します。

### ネットワーク構成: Vagrant boxの場合

```
    GitHub
    |
    Internet
    |
    Gateway
    |
   -o---o-----------------------------o-
        |                             |
        |                             NAT Router
        |                             |
        |                            -o- 10.0.2.15/24
        |                             |
        |                             adapter1
        |                             eth0 (altname enp0s3) (DHCP)
        VirtualBox Host               Virtual Machine
          port forwarding             Hostname: archlinux
            adapter1                    User: vagrant
              TCP                       Password: vagrant
                Host: 127.0.0.1:2222
                Guest: 22
```

### 仮想マシンへのログイン

* SSHクライアントによるログイン
    * 仮想化ホストで `ssh -l OSユーザ名 ホスト名` で公開鍵認証でログインする。
* コンソールによるログイン
    * OSユーザに設定したパスワードでログインする。

## このリポジトリのスコープ

インストレーションガイドの目次と、このリポジトリのカバー範囲は次の通り。

https://wiki.archlinux.org/index.php/Installation_guide

| Contents                              | カバー手段    |
| ------------------------------------- | ------------- |
| 1 Pre-installation                    | (子要素参照)  |
| 1.1 Acquire an installation image     | 対象外        |
| 1.2 Verify signature                  | 対象外        |
| 1.3 Prepare an installation medium    | 対象外        |
| 1.4 Boot the live environment		    | 対象外        |
| 1.5 Set the keyboard layout		    | bootstrap.sh  |
| 1.6 Verify the boot mode		        | bootstrap.sh  |
| 1.7 Connect to the internet		    | bootstrap.sh  |
| 1.8 Update the system clock		    | bootstrap.sh  |
| 1.9 Partition the disks		        | bootstrap.sh  |
| 1.9.1 Example layouts		            | bootstrap.sh  |
| 1.10 Format the partitions            | bootstrap.sh  |
| 1.11 Mount the file systems           | bootstrap.sh  |
| 2 Installation                        | bootstrap.sh  |
| 2.1 Select the mirrors                | bootstrap.sh  |
| 2.2 Install essential packages        | bootstrap.sh  |
| 3 Configure the system                | (子要素参照)  |
| 3.1 Fstab                             | bootstrap.sh  |
| 3.2 Chroot                            | 対象外        |
| 3.3 Time zone                         | ansible       |
| 3.4 Localization                      | ansible       |
| 3.5 Network configuration             | ansible       |
| 3.6 Initramfs                         | ansible       |
| 3.7 Root password                     | ansible       |
| 3.8 Boot loader                       | ansible       |
| 4 Reboot                              | 対象外        |
| 5 Post-installation                   | ansible       |

ただし、 `hwclock` は bootstrap.sh の範囲外として手動実行とする。

## ArchLinux をインストールする

live 環境で起動後、インターネット経由で bootstrap.sh を取得し、
bootstrap.sh を実行してください。
ディスクのパーティションは上書きされる点に注意してください。


```
curl -o bootstrap.sh https://raw.githubusercontent.com/kumarstack55/archlinux-bootstrap/main/bin/bootstrap.sh
bash ./bootstrap.sh
```

```
arch-chroot /mnt
```

```sh
# システムの時刻を、ハードウェアの時刻に反映する
# 仮想マシンにおいてはいらなそう。
hwclock --systohc
```

```sh
# リポジトリ取得と Ansible プレイブック実行のため、パッケージを導入する。
sudo pacman -S --noconfirm git ansible

# リポジトリを得る。
cd /tmp
git clone https://github.com/kumarstack55/archlinux-bootstrap
cd ./archlinux-bootstrap/playbooks/bootstrap

# 必要あれば設定する。
vi ./host_vars/localhost.yml

# プレイブックを dry-run で実行する。
ansible-playbook --check \
  -i inventory site.yml \
  --extra-vars "hostname=vm-archlinux" \
  --diff

# プレイブックを実行する。
ansible-playbook \
  -i inventory site.yml \
  --extra-vars "hostname=vm-archlinux" \
  --diff

# chroot を抜ける。
exit

# アンマウントする。
umount -R /mnt

# DVD を仮想メディアドライブから除去する。
# (手順省略)

# 再起動し、インストールされたOSの初回起動を試みる。
reboot
```
