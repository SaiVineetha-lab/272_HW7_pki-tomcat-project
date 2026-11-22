#!/usr/bin/env bash
# Step 1: Create the Root CA (self-signed)
source "$(dirname "$0")/00-common.sh"

step "1.1 Create directories"
mkdir -p ca/root-ca/private ca/root-ca/db crl certs
chmod 700 ca/root-ca/private

step "1.2 Create database"
cp /dev/null ca/root-ca/db/root-ca.db
cp /dev/null ca/root-ca/db/root-ca.db.attr
echo 01 > ca/root-ca/db/root-ca.crt.srl
echo 01 > ca/root-ca/db/root-ca.crl.srl

step "1.3 Create CA request (private key + CSR)"
openssl req -new \
    -config etc/root-ca.conf \
    -out ca/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key \
    -passout env:CA_PASS

step "1.4 Create CA certificate (self-signed, 10 years)"
openssl ca -selfsign -batch \
    -config etc/root-ca.conf \
    -in ca/root-ca.csr \
    -out ca/root-ca.crt \
    -extensions root_ca_ext \
    -passin env:CA_PASS

step "1.5 Create initial CRL"
openssl ca -gencrl \
    -config etc/root-ca.conf \
    -out crl/root-ca.crl \
    -passin env:CA_PASS

openssl x509 -in ca/root-ca.crt -noout -subject -issuer -dates
