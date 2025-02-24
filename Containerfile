FROM registry.redhat.io/ubi9/ubi:9.5

RUN dnf install -y stunnel openldap-clients gettext && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    mkdir /ldaps-stunnel/ && \
    chmod g+rw /ldaps-stunnel/

COPY entrypoint.sh /ldaps-stunnel/
COPY stunnel.conf.tmpl /ldaps-stunnel/

WORKDIR /ldaps-stunnel/

ENTRYPOINT /ldaps-stunnel/entrypoint.sh