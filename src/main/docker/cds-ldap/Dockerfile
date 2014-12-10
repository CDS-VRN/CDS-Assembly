FROM cds-base
MAINTAINER erik.orbons@idgis.nl

# Install dependencies:
RUN apt-get update && \
	apt-get install -y \
		unzip \
		openjdk-6-jre-headless

# Copy the OpenDS binaries into the image and unzip:
COPY OpenDS-2.2.1.zip /usr/src/OpenDS/

RUN unzip -d /opt /usr/src/OpenDS/OpenDS-2.2.1.zip

# Set file permissions and run OpenDS setup:
RUN chmod u+x /opt/OpenDS-2.2.1/setup && \
	chmod u+x /opt/OpenDS-2.2.1/bin/* && \
	chmod u+x /opt/OpenDS-2.2.1/lib/*
	
# Populate OpenDS with an initial LDIF-file:
COPY ldap-ontw.ldif /usr/share/cds/ldif/

# Setup OpenDS:	
RUN /opt/OpenDS-2.2.1/setup -i -n -b dc=inspire,dc=idgis,dc=eu -D cn=admin,dc=inspire,dc=idgis,dc=eu -w admin -p 389 -a && \
	/opt/OpenDS-2.2.1/bin/ldapmodify -p 389 -h localhost -D cn=admin,dc=inspire,dc=idgis,dc=eu -w admin -a -f /usr/share/cds/ldif/ldap-ontw.ldif

EXPOSE 389

VOLUME ["/opt/OpenDS-2.2.1/logs", "/opt/OpenDS-2.2.1/config", "/opt/OpenDS-2.2.1/db"]
	
CMD ["/opt/OpenDS-2.2.1/bin/start-ds", "-N"]