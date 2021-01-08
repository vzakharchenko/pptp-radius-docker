#!/bin/bash

set -e
service rsyslog start
iptables-restore < /etc/iptables/rules.v4

echo "export RADSEC_TEMPLATE_PROXY_CONF=/opt/etc/radsecproxy.conf">/opt/envs_docker.sh
echo "export RADSEC_PROXY_CONF=/etc/radsecproxy.conf">>/opt/envs_docker.sh
echo "export RADIUS_CLIENT=/etc/radcli/radiusclient.conf">>/opt/envs_docker.sh
echo "export RADIUS_SERVER=/etc/radcli/servers">>/opt/envs_docker.sh
echo "export RADSEC_PROXY_FILE=/opt/radsec.sh">>/opt/envs_docker.sh
echo "export RADIUS_ENVS=/opt/envs.sh">>/opt/envs_docker.sh
echo "export RADIUS_ROUTES=/opt/roles">>/opt/envs_docker.sh
echo "export CONFIG_PATH=/opt/config.json">>/opt/envs_docker.sh
echo "export REDIR_SH=/opt/redir.sh">>/opt/envs_docker.sh
chmod +x /opt/envs_docker.sh
rm -rf /opt/roles
mkdir -p /opt/roles
node /opt/pptp-js/parsingConfigFile.js
chmod -R +x /opt/roles
chmod +x /opt/radsec.sh
source /opt/envs.sh
chmod +x /opt/redir.sh
service pptpd restart
if [[ "x${RAD_SEC}" = "xtrue" ]]; then
  /opt/radsec.sh
fi
if [[ "x${USE_COA}" = "xtrue" ]]; then
 pm2 start /opt/coa/server.js
fi
/opt/redir.sh
tail -f /var/log/messages
