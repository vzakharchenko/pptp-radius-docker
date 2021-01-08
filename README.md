# Docker image with PPTP server including routing and port forwarding

## Description
Access private network from the internet, support port forwarding from private network to outside via cloud.

[GitHub Project](https://github.com/vzakharchenko/pptp-radius-docker)

## Example
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/pptpKeycloakWithRouting.png?raw=true)


## Features
 - Docker image
 - Keycloak authentication and authorization
 - Radius client
 - RadSec protocol (Radius over TLS)
 - [Management routing  and portforwarding using json file](#configjson-structure)
 - [Connect to LAN from the internet](#connect-to-lan-from-the--internet)
 - [Port forwarding](#port-forwarding)
 - [Connect multiple networks](#connect-multiple-networks)
 - [Automatic installation(Ubuntu)](#automatic-cloud-installation)
 - [Manual Installation steps (Ubuntu)](#manual-cloud-installationubuntu)

## config.json structure

```
{
  "radsec": {
    "privateKey": RADSEC_PRIVATE_KEY,
    "certificateFile": RADSEC_CERTIFICATE_FILE,
    "CACertificateFile": RADSEC_CA_CERTIFICATE_FILE,
    "certificateKeyPassword": RADSEC_PRIVATE_KEY_PASSWORD
  },
  "keycloak": {
    "json": KEYCLOAK_JSON
  },
  "authorizationMap": {
    "roles": {
      "KEYCLOAK_ROLE": {
        "routes": ROUTING_TABLE,
        "forwarding":{
            "sourceIp": APPLICATION_IP,
            "sourcePort": APPLICATION_PORT,
            "externalPort": REMOTE_PORT
        }
      }
    }
  }
}
```
Where
- **RADSEC_PRIVATE_KEY** ssl privateKey
- **RADSEC_CERTIFICATE_FILE** ssl private certificate
- **CACertificateFile** ssl CA certificate
- **certificateKeyPassword** privateKey password
- **KEYCLOAK_JSON** Keycloak.json
- **APPLICATION_IP** service IP behind NAT (port forwarding)
- **APPLICATION_PORT** service PORT behind NAT (port forwarding)
- **REMOTE_PORT**  port accessible from the internet (port forwarding)
- **ROUTING_TABLE**  ip with subnet for example 192.168.8.0/24
- **KEYCLOAK_ROLE**  Role assigned to user

## Examples

### Connect to LAN from the  internet
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/pptpRoutingKeycloak.png?raw=true)
**user1** - router with subnet 192.168.88.0/24 behind NAT
**user2** - user who has access to subnet 192.168.88.0/24 from the Internet
```
{
  "users": {
    "user1": {
      "password": "password1",
      "ip": "192.168.122.10",
      "routing": [
        {
          "route": "192.168.88.0/24"
        }
      ]
    },
    "user2": {
      "password": "password2",
      "ip": "192.168.122.11"
    }
  }
}
```

### Port forwarding
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/pptpKeycloakWithRouting.png?raw=true)
**user** - router with subnet 192.168.88.0/24 behind NAT.
Subnet contains service http://192.168.8.254:80 which is available at from http://195.138.164.211:9000

```
{
  "users": {
    "user": {
      "password": "password",
      "ip": "192.168.122.10",
      "forwarding": [{
        "sourceIp": "192.168.88.1",
        "sourcePort": "80",
        "destinationPort": 9000
      }],
    }
  }
}
```
### connect multiple networks
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/pptpKeycloakWithRoutingMany.png?raw=true)
**user1** - router with subnet 192.168.88.0/24 behind NAT. Subnet contains service http://192.168.88.254:80 which is available at from http://195.138.164.211:9000
**user2** - router with subnet 192.168.89.0/24 behind NAT.
**user3** - user who has access to subnets 192.168.88.0/24 and 192.168.89.0/24 from the Internet
```
{
  "users": {
    "user1": {
      "password": "password1",
      "ip": "192.168.122.10",
      "forwarding": [
        {
          "sourceIp": "192.168.88.254",
          "sourcePort": "80",
          "destinationPort": 9000
        }
      ],
       "routing": [
        {
          "route": "192.168.88.0/24"
        }
      ]
    },
    "user2": {
      "password": "password2",
      "ip": "192.168.122.11",
      "routing": [
        {
          "route": "192.168.89.0/24"
        }
      ]
    },
    "user3": {
      "password": "password3",
      "ip": "192.168.122.12"
    }
  }
}
```


## Troubleshooting
1. Viewing logs in docker container:
```
docker logs pptp-port-forwarding -f
```
2. print routing tables
```
docker exec pptp-port-forwarding bash -c "ip route"
```
3. print iptable rules
```
docker exec pptp-port-forwarding bash -c "iptables -S"
```


## Cloud Installation
### Automatic cloud installation
[create /opt/config.json](#configjson-structure)
```
sudo apt-get update && sudo apt-get install -y curl
curl -sSL https://raw.githubusercontent.com/vzakharchenko/pptp-radius-docker/main/ubuntu.install -o ubuntu.install
chmod +x ubuntu.install
./ubuntu.install
```

### Manual Cloud Installation(Ubuntu)

1. install all dependencies
```
sudo apt-get update && sudo apt-get install -y iptables git iptables-persistent node
```
2. install docker
```
sudo apt-get remove docker docker.io containerd runc
sudo curl -sSL https://get.docker.com | bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

3. Configure host machine
```
echo "nf_nat_pptp" >> /etc/modules
echo "ip_gre" >> /etc/modules
iptables -I FORWARD -p gre -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.netfilter.nf_conntrack_helper=1
sudo echo "net.ipv4.ip_forward=1">/etc/sysctl.conf
sudo echo "net.netfilter.nf_conntrack_helper=1">/etc/sysctl.conf
```
4. [create /opt/config.json](#configjson-structure)

5. start docker image

```
export CONFIG_PATH=/opt/config.json
curl -sSL https://raw.githubusercontent.com/vzakharchenko/pptp-radius-docker/main/pptp-js/generateDockerCommands.js -o generateDockerCommands.js
`node generateDockerCommands.js`
```
6. reboot machine
