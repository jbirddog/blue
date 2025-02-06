FROM alpine:3.21

WORKDIR /app

ENV GOCACHE=/app/.cache

RUN apk add --no-cache build-base go

COPY *.c /app/
