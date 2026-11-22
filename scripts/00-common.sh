#!/usr/bin/env bash
# Shared settings. Override any of these with environment variables.
set -euo pipefail
cd "$(dirname "$0")/.."              # always run from the project root
export CA_PASS="${CA_PASS:-RootSign#2026}"          # passphrase for both CA keys (lab only!)
export KEYSTORE_PASS="${KEYSTORE_PASS:-changeit}"   # PKCS#12 keystore password for Tomcat
export SAN="${SAN:-DNS:localhost,DNS:www.simple.org,IP:127.0.0.1}"
step() { echo; echo "==> $*"; }
