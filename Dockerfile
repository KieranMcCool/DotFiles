FROM ubuntu:latest

RUN apt update
RUN apt install -y git
RUN apt install -y curl
RUN apt install -y neovim

COPY . /etc/DotFiles
WORKDIR /etc/DotFiles

RUN chmod +x ./install.sh
RUN ./install.sh

CMD /bin/bash