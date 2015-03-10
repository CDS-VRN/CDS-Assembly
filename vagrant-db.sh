#!/bin/bash

set -e

# Instal PostgreSQL:
apt-get -qy update
apt-get -qy install \
	postgresql-9.1 \
	postgresql-client-9.1 \
	postgresql-9.1-postgis \
	unzip \
	openjdk-6-jre-headless

# Create template_postgis:
RESULT=$(sudo -u postgres psql -l | grep template_postgis | wc -l)
if [[ $RESULT != 1 ]]; then
	echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/9.1/main/pg_hba.conf
	echo "listen_addresses='*'" >> /etc/postgresql/9.1/main/postgresql.conf
	
	sudo -u postgres psql -c "alter user postgres with password 'postgres';"
	sudo -u postgres psql --command "CREATE USER inspire WITH PASSWORD 'inspire';"
	sudo -u postgres psql --command "CREATE USER nagios;"
	sudo -u postgres createdb -l en_US.UTF8 -E UTF8 -T template0 template_postgis
	sudo -u postgres psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';"
	sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
	sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql
	sudo -u postgres psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
	sudo -u postgres psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
	sudo -u postgres psql -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"
fi

/etc/init.d/postgresql restart

# Drop the previous databases:
RESULT=$(sudo -u postgres psql -l | grep cds_inspire_unittest | wc -l)
if [[ $RESULT == 1 ]]; then
	sudo -u postgres dropdb cds_inspire_unittest
fi

RESULT=$(sudo -u postgres psql -l | grep cds | wc -l)
if [[ $RESULT == 1 ]]; then
	sudo -u postgres dropdb cds
fi

# Create and populate the CDS database:	
sudo -u postgres createdb -l en_US.UTF8 -O inspire -E UTF8 -T template_postgis cds
sudo -u postgres createdb -l en_US.UTF8 -O inspire -E UTF8 -T template_postgis cds_inspire_unittest
sudo -u postgres psql -d cds -f /vagrant/target/sql/create-database.sql
sudo -u postgres psql -d cds_inspire_unittest -f /vagrant/target/sql/create-database.sql
sudo -u postgres psql -d cds -f /vagrant/target/sql/add-themes.sql

/etc/init.d/postgresql restart

# Setup LDAP server:
if [[ ! -d /opt/OpenDS-2.2.1 ]]; then
	unzip -d /opt /vagrant/src/main/docker/cds-ldap/OpenDS-2.2.1.zip

	cp /vagrant/src/main/docker/cds-ldap/opends /etc/init.d/opends
		
	chmod +x /opt/OpenDS-2.2.1/setup
	chmod +x /opt/OpenDS-2.2.1/bin/*
	chmod +x /opt/OpenDS-2.2.1/lib/*
	chmod +x /etc/init.d/opends
	
	/opt/OpenDS-2.2.1/setup -i -n -b dc=inspire,dc=idgis,dc=eu -D cn=admin,dc=inspire,dc=idgis,dc=eu -w admin -p 1389 -a
	/opt/OpenDS-2.2.1/bin/ldapmodify -p 1389 -h localhost -D cn=admin,dc=inspire,dc=idgis,dc=eu -w admin -a -f /vagrant/src/main/docker/cds-ldap/ldap-init.ldif
	
	update-rc.d opends defaults
	
	/etc/init.d/opends start
fi