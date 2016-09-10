FROM atyenoria/cron-base

COPY .zshrc /root/.zshrc
COPY file /


RUN mv /ssh-config /laravel/.ssh/config
RUN mv /pkey /laravel/.ssh/pkey
RUN mv /known_hosts /laravel/.ssh/known_hosts
RUN chmod 600 /laravel/.ssh/pkey
RUN chmod 600 /laravel/.ssh/config
RUN chown -Rf laravel.laravel /laravel


COPY task /
ADD crontab /etc/cron.d/crontab
RUN cp /.s3cfg /root/.s3cfg

# CMD env > /env && service cron start && bash