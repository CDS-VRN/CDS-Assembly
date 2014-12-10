FROM cds-base
MAINTAINER erik.orbons@idgis.nl

ADD sql/*.sql /usr/share/cds/sql/

RUN apt-get update && \
        apt-get install -y \
        postgresql-9.1 \
        postgresql-client-9.1 \
        postgresql-9.1-postgis \
        language-pack-en

# Run the remainder of the commands under the postgres user:
USER postgres

RUN echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/9.1/main/pg_hba.conf

RUN echo "listen_addresses='*'" >> /etc/postgresql/9.1/main/postgresql.conf

# Create a CDS owner, postgis template and CDS database:
RUN /etc/init.d/postgresql start && \
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


EXPOSE 5432

VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

CMD ["/usr/lib/postgresql/9.1/bin/postgres", "-D", "/var/lib/postgresql/9.1/main", "-c", "config_file=/etc/postgresql/9.1/main/postgresql.conf"]