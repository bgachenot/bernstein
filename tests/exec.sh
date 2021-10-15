#!/usr/bin/env bash

kubectl_bin=$(which kubectl)
cadvisor_files="cadvisor.daemonset.yaml"
postgres_files="postgres.secret.yaml postgres.configmap.yaml postgres.volume.yaml postgres.vdeployment.yaml postgres.service.yaml"
redis_files="redis.configmap.yaml redis.deploymet.yaml redis.service.yaml"
poll_files="poll.deployment.yaml worker.deployment.yaml result.deployment.yaml poll.service.yaml result.service.yaml poll.ingress.yaml result.ingress.yaml"
traefik_files="traefik.rbac.yaml traefik.deployment.yaml traefik.service.yaml"

source tests/.prod.env

echo "Deploying cadvisor..."
"$kubectl_bin" apply -f cadvisor.daemonset.yaml

echo "Deploying postgres..."
"$kubectl_bin" apply -f postgres.secret.yaml \
-f postgres.configmap.yaml \
-f postgres.volume.yaml \
-f postgres.deployment.yaml \
-f postgres.service.yaml

echo "Deploying redis..."
"$kubectl_bin" apply -f redis.configmap.yaml \
-f redis.deployment.yaml \
-f redis.service.yaml

echo "Deploying poll, worker, result..."
"$kubectl_bin" apply -f poll.deployment.yaml \
-f worker.deployment.yaml \
-f result.deployment.yaml \
-f poll.service.yaml \
-f result.service.yaml \
-f poll.ingress.yaml \
-f result.ingress.yaml

echo "Deploying traefik..."
"$kubectl_bin" apply -f traefik.rbac.yaml \
-f traefik.deployment.yaml \
-f traefik.service.yaml

echo "Creating postgresql table..."
echo 'CREATE TABLE votes (id text PRIMARY KEY, vote text NOT NULL);' | "$kubectl_bin" exec -i $("$kubectl_bin" get pods -o=custom-columns="DATA:metadata.name" | grep postgres) -- psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"