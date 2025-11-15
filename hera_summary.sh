#!/bin/bash
mkdir -p /var/log/hera
OUT="/var/log/hera/security_summary_$(date +%Y%m%d_%H%M%S).txt"

{
echo "==============================="
echo "HERA SECURITY SUMMARY"
echo "Generated: $(date)"
echo "==============================="

echo
echo "[TOP PRIORITIES]"
echo "1. Check SSH failed attempts"
echo "2. Review unexpected users"
echo "3. Inspect unknown services"
echo "4. Validate cron + systemd"
echo "5. Look for recent file changes"

echo
echo "[QUICK STATUS]"

FAILED=$(grep -i "Failed" /var/log/auth.log | wc -l)
if [ $FAILED -gt 20 ]; then 
    echo "- High SSH failure volume: POSSIBLE BRUTE FORCE"
else 
    echo "- SSH failure volume normal"
fi

echo
echo "[OPEN PORTS]"
ss -tulpn | grep -vE "ssh|systemd|dns|http"

echo
echo "[RECENT CHANGES (<24h)]"
find / -mtime -1 -type f 2>/dev/null | head -n 20

echo
echo "[FINAL ASSESSMENT]"
echo "Manually review any warnings. Address open ports and recent file changes first."

} > "$OUT"

echo "Report written to $OUT"
