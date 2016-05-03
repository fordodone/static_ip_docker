#!/bin/bash
COMPOSE_HTTP_TIMEOUT=3600
docker-compose -f ../docker-compose-full-slash-24-swarm.yml up -d

