sudo iptables -I FORWARD -p gre -j ACCEPT
sudo sudo modprobe nf_nat_pptp
sudo sudo sysctl -w net.ipv4.ip_forward=1
docker stop pptp-radius-docker
docker rm pptp-radius-docker

docker build -t pptp-radius-docker .
docker run --name=pptp-radius-docker -v /home/vzakharchenko/home/docker-pptp-port-forwarding/key.pem:/opt/key.pem -v /home/vzakharchenko/home/docker-pptp-port-forwarding/cert.pem:/opt/cert.pem -v /home/vzakharchenko/home/pptp-radius-docker/examples/config.json:/opt/config.json -p 1723:1723 -p 3799:3799 --privileged pptp-radius-docker
