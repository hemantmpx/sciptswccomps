#!/bin/bash
mkdir -p /var/log/hera
OUT="/var/log/hera/enum_report_$(date +%Y%m%d_%H%M%S).txt"

{
echo "==============================="
echo "HERA ENUMERATION REPORT"
echo "Generated: $(date)"
echo "==============================="

echo
echo "[SYSTEM INFORMATION]"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
if command -v lsb_release >/dev/null 2>&1; then lsb_release -d; fi

echo
echo "[NETWORK]"
ip addr show
ip route

echo
echo "[USERS]"
awk -F: '$3>=1000 {print "- " $1 " (UID " $3 ", HOME " $6 ")"}' /etc/passwd

echo
echo "[SUDO PRIVILEGES]"
grep -v '^#' /etc/sudoers
ls -al /etc/sudoers.d/

echo
echo "[RUNNING SERVICES]"
ss -tulpn

echo
echo "[RECENT FILE CHANGES (<48h)]"
find / -mtime -2 -type f 2>/dev/null | head -n 30

echo
echo "[POTENTIAL RISKS]"
echo "- Any unexpected users?"
echo "- Any unknown processes?"
echo "- Any unexpected listening ports?"

echo
echo "[SUMMARY]"
echo "Review above sections for anomalies. Focus on:"
echo "1. Unknown users"
echo "2. Unknown sudo privileges"
echo "3. Suspicious processes or ports"
echo "4. Recently modified files"

} > "$OUT"

echo "Report written to $OUT"
