FROM ubuntu:24.04 AS build

ARG OPENCOMAL_VERSION=0.3.0

# The build compiles the Irish message catalog in the ga_IE@euro locale
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential flex bison libncurses-dev libreadline-dev locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen ga_IE@euro

ADD --checksum=sha256:c3b2db01f467964fdac7decaff505569b95d64429db3f7ddd3286f7b06586288 \
    https://github.com/poldy/OpenCOMAL/archive/refs/tags/v${OPENCOMAL_VERSION}.tar.gz /tmp/opencomal.tar.gz

# The OpenCOMAL makefile asks ncursesw5-config for its ncurses flags. Ubuntu 24.04
# only ships ncursesw6-config, so pass the (identical) flags explicitly.
RUN mkdir /opt/OpenCOMAL \
    && tar -xzf /tmp/opencomal.tar.gz -C /opt/OpenCOMAL --strip-components=1 \
    && make -C /opt/OpenCOMAL \
        TARG_CFLAGS="$(ncursesw6-config --cflags)" \
        TARG_LDFLAGS="-lreadline -lm $(ncursesw6-config --libs)"

FROM ubuntu:24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libncursesw6 libreadline8t64 locales bash \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen ga_IE.utf8 && locale-gen ga_IE@euro && update-locale LANG=ga_IE.utf8

COPY --from=build /opt/OpenCOMAL/bin /opt/OpenCOMAL/bin

ENV PATH="/opt/OpenCOMAL/bin:$PATH"
