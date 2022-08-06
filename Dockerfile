FROM openjdk:11-jre-slim AS builder

ENV HSQLDB_VERSION=2.7.0

RUN  apt-get update && \
	apt-get install -y wget unzip && \
	wget -O /tmp/hsqldb.zip https://sourceforge.net/projects/hsqldb/files/hsqldb/hsqldb_$(echo ${HSQLDB_VERSION%.*} | tr '.' '_')/hsqldb-${HSQLDB_VERSION}.zip/download && \
	unzip -o -j /tmp/hsqldb.zip "**/hsqldb.jar" "**/sqltool.jar" "**/hsqldb_lic.txt" -d /tmp/hsqldb

FROM openjdk:11-jre-slim

# Image Environment Variables
ENV JAVA_VM_PARAMETERS= \
    HSQLDB_TRACE=false \
    HSQLDB_SILENT=true \
    HSQLDB_REMOTE=true \
	HSQLDB_PORT=9001 \
    HSQLDB_DATABASE_NAME=hsqldb \
    HSQLDB_DATABASE_ALIAS=test \
    HSQLDB_USER=sa \
    HSQLDB_PASSWORD=

RUN mkdir -p /opt/hsqldb && \
	mkdir -p /opt/database && \
    chmod -R 777 /opt/database && \
    mkdir -p /docker-entrypoint-initdb.d 

VOLUME ["/opt/database","/docker-entrypoint-initdb.d"]
EXPOSE 9001
WORKDIR /opt/hsqldb

COPY --from=builder /tmp/hsqldb /opt/hsqldb
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["hsqldb"]