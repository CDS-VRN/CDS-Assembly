#!/bin/sh

echo "Generating CDS configuration ..."

# Create dataSource properties:
echo "jdbc.driverClassName=org.postgresql.Driver" > /etc/cds/configdir/nl/ipo/cds/dao/dataSource.properties
echo "jdbc.dburl=jdbc:postgresql://db:5432/cds" >> /etc/cds/configdir/nl/ipo/cds/dao/dataSource.properties
echo "jdbc.username=inspire" >> /etc/cds/configdir/nl/ipo/cds/dao/dataSource.properties
echo "jdbc.password=inspire" >> /etc/cds/configdir/nl/ipo/cds/dao/dataSource.properties
echo "ldap.ldapbase=dc=inspire,dc=idgis,dc=eu" >> /etc/cds/configdir/nl/ipo/cds/dao/dataSource.properties
echo "ldap.ldapurl=ldap\://ldap:389/dc=inspire,dc=idgis,dc=eu" >> /etc/cds/configdir/nl/ipo/cds/dao/dataSource.properties
echo "ldap.managerdn=cn=admin,dc=inspire,dc=idgis,dc=eu" >> /etc/cds/configdir/nl/ipo/cds/dao/dataSource.properties
echo "ldap.managerpw=admin" >> /etc/cds/configdir/nl/ipo/cds/dao/dataSource.properties

# Create ETL properties:
echo "pgrBaseUrl=$CDS_ETL_PGR_URL" > /etc/cds/configdir/nl/ipo/cds/etl/etl.properties
echo "cdsFileCacheRoot=/var/lib/cds/filecache" >> /etc/cds/configdir/nl/ipo/cds/etl/etl.properties
echo "numberOfThreads=10" >> /etc/cds/configdir/nl/ipo/cds/etl/etl.properties
echo "mail.smtpHost=mail" >> /etc/cds/configdir/nl/ipo/cds/etl/etl.properties
echo "mail.smtpPort=25" >> /etc/cds/configdir/nl/ipo/cds/etl/etl.properties
echo "mail.from=$CDS_MAIL_FROM" >> /etc/cds/configdir/nl/ipo/cds/etl/etl.properties
echo "mail.host=$CDS_MAIL_HOST" >> /etc/cds/configdir/nl/ipo/cds/etl/etl.properties

# Create metadata properties:
echo "metadataFolder=/var/lib/cds/metadata" > /etc/cds/configdir/nl/ipo/cds/metadata/manager.properties

# Create monitoring properties:
echo "awstatsUrls=$CDS_AWSTATS_URL" > /etc/cds/configdir/nl/ipo/cds/monitoring/monitoring.properties
echo "awstatsNames=$CDS_AWSTATS_NAMES" >> /etc/cds/configdir/nl/ipo/cds/monitoring/monitoring.properties
echo "muninUrl=$CDS_MUNIN_URL" >> /etc/cds/configdir/nl/ipo/cds/monitoring/monitoring.properties
echo "nagiosUrl=$CDS_NAGIOS_URL" >> /etc/cds/configdir/nl/ipo/cds/monitoring/monitoring.properties
echo "nagiosHosts=$CDS_NAGIOS_HOSTS" >> /etc/cds/configdir/nl/ipo/cds/monitoring/monitoring.properties
echo "nagiosHostgroup=$CDS_NAGIOS_HOSTGROUP" >> /etc/cds/configdir/nl/ipo/cds/monitoring/monitoring.properties
echo "nagiosStatusRegistryPort=$CDS_NAGIOS_STATUS_REGISTRY_PORT" >> /etc/cds/configdir/nl/ipo/cds/monitoring/monitoring.properties
echo "nagiosStatusServiceUrl=$CDS_NAGIOS_STATUS_SERVICE_URL" >> /etc/cds/configdir/nl/ipo/cds/monitoring/monitoring.properties

# Create webservices properties:
echo "inspireGetFeatureRequest=$CDS_INSPIRE_GET_FEATURE_REQUEST" > /etc/cds/configdir/nl/ipo/cds/webservices/webservices.properties
echo "inspireHost=$CDS_INSPIRE_HOST" >> /etc/cds/configdir/nl/ipo/cds/webservices/webservices.properties
echo "inspireGetCapabilitiesRequestTemplate=request=GetCapabilities" >> /etc/cds/configdir/nl/ipo/cds/webservices/webservices.properties
echo "inspireGetCapabilitiesRequestWMSVersion=1.3.0" >> /etc/cds/configdir/nl/ipo/cds/webservices/webservices.properties
echo "inspireGetCapabilitiesRequestWFSVersion=2.0.0" >> /etc/cds/configdir/nl/ipo/cds/webservices/webservices.properties