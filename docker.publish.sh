docker build -t pptp-radius-docker .
docker tag  pptp-radius-docker vassio/pptp-radius-docker:1.0.0
docker push vassio/pptp-radius-docker:1.0.0

docker tag  pptp-radius-docker vassio/pptp-radius-docker:latest
docker push vassio/pptp-radius-docker:latest
