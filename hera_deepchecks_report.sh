#!/bin/bash
mkdir -p /var/log/hera
OUT="/var/log/hera/deepchecks_report_$(date +%Y%m%d_%H%M%S).txt"

{
echo "==============================="
echo "HERA DEEP SECURITY CHECKS REPORT"
echo "Generated: $(date)"
echo "==============================="

echo
echo "[SYSTEMD SERVICES]"
systemctl list-unit-files --type=service | grep enabled

echo
echo "[PERSISTENCE CHECK – CRON]"
grep -RiE "wget|curl|nc" /etc/cron* /var/spool/cron 2>/dev/null

echo
echo "[BASH HISTORY REVIEW]"
for u in $(ls /home); do
    if [ -f /home/$u/.bash_history ]; then
        echo "--- Last 20 commands of $u ---"
        tail -20 /home/$u/.bash_history
    fi
done

echo
echo "[WEBSHELL CHECK]"
grep -R "shell_exec" /var/www 2>/dev/null
grep -R "base64_decode" /var/www 2>/dev/null
grep -R "eval(" /var/www 2>/dev/null

echo
echo "[FILE CAPABILITIES]"
if command -v getcap >/dev/null 2>&1; then
    getcap -r / 2>/dev/null
fi

echo
echo "[SUMMARY]"
echo "Review findings carefully. Any unexpected cron, systemd, or web code may indicate compromise."

} > "$OUT"

echo "Report written to $OUT"
