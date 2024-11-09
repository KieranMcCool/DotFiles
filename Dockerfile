FROM ubuntu:latest

RUN apt update
RUN apt install -y git
RUN apt install -y curl
RUN apt install -y neovim
RUN apt install -y pandoc
RUN apt install -y nodejs
RUN apt install -y npm

COPY . /etc/DotFiles
WORKDIR /etc/DotFiles

RUN chmod +x ./install.sh
RUN ./install.sh

RUN mkdir /workspace
WORKDIR /workspace

# PORT MAPPINGS
# =============

# Web development ports

# React, Node.js, Next.js
EXPOSE 3000
# Alternate Node.js port
EXPOSE 3001
# Angular, Vue.js, general web server
EXPOSE 8080
# Alternate web server port
EXPOSE 8081
# Flask, FastAPI, ASP.NET Core
EXPOSE 5000
# Django, SimpleHTTPServer
EXPOSE 8000
# Angular (ng serve)
EXPOSE 4200

# Database ports

# PostgreSQL
EXPOSE 5432
# MySQL
EXPOSE 3306
# MongoDB
EXPOSE 27017
# SQL Server
EXPOSE 1433
# Redis
EXPOSE 6379

# Messaging and search services

# RabbitMQ (AMQP)
EXPOSE 5672
# RabbitMQ Management UI
EXPOSE 15672   
# Elasticsearch (API)
EXPOSE 9200
# Elasticsearch (Cluster communication)
EXPOSE 9300

# Data science and exploratory tools

# Jupyter Notebook
EXPOSE 8888

# Game servers and specific development needs

# Minecraft server
EXPOSE 25565   
# Custom application or debugging server (often used by PHP, .NET)
EXPOSE 9000
# Additional debugging or application port (Grafana, Prometheus)
EXPOSE 9090

# Additional general-purpose ports
EXPOSE 4000
EXPOSE 7000
EXPOSE 8001
EXPOSE 8082
EXPOSE 8100
EXPOSE 8500
EXPOSE 8600

