DC = docker-compose
DC_DIR = config/docker

CMP_BASE = -f $(DC_DIR)/docker-compose.yml
CMP_DEV = $(CMP_BASE) -f $(DC_DIR)/docker-compose.dev.yml

.PHONY: up dev down logs cert

dev:
	$(DC) $(CMP_DEV) up -d

up:
	$(DC) $(CMP_BASE) up -d

down:
	$(DC) $(CMP_DEV) down --remove-orphans

logs:
	$(DC) $(CMP_DEV) logs -f

cert:
	mkcert -install
	mkcert -cert-file config/caddy/localhost.pem -key-file config/caddy/localhost-key.pem localhost
