#!/bin/sh

echo "Starting catalina in: $CATALINA_HOME ($CATALINA_BASE) ..."
 
mkdir $CATALINA_TMPDIR && catalina.sh run