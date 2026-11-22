# PKI Infrastructure with Root CA, Signing CA, TLS Certificate and Apache Tomcat

This project builds a two-tier Public Key Infrastructure with OpenSSL and uses it to
secure an Apache Tomcat web server with HTTPS.

It follows the **Simple PKI** design from the OpenSSL PKI Tutorial
(<https://pki-tutorial.readthedocs.io/en/latest/simple/>) and the Tomcat SSL/TLS
how-to (<https://tomcat.apache.org/tomcat-10.1-doc/ssl-howto.html>).

```
Simple Root CA  (self-signed, RSA 4096, 10 years)
   └── Simple Signing CA  (intermediate, RSA 4096, pathlen:0)
          └── www.simple.org TLS server certificate  (RSA 2048, 2 years,
                 SAN: localhost, www.simple.org, 127.0.0.1)
                    └── PKCS#12 keystore  ->  Tomcat HTTPS connector on :8443
```

## Repository layout

| Path | Purpose |
|------|---------|
| `etc/root-ca.conf` | OpenSSL config for the Root CA |
| `etc/signing-ca.conf` | OpenSSL config for the Signing CA |
| `etc/server.conf` | OpenSSL config for the TLS server certificate request |
| `scripts/01-root-ca.sh` | Create Root CA key, self-signed certificate, initial CRL |
| `scripts/02-signing-ca.sh` | Create Signing CA key and certificate signed by the Root CA |
| `scripts/03-tls-cert.sh` | Create TLS server key and certificate signed by the Signing CA |
| `scripts/04-create-keystore.sh` | Bundle key + chain into a PKCS#12 keystore |
| `scripts/05-configure-tomcat.sh` | Install keystore, `server.xml` and demo page into Tomcat |
| `scripts/06-verify.sh` | Verify HTTPS with `openssl s_client` and `curl` |
| `scripts/run-all.sh` | Run steps 1-4 |
| `scripts/clean.sh` | Delete all generated material |
| `tomcat/server.xml` | Tomcat config with the HTTPS connector |
| `tomcat/webapp/index.jsp` | Demo page showing TLS details |
| `sample-output/` | Public certificates, logs and screenshots from a real run |

Private keys, CSRs and keystores are generated locally and excluded by `.gitignore`.

## Requirements

* Linux (tested on macOS 26 with Homebrew and on Ubuntu 24.04) or macOS / WSL with OpenSSL 3.x
* Java 17+ (for Tomcat and `keytool`)
* Apache Tomcat 10.1 (`sudo apt install tomcat10`, or the tarball from tomcat.apache.org)

## Quick start (Ubuntu)

```bash
git clone https://github.com/<your-username>/pki-tomcat-project.git
cd pki-tomcat-project

# 1-4: build the PKI and the keystore
./scripts/run-all.sh

# 5: install into Tomcat and restart it
sudo apt install -y tomcat10
sudo ./scripts/05-configure-tomcat.sh
sudo systemctl restart tomcat10

# 6: verify
./scripts/06-verify.sh
```

For a Tomcat tarball install, set the paths first:

```bash
export TOMCAT_CONF=$CATALINA_HOME/conf TOMCAT_WEBAPPS=$CATALINA_HOME/webapps
./scripts/05-configure-tomcat.sh && $CATALINA_HOME/bin/catalina.sh start
```

## Trusting the Root CA in a browser

Browsers show "Your connection is not private" until the Root CA is trusted.
Import `ca/root-ca.crt` as a trusted root:

* **Windows:** double-click `root-ca.crt` → Install Certificate → Local Machine →
  *Trusted Root Certification Authorities*.
* **macOS:** open in Keychain Access → System → set *Always Trust*.
* **Linux/Chrome:** `certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "Simple Root CA" -i ca/root-ca.crt`

Then open <https://localhost:8443/>.

## Passwords

For an unattended lab run the scripts use default passwords set in
`scripts/00-common.sh` (`CA_PASS`, `KEYSTORE_PASS`). Override them with environment
variables. In a real PKI the Root CA key would be kept offline and protected by a
strong passphrase.
