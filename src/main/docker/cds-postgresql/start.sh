#!/bin/bash
# TODO: ADD UPDATE sequence, CREATE only now.

/etc/init.d/postgresql start


# If no data present, create new data in external data volume (/var/lib/postgresql).


psql --command "CREATE USER inspire WITH PASSWORD 'inspire';" && \
psql --command "CREATE USER nagios;" && \
createdb -l en_US.UTF8 -E UTF8 -T template0 template_postgis && \
psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';" && \
psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql && \
psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql && \
psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;" && \
psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;" && \
psql -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;" && \
createdb -l en_US.UTF8 -O inspire -E UTF8 -T template_postgis cds && \
psql -d cds -f /usr/share/cds/sql/create-database.sql && \
psql -d cds -f /usr/share/cds/sql/add-themes.sql


# If previous version present, and previous version does not equal version to be deployed, check for database
# structure updates to be applied.


/etc/init.d/postgresql stop

# Always start (non-daemon/blocking) PostgreSQL process.
/usr/lib/postgresql/9.1/bin/postgres -D /var/lib/postgresql/9.1/main \
-c config_file=/etc/postgresql/9.1/main/postgresql.conf
