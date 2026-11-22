#!/usr/bin/env bash
# Remove all generated keys, certificates and CA databases
cd "$(dirname "$0")/.." && rm -rf ca crl certs && echo "Cleaned."
