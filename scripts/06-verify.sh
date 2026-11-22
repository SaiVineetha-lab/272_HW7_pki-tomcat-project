#!/usr/bin/env bash
# Step 6: Verify the HTTPS server presents our certificate chain
source "$(dirname "$0")/00-common.sh"
HOST="${HOST:-localhost}"; PORT="${PORT:-8443}"

step "6.1 TLS handshake with openssl s_client (trusting only our Root CA)"
echo | openssl s_client -connect "$HOST:$PORT" -servername "$HOST" \
    -CAfile ca/root-ca.crt -showcerts 2>/dev/null \
    | grep -E "^ *[0-9] s:|^ *i:|Verify return code|Protocol|Cipher is" 

step "6.2 HTTPS request with curl (trusting only our Root CA)"
curl -sS --noproxy "*" --cacert ca/root-ca.crt "https://$HOST:$PORT/" | sed -n 's:.*<h1>\(.*\)</h1>.*:\1:p'
curl -sS --noproxy "*" -o /dev/null -w "HTTP status: %{http_code}, TLS verify result: %{ssl_verify_result} (0 = OK)\n" \
    --cacert ca/root-ca.crt "https://$HOST:$PORT/"

step "6.3 Same request WITHOUT trusting our Root CA (should fail)"
curl -sS --noproxy "*" "https://$HOST:$PORT/" -o /dev/null 2>&1 || true
