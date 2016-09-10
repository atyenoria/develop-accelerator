FROM atyenoria/laravel-base

COPY ./file /


RUN cp -f /zshrc /root/.zshrc && \
    cp -f /zshrc /laravel/.zshrc && \
    cp -f /main/gitconfig /root/.gitconfig && \
    cp -f /main/pkey-laravel /laravel/.ssh/id_rsa1 && \
    cp -f /main/pubkey-laravel /laravel/.ssh/authorized_keys && \
    cp -f /main/sshconfig-laravel /laravel/.ssh/config && \
    cp -f /main/known_hosts /laravel/.ssh/known_hosts && \
    cp -f /main/sshd_config /etc/ssh/sshd_config && \
    rm -rf /usr/local/etc && \
    rm -rf /etc/nginx && \
    rm -rf /etc/supervisor && \
    cp -fR /etc-php /usr/local && \
    mv /usr/local/etc-php /usr/local/etc && \
    cp -fR /nginx /etc && \
    cp -fR /supervisor /etc

