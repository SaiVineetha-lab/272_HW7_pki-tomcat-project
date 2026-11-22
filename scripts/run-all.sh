#!/usr/bin/env bash
# Build the whole PKI (steps 1-4). Run steps 5-6 separately once Tomcat is installed.
set -euo pipefail
d="$(dirname "$0")"
bash "$d/01-root-ca.sh"
bash "$d/02-signing-ca.sh"
bash "$d/03-tls-cert.sh"
bash "$d/04-create-keystore.sh"
