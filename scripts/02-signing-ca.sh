#!/usr/bin/env bash
# Step 2: Create the Signing CA (issued by the Root CA)
source "$(dirname "$0")/00-common.sh"

step "2.1 Create directories"
mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
chmod 700 ca/signing-ca/private

step "2.2 Create database"
cp /dev/null ca/signing-ca/db/signing-ca.db
cp /dev/null ca/signing-ca/db/signing-ca.db.attr
echo 01 > ca/signing-ca/db/signing-ca.crt.srl
echo 01 > ca/signing-ca/db/signing-ca.crl.srl

step "2.3 Create CA request"
openssl req -new \
    -config etc/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key \
    -passout env:CA_PASS

step "2.4 Create CA certificate (signed by Root CA, 10 years)"
openssl ca -batch \
    -config etc/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext \
    -passin env:CA_PASS

step "2.5 Create initial CRL"
openssl ca -gencrl \
    -config etc/signing-ca.conf \
    -out crl/signing-ca.crl \
    -passin env:CA_PASS

openssl x509 -in ca/signing-ca.crt -noout -subject -issuer -dates
