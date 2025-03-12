# Makefile

# Apparently needed to avoid conflicts with files of the same name
.PHONY: help up down

help:
	@echo
	@echo	"Available Makefile Commands: "
	@echo	"  make up	- Start 3 containers via docker-compose (ElasticSearch, Kibana, and Filebeat -- which are all depended on the ElasticSearch container)"
	@echo	"  make down	- Stop all 3 containers and volumes via docker-compose"
	@echo

# Add -d after up in the case we want to run in detached mode
up:
	docker-compose -f docker-compose.yml up

# Running down command with -v to remove volumes as well
down:
	docker-compose -f docker-compose.yml down -v
