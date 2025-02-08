FROM debian:testing-slim

WORKDIR /app

RUN apt-get update \
  && apt-get install -y \
     build-essential \
     ninja-build \
  && rm -rf /var/lib/apt/lists/*

COPY . /app/
