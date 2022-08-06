# HSQLDB Docker Image

BASE IMAGE: openjdk:11-jre-slim  
HSQLDB v2.7.0

Usage:
```
docker run -v ${pwd}/test:/docker-entrypoint-initdb.d -p 9001:9001 --name hsqldb infotechsoft/hsqldb:2.7.0
```

Add scripts into `/docker-entrypoint-initdb.d`

```
# Startup Options
HSQLDB_TRACE=false # print Java stack traces
HSQLDB_SILENT=true # do not print SQL statements
HSQLDB_REMOTE=true # allow remote access
HSQLDB_PORT=9001   # listen on port
HSQLDB_DATABASE_NAME=hsqldb # auto-create/connect to database
HSQLDB_DATABASE_ALIAS=test # database alias
HSQLDB_USER=sa     # database username
HSQLDB_PASSWORD=   # database password
```

On startup, `docker-entrypoint.sh` generates HSQLDB `server.properties` and SQLTOOL `sqltool.rc` configuration files.

If there are no files in DATABASE volume matching HSQLDB_DATABASE_NAME, 
1. Check to see if there are any `.sql` scripts in `docker-entrypoint-initdb.d` and execute them with `sqltool`.
2. Start `hsqldb` using the startup options

HSQL_HOME::  
`/opt/hsqldb/`  

DATABASE Volume:  
`/opt/database/`

## SQLTOOL
`sqltool` is installed in `/opt/hsqldb`. It is used to run startup scripts, and can be used to connect and query the HSQLDB database within the Docker container.  
The `sqltool.rc` file is generated to run the initial SQL scripts using a FILE connection. 
Note: `hsqldb` creates a file lock on the database. You will need to override the `sqltool` configuration to connect to the local server.

Usage:
```
java -jar /opt/hsqldb/sqltool.jar --rcFile=/opt/hsqldb/sqltool.rc init
```

## Shutdown
To gracefully shutdown HSQLDB, send a `SHUTDOWN` sql command to the database. This will perist temporary data, but it will not terminate the HSQLDB Java process. Subsequent connections will fail.

There may be a problem with using CTRL+C to terminate the container. Use `docker stop` instead.