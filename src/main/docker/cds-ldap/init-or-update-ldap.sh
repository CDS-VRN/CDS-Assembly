#!/bin/bash

# TODO: UPDATE LDAP sequence. This is only a CREATE now.
/opt/OpenDS-2.2.1/setup -i -n -b dc=inspire,dc=idgis,dc=eu -D cn=admin,dc=inspire,dc=idgis,dc=eu -w admin -p 389 -a && \
	/opt/OpenDS-2.2.1/bin/ldapmodify -p 389 -h localhost -D cn=admin,dc=inspire,dc=idgis,dc=eu -w admin -a -f /usr/share/cds/ldif/ldap-init.ldif

