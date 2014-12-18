#!/bin/sh

echo "Starting catalina in: $CATALINA_HOME ($CATALINA_BASE) ..."

echo "JAVA_OPTS: $JAVA_OPTS"
 
mkdir -p $CATALINA_TMPDIR && catalina.sh run