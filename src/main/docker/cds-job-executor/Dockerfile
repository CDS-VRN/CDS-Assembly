FROM cds-base:1.0
MAINTAINER erik.orbons@idgis.nl

# Install JRE 7:
RUN apt-get update && \
	apt-get -y install \
	openjdk-7-jre
	
# Copy the job-executor:
COPY /jars/job-executor.jar /usr/share/cds/lib/

CMD [ "java", "-Xmx1536m", "-DCONFIGDIR=/etc/cds/configdir", "-cp", "/usr/share/cds/lib/job-executor.jar", "nl.ipo.cds.executor.CdsJobExecuter" ]