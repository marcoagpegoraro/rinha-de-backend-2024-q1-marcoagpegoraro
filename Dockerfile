FROM alpine:3.11

LABEL maintainer="Marco Pegoraro <marco@marcoagpegoraro.com.br>"

WORKDIR /opt/vlang

ENV VVV  /opt/vlang
ENV PATH /opt/vlang:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p /opt/vlang && ln -s /opt/vlang/v /usr/bin/v

RUN apk --no-cache add \
  git make upx gcc \
  musl-dev \
  openssl-dev sqlite-dev \
  libx11-dev glfw-dev freetype-dev \
  libpq postgresql-dev

RUN git clone https://github.com/vlang/v /opt/vlang && make

COPY ./src ./app
RUN v -prod -d no_segfault_handler ./app
EXPOSE 8080

CMD [ "./app/app" ]
