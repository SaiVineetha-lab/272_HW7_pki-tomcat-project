#!/usr/bin/env bash
# Step 5: Install the keystore and HTTPS connector into Tomcat
# TOMCAT_CONF = Tomcat's conf directory (Ubuntu package: /etc/tomcat10,
#               tarball install: $CATALINA_HOME/conf)
# TOMCAT_WEBAPPS = webapps directory (Ubuntu: /var/lib/tomcat10/webapps)
source "$(dirname "$0")/00-common.sh"
TOMCAT_CONF="${TOMCAT_CONF:-/etc/tomcat10}"
TOMCAT_WEBAPPS="${TOMCAT_WEBAPPS:-/var/lib/tomcat10/webapps}"

step "5.1 Copy keystore into $TOMCAT_CONF"
cp certs/simple.org.p12 "$TOMCAT_CONF/simple.org.p12"
chmod 640 "$TOMCAT_CONF/simple.org.p12"
chgrp tomcat "$TOMCAT_CONF/simple.org.p12" 2>/dev/null || true

step "5.2 Install server.xml with HTTPS connector on port 8443"
[ -f "$TOMCAT_CONF/server.xml.orig" ] || cp "$TOMCAT_CONF/server.xml" "$TOMCAT_CONF/server.xml.orig"
sed "s/@KEYSTORE_PASS@/$KEYSTORE_PASS/" tomcat/server.xml > "$TOMCAT_CONF/server.xml"

step "5.3 Deploy demo page"
mkdir -p "$TOMCAT_WEBAPPS/ROOT"
cp tomcat/webapp/index.jsp "$TOMCAT_WEBAPPS/ROOT/index.jsp"
rm -f "$TOMCAT_WEBAPPS/ROOT/index.html"
echo "Done. Restart Tomcat, then browse to https://localhost:8443/"
