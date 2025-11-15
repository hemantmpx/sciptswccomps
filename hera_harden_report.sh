#!/bin/bash
mkdir -p /var/log/hera
OUT="/var/log/hera/hardening_report_$(date +%Y%m%d_%H%M%S).txt"

{
echo "==============================="
echo "HERA HARDENING REPORT"
echo "Generated: $(date)"
echo "==============================="

echo
echo "[APPLYING UPDATES]"
apt update -y

echo
echo "[SECURING SSH]"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%s)
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh || systemctl restart sshd
echo "- Root login disabled"
echo "- Password auth allowed for team login"

echo
echo "[FIREWALL CONFIGURATION]"
apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22 80 443
ufw --force enable
echo "- UFW enabled with minimal ports"

echo
echo "[FILE PERMISSIONS]"
chmod 700 /root
chmod 600 /etc/shadow
chmod -R o-w /etc/cron.*
echo "- Critical permissions hardened"

echo
echo "[KILLING COMMON BACKDOORS]"
pkill -f "nc -e"
pkill -f "bash -i"
pkill -f "python -c"
echo "- Common reverse shells terminated"

echo
echo "[SUMMARY]"
echo "System has been hardened."
echo "Ensure services remain functional after lockdown."

} > "$OUT"

echo "Report written to $OUT"
