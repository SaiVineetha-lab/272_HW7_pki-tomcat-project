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

## Troubleshooting

| Problem | Likely cause | Fix |
|---------|--------------|-----|
| `openssl version` prints `LibreSSL` on macOS | The built-in macOS `openssl` is LibreSSL, not OpenSSL 3 | `brew install openssl@3` and put `$(brew --prefix openssl@3)/bin` first in `PATH` |
| `unable to load CA private key` / `bad decrypt` | `CA_PASS` is different from the run that created the CA keys | Use the same `CA_PASS`, or run `./scripts/clean.sh` and rebuild with `./scripts/run-all.sh` |
| `openssl verify` does not print `OK` | Signing CA or Root CA was rebuilt after the TLS cert was issued | Run `./scripts/clean.sh`, then `./scripts/run-all.sh` so the whole chain is issued again |
| Tomcat does not listen on 8443, log says `keystore password was incorrect` | `KEYSTORE_PASS` used in step 4 and step 5 do not match | Export the same `KEYSTORE_PASS` and rerun steps 4 and 5 |
| `Address already in use` for 8443 or 8080 | Another Tomcat or app already holds the port | `lsof -i :8443` to find it, stop it, then restart Tomcat |
| Tomcat log shows `Permission denied` on `simple.org.p12` (Ubuntu) | The `tomcat` user cannot read the keystore | `sudo chgrp tomcat /etc/tomcat10/simple.org.p12 && sudo chmod 640 /etc/tomcat10/simple.org.p12` |
| Browser shows `NET::ERR_CERT_COMMON_NAME_INVALID` | The host name you typed is not in the certificate's SAN | Use `localhost`, `127.0.0.1` or `www.simple.org`, or set `SAN=...` and rerun steps 3, 4 and 5 |
| Chrome still warns after trusting the Root CA | Chrome caches certificate state | Quit Chrome fully (Cmd+Q on macOS) and open it again |
| Firefox still warns after trusting the Root CA | Firefox uses its own certificate store | Import `ca/root-ca.crt` under Settings → Privacy & Security → Certificates → Authorities |
| `curl: (60) self signed certificate in certificate chain` | curl does not trust our Root CA | Expected without `--cacert ca/root-ca.crt`; step 6.3 tests exactly this |

To check what Tomcat is actually serving, run:

```bash
echo | openssl s_client -connect localhost:8443 -CAfile ca/root-ca.crt -showcerts
```

You should see three certificates and `Verify return code: 0 (ok)`.
