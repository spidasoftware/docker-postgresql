FROM postgres:9.4

ENV LANG en_US.UTF-8

# these can be overridden in .docker-common.env but they are not set there by default
ENV POSTGRES_USER=minmaster
ENV POSTGRES_DATABASE=minmaster
# POSTGRES_PASSWORD is set in .docker-common.env

RUN echo postfix postfix/mailname string willbechanged.spidastudio.com | debconf-set-selections && \
	echo postfix postfix/main_mailer_type string 'Local Only' | debconf-set-selections && \
	apt-get update && \
	apt-get install cron vim postfix libsasl2-modules mailutils -y && \
  	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d && \
	sed -i -r 's/exec \"\$@\"//' /docker-entrypoint.sh && \
	sed -i -r 's/exec gosu postgres \"\$@\"//' /docker-entrypoint.sh && \
    sed -i -r "s/default_transport = error/#default_transport = error/" /etc/postfix/main.cf && \
    sed -i -r "s/relay_transport = error/#relay_transport = error/" /etc/postfix/main.cf && \
    postconf -e "relayhost = [smtp.sendgrid.net]:2525" && \
    postconf -e "smtp_tls_security_level = encrypt" && \
    postconf -e "smtp_sasl_auth_enable = yes" && \
    postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" && \
    postconf -e "header_size_limit = 4096000" && \
    postconf -e "smtp_sasl_security_options = noanonymous"

COPY postgres-entrypoint.sh /postgres-entrypoint.sh
COPY reset-passwords.sh /reset-passwords.sh
COPY backup.sh /backup.sh
COPY restore.sh /restore.sh
COPY crontab /etc/cron.d/postgres-backup-cron

VOLUME ["/backups"]
ENTRYPOINT ["/postgres-entrypoint.sh"]
CMD ["postgres"]
