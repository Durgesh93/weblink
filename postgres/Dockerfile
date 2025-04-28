FROM postgres:latest
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init/01-init.sql /tmp/01-init.sql
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["postgres"]