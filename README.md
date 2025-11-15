1. hera_enum_report.sh
Purpose:

This script performs a full, clean system enumeration and produces a structured report (not raw logs) in:

/var/log/hera/enum_report_<timestamp>.txt

What it checks:
System Info

Hostname

Kernel version

OS version

Network

All IP addresses

Routing table

Users

Lists all local users with:

username

UID

home directory

Helps catch suspicious user accounts created by the Red Team.

Sudo Privileges

Shows:

/etc/sudoers rules

/etc/sudoers.d/ overrides

This is CRITICAL — Red Team often adds NOPASSWD backdoors.

Running Processes

Shows processes sorted by start time — easy to spot long-running shells.

Listening Ports

Lists open ports and the processes running them.

Helps identify:

backdoors

reverse shells

unauthorized services

Recent File Changes (<48 hours)

Shows new or modified files, which is VERY effective for finding uploaded malware or persistence scripts.

Summary

Explains what you should review manually.

When to run:

Run this FIRST when you get the box.

2. hera_harden_report.sh
Purpose:

Applies basic safe hardening and logs each action in human-readable report:

/var/log/hera/hardening_report_<timestamp>.txt

What it does:
System Updates

Runs:

apt update


(to update package lists — safe, fast)

SSH Security

Backs up sshd_config

Disables root SSH login

Ensures PasswordAuthentication is enabled (so your team can log in)

Restarts SSH service

This closes one of the biggest CCDC attack vectors.

Firewall Setup (UFW)

Installs UFW

Denies all incoming by default

Allows essential ports:

SSH (22)

HTTP (80)

HTTPS (443)

DNS (53)

Enables firewall

This protects you without breaking typical services.

File Permissions

Secures /root

Secures /etc/shadow

Hardens cron folders

Kill Common Reverse Shells

Terminates:

nc reverse shells

bash interactive shells

python/Perl/PHP shells

When to run:

Run this immediately after hera_enum_report.sh to lock down the machine.

3. hera_deeplog_report.sh
Purpose:

Reads system logs and extracts the critical events a defender needs, generating:

/var/log/hera/deeplog_report_<timestamp>.txt

What it checks:
Authentication Events

Failed SSH attempts

Successful SSH logins
This helps detect:

brute-force

unauthorized access

System Errors

All lines containing “error” from syslog.

High Priority Journal Logs

Journalctl priority 3 (error) and above:

service failures

crashes

security problems

SSH Service Logs

Includes:

journalctl -u ssh


to show:

restarts

reconnects

suspicious changes

When to run:

Run this:

after a suspected compromise

when you see weird activity

every hour during competition

4. hera_deepchecks_report.sh
Purpose:

Performs advanced persistence hunting and produces a detailed report:

/var/log/hera/deepchecks_report_<timestamp>.txt

What it checks:
systemd Services

Lists enabled services, which is where the Red Team hides persistence such as:

evil-backdoor.service
update.service
sync.service

Cron Persistence

Searches for suspicious cron jobs containing:

wget

curl

nc

bash

python

Red Teams often plant persistence in /etc/cron*.

Bash History Review

Shows last 20 commands for each user.

Lets you see:

if a Red Teamer typed commands

if a teammate accidentally broke something

Webshell Detection

Searches /var/www for:

shell_exec

base64_decode

eval(

These are common PHP shells.

File Capabilities

Modern privilege escalation trick:

getcap -r /

When to run:

After the first 15–30 min of competition

If you suspect backdoors

After regaining control of a box

5. hera_summary.sh
Purpose:

Creates a one-page, beginner-friendly summary report:

/var/log/hera/security_summary_<timestamp>.txt

What it shows:
Top Priorities

A checklist of what to look at immediately.

Quick Status

Example:

SSH failures: HIGH (possible brute force)

Open Ports

Shows only non-standard ports so risks stand out.

Recent File Changes

Detects:

malware drops

unauthorized changes

persistence scripts

Final Assessment

A simple, readable conclusion such as:

Assessment: SAFE WITH WARNINGS  

When to run:

Run every ~30 minutes so you know if anything changed.


VPN Script
#!/bin/bash

echo "[+] Installing OpenVPN..."
apt update -y >/dev/null 2>&1
apt install -y openvpn curl wget >/dev/null 2>&1

VPN_DIR="/etc/openvpn/client"
CONFIG="$VPN_DIR/vpnbook.ovpn"
AUTH="$VPN_DIR/auth.txt"

echo "[+] Creating directories..."
mkdir -p "$VPN_DIR"

echo "[+] Downloading working VPNBook OpenVPN config..."
wget -q -O "$CONFIG" "https://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-US1.ovpn"

if [ ! -f "$CONFIG" ]; then
    echo "[!] Failed to download VPN config. Exiting."
    exit 1
fi

echo "[+] Fetching latest VPNBook password..."
PASS=$(curl -s https://www.vpnbook.com/freevpn | grep -A2 "Password" | tail -n1 | sed 's/<[^>]*>//g' | xargs)

if [ -z "$PASS" ]; then
    echo "[!] Could not retrieve VPNBook password automatically."
    exit 1
fi

echo "[+] Creating auth file..."
echo "vpnbook" > "$AUTH"
echo "$PASS" >> "$AUTH"
chmod 600 "$AUTH"

echo "[+] Updating .ovpn to use auth file..."
sed -i "s/auth-user-pass/auth-user-pass $AUTH/" "$CONFIG"

echo "[+] Starting VPN... (press CTRL+C to disconnect)"
openvpn --config "$CONFIG"

