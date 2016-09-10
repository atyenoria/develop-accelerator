FROM atyenoria/redis-base

COPY ./file /
RUN cp -fR /supervisor /etc
RUN cp -fR /master /usr/local/etc
RUN cp -fR /slave /usr/local/etc
RUN cp -fR /local /usr/local/etc
ADD .zshrc /root/.zshrc
