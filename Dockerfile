FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential flex bison libncursesw5-dev git locales bash libreadline-dev && \
    locale-gen ga_IE.utf8 && locale-gen ga_IE@euro && update-locale LANG=ga_IE.utf8

WORKDIR /opt/

RUN git clone https://github.com/poldy/OpenCOMAL.git

WORKDIR /opt/OpenCOMAL

RUN git checkout tags/v0.3.0 && \
    make

ENV PATH="/opt/OpenCOMAL/bin:$PATH"