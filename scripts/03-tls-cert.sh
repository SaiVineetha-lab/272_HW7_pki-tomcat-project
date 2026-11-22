#!/usr/bin/env bash
# Step 3: Create the TLS server certificate (issued by the Signing CA)
source "$(dirname "$0")/00-common.sh"
mkdir -p certs

step "3.1 Create TLS server request (SAN=$SAN)"
openssl req -new \
    -config etc/server.conf \
    -out certs/simple.org.csr \
    -keyout certs/simple.org.key

step "3.2 Create TLS server certificate (signed by Signing CA, 2 years)"
openssl ca -batch \
    -config etc/signing-ca.conf \
    -in certs/simple.org.csr \
    -out certs/simple.org.crt \
    -extensions server_ext \
    -passin env:CA_PASS

step "3.3 Create PEM bundles"
cat ca/signing-ca.crt ca/root-ca.crt > ca/signing-ca-chain.pem
cat certs/simple.org.crt ca/signing-ca-chain.pem > certs/simple.org-fullchain.pem

step "3.4 Verify the chain: TLS cert -> Signing CA -> Root CA"
openssl verify -CAfile ca/root-ca.crt -untrusted ca/signing-ca.crt certs/simple.org.crt
