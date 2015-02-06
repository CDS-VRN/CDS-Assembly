FROM cds-base:1.0
MAINTAINER erik.orbons@idgis.nl

# Environment variables:
ENV CDS_MAIL_FROM noreply@services.inspire-provincies.nl
ENV CDS_MAIL_HOST www.inspire-provincies.nl
ENV CDS_ETL_PGR_URL http://www.provinciaalgeoregister.nl/pgr-csw/services?request=GetRecordById&service=CSW&version=2.0.2&OUTPUTSCHEMA=http://www.isotc211.org/2005/gmd&ID=
ENV CDS_AWSTATS_URL http\://server-a.inspire-provincies.nl/awstats/awstats.pl?config\=protectedsites
ENV CDS_AWSTATS_NAMES AWstats Protected Sites
ENV CDS_MUNIN_URL https://repos.idgis.eu/munin/Inspire/server-a.inspire-provincies.nl
ENV CDS_NAGIOS_URL https://repos.idgis.eu/cgi-bin/nagios3
ENV CDS_NAGIOS_HOSTS inspire-host-a,inspire-host-b
ENV CDS_NAGIOS_HOSTGROUP inspire-hosts
ENV CDS_NAGIOS_STATUS_REGISTRY_PORT 8765
ENV CDS_NAGIOS_STATUS_SERVICE_URL rmi://repos.idgis.eu:8765/nagios-status
ENV CDS_INSPIRE_GET_FEATURE_REQUEST http://localhost/ProtectedSites/services?request=GetFeature&service=WFS&typenames=ProtectedSite
ENV CDS_INSPIRE_HOST http://services.inspire-provincies.nl

# Copy configuration:
COPY create-config.sh /bin/
COPY /config /etc/cds

RUN chmod u+x /bin/create-config.sh

# Create the filecache and metadata folders:
RUN mkdir -p /var/lib/cds/filecache

VOLUME /etc/cds

CMD [ "/bin/create-config.sh" ]