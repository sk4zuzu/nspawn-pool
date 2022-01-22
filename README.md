SIMPLE NSPAWN CONTAINER CLUSTER / NSPAWN ON UBUNTU
==================================================

## 1. PURPOSE

Use ubuntu-based bare metal machines (or VMs with nested KVM) to automatically partition them into multiple systemd nspawn containers.

## 2. REQUIREMENTS

### 2.1 SOFTWARE

- modern `ansible` (2022), for example 2.12.1
- (optional) recent `mitogen` (2022), for example [this](https://github.com/mitogen-hq/mitogen/commit/5b505f524a7ae170fe68613841ab92b299613d3f) commit
- (optional) `bash`
- (optional) GNU `make`

__NOTE: If you don't want to use `mitogen`, just disable it in the Makefile or run `ansible-playbook` directly. :+1:__

### 2.2 UBUNTU ON A CONTAINER HOST

- `hirsute` (21.04)
- `focal` (20.04)

## 3. USAGE

Create inventory:
```dosini
$ cat >inventory/hosts.ini <<EOF
[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
authorized_key="{{ lookup('file', '~/.ssh/id_rsa.pub') | trim }}"
subnet_cidr=192.168.144.0/24
ubuntu_codenames=["hirsute","focal"]

[hosts]
asd ansible_host=10.11.12.13

[asd_machines]
asd1 ubuntu=hirsute ansible_port=2202 ansible_host="{{ subnet_cidr | ipaddr('2') | ipaddr('address') }}"
asd2 ubuntu=focal   ansible_port=2204 ansible_host="{{ subnet_cidr | ipaddr('4') | ipaddr('address') }}"
asd3 ubuntu=focal   ansible_port=2208 ansible_host="{{ subnet_cidr | ipaddr('8') | ipaddr('address') }}"
EOF
```

Deploy containers:
```
$ ansible-playbook -i inventory/hosts.ini main.yml

PLAY [hosts] **************************************************************************************************************************************

TASK [include_tasks] ******************************************************************************************************************************
included: /stor/asd/_git/nspawn-pool/ubuntu.yml for asd

TASK [Install required system packages] ***********************************************************************************************************
changed: [asd]

TASK [Ensure /var/lib/machines directory exists] **************************************************************************************************
changed: [asd]

TASK [Deboostrap ubuntu chroot filesystems] *******************************************************************************************************
changed: [asd] => (item=hirsute)
changed: [asd] => (item=focal)

TASK [include_tasks] ******************************************************************************************************************************
included: /stor/asd/_git/nspawn-pool/machine.yml for asd => (item=asd1)
included: /stor/asd/_git/nspawn-pool/machine.yml for asd => (item=asd2)
included: /stor/asd/_git/nspawn-pool/machine.yml for asd => (item=asd3)

TASK [Create directory for the machine] ***********************************************************************************************************
changed: [asd]

TASK [Unarchive cached ubuntu root filesystem] ****************************************************************************************************
changed: [asd]

TASK [Add ubuntu user and group] ******************************************************************************************************************
changed: [asd] => (item={'path': '/var/lib/machines/asd1/etc/group', 'line': 'ubuntu:x:1000:'})
changed: [asd] => (item={'path': '/var/lib/machines/asd1/etc/passwd', 'line': 'ubuntu:x:1000:1000::/home/ubuntu:/bin/bash'})
changed: [asd] => (item={'path': '/var/lib/machines/asd1/etc/shadow', 'line': 'ubuntu:!:1::::::'})

TASK [Add ubuntu user to sudoers] *****************************************************************************************************************
changed: [asd]

TASK [Create home and .ssh directories for the ubuntu user] ***************************************************************************************
changed: [asd] => (item=/var/lib/machines/asd1/home/ubuntu/)
changed: [asd] => (item=/var/lib/machines/asd1/home/ubuntu/.ssh/)

TASK [Create home and .ssh directories for root user] *********************************************************************************************
ok: [asd] => (item=/var/lib/machines/asd1/root/)
changed: [asd] => (item=/var/lib/machines/asd1/root/.ssh/)

TASK [Install authorized_keys for ubuntu and root users] ******************************************************************************************
changed: [asd] => (item={'path': '/var/lib/machines/asd1/home/ubuntu/.ssh/authorized_keys', 'owner': 1000, 'group': 1000})
changed: [asd] => (item={'path': '/var/lib/machines/asd1/root/.ssh/authorized_keys', 'owner': 0, 'group': 0})

TASK [Define default DNS server in systemd-resolved] **********************************************************************************************
changed: [asd]

TASK [Configure network interfaces lo and host0] **************************************************************************************************
changed: [asd] => (item={'dest': '/var/lib/machines/asd1/etc/network/interfaces.d/lo', 'content': 'auto lo\niface lo inet loopback\n'})
changed: [asd] => (item={'dest': '/var/lib/machines/asd1/etc/network/interfaces.d/host0', 'content': 'auto host0\niface host0 inet static\n    address 192.168.144.2/24\n    gateway 192.168.144.1\n'})

TASK [Polpulate /etc/hosts file with names of all machines for current host] **********************************************************************
changed: [asd] => (item=asd1)
changed: [asd] => (item=asd2)
changed: [asd] => (item=asd3)

TASK [Define hostname for current machine] ********************************************************************************************************
changed: [asd]

TASK [Disable DHCP for host0 interface (fix)] *****************************************************************************************************
changed: [asd]

TASK [Create directory for the machine] ***********************************************************************************************************
changed: [asd]

TASK [Unarchive cached ubuntu root filesystem] ****************************************************************************************************
changed: [asd]

TASK [Add ubuntu user and group] ******************************************************************************************************************
changed: [asd] => (item={'path': '/var/lib/machines/asd2/etc/group', 'line': 'ubuntu:x:1000:'})
changed: [asd] => (item={'path': '/var/lib/machines/asd2/etc/passwd', 'line': 'ubuntu:x:1000:1000::/home/ubuntu:/bin/bash'})
changed: [asd] => (item={'path': '/var/lib/machines/asd2/etc/shadow', 'line': 'ubuntu:!:1::::::'})

TASK [Add ubuntu user to sudoers] *****************************************************************************************************************
changed: [asd]

TASK [Create home and .ssh directories for the ubuntu user] ***************************************************************************************
changed: [asd] => (item=/var/lib/machines/asd2/home/ubuntu/)
changed: [asd] => (item=/var/lib/machines/asd2/home/ubuntu/.ssh/)

TASK [Create home and .ssh directories for root user] *********************************************************************************************
ok: [asd] => (item=/var/lib/machines/asd2/root/)
changed: [asd] => (item=/var/lib/machines/asd2/root/.ssh/)

TASK [Install authorized_keys for ubuntu and root users] ******************************************************************************************
changed: [asd] => (item={'path': '/var/lib/machines/asd2/home/ubuntu/.ssh/authorized_keys', 'owner': 1000, 'group': 1000})
changed: [asd] => (item={'path': '/var/lib/machines/asd2/root/.ssh/authorized_keys', 'owner': 0, 'group': 0})

TASK [Define default DNS server in systemd-resolved] **********************************************************************************************
changed: [asd]

TASK [Configure network interfaces lo and host0] **************************************************************************************************
changed: [asd] => (item={'dest': '/var/lib/machines/asd2/etc/network/interfaces.d/lo', 'content': 'auto lo\niface lo inet loopback\n'})
changed: [asd] => (item={'dest': '/var/lib/machines/asd2/etc/network/interfaces.d/host0', 'content': 'auto host0\niface host0 inet static\n    address 192.168.144.4/24\n    gateway 192.168.144.1\n'})

TASK [Polpulate /etc/hosts file with names of all machines for current host] **********************************************************************
changed: [asd] => (item=asd1)
changed: [asd] => (item=asd2)
changed: [asd] => (item=asd3)

TASK [Define hostname for current machine] ********************************************************************************************************
changed: [asd]

TASK [Disable DHCP for host0 interface (fix)] *****************************************************************************************************
changed: [asd]

TASK [Create directory for the machine] ***********************************************************************************************************
changed: [asd]

TASK [Unarchive cached ubuntu root filesystem] ****************************************************************************************************
changed: [asd]

TASK [Add ubuntu user and group] ******************************************************************************************************************
changed: [asd] => (item={'path': '/var/lib/machines/asd3/etc/group', 'line': 'ubuntu:x:1000:'})
changed: [asd] => (item={'path': '/var/lib/machines/asd3/etc/passwd', 'line': 'ubuntu:x:1000:1000::/home/ubuntu:/bin/bash'})
changed: [asd] => (item={'path': '/var/lib/machines/asd3/etc/shadow', 'line': 'ubuntu:!:1::::::'})

TASK [Add ubuntu user to sudoers] *****************************************************************************************************************
changed: [asd]

TASK [Create home and .ssh directories for the ubuntu user] ***************************************************************************************
changed: [asd] => (item=/var/lib/machines/asd3/home/ubuntu/)
changed: [asd] => (item=/var/lib/machines/asd3/home/ubuntu/.ssh/)

TASK [Create home and .ssh directories for root user] *********************************************************************************************
ok: [asd] => (item=/var/lib/machines/asd3/root/)
changed: [asd] => (item=/var/lib/machines/asd3/root/.ssh/)

TASK [Install authorized_keys for ubuntu and root users] ******************************************************************************************
changed: [asd] => (item={'path': '/var/lib/machines/asd3/home/ubuntu/.ssh/authorized_keys', 'owner': 1000, 'group': 1000})
changed: [asd] => (item={'path': '/var/lib/machines/asd3/root/.ssh/authorized_keys', 'owner': 0, 'group': 0})

TASK [Define default DNS server in systemd-resolved] **********************************************************************************************
changed: [asd]

TASK [Configure network interfaces lo and host0] **************************************************************************************************
changed: [asd] => (item={'dest': '/var/lib/machines/asd3/etc/network/interfaces.d/lo', 'content': 'auto lo\niface lo inet loopback\n'})
changed: [asd] => (item={'dest': '/var/lib/machines/asd3/etc/network/interfaces.d/host0', 'content': 'auto host0\niface host0 inet static\n    address 192.168.144.8/24\n    gateway 192.168.144.1\n'})

TASK [Polpulate /etc/hosts file with names of all machines for current host] **********************************************************************
changed: [asd] => (item=asd1)
changed: [asd] => (item=asd2)
changed: [asd] => (item=asd3)

TASK [Define hostname for current machine] ********************************************************************************************************
changed: [asd]

TASK [Disable DHCP for host0 interface (fix)] *****************************************************************************************************
changed: [asd]

TASK [include_tasks] ******************************************************************************************************************************
included: /stor/asd/_git/nspawn-pool/systemd.yml for asd

TASK [Install required system packages] ***********************************************************************************************************
changed: [asd]

TASK [Define br0 interface (systemd-networkd)] ****************************************************************************************************
changed: [asd] => (item={'dest': '/etc/systemd/network/br0.netdev', 'content': '[NetDev]\nName=br0\nKind=bridge\n'})

TASK [Configure br0 interface (systemd-networkd)] *************************************************************************************************
changed: [asd] => (item={'dest': '/etc/systemd/network/br0.network', 'content': '[Match]\nName=br0\n[Network]\nAddress=192.168.144.1/24\nIPForward=ipv4\nIPMasquerade=yes\nConfigureWithoutCarrier=yes\n[Link]\nActivationPolicy=always-up\n'})

TASK [Restart systemd-networkd service] ***********************************************************************************************************
changed: [asd]

TASK [Ensure systemd-networkd service is enabled and started] *************************************************************************************
ok: [asd]

TASK [Create required systemd directories] ********************************************************************************************************
changed: [asd] => (item=/etc/systemd/nspawn/)
changed: [asd] => (item=/etc/systemd/system/)

TASK [Create required systemd directories for all installed systemd-nspawn services] **************************************************************
changed: [asd] => (item=asd1)
changed: [asd] => (item=asd2)
changed: [asd] => (item=asd3)

TASK [Define all installed systemd-nspawn machines] ***********************************************************************************************
changed: [asd] => (item=asd1)
changed: [asd] => (item=asd2)
changed: [asd] => (item=asd3)

TASK [Configure all installed systemd-nspawn services] ********************************************************************************************
changed: [asd] => (item=asd1)
changed: [asd] => (item=asd2)
changed: [asd] => (item=asd3)

TASK [Reload systemd daemon] **********************************************************************************************************************
ok: [asd]

TASK [Restart all installed systemd-nspawn services] **********************************************************************************************
changed: [asd] => (item=asd1)
changed: [asd] => (item=asd2)
changed: [asd] => (item=asd3)

TASK [Ensure all installed systemd-nspawn services are started] ***********************************************************************************
changed: [asd] => (item=asd1)
changed: [asd] => (item=asd2)
changed: [asd] => (item=asd3)

PLAY RECAP ****************************************************************************************************************************************
asd                        : ok=56   changed=49   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

List containers (on a host):
```shell
$ machinectl list
MACHINE CLASS     SERVICE        OS     VERSION ADDRESSES
asd1    container systemd-nspawn ubuntu 21.04   192.168.144.2…
asd2    container systemd-nspawn ubuntu 20.04   192.168.144.4…
asd3    container systemd-nspawn ubuntu 20.04   192.168.144.8…

3 machines listed.
```
