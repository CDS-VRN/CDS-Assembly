FROM cds-base:1.0
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
	

# Copy LDAP schema diffs.
# 1) When deployed on a new server, the create-or-update-ldap.sh script uses the data of ldap-init.ldif
#    to create the initial LDAP schema.
# 2) When deployed on a server that has a previous version running, create-or-update-ldap.sh will look for a sequence of
#    update_<old version>_<new version>.ldif files and apply these to the LDAP database.
#    E.g. update_2.2_2.2-vrn-0.1.ldif , update_2.2-vrn-0.1_2.2-vrn-0.2.ldif to update from 2.2 to 2.2-vrn-0.2.
ADD *.ldif /usr/share/cds/ldif/
COPY init-or-update-ldap.sh /opt/init-or-update-ldap.sh
RUN chmod +x /opt/init-or-update-ldap.sh
RUN ["/bin/bash", "-c", "/opt/init-or-update-ldap.sh"]

EXPOSE 389

VOLUME ["/opt/OpenDS-2.2.1/logs", "/opt/OpenDS-2.2.1/config"]
	
CMD ["/opt/OpenDS-2.2.1/bin/start-ds", "-N"]