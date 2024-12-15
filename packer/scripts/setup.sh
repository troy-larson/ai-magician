#!/bin/bash

# Prompt the user for domain names and email
read -p "Enter the domain for n8n (e.g., n8n.example.com): " N8N_DOMAIN
read -p "Enter the domain for OpenWebUI (e.g., openwebui.example.com): " OPENWEBUI_DOMAIN
read -p "Enter your email for Let's Encrypt notifications: " EMAIL

# Create project directory
sudo mkdir -p /opt/n8n_openwebui
sudo chown $USER:$USER /opt/n8n_openwebui
cd /opt/n8n_openwebui || exit

# Create Docker Compose file
cat <<EOF >docker-compose.yml
version: '3.8'

services:
  traefik:
    image: traefik:v2.5
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.email=$EMAIL"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
      - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./letsencrypt:/letsencrypt"

  n8n:
    image: n8nio/n8n
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=securepassword
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(\`$N8N_DOMAIN\`)"
      - "traefik.http.routers.n8n.entrypoints=websecure"
      - "traefik.http.routers.n8n.tls.certresolver=myresolver"

  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.openwebui.rule=Host(\`$OPENWEBUI_DOMAIN\`)"
      - "traefik.http.routers.openwebui.entrypoints=websecure"
      - "traefik.http.routers.openwebui.tls.certresolver=myresolver"

volumes:
  letsencrypt:
EOF

# Start Docker Compose services
sudo docker-compose up -d
