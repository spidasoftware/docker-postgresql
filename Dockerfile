FROM postgres:9.4.1

RUN apt-get update && \
	apt-get install cron vim -y && \
  	rm -rf /var/lib/apt/lists/*

ENV POSTGRES_USER=minmaster
ENV POSTGRES_PASSWORD=overrideincompose

RUN mkdir -p /docker-entrypoint-initdb.d && \
	sed -i -r 's/exec \"\$@\"//' /docker-entrypoint.sh && \
	sed -i -r 's/exec gosu postgres \"\$@\"//' /docker-entrypoint.sh

COPY postgres-entrypoint.sh /postgres-entrypoint.sh
COPY backup.sh /backup.sh
COPY restore.sh /restore.sh
COPY crontab /etc/cron.d/postgres-backup-cron

VOLUME ["/backups"]
ENTRYPOINT ["/postgres-entrypoint.sh"]
CMD ["postgres"]
