FROM atyenoria/fluentd-base
ADD fluent.conf /fluentd/etc/fluent.conf
COPY plugins/ /fluentd/plugins
RUN touch /fluentd/log/temp.log
# COPY log /fluentd/log
CMD exec fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT