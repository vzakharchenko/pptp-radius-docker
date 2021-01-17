FROM ubuntu:latest
MAINTAINER Vasyl Zakharchenko <vaszakharchenko@gmail.com>
LABEL author="Vasyl Zakharchenko"
LABEL email="vaszakharchenko@gmail.com"
LABEL name="keycloak-pptp-server"
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y gnupg2 ca-certificates lsb-release wget
RUN update-ca-certificates --fresh
RUN apt-get purge curl
RUN wget -qO-  https://deb.nodesource.com/setup_15.x | bash
RUN apt-get update && apt-get install -y curl ppp pptpd iptables rsyslog iproute2 redir net-tools inetutils-inetd git iptables-persistent systemd nodejs npm
RUN apt-get install -y autoconf libtool automake nettle-dev libgnutls28-dev abi-compliance-checker libradcli4 radsecproxy wget
RUN npm i pm2 -g
RUN ln -s  /etc/radcli /etc/radiusclient
RUN echo "net.ipv4.ip_forward=1">/etc/sysctl.conf
RUN echo "net.ipv4.ip_forward=1">/etc/sysctl.conf
COPY ./etc/ppp/ip-up.d/routes-up /etc/ppp/ip-up.d/routes-up
COPY ./etc/ppp/ip-down.d/routes-down /etc/ppp/ip-down.d/routes-down
RUN chmod +x ./etc/ppp/ip-up.d/routes-up
RUN chmod +x ./etc/ppp/ip-down.d/routes-down
COPY ./etc/iptables/rules.v4 /etc/iptables/rules.v4
COPY ./etc/rsyslog.conf /etc/rsyslog.conf
COPY ./etc/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf
COPY ./etc/pptpd.conf /etc/pptpd.conf
COPY ./etc/ppp/pptpd-options /opt/etc/pptpd-options
COPY ./pptp-js /opt/pptp-js
RUN mkdir -p /opt/etc/
COPY ./etc/radsecproxyRadSec.conf /opt/etc/radsecproxyRadSec.conf
COPY ./etc/radsecproxyUDP.conf /opt/etc/radsecproxyUDP.conf
COPY ./coa /opt/coa
RUN cd /opt/coa && npm i && cd /
COPY ./pptp-js /opt/pptp-js
RUN cd /opt/pptp-js && npm i && cd /

RUN cat /etc/radcli/dictionary.microsoft >> /etc/radcli/dictionary
RUN grep -rl ipv4addr /etc/radiusclient/ | xargs sed -i 's/ipv4addr/ipaddr/g'
RUN grep -rl ipv6addr /etc/radiusclient/ | xargs sed -i 's/ipv6addr/string/g'
RUN grep -rl ipv6prefix /etc/radiusclient/ | xargs sed -i 's/ipv6prefix/string/g'
COPY ./etc/radcli/servers /etc/radiusclient/servers
COPY ./etc/radcli/port-id-map /etc/radiusclient/port-id-map
RUN chmod 777 /etc/iptables/rules.v4
COPY entrypoint.sh /entrypoint.sh
RUN  chmod +x /entrypoint.sh
RUN mkdir -p /opt/roles
ENV RADSEC_TEMPLATE_PROXY_CONF /opt/etc/radsecproxyRadSec.conf
ENV UDP_TEMPLATE_PROXY_CONF /opt/etc/radsecproxyUDP.conf
ENV RADSEC_PROXY_CONF /etc/radsecproxy.conf
ENV RADIUS_CLIENT /etc/radcli/radiusclient.conf
ENV RADIUS_SERVER /etc/radcli/servers
ENV RADSEC_PROXY_FILE /opt/radsec.sh
ENV RADIUS_ENVS /opt/envs.sh
ENV RADIUS_ROUTES /opt/roles
ENV TEMPLATE_PPP_OPTIONS /opt/etc/pptpd-options
ENV PPP_OPTIONS /etc/ppp/pptpd-options

ENV CONFIG_PATH  /opt/config.json
ENV REDIR_SH  /opt/redir.sh
#ENV ROUTES_UP  /etc/ppp/ip-up.d/routes-up
#ENV SECRET_PATH  /etc/ppp/chap-secrets
EXPOSE 1723
ENTRYPOINT ["/entrypoint.sh"]
