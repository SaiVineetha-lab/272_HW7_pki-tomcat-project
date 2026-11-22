#!/usr/bin/env bash
# Step 4: Bundle key + certificate chain into a PKCS#12 keystore for Tomcat
source "$(dirname "$0")/00-common.sh"

step "4.1 Create PKCS#12 keystore (key + TLS cert + Signing CA + Root CA)"
openssl pkcs12 -export \
    -name tomcat \
    -inkey certs/simple.org.key \
    -in certs/simple.org.crt \
    -certfile ca/signing-ca-chain.pem \
    -out certs/simple.org.p12 \
    -passout env:KEYSTORE_PASS

step "4.2 List keystore contents with keytool"
keytool -list -v -storetype PKCS12 -keystore certs/simple.org.p12 \
    -storepass "$KEYSTORE_PASS" | grep -E "Alias name|Certificate chain length|^Owner|^Issuer|^Certificate\[" 
