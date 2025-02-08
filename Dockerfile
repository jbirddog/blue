FROM debian:testing-slim

WORKDIR /app

ENV GOCACHE=/app/.cache

#RUN apk add --no-cache build-base go
RUN apt-get update && apt-get install -y golang && rm -rf /var/lib/apt/lists/*

COPY . /app/
