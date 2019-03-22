FROM postgres:9.4

# these can be overridden in .docker-common.env but they are not set there by default
ENV POSTGRES_USER=minmaster
ENV POSTGRES_DATABASE=minmaster
# POSTGRES_PASSWORD is set in .docker-common.env

RUN apt-get update && \
	apt-get install cron vim -y && \
  	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d && \
	sed -i -r 's/exec \"\$@\"//' /docker-entrypoint.sh && \
	sed -i -r 's/exec gosu postgres \"\$@\"//' /docker-entrypoint.sh

COPY postgres-entrypoint.sh /postgres-entrypoint.sh
COPY reset-passwords.sh /reset-passwords.sh
COPY backup.sh /backup.sh
COPY restore.sh /restore.sh
COPY crontab /etc/cron.d/postgres-backup-cron

VOLUME ["/backups"]
ENTRYPOINT ["/postgres-entrypoint.sh"]
CMD ["postgres"]
