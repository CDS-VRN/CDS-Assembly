#!/bin/sh

# Create vhost files:
cat > /etc/apache2/sites-available/cds-admin <<EOF
<VirtualHost *:80>
	ServerAdmin	$CDS_SERVER_ADMIN
	ServerName $CDS_SERVER_NAME
	
	ProxyPass /admin ajp://admin:8009/admin
	ProxyPassReverse /admin ajp://admin:8009/admin
</VirtualHost>
EOF

a2ensite cds-admin

/usr/sbin/apache2 -DFOREGROUND