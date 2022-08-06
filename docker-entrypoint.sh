#!/bin/bash
set -o errexit

if [ "$1" = 'hsqldb' ]; then
	java_vm_parameters="-Dfile.encoding=UTF-8"

# sqltool.rc resource file
cat <<EOF > sqltool.rc
urlid init
username ${HSQLDB_USER:-sa}
password ${HSQLDB_PASSWORD}
url jdbc:hsqldb:file:/opt/database/${HSQLDB_DATABASE_NAME:-hsqldb};shutdown=true
transiso TRANSACTION_READ_COMMITTED
EOF

# hsqldb server.properties file
cat <<EOF > server.properties
server.port=${HSQLDB_PORT:-9001}
server.silent=${HSQLDB_SILENT:-true}
server.trace=${HSQLDB_TRACE:-false}
server.remote_open=${HSQLDB_REMOTE:-true}
server.database.0=file:/opt/database/${HSQLDB_DATABASE_NAME:-hsqldb};user=${HSQLDB_USER:-sa};password=${HSQLDB_PASSWORD}
server.dbname.0=${HSQLDB_DATABASE_NAME:-hsqldb}
EOF

	# Check if DBNAME has already been created
	if ! compgen -G "/opt/database/${HSQLDB_DATABASE_NAME:-hsqldb}.*" > /dev/null; then
		echo "Creating ${HSQLDB_DATABASE_NAME:-hsqldb}."
	
		# Execute any SQL_SCRIPTS in docker-entrypoint-initdb
		sqlscripts=(`find /docker-entrypoint-initdb.d/ -maxdepth 1 -name "*.sql"`)
		if [ ${#sqlscripts[@]} -gt 0 ]; then
			echo "Found ${#sqlscripts[@]} scripts: /docker-entrypoint-initdb.d/"
			
			# cat sqltool.rc
			for sqlfile in "${sqlscripts[@]}"; do
				echo "Executing: ${sqlfile}"
				java -jar /opt/hsqldb/sqltool.jar --rcFile=./sqltool.rc init "${sqlfile}"
			done
			
		fi
	fi
	
	cat server.properties
	echo "Starting HSQLDB: ${HSQLDB_DATABASE_NAME:-hsqldb}"
	exec java ${java_vm_parameters} -cp /opt/hsqldb/hsqldb.jar org.hsqldb.server.Server
elif [ "$1" = 'sqltool' ]; then
	echo "Connecting SQLTool: ${HSQLDB_DATABASE_NAME:-hsqldb}"
	exec java -jar /opt/hsqldb/sqltool.jar --rcFile=./sqltool.rc init
else
	exec "$@"
fi