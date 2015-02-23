#!/bin/bash

set -e

if [[ $# < 3 ]]
then

    echo "Insufficient arguments provided, required: <settings file> <docker host address tcp://127.0.0.1:2375> <deploy version> [<version to upgrade from if different from currently running>]"
    exit 1
fi
SETTINGS_FILE=$1
DOCKER_HOST=$2
DOCKER_CMD="docker -H ${DOCKER_HOST}"
DEPLOY_VERSION=$3

echo "Loading settings from $SETTINGS_FILE ..."
source $SETTINGS_FILE

echo "Deploying version: ${DEPLOY_VERSION} ; host ${DOCKER_HOST}."
CURRENT_VERSION=$(${DOCKER_CMD} ps -a | grep "cds-master-admin" | awk 'BEGIN {FS=" "}; {print $NF}' | awk 'BEGIN {FS="_"}; {print $2}')


# Note that we can upgrade from a different version that the currently running in case of an error after deploying, we are already running the newer version but we want to still upgrade from the previous in order to run the fixed update scripts for the database and LDAP.
if [[ $# > 3 ]]
then
    PREV_VERSION=$4
else
    PREV_VERSION=${CURRENT_VERSION}
fi
echo "Upgrading from version ${PREV_VERSION}"

echo "Running containers before upgrade:"
${DOCKER_CMD} ps -a

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
  ${DOCKER_CMD} stop cds-master-cron_${CURRENT_VERSION}
  ${DOCKER_CMD} stop cds-master-apache_${CURRENT_VERSION}
  ${DOCKER_CMD} stop cds-master-webservices_${CURRENT_VERSION}
  ${DOCKER_CMD} stop cds-master-jobexecutor_${CURRENT_VERSION}
  ${DOCKER_CMD} stop cds-master-admin_${CURRENT_VERSION}
  ${DOCKER_CMD} stop cds-master-ldap_${CURRENT_VERSION}
  ${DOCKER_CMD} stop cds-master-postgresql_${CURRENT_VERSION}

  echo "Removing existing ${CURRENT_VERSION} containers (except data only containers) ..."
  # Remove existing non-data-only containers.

  ${DOCKER_CMD} rm cds-master-cron_${CURRENT_VERSION}
  ${DOCKER_CMD} rm cds-master-apache_${CURRENT_VERSION}
  ${DOCKER_CMD} rm cds-master-webservices_${CURRENT_VERSION}
  ${DOCKER_CMD} rm cds-master-jobexecutor_${CURRENT_VERSION}
  ${DOCKER_CMD} rm cds-master-admin_${CURRENT_VERSION}
  ${DOCKER_CMD} rm cds-master-ldap_${CURRENT_VERSION}
  ${DOCKER_CMD} rm cds-master-postgresql_${CURRENT_VERSION}
  ${DOCKER_CMD} rm cds-master-config_${CURRENT_VERSION}

fi

# Start the containers. Each container can perform data container updates when needed by checking the current and deploy version.
echo "Deploying new ${DEPLOY_VERSION} containers..."

echo "Generating config from cds-config..."
${DOCKER_CMD} run \
	--name cds-master-config_${DEPLOY_VERSION} \
	-e CDS_ADMIN_REQUEST_AUTHORIZATION_PROMPT="$CDS_ADMIN_REQUEST_AUTHORIZATION_PROMPT" \
	-e CDS_ADMIN_REQUEST_AUTHORIZATION_HREF="$CDS_ADMIN_REQUEST_AUTHORIZATION_HREF" \
	-e CDS_MAIL_FROM="$CDS_MAIL_FROM" \
	-e CDS_MAIL_HOST="$CDS_MAIL_HOST" \
	-e CDS_ETL_PGR_URL="$CDS_ETL_PGR_URL" \
	-e CDS_AWSTATS_URL="$CDS_AWSTATS_URL" \
	-e CDS_AWSTATS_NAMES="$CDS_AWSTATS_NAMES" \
	-e CDS_MUNIN_URL="$CDS_MUNIN_URL" \
	-e CDS_NAGIOS_URL="$CDS_NAGIOS_URL" \
	-e CDS_NAGIOS_HOSTS="$CDS_NAGIOS_HOSTS" \
	-e CDS_NAGIOS_HOSTGROUP="$CDS_NAGIOS_HOSTGROUP" \
	-e CDS_NAGIOS_STATUS_REGISTRY_PORT="$CDS_NAGIOS_STATUS_REGISTRY_PORT" \
	-e CDS_NAGIOS_STATUS_SERVICE_URL="$CDS_NAGIOS_STATUS_SERVICE_URL" \
	-e CDS_INSPIRE_GET_FEATURE_REQUEST="$CDS_INSPIRE_GET_FEATURE_REQUEST" \
	-e CDS_INSPIRE_HOST="$CDS_INSPIRE_HOST" \
	cds-config:${DEPLOY_VERSION}

echo "Deploying cds-postgresql..."
${DOCKER_CMD} run --name cds-master-postgresql_${DEPLOY_VERSION} -P -d --volumes-from cds-master-dbdata \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e PREV_VERSION=${PREV_VERSION} \
    --restart=always \
    cds-postgresql:${DEPLOY_VERSION}

echo "Deploying cds-ldap..."
${DOCKER_CMD} run --name cds-master-ldap_${DEPLOY_VERSION} -P -d --volumes-from cds-master-ldapdata \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e PREV_VERSION=${PREV_VERSION} \
    --restart=always \
    cds-ldap:${DEPLOY_VERSION}

echo "Deploying cds-admin..."
${DOCKER_CMD} run --name cds-master-admin_${DEPLOY_VERSION} -P -d --volumes-from cds-master-config_${DEPLOY_VERSION} \
    --volumes-from cds-master-metadata \
    --link cds-master-postgresql_${DEPLOY_VERSION}:db \
    --link cds-master-ldap_${DEPLOY_VERSION}:ldap \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e PREV_VERSION=${PREV_VERSION} \
    --restart=always \
    cds-admin:${DEPLOY_VERSION}

echo "Deploying cds-jobexecutor..."
${DOCKER_CMD} run --name cds-master-jobexecutor_${DEPLOY_VERSION} -P -d --volumes-from cds-master-config_${DEPLOY_VERSION} \
    --volumes-from cds-master-metadata \
    --link cds-master-postgresql_${DEPLOY_VERSION}:db \
    --link cds-master-ldap_${DEPLOY_VERSION}:ldap \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e PREV_VERSION=${PREV_VERSION} \
    --restart=always \
    cds-job-executor:${DEPLOY_VERSION}

echo "Deploying cds-webservices..."
${DOCKER_CMD} run --name cds-master-webservices_${DEPLOY_VERSION} -P -d --volumes-from cds-master-config_${DEPLOY_VERSION} \
    --volumes-from cds-master-workspaces \
    --link cds-master-postgresql_${DEPLOY_VERSION}:db \
    --volumes-from cds-master-metadata \
    --link cds-master-ldap_${DEPLOY_VERSION}:ldap \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e PREV_VERSION=${PREV_VERSION} \
    --restart=always \
    cds-webservices:${DEPLOY_VERSION} 

echo "Deploying cds-apache..."
${DOCKER_CMD} run --name cds-master-apache_${DEPLOY_VERSION} -p 80:80 -d --link cds-master-admin_${DEPLOY_VERSION}:admin \
    --link cds-master-webservices_${DEPLOY_VERSION}:webservices \
    --volumes-from cds-master-metadata \
    -e CDS_SERVER_NAME="$CDS_SERVER_NAME" \
    -e CDS_WEBSERVICES_SERVER_NAME="$CDS_WEBSERVICES_SERVER_NAME" \
    -e CDS_SERVER_ADMIN="$CDS_SERVER_ADMIN" \
    -e CDS_SERVICES="$CDS_SERVICES" \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e PREV_VERSION=${PREV_VERSION} \
    --restart=always \
    cds-apache:${DEPLOY_VERSION}

echo "Deploying cds-cron..."
${DOCKER_CMD} run --name cds-master-cron_${DEPLOY_VERSION} -d --link cds-master-postgresql_${DEPLOY_VERSION}:db \
    -e DEPLOY_VERSION=${DEPLOY_VERSION} \
    -e PREV_VERSION=${PREV_VERSION} \
    cds-cron:${DEPLOY_VERSION} 



# TODO: Make this more elegant.
sleep 2
ERROR_CHECK=$(${DOCKER_CMD} logs cds-master-postgresql_${DEPLOY_VERSION} | grep error | wc -l)
if [[ ${ERROR_CHECK} != 0 ]]
then
    echo "Database update failed:"
    exit 1
fi

echo "Existing containers after upgrade:"
${DOCKER_CMD} ps -a
