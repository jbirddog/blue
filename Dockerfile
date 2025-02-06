FROM alpine:3.21

WORKDIR /app

RUN apk add --no-cache build-base samurai

COPY *.c /app/
