# W0D1 Lab

sudo timedatectl set-timezone Australia/Brisbane


## Verify hostname

```
hostnamectl
```

Expected

```
luke
```

Repeat on every server.

---

## Verify IP

```
ip addr
```

Expected

```
10.1.1.10
10.1.1.11
10.1.1.12
```

---

## Verify connectivity

From every node

```
ping -c3 10.1.1.10
ping -c3 10.1.1.11
ping -c3 10.1.1.12
```

---

## Verify DNS

```
cat /etc/resolv.conf
```

---

## Verify time

```
timedatectl
```

Expected

```
System clock synchronized: yes
```

---

## Verify SSH

```
systemctl status sshd
```

Ubuntu

```
systemctl status ssh
```

---

## Verify swap

```
swapon --show
```

Expected

No output.

---

## Verify firewall

Rocky

```
systemctl status firewalld
firewall-cmd --list-all
```

Ubuntu

```
ufw status
```

---

## Verify SELinux

Rocky

```
getenforce
```

Expected

```
Permissive
```

Ubuntu

Skip.

---

## Verify kernel modules

```
lsmod | grep overlay

lsmod | grep br_netfilter
```

---

## Verify sysctl

```
sysctl net.bridge.bridge-nf-call-iptables

sysctl net.ipv4.ip_forward
```

Expected

```
1
```

---

For Ubuntu

```bash
$ grep HandleLidSwitch /etc/systemd/logind.conf
HandleLidSwitch=ignore
```

---

## Verify hosts file

```
cat /etc/hosts
```

Should contain

```
10.1.1.10 luke
10.1.1.11 han
10.1.1.12 leia
```