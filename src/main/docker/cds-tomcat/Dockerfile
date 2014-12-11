FROM cds-base
MAINTAINER erik.orbons@idgis.nl

# Install software:
RUN apt-get update && \
    apt-get install -y \
    	openjdk-7-jre \
    	tomcat7 \
    	tomcat7-user
    	
COPY run-catalina.sh /bin/

RUN chown tomcat7:tomcat7 /bin/run-catalina.sh && \
	chmod u+x /bin/run-catalina.sh

# Configure Tomcat:
# RUN echo "JAVA_OPTS=\"-Djava.awt.headless=true -Xmx2048m -XX:MaxPermSize=256m -DDEEGREE_WORKSPACE_ROOT=/etc/cds/deegree-workspace -DCONFIGDIR=/etc/cds/configdir\"" >> /etc/default/tomcat7

ENV CATALINA_BASE /var/lib/tomcat7
ENV CATALINA_HOME /usr/share/tomcat7
ENV CATALINA_TMPDIR /tmp/tomcat7-tmp
ENV PATH $CATALINA_HOME/bin:$PATH
ENV JAVA_OPTS "-Djava.awt.headless=true -Xmx2048m -XX:MaxPermSize=256m -DCONFIGDIR=/etc/cds/configdir" 

USER tomcat7

EXPOSE 8080

VOLUME /var/log/tomcat7/

CMD [ "/bin/run-catalina.sh" ]