Instructions for creating docker images
---------------------------------------

First make sure you have a docker daemon running on a reachable host that exposes the REST-interface
over HTTP. On ubuntu this can be accomplished by editing the file /etc/default/docker and adding the
following values to the variable DOCKER_OPTS:

	DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"
	
Then, restart the docker daemon using: service docker restart.

The docker images are built when the docker-build profile is active. This profile is automatically
activated when the docker.host variable is provided:

mvn -Ddocker.host=http://localhost:2375 package

Images are built during the package phase.

Creates the following docker images:

 - cds-base: base image for the other CDS images.
 - cds-config: image containing CDS configuration. Container name "config".
 - cds-postgresql: container name "db".
 - cds-ldap: container name "ldap".
 - cds-tomcat: base image for CDS tomcat
 - cds-admin: tomcat containing admin war. Container name "admin".
 - cds-webservices: tomcat containing webservices wars Container name "webservices".
 - cds-mail: mail server. Container name "mail".
 
Starting CDS in Docker
----------------------
docker run --name cds-master-postgresql -P -d cds-postgresql
docker run --name cds-master-ldap -P -d cds-ldap
TODO: run cds-mail
docker run --name cds-master-config --link cds-master-postgresql:db --link cds-master-ldap:ldap cds-config
docker run --name cds-master-admin -P -d --volumes-from cds-master-config --link cds-master-postgresql:db --link cds-master-ldap:ldap cds-admin
docker run --name cds-master-jobexecutor -P -d --volumes-from cds-master-config --link cds-master-postgresql:db --link cds-master-ldap:ldap cds-admin
docker run --name cds-master-webservices -P -d --volumes-from cds-master-config --link cds-master-postgresql:db --link cds-master-ldap:ldap cds-webservices 