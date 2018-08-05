#! /bin/sh

DOCKER_PS=`docker ps -a | grep "qkbot" | grep "Exited (1)" | sed -e "s/[^a-zA-Z_0-9]\+/#/g" | sed -e "s/^[a-zA-Z_0-9#]\+\(qkbot_[a-zA-Z_0-9]\+\)$/\1/g"`
WEBHOOKS_URL=`cat .qkbotwebhooks`

for container in $DOCKER_PS; do
    docker logs -t $container >$container.log 2>&1
    curl -X POST \
    -F "content=[ERROR]**$container is exited(1)**" \
    -F "file=@$container.log" $WEBHOOKS_URL
done