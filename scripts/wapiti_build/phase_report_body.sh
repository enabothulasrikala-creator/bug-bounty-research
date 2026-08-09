phase_report() {
    header "PHASE 9: REPORT GENERATION"

    timer_start

    local REPORT="$OUTDIR/reports/full_scan_report.md"
    local HTML_REPORT="$OUTDIR/reports/full_scan_report.html"
    local duration_min=$(( ($(date +%s) - START_TIME) / 60 ))

    # ---- Collect statistics (safe reads) ----
    local st_subs=$(count_lines "$OUTDIR/subs/subdomains_final.txt")
    local st_live=$(count_lines "$OUTDIR/live/live_hosts.txt")
    local st_ips=$(count_lines "$OUTDIR/live/live_ips.txt")
    local st_ports=$(count_lines "$OUTDIR/ports/ports_summary.txt")
    local st_urls=$(count_lines "$OUTDIR/urls/all_urls.txt")
    local st_js=$(count_lines "$OUTDIR/js/js_files.txt")
    local st_secrets=$(count_lines "$OUTDIR/js/secrets_found.txt")
    local st_params=$(count_lines "$OUTDIR/params/param_urls.txt")
    local st_nuclei=$(count_lines "$OUTDIR/nuclei/all_findings.txt")
    local st_wapiti=$(count_lines "$OUTDIR/wapiti/all_findings.txt")
    local st_fuzz=$(count_lines "$OUTDIR/fuzz/interesting_results.txt")
    local st_cors=$(count_lines "$OUTDIR/nuclei/cors_vuln.txt")

    # Count nuclei by severity
    local n_critical=$(grep -c '\[critical\]' "$OUTDIR/nuclei/all_findings.txt" 2>/dev/null || echo 0)
    local n_high=$(grep -c '\[high\]' "$OUTDIR/nuclei/all_findings.txt" 2>/dev/null || echo 0)
    local n_medium=$(grep -c '\[medium\]' "$OUTDIR/nuclei/all_findings.txt" 2>/dev/null || echo 0)
    local n_low=$(grep -c '\[low\]' "$OUTDIR/nuclei/all_findings.txt" 2>/dev/null || echo 0)
    local n_info=$(grep -c '\[info\]' "$OUTDIR/nuclei/all_findings.txt" 2>/dev/null || echo 0)

    # ---- Top 10 technologies ----
    local tech_list=$(head -10 "$OUTDIR/live/tech_summary.txt" 2>/dev/null || echo "N/A")

    # ---- Generate Markdown Report ----
    log "Generating Markdown report ..."
    cat > "$REPORT" << REPORTEOF
# Wapiti Improvised Scan Report

**Target:** ${DOMAIN:-Bulk Scan}
**Date:** $(date)
**Mode:** $MODE
**Duration:** ${duration_min} minutes

---

## Executive Summary

| Category | Count |
|----------|-------|
| Subdomains Discovered | $st_subs |
| Live Hosts Found | $st_live |
| Unique IPs | $st_ips |
| Open Ports | $st_ports |
| Total URLs Collected | $st_urls |
| JavaScript Files | $st_js |
| Parameterized URLs | $st_params |

## Vulnerability Summary

| Category | Count |
|----------|-------|
| **Nuclei Total** | **$st_nuclei** |
| ├ Critical | $n_critical |
| ├ High | $n_high |
| ├ Medium | $n_medium |
| ├ Low | $n_low |
| └ Info | $n_info |
| **Wapiti Findings** | **$st_wapiti** |
| **Secrets in JS** | **$st_secrets** |
| **Fuzzing Results** | **$st_fuzz** |
| **CORS Misconfigs** | **$st_cors** |

## Top Technologies Detected

\`\`\`
$tech_list
\`\`\`

---

## Detailed Findings

REPORTEOF

    # ---- Nuclei Findings ----
    if has_content "$OUTDIR/nuclei/nuclei_cve_critical.txt"; then
        echo -e "\n### Critical & High Severity CVEs\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        cat "$OUTDIR/nuclei/nuclei_cve_critical.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    if has_content "$OUTDIR/nuclei/nuclei_exposures.txt"; then
        echo -e "\n### Exposures & Misconfigurations\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        head -100 "$OUTDIR/nuclei/nuclei_exposures.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    if has_content "$OUTDIR/nuclei/nuclei_takeover.txt"; then
        echo -e "\n### Subdomain Takeover\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        cat "$OUTDIR/nuclei/nuclei_takeover.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    if has_content "$OUTDIR/nuclei/nuclei_default_logins.txt"; then
        echo -e "\n### Default Logins\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        cat "$OUTDIR/nuclei/nuclei_default_logins.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    if has_content "$OUTDIR/nuclei/cors_vuln.txt"; then
        echo -e "\n### CORS Misconfigurations\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        cat "$OUTDIR/nuclei/cors_vuln.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    # ---- Secrets ----
    if has_content "$OUTDIR/js/secrets_found.txt"; then
        echo -e "\n### Hardcoded Secrets & Credentials\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        cat "$OUTDIR/js/secrets_found.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    # ---- Wapiti findings ----
    if has_content "$OUTDIR/wapiti/all_findings.txt"; then
        echo -e "\n### Wapiti DAST Findings\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        cat "$OUTDIR/wapiti/all_findings.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    # ---- Sensitive endpoints exposed ----
    if has_content "$OUTDIR/nuclei/baseline_checks.txt"; then
        echo -e "\n### Exposed Endpoints\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        cat "$OUTDIR/nuclei/baseline_checks.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    # ---- API endpoints discovered ----
    if has_content "$OUTDIR/urls/api_endpoints.txt"; then
        echo -e "\n### API Endpoints Discovered\n" >> "$REPORT"
        echo '```' >> "$REPORT"
        head -100 "$OUTDIR/urls/api_endpoints.txt" >> "$REPORT"
        echo '```' >> "$REPORT"
    fi

    # ---- Recommendations ----
    cat >> "$REPORT" << 'RECEOF'

---

## Recommendations

### Critical Priority
1. **Rotate exposed credentials immediately** — API keys, tokens, passwords found in JS files
2. **Patch critical CVEs** identified by Nuclei scanning
3. **Fix CORS misconfigurations** — only allow specific trusted origins with proper validation
4. **Secure subdomain takeovers** — claim or remove dangling CNAME records

### High Priority
5. **Remove sensitive files** from public web roots (`.env`, `.git`, backup files)
6. **Implement proper authentication** on discovered admin panels and dashboards
7. **Add rate limiting** on API endpoints to prevent abuse and brute force
8. **Review Wapiti findings** in order of severity (Critical → High → Medium)

### Medium Priority
9. **Implement security headers** (CSP, HSTS, X-Frame-Options, X-Content-Type-Options)
10. **Enable directory listing protection** on web servers
11. **Regular security scanning** — set up automated weekly scans
12. **Review exposed endpoints** — hide actuator, debug, and info endpoints

---

*Report generated by **Wapiti Improvised v3.0** — The Ultimate All-in-One Web Security Scanner*
RECEOF

    log "Markdown report: $REPORT"

    # ---- Generate HTML Report ----
    log "Generating HTML report ..."

    # Severity coloring
    local sev_colors
    if [[ $n_critical -gt 0 ]]; then
        sev_colors="${sev_colors}.critical{color:#e94560;font-weight:bold}"
    fi
    if [[ $n_high -gt 0 ]]; then
        sev_colors="${sev_colors}.high{color:#f5a623;font-weight:bold}"
    fi

    cat > "$HTML_REPORT" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Wapiti Improvised — Scan Report</title>
<style>
  *{margin:0;padding:0;box-sizing:border-box}
  body{font-family:'SF Mono','Fira Code','Courier New',monospace;background:#0f0f23;color:#e0e0e0;padding:20px;line-height:1.6}
  h1{color:#e94560;font-size:2em;margin:20px 0;border-left:4px solid #e94560;padding-left:15px}
  h2{color:#f5a623;margin:25px 0 15px;border-bottom:2px solid #533483;padding-bottom:5px}
  h3{color:#87ceeb;margin:20px 0 10px}
  .meta{background:#16213e;padding:15px;border-radius:8px;margin:15px 0}
  .meta span{color:#f5a623}
  table{border-collapse:collapse;width:100%;margin:15px 0;font-size:0.95em}
  th,td{border:1px solid #533483;padding:10px;text-align:left}
  th{background:#533483;color:#fff;font-weight:bold}
  td{background:#1a1a3e}
  tr:hover td{background:#252550}
  pre{background:#16213e;padding:15px;border-radius:8px;overflow-x:auto;margin:10px 0;font-size:0.9em;white-space:pre-wrap;word-break:break-all}
  code{background:#16213e;padding:2px 6px;border-radius:4px;font-size:0.95em}
  .critical{color:#e94560;font-weight:bold}
  .high{color:#f5a623;font-weight:bold}
  .medium{color:#ffd700}
  .low{color:#87ceeb}
  .info{color:#7ec8e3}
  .stat-box{display:inline-block;background:#16213e;padding:20px;margin:10px;border-radius:10px;min-width:150px;text-align:center}
  .stat-box .num{font-size:2.5em;font-weight:bold;color:#e94560}
  .stat-box .label{font-size:0.85em;color:#aaa;margin-top:5px}
  .footer{text-align:center;margin-top:50px;padding:20px;color:#666;font-size:0.85em;border-top:1px solid #333}
  .grid{display:flex;flex-wrap:wrap;gap:10px}
  .warn{background:#2a1a1a;border:1px solid #e94560;padding:10px;border-radius:5px;margin:10px 0}
  .section-toggle{cursor:pointer;color:#f5a623;text-decoration:underline}
  @media(max-width:600px){.grid{flex-direction:column}.stat-box{min-width:100%}}
</style>
</head>
<body>

<h1>Wapiti Improvised — Scan Report</h1>

<div class="meta">
  <strong>Target:</strong> ${DOMAIN:-Bulk Scan}<br>
  <strong>Date:</strong> $(date)<br>
  <strong>Mode:</strong> $MODE<br>
  <strong>Duration:</strong> ${duration_min} minutes<br>
  <strong>Output:</strong> $OUTDIR
</div>

<h2>Executive Summary</h2>

<div class="grid">
  <div class="stat-box"><div class="num">$st_subs</div><div class="label">Subdomains</div></div>
  <div class="stat-box"><div class="num">$st_live</div><div class="label">Live Hosts</div></div>
  <div class="stat-box"><div class="num">$st_ips</div><div class="label">IPs</div></div>
  <div class="stat-box"><div class="num">$st_ports</div><div class="label">Open Ports</div></div>
  <div class="stat-box"><div class="num">$st_urls</div><div class="label">URLs</div></div>
  <div class="stat-box"><div class="num">$st_js</div><div class="label">JS Files</div></div>
</div>

<h2>Vulnerability Summary</h2>

<div class="grid">
  <div class="stat-box"><div class="num ${n_critical:+critical}">$n_critical</div><div class="label">Critical</div></div>
  <div class="stat-box"><div class="num ${n_high:+high}">$n_high</div><div class="label">High</div></div>
  <div class="stat-box"><div class="num">$n_medium</div><div class="label">Medium</div></div>
  <div class="stat-box"><div class="num">$n_low</div><div class="label">Low</div></div>
</div>

<table>
<tr><th>Category</th><th>Count</th></tr>
<tr><td>Nuclei Total</td><td><strong>$st_nuclei</strong></td></tr>
<tr><td>Wapiti Findings</td><td>$st_wapiti</td></tr>
<tr><td>Secrets in JS</td><td class="${st_secrets:+critical}">$st_secrets</td></tr>
<tr><td>Fuzzing Results</td><td>$st_fuzz</td></tr>
<tr><td>CORS Misconfigs</td><td class="${st_cors:+high}">$st_cors</td></tr>
<tr><td>Parameterized URLs</td><td>$st_params</td></tr>
</table>

HTMLEOF

    # Add secrets warning
    if [[ $st_secrets -gt 0 ]]; then
        cat >> "$HTML_REPORT" << 'SECEOF'
<div class="warn">
  <strong>⚠ SECRETS FOUND!</strong> Hardcoded credentials, API keys, or tokens were discovered.
  These should be rotated immediately.
</div>
SECEOF
    fi

    # Add findings sections
    if has_content "$OUTDIR/nuclei/nuclei_cve_critical.txt"; then
        echo -e "\n<h2>Critical & High CVEs</h2>\n<pre>" >> "$HTML_REPORT"
        cat "$OUTDIR/nuclei/nuclei_cve_critical.txt" >> "$HTML_REPORT"
        echo "</pre>" >> "$HTML_REPORT"
    fi

    if has_content "$OUTDIR/js/secrets_found.txt"; then
        echo -e "\n<h2>Secrets Found</h2>\n<pre>" >> "$HTML_REPORT"
        cat "$OUTDIR/js/secrets_found.txt" >> "$HTML_REPORT"
        echo "</pre>" >> "$HTML_REPORT"
    fi

    if has_content "$OUTDIR/nuclei/nuclei_takeover.txt"; then
        echo -e "\n<h2>Subdomain Takeover</h2>\n<pre>" >> "$HTML_REPORT"
        cat "$OUTDIR/nuclei/nuclei_takeover.txt" >> "$HTML_REPORT"
        echo "</pre>" >> "$HTML_REPORT"
    fi

    if has_content "$OUTDIR/nuclei/cors_vuln.txt"; then
        echo -e "\n<h2>CORS Misconfigurations</h2>\n<pre>" >> "$HTML_REPORT"
        cat "$OUTDIR/nuclei/cors_vuln.txt" >> "$HTML_REPORT"
        echo "</pre>" >> "$HTML_REPORT"
    fi

    # Tech stack
    if has_content "$OUTDIR/live/tech_summary.txt"; then
        echo -e "\n<h2>Technology Stack</h2>\n<pre>" >> "$HTML_REPORT"
        cat "$OUTDIR/live/tech_summary.txt" >> "$HTML_REPORT"
        echo "</pre>" >> "$HTML_REPORT"
    fi

    # Footer & close
    cat >> "$HTML_REPORT" << 'HTMLEOF'

<h2>Recommendations</h2>

<ol>
  <li><strong>Rotate exposed credentials</strong> immediately — any API keys, tokens, or passwords found in JavaScript files are publicly accessible</li>
  <li><strong>Patch critical and high severity CVEs</strong> identified by the Nuclei vulnerability scanner</li>
  <li><strong>Fix CORS misconfigurations</strong> — only allow specific trusted origins with proper origin validation</li>
  <li><strong>Secure subdomain takeovers</strong> — claim or remove dangling CNAME records pointing to unclaimed cloud services</li>
  <li><strong>Remove sensitive files</strong> from public web roots, including .env, .git directories, backup files, and configuration files</li>
  <li><strong>Implement proper authentication</strong> on any discovered admin panels, dashboards, and internal tools</li>
  <li><strong>Add rate limiting</strong> on authentication and API endpoints to prevent brute force and abuse</li>
  <li><strong>Review and remediate Wapiti findings</strong> in severity order (Critical → High → Medium → Low)</li>
  <li><strong>Implement security headers</strong> — Content-Security-Policy, Strict-Transport-Security, X-Frame-Options</li>
  <li><strong>Set up recurring scans</strong> — schedule automated weekly scans to catch new vulnerabilities</li>
</ol>

<div class="footer">
  Generated by Wapiti Improvised v3.0 — The Ultimate All-in-One Web Security Scanner<br>
  <em>For authorized security testing only</em>
</div>

</body>
</html>
HTMLEOF

    log "HTML report: $HTML_REPORT"
    log "Markdown report: $REPORT"

    # ---- Generate JSON Report ----
    log "Generating JSON report ..."
    local JSON_REPORT="$OUTDIR/reports/full_scan_report.json"
    {
        # Build findings array
        local json_findings="[]"
        local first=true

        # Add nuclei critical/high findings
        if has_content "$OUTDIR/nuclei/nuclei_cve_critical.txt"; then
            while IFS= read -r line; do
                if $first; then json_findings="["; first=false; else json_findings="${json_findings},"; fi
                local escaped=$(echo "$line" | sed 's/"/\\"/g')
                json_findings="${json_findings}{\"type\":\"nuclei_cve\",\"severity\":\"critical\",\"detail\":\"${escaped}\"}"
            done < "$OUTDIR/nuclei/nuclei_cve_critical.txt"
        fi

        # Add secrets
        if has_content "$OUTDIR/js/secrets_found.txt"; then
            head -20 "$OUTDIR/js/secrets_found.txt" | while IFS= read -r line; do
                escaped=$(echo "$line" | sed 's/"/\\"/g')
                jq -n --arg t "secret" --arg s "high" --arg d "$escaped" \
                    '{type: $t, severity: $s, detail: $d}' 2>/dev/null || true
            done
        fi

        # Write JSON
        cat > "$JSON_REPORT" << JSONEOF
{
  "scan_metadata": {
    "tool": "Wapiti Improvised v3.0",
    "target": "${DOMAIN:-bulk}",
    "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "mode": "$MODE",
    "duration_minutes": ${duration_min}
  },
  "statistics": {
    "subdomains": ${st_subs},
    "live_hosts": ${st_live},
    "ips": ${st_ips},
    "open_ports": ${st_ports},
    "urls_collected": ${st_urls},
    "js_files": ${st_js},
    "parameterized_urls": ${st_params}
  },
  "vulnerabilities": {
    "nuclei_total": ${st_nuclei},
    "critical": ${n_critical},
    "high": ${n_high},
    "medium": ${n_medium},
    "low": ${n_low},
    "info": ${n_info},
    "secrets": ${st_secrets},
    "cors_misconfigs": ${st_cors},
    "fuzz_interesting": ${st_fuzz}
  },
  "report_files": {
    "markdown": "$REPORT",
    "html": "$HTML_REPORT",
    "json": "$JSON_REPORT",
    "output_dir": "$OUTDIR"
  }
}
JSONEOF
    } 2>/dev/null || echo "{\"error\":\"JSON generation failed\"}" > "$JSON_REPORT"
    log "JSON report: $JSON_REPORT"

    # ---- Generate CSV Report ----
    log "Generating CSV report ..."
    local CSV_REPORT="$OUTDIR/reports/full_scan_report.csv"
    {
        echo "Category,Count,Details"
        echo "Subdomains,${st_subs},Total unique subdomains discovered"
        echo "Live Hosts,${st_live},Responding HTTP/HTTPS hosts"
        echo "Unique IPs,${st_ips},Total unique IP addresses"
        echo "Open Ports,${st_ports},All open TCP ports found"
        echo "URLs Collected,${st_urls},Total unique URLs"
        echo "JS Files,${st_js},JavaScript files discovered"
        echo "Parameterized URLs,${st_params},URLs containing query parameters"
        echo "Nuclei Total,${st_nuclei},All Nuclei findings combined"
        echo "Critical CVEs,${n_critical},Critical and High severity CVEs"
        echo "Secrets Found,${st_secrets},Hardcoded credentials in JS"
        echo "CORS Misconfigs,${st_cors},Reflective/wildcard CORS issues"
        echo "Fuzzing Interesting,${st_fuzz},HTTP 200/401/403 fuzz results"

        # Add nuclei findings as rows
        if has_content "$OUTDIR/nuclei/nuclei_cve_critical.txt"; then
            while IFS= read -r line; do
                local escaped=$(echo "$line" | sed 's/"/""/g')
                echo "Critical CVE,,${escaped}"
            done < "$OUTDIR/nuclei/nuclei_cve_critical.txt"
        fi
        if has_content "$OUTDIR/nuclei/cors_vuln.txt"; then
            while IFS= read -r line; do
                local escaped=$(echo "$line" | sed 's/"/""/g')
                echo "CORS Issue,,${escaped}"
            done < "$OUTDIR/nuclei/cors_vuln.txt"
        fi
    } > "$CSV_REPORT" 2>/dev/null || true
    log "CSV report: $CSV_REPORT"

    log "Report generation complete."

    # ---- Save scan state for diffing ----
    save_diff_state

    # ---- Send final notification ----
    local total_findings=$(( st_nuclei + st_secrets + st_fuzz + st_cors ))
    if [[ $total_findings -gt 0 ]]; then
        send_notification "Scan COMPLETE for ${DOMAIN:-bulk}. ${total_findings} total findings. Report: ${OUTDIR}/reports/full_scan_report.html" "critical"
    else
        send_notification "Scan complete for ${DOMAIN:-bulk}. No findings detected." "info"
    fi

    local elapsed=$(timer_end)
    log "Phase 9 complete in ${elapsed}"
}# ============================================================================# PART 19: MAIN EXECUTION ENGINE
