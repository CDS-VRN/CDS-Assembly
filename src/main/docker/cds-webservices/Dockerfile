FROM cds-tomcat:1.0
MAINTAINER erik.orbons@idgis.nl

ENV JAVA_OPTS $JAVA_OPTS -DDEEGREE_WORKSPACE_ROOT=/etc/cds/workspaces

COPY /webapps/deegree.war /var/lib/tomcat7/webapps/AreaManagement.war
COPY /webapps/deegree.war /var/lib/tomcat7/webapps/HabitatsAndBiotopes.war
COPY /webapps/deegree.war /var/lib/tomcat7/webapps/NaturalRiskZones.war
COPY /webapps/deegree.war /var/lib/tomcat7/webapps/ProductionAndIndustrialFacilities.war
COPY /webapps/deegree.war /var/lib/tomcat7/webapps/ProtectedSites.war

COPY /webapps/deegree.war /var/lib/tomcat7/webapps/AgriculturalAndAquacultureFacilities.war
COPY /webapps/deegree.war /var/lib/tomcat7/webapps/EnvironmentalMonitoringFacilities.war