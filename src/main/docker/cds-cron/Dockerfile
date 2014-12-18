FROM cds-base
MAINTAINER erik.orbons@idigs.nl

RUN apt-get update && \
	apt-get install -y \
		cron \
		rsyslog \
		postgresql-client-9.1
		
COPY start.sh /opt/start.sh
COPY 20-cron.conf /etc/rsyslog.d/
COPY /cron.d/* /etc/cron.d/

RUN chmod +x /opt/start.sh

# Expose cron.d as a volume:
VOLUME /etc/cron.d
		
# Run CRON in the foreground:
CMD ["/opt/start.sh"]