FROM cds-base:1.0
MAINTAINER erik.orbons@idgis.nl


RUN apt-get update && \
        apt-get install -y \
        postgresql-9.1 \
        postgresql-client-9.1 \
        postgresql-9.1-postgis \
        language-pack-en


# Copy database schema scripts into image volume.
# 1) When deployed on a new server, the start.sh file uses the data of create-db.sql and add-themes.sql
#    to create the initial database schema.
# 2) When deployed on a server that has a previous version running, start.sh will look for a sequence of
#    update_<old version>_<new version>.sql files and apply these to the database.
#    E.g. update_2.2_2.2-vrn-0.1.sql , update_2.2-vrn-0.1_2.2-vrn-0.2.sql to update from 2.2 to 2.2-vrn-0.2.
ADD sql/*.sql /usr/share/cds/sql/
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

# Run the remainder of the commands under the postgres user:
USER postgres

RUN echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/9.1/main/pg_hba.conf

RUN echo "listen_addresses='*'" >> /etc/postgresql/9.1/main/postgresql.conf


EXPOSE 5432

VOLUME ["/etc/postgresql", "/var/log/postgresql"]

CMD ["/bin/bash", "-c", "/opt/start.sh"]

