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
