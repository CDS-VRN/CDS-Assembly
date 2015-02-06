#!/bin/bash
DOCKER_HOST="tcp://127.0.0.1:2375"
DOCKER_CMD="docker -H ${DOCKER_HOST}"
DEPLOY_VERSION="2.2"

echo "Deploying version: ${DEPLOY_VERSION} ; host ${DOCKER_HOST}."
CURRENT_VERSION=$(${DOCKER_CMD} ps -a | grep "cds-master-postgresql" | awk 'BEGIN {FS=" "}; {print $2}' | awk 'BEGIN {FS=":"}; {print $2}')


if [[ -z "${CURRENT_VERSION}" ]]
then

  # New installation
  echo "No existing installation detected; New installation."
  ${DOCKER_CMD} run -d -v /var/lib/postgresql --name cds-master-dbdata cds-postgresql:${DEPLOY_VERSION} true
  ${DOCKER_CMD} run -d -v /opt/OpenDS-2.2.1/db --name cds-master-ldapdata cds-ldap:${DEPLOY_VERSION} true
  ${DOCKER_CMD} run -d -v /etc/cds/workspaces --name cds-master-workspaces cds-webservices:${DEPLOY_VERSION} true
  ${DOCKER_CMD} run -d -v /var/lib/cds --name cds-master-metadata cds-admin:${DEPLOY_VERSION} true

  #${DOCKER_CMD} run --rm --volumes-from cds-master-workspaces -v /path/to/local/workspaces:/etc/cds/workspaces-src cds-base sh -c 'cp -r /etc/cds/workspaces-src/* /etc/cds/workspaces'

else
  echo "Detected current version: ${CURRENT_VERSION}."


  


  echo "Stopping existing ${CURRENT_VERSION} containers..."
  # Stop all existing containers.
  ${DOCKER_CMD} stop cds-master-cron
  ${DOCKER_CMD} stop cds-master-apache
  ${DOCKER_CMD} stop cds-master-jobexecutor
  ${DOCKER_CMD} stop cds-master-ldap
  ${DOCKER_CMD} stop cds-master-postgresql

  echo "Removing existing ${CURRENT_VERSION} containers (except data only containers) ..."
  # Remove existing non-data-only containers.
  ${DOCKER_CMD} rm cds-master-cron
  ${DOCKER_CMD} rm cds-master-apache
  ${DOCKER_CMD} rm cds-master-webservices
  ${DOCKER_CMD} rm cds-master-jobexecutor
  ${DOCKER_CMD} rm cds-master-admin
  ${DOCKER_CMD} rm cds-master-ldap
  ${DOCKER_CMD} rm cds-master-postgresql
  ${DOCKER_CMD} rm cds-master-config
fi

# Start the containers. Each container can perform data container updates when needed by checking the current and deploy version.
echo "Deploying new ${DEPLOY_VERSION} containers..."

echo "Generating config from cds-config..."
${DOCKER_CMD} run --name cds-master-config -e CDS_INSPIRE_HOST=http://vrn-services.geodan.nl cds-config:${DEPLOY_VERSION}

echo "Deploying cds-postgresql..."
${DOCKER_CMD} run --name cds-master-postgresql -P -d --volumes-from cds-master-dbdata \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e CURRENT_VERSION=${CURRENT_VERSION} \
    --restart=always \
    cds-postgresql:${DEPLOY_VERSION}

echo "Deploying cds-ldap..."
${DOCKER_CMD} run --name cds-master-ldap -P -d --volumes-from cds-master-ldapdata \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e CURRENT_VERSION=${CURRENT_VERSION} \
    --restart=always \
    cds-ldap:${DEPLOY_VERSION}

echo "Deploying cds-admin..."
${DOCKER_CMD} run --name cds-master-admin -P -d --volumes-from cds-master-config \
    --volumes-from cds-master-metadata \
    --link cds-master-postgresql:db \
    --link cds-master-ldap:ldap \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e CURRENT_VERSION=${CURRENT_VERSION} \
    --restart=always \
    cds-admin:${DEPLOY_VERSION}

echo "Deploying cds-jobexecutor..."
${DOCKER_CMD} run --name cds-master-jobexecutor -P -d --volumes-from cds-master-config \
    --volumes-from cds-master-metadata \
    --link cds-master-postgresql:db \
    --link cds-master-ldap:ldap \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e CURRENT_VERSION=${CURRENT_VERSION} \
    --restart=always \
    cds-job-executor:${DEPLOY_VERSION}

echo "Deploying cds-webservices..."
${DOCKER_CMD} run --name cds-master-webservices -P -d --volumes-from cds-master-config \
    --volumes-from cds-master-workspaces \
    --link cds-master-postgresql:db \
    --volumes-from cds-master-metadata \
    --link cds-master-ldap:ldap \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e CURRENT_VERSION=${CURRENT_VERSION} \
    --restart=always \
    cds-webservices:${DEPLOY_VERSION} 

echo "Deploying cds-apache..."
${DOCKER_CMD} run --name cds-master-apache -p 80:80 -d --link cds-master-admin:admin \
    --link cds-master-webservices:webservices \
    --volumes-from cds-master-metadata \
    -e CDS_SERVER_NAME=vrn.geodan.nl \
    -e CDS_WEBSERVICES_SERVER_NAME=vrn-services.geodan.nl \
    -e CDS_SERVER_ADMIN=cds-support@inspire-provincies.nl \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e CURRENT_VERSION=${CURRENT_VERSION} \
    --restart=always \
    cds-apache:${DEPLOY_VERSION}

echo "Deploying cds-cron..."
${DOCKER_CMD} run --name cds-master-cron -d --link cds-master-postgresql:db \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e CURRENT_VERSION=${CURRENT_VERSION} \
    cds-cron:${DEPLOY_VERSION}

