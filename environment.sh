#!/usr/bin/env bash

export LC_ALL=en_US.UTF8
LC_ALL=en_US.UTF8
update-locale LANG=en_US.UTF8 LC_MESSAGES=POSIX

# Install packages:
apt-get update
apt-get install -y unzip postgresql postgresql-9.1-postgis openjdk-6-jre-headless

# Setup database:
cp /vagrant/src/main/vagrant/pg_config /opt/pg_config
chmod a+x /opt/pg_config

sudo -u postgres createdb -l en_US.UTF8 -E UTF8 template_postgis -T template0
sudo -u postgres psql -d postgres -c "UPDATE pg_database SET datistemplate = 'true' WHERE datname = 'template_postgis';"
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql
sudo -u postgres psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
sudo -u postgres psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
sudo -u postgres psql -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"

sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

/opt/pg_config 9.1 main postgresql.conf listen_addresses '*'

sudo -u postgres createdb -l en_US.UTF8 -E UTF8 -T template_postgis cds_inspire
sudo -u postgres createuser --cluster 9.1/main -D -E -i -l -R -S "inspire"
sudo -u postgres createuser --cluster 9.1/main -D -E -i -l -R -S "nagios"

sudo -u postgres psql -d cds_inspire -f /vagrant/target/sql/create-database.sql
sudo -u postgres psql -d cds_inspire -f /vagrant/target/sql/add-themes.sql

service postgresql restart

# OpenDS:
unzip -d /opt /vagrant/src/main/vagrant/OpenDS-2.2.1.zip

cp /vagrant/src/main/vagrant/opends /etc/init.d
chmod u+x /opt/OpenDS-2.2.1/setup
chmod u+x /opt/OpenDS-2.2.1/bin/*
chmod u+x /opt/OpenDS-2.2.1/lib/*
chmod a+x /etc/init.d/opends

/opt/OpenDS-2.2.1/setup -i -n -b dc=inspire,dc=idgis,dc=eu -D cn=admin,dc=inspire,dc=idgis,dc=eu -w admin -p 1389 -a
/opt/OpenDS-2.2.1/bin/ldapmodify -p 1389 -h localhost -D cn=admin,dc=inspire,dc=idgis,dc=eu -w admin -a -f /vagrant/src/main/vagrant/ldap-ontw.ldif

update-rc.d opends defaults