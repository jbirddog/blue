FROM alpine:3.21

WORKDIR /app

RUN apk add --no-cache build-base go

COPY *.c /app/
