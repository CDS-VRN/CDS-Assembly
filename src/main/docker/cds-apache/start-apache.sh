#!/bin/sh

if [ ! -e /var/www/metadata ]; then
	ln -s /var/lib/cds/metadata /var/www/metadata
fi


# Create vhost file.
# ServerNames cannot be identical or only the first virtualhost is being matched.
# Therefore we just create one vhost file. We do not restart apache on virtual host level anyway.

echo "<VirtualHost *:80>" > /etc/apache2/sites-available/cds
echo "ServerAdmin $CDS_SERVER_ADMIN" >> /etc/apache2/sites-available/cds
echo "ServerName $CDS_SERVER_NAME" >> /etc/apache2/sites-available/cds
for SERVICE in $CDS_SERVICES; do
	echo "ProxyPass /$SERVICE/services ajp://webservices:8009/$SERVICE/services" >>/etc/apache2/sites-available/cds
	echo "ProxyPassReverse /$SERVICE/services ajp://webservices:8009/$SERVICE/services">>/etc/apache2/sites-available/cds
done
echo "ProxyPass /risicokaart-export ajp://webservices:8009/risicokaart-export" >> /etc/apache2/sites-available/cds
echo "ProxyPassReverse /risicokaart-export ajp://webservices:8009/risicokaart-export" >> /etc/apache2/sites-available/cds

cat >> /etc/apache2/sites-available/cds <<EOF

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

a2ensite cds
a2dissite default

/usr/sbin/apache2 -DFOREGROUND