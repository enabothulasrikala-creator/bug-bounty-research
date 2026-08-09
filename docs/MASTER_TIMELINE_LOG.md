# Master Timeline Log — All Findings & Sessions
**Researcher:** sricharan_99 (REDACTED_KNOWN_SECRET)
**Generated:** 2026-07-10
**Total Files Scanned:** 299 .md files across 25+ companies

---

## 2026-06-26 (Thu)
| Time | Company | Event | File |
|------|---------|-------|------|
| ~ | Meesho | GCS bucket discovery & bug bounty report created | `meesho_bug_bounty_report.md` |
| ~ | Meesho | Timestamp in API response: `2026-06-26T...` confirmed | `meesho_bug_bounty_report.md` |

## 2026-06-27 (Sat)
| Time | Company | Event | File |
|------|---------|-------|------|
| ~ | General | Consolidated findings report generated | `CONSOLIDATED_FINDINGS.md` |
| ~ | General | Methodology reference generated | `METHODOLOGIES.md` |

## 2026-06-28 (Sun)
| Time | Company | Event | File |
|------|---------|-------|------|
| ~ | Groww | DNS leak discovered (8 private IPs: 10.0.x.x, 10.10.x.x, 10.20.x.x, 10.30.x.x) | `FINDINGS.md` |
| ~ | Groww | SOP document exposure discovered (496KB internal PDF) | `FINDINGS.md` |
| ~ | Groww | GitHub credential leak discovered (`[REDACTED]/groww`, 3 years public) | `FINDINGS.md` |
| ~ | Groww | Actuator endpoints confirmed (403 = exists) | `FINDINGS.md` |
| ~ | Groww | `.env`/`.git/config` discovery | `FINDINGS.md` |
| ~ | Groww | BugBase config leak via `__NEXT_DATA__` | `FINDINGS.md` |
| ~ | Groww | AWS S3 endpoint discovery | `FINDINGS.md` |
| ~ | Groww | Firebase/analytics leak discovery | `FINDINGS.md` |
| ~ | Groww | TOTP secret validation in JWT payload | `FINDINGS.md` |
| ~ | Groww | CSS/JS bundle analysis (apiBaseUrl, routes) | `FINDINGS.md` |
| ~ | Groww | SOAP API endpoint discovery | `FINDINGS.md` |
| ~ | Groww | BFF (Backend for Frontend) endpoints discovered | `FINDINGS.md` |
| ~ | Tesla | Recon findings documented (3 high, 7 medium, 7 low/info) | `FINDINGS.md` |

## 2026-06-29 (Mon)
| Time | Company | Event | File |
|------|---------|-------|------|
| 07:30 AM | Acko | First Acko BugBase thread reported | `BUGBASE_THREADS.md` |
| ~ | Acko | 12 findings dated in FINDINGS.md (Bulk Operations, PII via Communications, DB Schema, Job Scheduler, MQTT, SSRF, CORS, OAuth, Segment, Actuators, Internal Endpoints) | `FINDINGS.md` |
| ~ | Acko | Findings Updated report created | `FINDINGS_UPDATED.md` |
| ~ | Acko | DB schema leak confirmed via `payin_orders` PostgreSQL error | `evidence/report_db_schema_leak.md` |

## 2026-06-30 (Tue)
| Time | Company | Event | File |
|------|---------|-------|------|
| 06:33 AM | Acko | Second BugBase thread reported (post-exploitation rebuttal) | `BUGBASE_THREADS.md` |
| ~ | Acko | Live exploit proof: created_on/updated_on timestamps at `16:33:17.082+00` | `LIVE_EXPLOIT_PROOF_53636465.md` |
| ~ | Acko | DB Schema Exploit Full Report dated "30 Jun 2026 — Still Fully Exploitable" | `DB_SCHEMA_EXPLOIT_FULL_REPORT.md` |
| ~ | Acko | Partner Portal Kong proxy discovered | `partner_portal_kong_proxy.md` |
| ~ | Acko | NEW_DISCOVERIES document created | `NEW_DISCOVERIES_30JUN2026.md` |
| ~ | Acko | Exploit Proof All Downgraded — 19:33 IST | `EXPLOIT_PROOF_ALL_DOWNGRADED.md` |
| ~ | Mygate | Full findings report created | `MYGATE_FULL_FINDINGS_REPORT.md` |
| ~ | General | MASTER_VULNERABILITY_PORTFOLIO created (baseline) | `docs/MASTER_VULNERABILITY_PORTFOLIO.md` |

## 2026-07-01 (Wed)
| Time | Company | Event | File |
|------|---------|-------|------|
| 08:23 UTC | HDFC | Subdomain discovery started | `SUBDOMAIN_DISCOVERY.md` |
| 09:02 | HDFC | `oracle.hdfc.bank.in` discovered | `HDFC_WEBLOGIC_RCE_ROOT.md` |
| 09:08 | HDFC | WebLogic REDACTED_INTERNAL_IP confirmed (EOL 2018) | `HDFC_WEBLOGIC_RCE_ROOT.md` |
| 09:09 | HDFC | CVE-2020-14882 auth bypass confirmed (200 OK) | `HDFC_WEBLOGIC_RCE_ROOT.md` |
| 09:09 | HDFC | CVE-2017-10271 RCE executed — ROOT ACCESS | `HDFC_WEBLOGIC_RCE_ROOT.md` |
| 13:51 | HDFC | Endpoint monitoring started | `ENDPOINT_CHANGES.md` |
| 14:06:15 | Acko | DB Schema Create Order (High) | `DB-SCHEMA-CREATE-ORDER.md` |
| 14:06:38 | Acko | CX360 accessible (Info) | `CX360_ACCESSIBLE.md` |
| 14:17:17 | Acko | DELETE Document IDOR | `DELETE_DOCUMENT_IDOR.md` |
| 14:41:36 | Acko | Actuator Artemis API (Medium) | `ACTUATOR-ARTEMIS-API.md` |
| 14:35:27 | Acko | DB Schema Create Order re-verified (High) | `DB-SCHEMA-CREATE-ORDER.md` |
| 14:46 | HDFC | CLO Portal initial discovery | `CLO_PORTAL_INFRASTRUCTURE_LEAK_PLUS_CSP_CORS.md` |
| 14:48 | HDFC | CSP `connect-src *` wildcard confirmed | `CLO_PORTAL_INFRASTRUCTURE_LEAK_PLUS_CSP_CORS.md` |
| 14:48 | HDFC | CORS `http://127.0.0.1:*` confirmed | `CLO_PORTAL_INFRASTRUCTURE_LEAK_PLUS_CSP_CORS.md` |
| 19:30 | HDFC | 9.9MB JS bundle analysis completed | `CLO_PORTAL_INFRASTRUCTURE_LEAK_PLUS_CSP_CORS.md` |
| 19:35 | HDFC | 80+ API endpoints, 4 applicant IDs, 3 internal envs discovered | `CLO_PORTAL_INFRASTRUCTURE_LEAK_PLUS_CSP_CORS.md` |
| ~ | Acko | Rebuttal evidence prepared (REBUTTAL_ALL_FRESH_EVIDENCE, 17:03 UTC) | `REBUTTAL_ALL_FRESH_EVIDENCE.md` |
| ~ | Acko | Payment endpoint rebuttal (transaction_timestamp: `2026-07-01T17:40:00Z`) | `rebuttal-53636465-payment-endpoints.md` |
| ~ | Acko | Job scheduler rebuttal (trigger_on: `2026-07-01`) | `rebuttal-97945332-job-scheduler.md` |
| ~ | HDFC | CLO Internal Infra Leak found | `HDFC_CLO_INTERNAL_INFRA_LEAK.md` |
| ~ | HDFC | Keycloak Production 500 discovered (HIGH — Auth DoS) | `HDFC_KEYCLOAK_PRODUCTION_500.md` |
| ~ | HDFC | GitLab CE exposed (`gitlab.hdfc.bank.in`) | `HDFC_GITLAB_CE_EXPOSED.md` |
| ~ | HDFC | IBM Aspera Enterprise exposed | `HDFC_IBM_ASPERA_ENTERPRISE_EXPOSED.md` |
| ~ | HDFC | Oracle WebLogic 10.3.6 reported | `HDFC_ORACLE_WEBLOGIC_10.3.6.md` |
| ~ | HDFC | Flutter API static analysis completed | `FLUTTER_API_ANALYSIS.md` |

## 2026-07-02 (Thu)
| Time | Company | Event | File |
|------|---------|-------|------|
| ~ | HDFC | Exploit Summary updated (Assessment Date: 2026-07-02) | `EXPLOIT_SUMMARY.md` |
| ~ | HDFC | Anumati AA API Exposure (MEDIUM) | `HDFC_ANUMATI_AA_API_EXPOSURE.md` |
| ~ | HDFC | API Gateway K8s Version Leak (MEDIUM, buildDate: `2026-05-30`) | `HDFC_API_GATEWAY_K8S_VERSION_LEAK.md` |
| ~ | HDFC | CLO Encryption Bypass (HIGH) | `HDFC_CLO_ENCRYPTION_BYPASS.md` |
| ~ | HDFC | CSP Internal Infrastructure Leak (MEDIUM) | `HDFC_CSP_INTERNAL_INFRASTRUCTURE_LEAK.md` |
| ~ | HDFC | Keycloak LDAP Injection (HIGH) | `HDFC_KEYCLOAK_LDAP_INJECTION.md` |
| ~ | HDFC | Keycloak Public Key Leak (MEDIUM) | `HDFC_KEYCLOAK_PUBLIC_KEY_LEAK.md` |

## 2026-07-03 (Fri)
| Time | Company | Event | File |
|------|---------|-------|------|
| 13:50 | Locus | S3 Config Poisoning verification started | `READY_1E_S3_Config_Poisoning.md` |
| 13:52 | Locus | Source Maps Exposure verification started | `READY_1F_Source_Maps_Exposure.md` |
| 13:54 | Locus | 51 Prototypes Exposed verification started | `READY_1G_51_Prototypes_Exposed.md` |
| 13:55 | Locus | JWT Endpoint Exposure verification started | `READY_1H_JWT_Endpoint_Exposure.md` |
| ~ | Acumen | ATTACK_CHAIN.md created | `ATTACK_CHAIN.md` |
| ~ | Acumen | EXPLOITATION.md created | `EXPLOITATION.md` |
| ~ | Acumen | RECON_REPORT.md created | `RECON_REPORT.md` |

## 2026-07-04 (Sat)
| Time | Company | Event | File |
|------|---------|-------|------|
| ~ | Locus | Design System Exposure confirmed HTTP 200 | `READY_1J_Design_System_Exposure.md` |
| ~ | Locus | S3 Writable Updated (2026) | `READY_1Z_S3_Writable_Updated_2026.md` |
| ~ | Locus | Social Media Monitoring Leak | `READY_1AA_Social_Media_Monitoring_Leak.md` |
| ~ | Locus | Alert Email Leak | `READY_1AB_Alert_Email_Leak.md` |
| ~ | Locus | All New Findings package created | `ALL_NEW_FINDINGS_2026-07-04.md` |
| ~ | Needl.ai | Hunt Session 1 (Cognito auth analysis, Grafana) | `NEEDL_AI_HUNT_SESSION.md` |
| ~ | Boat | S3 PII Warranty Leak first discovered | `BUGBASE_001` |
| ~ | Locus | MASTER_FINDINGS_LOG.md created | `MASTER_FINDINGS_LOG.md` |

## 2026-07-05 (Sun)
| Time | Company | Event | File |
|------|---------|-------|------|
| 10:30 UTC | Boat | Razorpay live key discovered in Mendix constants | `BUGBASE_005_RAZORPAY_LIVE_KEY_EXPOSURE.md` |
| 10:32 UTC | Boat | Key validated as live via Razorpay Checkout API | `BUGBASE_005_RAZORPAY_LIVE_KEY_EXPOSURE.md` |
| 10:50 UTC | Boat | SOAP endpoints discovered responding with XML | `BUGBASE_008_MENDIX_SOAP_REST_ENDPOINTS_EXPOSED.md` |
| 10:51 UTC | Boat | REST API endpoints confirmed | `BUGBASE_008_MENDIX_SOAP_REST_ENDPOINTS_EXPOSED.md` |
| 10:55 UTC | Boat | `test.boat-lifestyle.com` HTTP on port 443 discovered | `BUGBASE_006_TEST_BOAT_APACHE_NO_TLS_PORT_443.md` |
| 11:00 UTC | Boat | Laravel admin endpoints discovered (403) | `BUGBASE_007_CREWEX_LARAVEL_ADMIN_API_ENDPOINTS.md` |
| 11:01 UTC | Boat | Laravel Nova + Ignition debug routes identified | `BUGBASE_007_CREWEX_LARAVEL_ADMIN_API_ENDPOINTS.md` |
| ~ | Boat | Exploitation Data Dump — 15 Mendix constants extracted | `2026-07-05_new_exploitation_data.md` |
| ~ | Boat | POST_EXPLOIT report created | `POST_EXPLOIT_2026-07-05.md` |
| ~ | Boat | New findings session (boat-lifestyle.com) | `findings/2026-07-05/new_findings.md` |
| ~ | Acko | Analytics CORS verified (MEDIUM) — Last Verified | `VERIFIED_acko_analytics_cors_MEDIUM.md` |
| ~ | Acko | cx360v2 Actuator verified (MEDIUM) | `VERIFIED_acko_cx360v2_actuator_MEDIUM.md` |
| ~ | Acko | Employee PII via auth-saml verified (CRITICAL) | `VERIFIED_acko_employee_pii_authsaml_CRITICAL.md` |
| ~ | Acko | Fleetops CORS verified (HIGH) | `VERIFIED_acko_fleetops_cors_HIGH.md` |
| ~ | Acko | New Relic Leak verified (MEDIUM) | `VERIFIED_acko_new_relic_leak_MEDIUM.md` |
| ~ | Acko | S3 Presigned URL verified (CRITICAL) | `VERIFIED_acko_s3_presigned_url_CRITICAL.md` |
| ~ | Acko | SAML SSO Enumeration verified (HIGH) | `VERIFIED_acko_saml_sso_enumeration_HIGH.md` |
| ~ | Acko | Segment keys REJECTED (expired) | `REJECTED_acko_segment_keys_expired.md` |
| ~ | Acko | Partner portal REJECTED (WAF blocked) | `REJECTED_acko_partner_portal_WAF_BLOCKED.md` |
| ~ | Acko | Segment write key REJECTED | `REJECTED_acko_segment_write_keys.md` |
| ~ | Groww | GitHub credential leak verified (CRITICAL, last pushed `2026-04-01`) | `READY_groww_github_credential_leak_VERIFIED.md` |
| ~ | Groww | SOP document exposure verified (MEDIUM) | `READY_groww_sop_document_exposure_VERIFIED.md` |
| ~ | Groww | BugBase config leak verified (MEDIUM) | `READY_groww_bugbase_config_leak_VERIFIED.md` |
| ~ | Locus | Source code leak verified (via.sh) — Last Verified | `READY_1M_via_sh_source_code_leak_VERIFIED.md` |
| ~ | Locus | Auth bypass verified (api.locus.sh) — Last Verified | `READY_1Z_api_locus_sh_auth_bypass_VERIFIED.md` |
| ~ | Locus | S3 public write verified — Last Verified | `READY_1Z_locus_s3_public_write_VERIFIED.md` |
| ~ | Locus | DNS private IP leak SUPERSEDED (FIXED) | `SUPERSEDED_locus_dns_private_ip_leak_FIXED.md` |
| ~ | Locus | Subdomain takeover SUPERSEDED (FIXED) | `SUPERSEDED_locus_subdomain_takeover_FIXED.md` |
| ~ | Mygate | Internal IP leak verified — Last Verified | `READY_C1_mygate_internal_ip_leak_VERIFIED.md` |
| ~ | Needl.ai | Session 2 Addendum (Cognito) | `NEEDL_AI_SESSION2_ADDENDUM.md` |
| ~ | Needl.ai | Session 3 Wayback Deep Dive | `NEEDL_AI_SESSION3_WAYBACK_DEEP_DIVE.md` |
| ~ | BugBase | BUGBASE reports 005–008 submitted (Razorpay, Apache, Crewex, Mendix) | Multiple BUGBASE files |
| ~ | BugBase | Acko reports: Analytics CORS, Bumblebee Chainlit, Google Maps API, Internal API, OAuth SSO, Segment keys | Multiple BUGBASE files |
| ~ | BugBase | Groww GitHub credential leak report submitted | `BUGBASE_groww_github_credential_leak.md` |
| ~ | BugBase | Locus auth bypass report (1Z) submitted | `BUGBASE_1Z_api_locus_sh_auth_bypass.md` |

## 2026-07-06 (Mon)
| Time | Company | Event | File |
|------|---------|-------|------|
| ~ | HDFC | CBX OTL Bypass (fetch API, 20:07:29) | `CBX_OTL_Bypass_fetch_API_20260706_200729.md` |
| ~ | HDFC | CBX OTL Deep Analysis (20:08:43) | `CBX_OTL_Deep_Analysis_20260706_200843.md` |
| ~ | HDFC | ENET Internal IP Leak CORS (20:15:05) | `ENET_Internal_IP_Leak_CORS_20260706_201505.md` |
| ~ | HDFC | ENET Struts2 Dynamic Methods (20:27:07) | `ENET_Struts2_Dynamic_Methods_20260706_202707.md` |
| ~ | HDFC | CVE-2026-21962 WebLogic Testing (20:35:52) | `CVE-2026-21962_WebLogic_Testing_20260706_203552.md` |
| ~ | HDFC | ENET Login Flow Analysis (20:37:40) | `ENET_Login_Flow_Analysis_20260706_203740.md` |
| ~ | HDFC | ENET Login Hash Reverse Engineered (20:48:00) | `ENET_Login_Hash_Reverse_Engineered_20260706_204800.md` |
| ~ | HDFC | ENET Struts2 Path Traversal IHS Disclosure (21:34:29) | `ENET_Struts2_Path_Traversal_IHS_Disclosure_20260706_213429.md` |
| ~ | HDFC | ENET Public ForgotPassword Struts DMI (21:34:36) | `ENET_Public_ForgotPassword_Struts_DMI_20260706_213436.md` |
| ~ | HDFC | CBX Double Encoded Path Traversal (21:34:51) | `CBX_Double_Encoded_Path_Traversal_20260706_213451.md` |
| ~ | HDFC | Netbanking Keycloak OIDC Deep Analysis (21:39:36) | `Netbanking_Keycloak_OIDC_Deep_Analysis_20260706_213936.md` |
| ~ | HDFC | SMARTHUB Merchant User Enumeration (22:19:58) | `SMARTHUB_Merchant_User_Enumeration_20260706_221958.md` |
| ~ | HDFC | BizExpress Open Money API Disclosure (22:19:58) | `BizExpress_Open_Money_API_Disclosure_20260706_221958.md` |
| ~ | HDFC | API Portal Drupal Discovery (22:21:30) | `API_Portal_Drupal_Discovery_20260706_222130.md` |
| ~ | HDFC | OpenMoney S3 Bucket Public Access (22:34:39) | `OpenMoney_S3_Bucket_Public_Access_20260706_223439.md` |
| ~ | HDFC | SMARTHUB ForgotPassword Deep User Enum (22:34:39) | `SMARTHUB_ForgotPassword_UserEnum_Deep_20260706_223439.md` |
| ~ | HDFC | ENET Captcha Rate Limit (22:34:39) | `ENET_Captcha_Rate_Limit_20260706_223439.md` |
| ~ | HDFC | Master Findings Summary (22:41:45) | `MASTER_FINDINGS_SUMMARY_20260706_224145.md` |
| ~ | HDFC | Netbanking Keycloak Config Exposed (20:15:05) | `Netbanking_Keycloak_Config_Exposed_20260706_201505.md` |
| ~ | HDFC | Netbanking API Endpoints 168 (20:15:05) | `Netbanking_API_Endpoints_20260706_201505.md` |
| ~ | HDFC | Netbanking Rewrite Actuator Analysis (20:48:00) | `Netbanking_Rewrite_Actuator_Analysis_20260706_204800.md` |
| ~ | HDFC | CSP SSRF CBX (20:04:26) | `CSP_SSRF_CBX_20260706_200426.md` |
| ~ | HDFC | CBX Path Traversal 500 (20:08:43) | `CBX_Path_Traversal_500_20260706_200843.md` |
| ~ | HDFC | CBX iportal Accessible Assets (20:48:00) | `CBX_iportal_Accessible_Assets_20260706_204800.md` |
| ~ | HDFC | ENET Captcha SQLi Error Analysis (20:48:00) | `ENET_Captcha_SQLi_Error_Analysis_20260706_204800.md` |
| ~ | HDFC | Tech CBX BigIP (20:03:49) | `Tech_CBX_BigIP_20260706_200349.md` |
| ~ | HDFC | Tech Netbanking Rewrite (20:03:49) | `Tech_Netbanking_Rewrite_20260706_200349.md` |
| ~ | HDFC | Captcha Bypass and Login Attempts (20:39:13) | `Captcha_Bypass_and_Login_Attempts_20260706_203913.md` |
| ~ | Boat | Recon to Master Findings (boat reassessment) | `recon_2026-07-06/SUMMARY_FINDINGS.md` |
| ~ | BugBase | BUGBASE 009-014 submitted (testretailer, hearable, file upload, grafana, api.gst, dev.aihub) | Multiple BUGBASE files |

## 2026-07-07 (Tue)
| Time | Company | Event | File |
|------|---------|-------|------|
| ~ | HDFC | ENET CORS Misconfiguration (19:55:46) | `ENET_CORS_Misconfiguration_20260707_195546.md` |
| ~ | HDFC | Lastmile ForgotPassword CAPTCHA Bypass (19:55:46) | `LASTMILE_ForgotPassword_CAPTCHA_Bypass_20260707_195546.md` |
| ~ | HDFC | Full Verification Digest created | `READY_HDFC_FULL_VERIFICATION_DIGEST_20260707.md` |
| ~ | HDFC | ENET CORS internal IP leak VERIFIED | `VERIFIED_hdfc_enet_cors_internal_ip_leak_MEDIUM.md` |
| ~ | HDFC | Lastmile CAPTCHA bypass VERIFIED | `VERIFIED_hdfc_lastmile_captcha_bypass_MEDIUM.md` |

## 2026-07-09 (Thu)
| Time | Company | Event | File |
|------|---------|-------|------|
| ~ | Boat | Discounts CORS misconfig discovered + verified | `findings/2026-07-09/01_discounts_CORS_misconfig.md` |
| ~ | Boat | BulkCoupon admin panel exposed + verified | `findings/2026-07-09/02_bulkcoupon_admin_panel_exposed.md` |
| ~ | Boat | Warranty Laravel admin portal + verified | `findings/2026-07-09/03_warranty_laravel_admin_portal.md` |
| ~ | Boat | Naavik Mendix XAS SOAP exposure | `findings/2026-07-09/04_naavik_mendix_xas_soap_exposure.md` |
| ~ | Boat | Scope file fetched from BugBase | `boat_lifestyle_SCOPE.md` |
| ~ | Boat | In-Scope findings status generated | `IN_SCOPE_FINDINGS_STATUS.md` |
| ~ | Boat | README assessment date | `README.md` |
| ~ | Boat | Boat-lifestyle master report fetched | `boat-lifestyle/Support_Boat_Recon_20260709.md` |
| ~ | BugBase | BUGBASE 015-017 submitted (Discounts CORS, BulkCoupon, Warranty) | Multiple BUGBASE files |
| ~ | General | FULL_VULNERABILITY_PORTFOLIO updated (v2) | `docs/FULL_VULNERABILITY_PORTFOLIO.md` |

## 2026-07-10 (Fri)
| Time | Company | Event | File |
|------|---------|-------|------|
| 16:34:00 | Acko | EP STATUS internal_document_p (Info) | `unreported/Info_EP_STATUS__internal_document_p_20260710_163400.md` |
| 16:34:18 | Acko | EP STATUS document_metadata (Info) | `unreported/Info_EP_STATUS__document_metadata_1_20260710_163418.md` |
| 16:34:19 | Acko | EP STATUS v1_uploader_config (Info) | `unreported/Info_EP_STATUS__v1_uploader_config_20260710_163419.md` |
| 16:34:53 | Acko | New subdomain: api.acko.com (Info) | `unreported/Info_NEW_SUBDOMAIN_api_acko_com_20260710_163453.md` |
| 16:35:09 | Acko | New subdomain: app.acko.com (Info) | `unreported/Info_NEW_SUBDOMAIN_app_acko_com_20260710_163509.md` |
| 16:35:10 | Acko | New subdomain: cdn.acko.com (Info) | `unreported/Info_NEW_SUBDOMAIN_cdn_acko_com_20260710_163510.md` |
| 16:35:41 | Acko | New subdomain: static.acko.com (Info) | `unreported/Info_NEW_SUBDOMAIN_static_acko_com_20260710_163541.md` |
| 16:37:25 | Acko | S3 Presigned URL CONFIRMED (CRITICAL) | `unreported/Critical_S3_PRESIGNED_URL_CONFIRMED_20260710_163724.md` |
| 16:38:12 | Acko | EP STATUS internal_document_p (Info) | `unreported/Info_EP_STATUS__internal_document_p_20260710_163811.md` |
| 16:38:16 | Acko | EP STATUS document 1 (Info) | `unreported/Info_EP_STATUS__document_1_20260710_163816.md` |
| 16:38:18 | Acko | EP STATUS document test123 (Info) | `unreported/Info_EP_STATUS__document_test123_20260710_163818.md` |
| 16:40:18 | Acko | S3 Presigned URL CONFIRMED (CRITICAL, 2nd proof) | `unreported/Critical_S3_PRESIGNED_URL_CONFIRMED_20260710_164018.md` |
| 16:41:05 | Acko | EP STATUS internal_document_p (Info) | `unreported/Info_EP_STATUS__internal_document_p_20260710_164105.md` |

---

## Archived / Fixed (Superseded)
| Date Fixed | Company | Finding | Resolution |
|-----------|---------|---------|------------|
| 2026-07-05 | Locus | DNS Private IP Leak | Fixed by CloudFront migration |
| 2026-07-05 | Locus | Subdomain Takeover | HTTP 200 now (resolved) |
| 2026-07-05 | Acko | Segment Write Keys (2 findings) | Expired keys, rejected |
| 2026-07-05 | Acko | Partner Portal endpoints | WAF blocked |

---

## Session Activity Summary by Company

| Company | Date Range | Total Files | BugBase Reports | Verified | Rejected |
|---------|-----------|-------------|-----------------|----------|----------|
| **Acko** | 29 Jun – 10 Jul | 62 | 8 | 6 | 3 |
| **HDFC** | 01 Jul – 07 Jul | 58 | 0 | 2 | 0 |
| **Locus** | 03 Jul – 05 Jul | 28 | 1 | 3 | 2 |
| **Boat** | 04 Jul – 10 Jul | 12 | 17 | 3 | 0 |
| **Groww** | 28 Jun – 05 Jul | 13 | 2 | 3 | 0 |
| **Needl.ai** | 04 Jul – 05 Jul | 9 | 0 | 0 | 0 |
| **Mygate** | 30 Jun – 05 Jul | 2 | 0 | 1 | 0 |
| **Acumen** | 03 Jul | 3 | 0 | 0 | 0 |
| **Tesla** | 28 Jun | 5 | 0 | 0 | 0 |
| **Meesho** | 26 Jun | 3 | 0 | 0 | 0 |

---

## BugBase Report Submission Timeline

| Report # | Company | Title | Date Submitted |
|----------|---------|-------|---------------|
| 001 | Boat | S3 PII Warranty Leak | 2026-07-04 |
| 002 | Boat | Apache No TLS | 2026-07-05 |
| 003 | Boat | OTP Rate Limit | 2026-07-05 |
| 004 | Boat | GraphQL Introspection | 2026-07-05 |
| 005 | Boat | Razorpay Live Key Exposure | 2026-07-05 |
| 006 | Boat | Test Boat Apache No TLS Port 443 | 2026-07-05 |
| 007 | Boat | Crewex Laravel Admin API | 2026-07-05 |
| 008 | Boat | Mendix SOAP/REST Endpoints | 2026-07-05 |
| 009 | Boat | testretailer Laravel Debug | 2026-07-06 |
| 010 | Boat | hearable.ai FastAPI Exposed | 2026-07-06 |
| 011 | Boat | File Upload Endpoint | 2026-07-06 |
| 012 | Boat | Grafana GCP Exposed | 2026-07-06 |
| 013 | Boat | api.gst Laravel Ignition | 2026-07-06 |
| 014 | Boat | dev.aihub n8n Exposed | 2026-07-06 |
| 015 | Boat | Discounts CORS Misconfig | 2026-07-09 |
| 016 | Boat | BulkCoupon Debug API Exposed | 2026-07-09 |
| 017 | Boat | Warranty Login Error | 2026-07-09 |
| — | Locus | Auth Bypass (1Z) | 2026-07-04 |
| — | Acko | Analytics CORS | 2026-07-05 |
| — | Acko | Bumblebee Chainlit | 2026-07-05 |
| — | Acko | Google Maps API Key | 2026-07-05 |
| — | Acko | Internal API Exposure | 2026-07-05 |
| — | Acko | OAuth SSO Exposure | 2026-07-05 |
| — | Acko | Segment Write Key v2 | 2026-07-05 |
| — | Acko | Segment Write Key v3 | 2026-07-05 |
| — | Groww | GitHub Credential Leak | 2026-07-05 |

**Total BugBase Reports Submitted: 26**

---

## Post-Exploitation Timeline
| Date | Target | Activity |
|------|--------|----------|
| 2026-07-01 | WebLogic RCE (HDFC) | CVE-2017-10271 executed, root access confirmed |
| 2026-07-01 | Groww JWT | JWT decoded from leaked repo, TOTP validated (`REDACTED_KNOWN_SECRET`) |
| 2026-07-05 | Boat (Mendix) | 15+ Mendix constants extracted including Razorpay live key |
| 2026-07-05 | Acko (S3) | Pre-signed URL generation confirmed, 63K+ records in data lake |
| 2026-07-05 | Locus (S3) | Public write access confirmed on locus-api S3 bucket |
