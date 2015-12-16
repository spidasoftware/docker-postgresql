#!/bin/bash
docker build -t spidasoftware/postgresql:latest .
docker save spidasoftware/postgresql:latest | sudo docker-squash -t spidasoftware/postgresql:latest -verbose | docker load

docker push spidasoftware/postgresql:latest