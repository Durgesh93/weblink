#!/bin/bash

echo "Stopping all running containers..."
docker stop $(docker ps -q) 2>/dev/null

echo "Removing all containers..."
docker rm $(docker ps -a -q) 2>/dev/null

echo "Removing all images..."
docker rmi -f $(docker images -q) 2>/dev/null

echo "Removing all volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null

echo "Removing all non-default networks..."
docker network rm $(docker network ls | awk '/bridge|host|none/ {next} {print $1}') 2>/dev/null

echo "Removing all Docker secrets (if in Swarm mode)..."
if docker info | grep -q "Swarm: active"; then
  docker secret rm $(docker secret ls -q) 2>/dev/null
else
  echo "Swarm not active. Skipping secrets removal."
fi

echo "Docker system prune..."
docker system prune -a --volumes -f

echo "All Docker resources cleaned up."
