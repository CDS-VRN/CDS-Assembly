FROM cds-base
MAINTAINER erik.orbons@idgis.nl

ENV CDS_MAIL_RELAY smtp.example.com
ENV DEBIAN_FRONTEND noninteractive

# Install postfix:
RUN apt-get update && \
	apt-get -y install \
		rsyslog \
		supervisor \
		postfix

COPY /install.sh /opt/install.sh
COPY /postfix.sh /opt/postfix.sh
	
# Configure postfix:
RUN postconf -e "relayhost = $CDS_MAIL_RELAY" && \
	postconf -e "smtp_sasl_auth_enable = no" && \
	postconf -e "myhostname=$CDS_MAIL_HOST" && \
	chmod u+x /opt/install.sh && \
	chmod u+x /opt/postfix.sh
	
RUN /opt/install.sh
	
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]