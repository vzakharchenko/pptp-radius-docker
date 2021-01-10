# Docker image with PPTP server including routing and port forwarding

## Description
Access private network from the internet, support port forwarding from private network to outside via cloud.

[GitHub Project](https://github.com/vzakharchenko/pptp-radius-docker)

## Features
 - Docker image
 - Keycloak authentication and authorization
 - Radius client
 - support RadSec protocol (Radius over TLS)
 - [Management routing  and portforwarding using json file](#configjson-structure)
 - [Connect to LAN from the internet](#connect-to-lan-from-the--internet)
 - [Port forwarding](#port-forwarding)
 - [Connect multiple networks](#connect-multiple-networks)
 - [Automatic installation(Ubuntu)](#automatic-cloud-installation)
 - [Manual Installation steps (Ubuntu)](#manual-cloud-installationubuntu)

## Example
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/pptpKeycloakWithRouting.png?raw=true)
## Download

Get the trusted build from the [Docker Hub registry](https://hub.docker.com/r/vassio/keycloak-radius-plugin/):

```
docker pull vassio/pptp-radius-docker
```

## Installation
[create /opt/config.json](#configjson-structure)
```
sudo apt-get update && sudo apt-get install -y curl
curl -sSL https://raw.githubusercontent.com/vzakharchenko/pptp-radius-docker/main/ubuntu.install -o ubuntu.install
chmod +x ubuntu.install
./ubuntu.install
```

## config.json structure

```json
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
  "radius": {
    "protocol":"RADIUS_PROTOCOL"
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
- **KEYCLOAK_JSON** [Keycloak.json](#configure-keycloak)
- **RADIUS_PROTOCOL** Radius protocol. Supported pap,chap and mschap-v2. If used RadSec(Radius over TLS) then better to use PAP, otherwise mschap-v2
- **APPLICATION_IP** service IP behind NAT (port forwarding)
- **APPLICATION_PORT** service PORT behind NAT (port forwarding)
- **REMOTE_PORT**  port accessible from the internet (port forwarding)
- **ROUTING_TABLE**  ip with subnet for example 192.168.8.0/24
- **KEYCLOAK_ROLE**  Role assigned to user

## Installation ![Keycloak-Radius-plugin](https://github.com/vzakharchenko/keycloak-radius-plugin)
- [Release Setup](https://github.com/vzakharchenko/keycloak-radius-plugin#release-setup)
- [Docker Setup](https://github.com/vzakharchenko/keycloak-radius-plugin/blob/master/docker/README.md)
- [Manual Setup](https://github.com/vzakharchenko/keycloak-radius-plugin#manual-setup)

## Configure Keycloak
1. Create Realm with Radius client
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/VPN1.png?raw=true)
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/VPN2.png?raw=true)
2. Create OIDC client to Radius Realm
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/VPN3.png?raw=true)
3. Enable Service Accounts for OIDC client
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/VPN4.png?raw=true)
4. Add role "Radius Session Role" to Service Accounts
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/VPN5.png?raw=true)
5. Download Keycloak.json
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/VPN6.png?raw=true)
6. add keycloak.json to config.json
```json
{
  "radsec": {
    "privateKey": RADSEC_PRIVATE_KEY,
    "certificateFile": RADSEC_CERTIFICATE_FILE,
    "CACertificateFile": RADSEC_CA_CERTIFICATE_FILE,
    "certificateKeyPassword": RADSEC_PRIVATE_KEY_PASSWORD
  },
  "keycloak": {
    "json": {
        "realm": "VPN",
        "auth-server-url": "http://192.168.1.234:8090/auth/",
        "ssl-required": "external",
        "resource": "vpn-client",
        "credentials": {
            "secret": "12747feb-794b-4561-a54f-1f49e9366b21"
         },
        "confidential-port": 0
    }
  },
  "radius": {
    "protocol":"pap"
  }
}
```


## Examples

# Connect to LAN from the  internet
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/pptpRoutingKeycloak.png?raw=true)
**user1** - router with subnet 192.168.88.0/24 behind NAT ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/Role1.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/User1.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/resetPassword.png?raw=true)
**user2** - user who has access to subnet 192.168.88.0/24 from the Internet ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/User2.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/resetPassword.png?raw=true)
```json
{
   "radsec":{
      "privateKey":"RADSEC_PRIVATE_KEY",
      "certificateFile":"RADSEC_CERTIFICATE_FILE",
      "CACertificateFile":"RADSEC_CA_CERTIFICATE_FILE",
      "certificateKeyPassword":"RADSEC_PRIVATE_KEY_PASSWORD"
   },
   "keycloak":{
      "json":{
         "realm":"VPN",
         "auth-server-url":"http://192.168.1.234:8090/auth/",
         "ssl-required":"external",
         "resource":"vpn-client",
         "credentials":{
            "secret":"12747feb-794b-4561-a54f-1f49e9366b21"
         },
         "confidential-port":0
      }
   },
   "radius":{
      "protocol":"pap"
   },
   "authorizationMap":{
      "roles":{
         "Role1":{
            "routing":[
               {
                  "route":"192.168.88.0/24"
               }
            ]
         }
      }
   }
}
```


# Port forwarding
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/pptpKeycloakWithRouting.png?raw=true)
**user** - router with subnet 192.168.88.0/24 behind NAT. ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/Role1.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/User1.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/resetPassword.png?raw=true)
Subnet contains service http://192.168.8.254:80 which is available at from http://195.138.164.211:9000

```json
{
   "radsec":{
      "privateKey":"RADSEC_PRIVATE_KEY",
      "certificateFile":"RADSEC_CERTIFICATE_FILE",
      "CACertificateFile":"RADSEC_CA_CERTIFICATE_FILE",
      "certificateKeyPassword":"RADSEC_PRIVATE_KEY_PASSWORD"
   },
   "keycloak":{
      "json":{
         "realm":"VPN",
         "auth-server-url":"http://192.168.1.234:8090/auth/",
         "ssl-required":"external",
         "resource":"vpn-client",
         "credentials":{
            "secret":"12747feb-794b-4561-a54f-1f49e9366b21"
         },
         "confidential-port":0
      }
   },
   "radius":{
      "protocol":"pap"
   },
   "authorizationMap":{
      "roles":{
         "Role1":{
            "forwarding":[
               {
                  "sourceIp":"192.168.88.1",
                  "sourcePort":"80",
                  "destinationPort":9000
               }
            ]
         }
      }
   }
}
```
# connect multiple networks
![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/pptpKeycloakWithRoutingMany.png?raw=true)
**user1** - router with subnet 192.168.88.0/24 behind NAT. Subnet contains service http://192.168.88.254:80 which is available at from http://195.138.164.211:9000 ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/Role1.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/User1.png)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/resetPassword.png?raw=true)
**user2** - router with subnet 192.168.89.0/24 behind NAT. ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/Role2.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/User2.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/User2Role.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/resetPassword.png?raw=true)
**user3** - user who has access to subnets 192.168.88.0/24 and 192.168.89.0/24 from the Internet  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/User2.png?raw=true)  ![](https://github.com/vzakharchenko/pptp-radius-docker/blob/main/img/resetPassword.png?raw=true)
```json
{
   "radsec":{
      "privateKey":"RADSEC_PRIVATE_KEY",
      "certificateFile":"RADSEC_CERTIFICATE_FILE",
      "CACertificateFile":"RADSEC_CA_CERTIFICATE_FILE",
      "certificateKeyPassword":"RADSEC_PRIVATE_KEY_PASSWORD"
   },
   "keycloak":{
      "json":{
         "realm":"VPN",
         "auth-server-url":"http://192.168.1.234:8090/auth/",
         "ssl-required":"external",
         "resource":"vpn-client",
         "credentials":{
            "secret":"12747feb-794b-4561-a54f-1f49e9366b21"
         },
         "confidential-port":0
      }
   },
   "radius":{
      "protocol":"pap"
   },
   "authorizationMap":{
      "roles":{
         "Role1":{
            "forwarding":[
               {
                  "sourceIp":"192.168.88.254",
                  "sourcePort":"80",
                  "destinationPort":9000
               }
            ],
            "routing":[
               {
                  "route":"192.168.88.0/24"
               }
            ]
         },
         "Role2":{
            "routing":[
               {
                  "route":"192.168.89.0/24"
               }
            ]
         }
      }
   }
}
```


## Troubleshooting
1. Viewing logs in docker container:
```
docker logs pptp-radius-docker -f
```
2. print routing tables
```
docker exec pptp-radius-docker bash -c "ip route"
```
3. print iptable rules
```
docker exec pptp-radius-docker bash -c "iptables -S"
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
