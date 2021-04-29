#! /bin/sh

set -e
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod u+x /usr/local/bin/docker-compose
docker-compose --version
