FROM cds-tomcat
MAINTAINER erik.orbons@idgis.nl

COPY /webapps/admin.war /var/lib/tomcat7/webapps/

USER root

RUN mkdir -p /var/lib/cds/metadata && mkdir -p /var/lib/cds/filecache && chown tomcat7:tomcat7 /var/lib/cds/metadata

USER tomcat7
