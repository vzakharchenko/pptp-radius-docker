sudo iptables -I FORWARD -p gre -j ACCEPT
sudo sudo modprobe nf_nat_pptp
sudo sudo sysctl -w net.ipv4.ip_forward=1
docker stop pptp-port-forwarding
docker rm pptp-port-forwarding

docker build -t pptp-port-forwarding .
docker run --name=pptp-port-forwarding -v /home/vzakharchenko/home/docker-pptp-port-forwarding/key.pem:/opt/key.pem -v /home/vzakharchenko/home/docker-pptp-port-forwarding/cert.pem:/opt/cert.pem -v /home/vzakharchenko/home/pptp-radius-docker/examples/example.json:/opt/config.json -p 1723:1723 -p 3799:3799 --privileged pptp-port-forwarding
