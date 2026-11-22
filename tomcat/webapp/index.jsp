<%@ page contentType="text/html; charset=UTF-8" import="java.security.cert.X509Certificate" %>
<!DOCTYPE html>
<html>
<head><title>Simple Inc - Secure Tomcat</title>
<style>
 body{font-family:Segoe UI,Arial,sans-serif;max-width:780px;margin:40px auto;color:#222}
 h1{color:#1a5d1a} table{border-collapse:collapse;width:100%} td{border:1px solid #ccc;padding:6px 10px}
 td:first-child{background:#f3f6f3;font-weight:600;width:35%}
</style></head>
<body>
<h1>HTTPS is working on Apache Tomcat</h1>
<p>This page is served over TLS using a certificate issued by the <b>Simple Signing CA</b>,
which is itself issued by the <b>Simple Root CA</b>.</p>
<table>
 <tr><td>Server</td><td><%= application.getServerInfo() %></td></tr>
 <tr><td>Request URL</td><td><%= request.getRequestURL() %></td></tr>
 <tr><td>Scheme / secure</td><td><%= request.getScheme() %> / <%= request.isSecure() %></td></tr>
 <tr><td>Host : port</td><td><%= request.getServerName() %> : <%= request.getServerPort() %></td></tr>
 <tr><td>TLS protocol</td><td><%= request.getAttribute("org.apache.tomcat.util.net.secure_protocol_version") %></td></tr>
 <tr><td>Cipher suite</td><td><%= request.getAttribute("jakarta.servlet.request.cipher_suite") %></td></tr>
 <tr><td>Server time</td><td><%= new java.util.Date() %></td></tr>
</table>
<p>Certificate chain: <code>www.simple.org</code> &rarr; <code>Simple Signing CA</code> &rarr; <code>Simple Root CA</code></p>
</body>
</html>
