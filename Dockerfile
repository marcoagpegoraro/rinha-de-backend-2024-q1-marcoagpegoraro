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

# RUN git clone https://github.com/vlang/v /opt/vlang && cd /opt/vlang && git reset --hard 5b1b2cc && make
RUN wget https://github.com/vlang/v/releases/download/0.4.2/v_linux.zip
RUN mv v_linux.zip /opt/vlang 
RUN mkdir temp
RUN unzip v_linux.zip -d temp
RUN cp -r temp/v/* . && rm -rf temp
# RUN wget https://github.com/vlang/v/archive/refs/tags/0.4.3.zip && mv 0.4.3.zip /opt/vlang && unzip 0.4.3.zip && make



COPY . ./app
RUN v -prod -d no_segfault_handler ./app
EXPOSE 8080

CMD [ "./app/app" ]
# CMD [ "sleep", "infinity" ]