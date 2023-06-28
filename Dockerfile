FROM curlimages/curl:latest
USER root
COPY fw-init.sh /etc
RUN apk -q add jq
RUN chmod 755 /etc/fw-init.sh
CMD ["/etc/fw-init.sh"]

