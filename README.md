Instructions for creating docker images
---------------------------------------

First make sure you have a docker daemon running on a reachable host that exposes the REST-interface
over HTTP. On ubuntu this can be accomplished by editing the file /etc/default/docker and adding the
following values to the variable DOCKER_OPTS:

	DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"
	
Then, restart the docker daemon using: service docker restart.

For a more secure connection, the same can be accomplished using an SSH-tunnel without exposing the 
docker REST-interface to the outside world (which is a bad thing).

The docker images are built when the docker-build profile is active. This profile is automatically
activated when the docker.host variable is provided, for example:

	mvn -Ddocker.host=http://localhost:2375 package

Images are built during the package phase.

Maven creates the following docker images:

 - **cds-base**: base image for the other CDS images.
 - **cds-config**: image containing CDS configuration (the configdir).
 - **cds-postgresql**: image containing a PostgreSQL/PostGis installation containing the CDS database.
 - **cds-ldap**: image containing an OpenDS installation containing several entries that are used by the CDS.
 - **cds-tomcat**: base image for CDS tomcat instances.
 - **cds-admin**: tomcat containing admin war.
 - **cds-webservices**: tomcat containing wars for the webservices.
 - **cds-jobexecutor**: contains and executes the job-executor jar. Queries the database for new jobs to execute.
 - **cds-apache**: contains Apache vhost-configurations for the CDS.
 - **cds-cron**: cronjob to update datasets.
 
Starting CDS in Docker
----------------------

Create data volume containers:

	docker run -d -v /var/lib/postgresql --name cds-master-dbdata cds-postgresql true
	docker run -d -v /opt/OpenDS-2.2.1/db --name cds-master-ldapdata cds-ldap true
	docker run -d -v /var/lib/cds/filecache --name cds-master-filecache cds-config true
	docker run -d -v /etc/cds/workspaces --name cds-master-workspaces cds-webservices true
	
**Note**: the data volume containers contain the data that is mutated by the CDS components. With the exception of the
workspaces container this data cannot be reproduced by repeating the installation instructions. Keep this in mind when destroying
these containers!

Copy the deegree workspaces into the cds-master-workspaces volume.

	docker run --rm --volumes-from cds-master-workspaces -v /path/to/local/workspaces:/etc/cds/workspaces-src cds-base sh -c 'cp -r /etc/cds/workspaces-src/* /etc/cds/workspaces'

Create data volume container containing the CDS configdir:

	docker run --name cds-master-config cds-config
	
Create service containers:

	TODO: setup e-mail
	docker run --name cds-master-postgresql -P -d --volumes-from cds-master-dbdata cds-postgresql
	docker run --name cds-master-ldap -P -d --volumes-from cds-master-ldapdata cds-ldap
	docker run --name cds-master-admin -P -d --volumes-from cds-master-config \
		--volumes-from cds-master-filecache --link cds-master-postgresql:db \
		--link cds-master-ldap:ldap cds-admin
	docker run --name cds-master-jobexecutor -P -d --volumes-from cds-master-config \
		--volumes-from cds-master-filecache --link cds-master-postgresql:db \ 
		--link cds-master-ldap:ldap cds-job-executor
	docker run --name cds-master-webservices -P -d --volumes-from cds-master-config \
		--volumes-from cds-master-workspaces --link cds-master-postgresql:db \
		--link cds-master-ldap:ldap cds-webservices 
	docker run --name cds-master-apache -p 80:80 -d --link cds-master-admin:admin \
		--link cds-master-webservices:webservices \
		-e CDS_SERVER_NAME=vrn-test.idgis.nl \
		-e CDS_WEBSERVICES_SERVER_NAME=vrn-test-services.idgis.nl \
		-e CDS_SERVER_ADMIN=cds-support@inspire-provincies.nl \
		cds-apache
	docker run --name cds-master-cron -d --link cds-master-postgresql:db cds-cron
		
Configuration (using environment variables):

- Apache -> **CDS_SERVER_NAME**: hostname for the admin vhost.
- Apache -> **CDS_WEBSERVICES_SERVER_NAME**: hostname for the services vhost.
- Apache -> **CDS_SERVER_ADMIN**: e-mail address for the CDS server administrator.