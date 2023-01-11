ARG IMAGE
FROM ${IMAGE}

RUN apk update && apk upgrade && apk add --no-cache \
  npm \
  git \
  mercurial \
  curl

# RUN npm install -g codecov
RUN curl -Os https://uploader.codecov.io/latest/alpine/codecov
RUN chmod +x codecov && mv codecov /usr/bin/codecov

ENTRYPOINT [ "codecov" ]