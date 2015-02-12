FROM cds-base:1.0

ENV CDS_SERVICES ProtectedSites AgriculturalAndAquacultureFacilities AreaManagement EnvironmentalMonitoringFacilities HabitatsAndBiotopes NaturalRiskZones ProductionAndIndustrialFacilities
ENV CDS_SERVER_NAME www.inspire-provincies.nl
ENV CDS_WEBSERVICES_SERVER_NAME services.inspire-provincies.nl
ENV CDS_SERVER_ADMIN cds-support@inspire-provincies.nl

# Install Apache 2:
RUN apt-get update && \
	apt-get -y install \
		apache2

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C

ENV HTCACHECLEAN_RUN auto
ENV HTCACHECLEAN_MODE daemon
ENV HTCACHECLEAN_SIZE 300M
ENV HTCACHECLEAN_DAEMON_INTERVAL 120
ENV HTCACHECLEAN_PATH /var/cache/apache2/mod_cache_disk
		
# Enable required modules:
RUN a2enmod proxy && \
	a2enmod proxy_http && \
	a2enmod proxy_ajp && \
	a2enmod dav && \
	a2enmod dav_fs
	
# Copy init-script:
COPY /start-apache.sh /opt/start-apache.sh
RUN chmod +x /opt/start-apache.sh
RUN echo "ServerName cds-vrn-acc.geodan.nl" >> /etc/apache2/httpd.conf

VOLUME /var/log/apache2

# Start Apache:
EXPOSE 80
CMD ["/opt/start-apache.sh"]