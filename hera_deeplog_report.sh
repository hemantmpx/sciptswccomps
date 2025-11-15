#!/bin/bash
mkdir -p /var/log/hera
OUT="/var/log/hera/deeplog_report_$(date +%Y%m%d_%H%M%S).txt"

{
echo "==============================="
echo "HERA DEEP LOG REPORT"
echo "Generated: $(date)"
echo "==============================="

echo
echo "[RECENT AUTH EVENTS]"
grep -i "Failed" /var/log/auth.log | tail -n 15
grep -i "Accepted" /var/log/auth.log | tail -n 15

echo
echo "[SYSTEM ERRORS]"
grep -i "error" /var/log/syslog | tail -n 20

echo
echo "[HIGH PRIORITY LOGS]"
journalctl -p 3 -xb | head -n 30

echo
echo "[SSH LOGS]"
journalctl -u ssh -n 40

echo
echo "[SUMMARY]"
echo "Check above for:"
echo "- Unauthorized SSH attempts"
echo "- Repeated failures"
echo "- Errors or warnings"
echo "- Unexpected service events"

} > "$OUT"

echo "Report written to $OUT"
