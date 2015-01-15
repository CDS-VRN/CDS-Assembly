#!/bin/sh

if [ ! -e /var/www/metadata ]; then
	ln -s /var/lib/cds/metadata /var/www/metadata
fi

# Create vhost files:
cat > /etc/apache2/sites-available/cds-admin <<EOF
<VirtualHost *:80>
	ServerAdmin	$CDS_SERVER_ADMIN
	ServerName $CDS_SERVER_NAME
	
	ProxyPass /admin ajp://admin:8009/admin
	ProxyPassReverse /admin ajp://admin:8009/admin
	
	DocumentRoot /var/www
	
	<Directory /var/www>
		Options FollowSymLinks -Indexes
		AllowOverride None
	</Directory>
	
	<Location /metadata>
		Options +Indexes
		Dav On
	</Location>
</VirtualHost>
EOF

echo "<VirtualHost *:80>" > /etc/apache2/sites-available/cds-webservices
echo "ServerAdmin $CDS_SERVER_ADMIN" >> /etc/apache2/sites-available/cds-webservices
echo "ServerName $CDS_WEBSERVICES_SERVER_NAME" >> /etc/apache2/sites-available/cds-webservices
for SERVICE in $CDS_SERVICES; do
	echo "ProxyPass /$SERVICE/services ajp://webservices:8009/$SERVICE/services" >> /etc/apache2/sites-available/cds-webservices
	echo "ProxyPassReverse /$SERVICE/services ajp://webservices:8009/$SERVICE/services" >> /etc/apache2/sites-available/cds-webservices
done
echo "</VirtualHost>" >> /etc/apache2/sites-available/cds-webservices

a2ensite cds-admin
a2ensite cds-webservices

/usr/sbin/apache2 -DFOREGROUND