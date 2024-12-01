FROM golang:1.23 AS builder

COPY . ./build/promobee/
RUN cd ./build/promobee && go build -mod=vendor -o /promobee

FROM ubuntu:24.04
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
RUN DEBIAN_FRONTEND=noninteractive \
  apt update \
  && apt dist-upgrade -y \
  && apt install -y openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
RUN groupadd -g 568 prunner
RUN useradd -m -u 568 -g 568 prunner
RUN passwd -l root
USER prunner
WORKDIR /home/prunner
RUN mkdir bin
COPY --from=builder /promobee bin/.
ENTRYPOINT [ "bin/promobee", "--store", "keys/kstore", "--api_key"]
