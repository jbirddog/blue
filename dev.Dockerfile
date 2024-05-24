FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y \
       binutils \
       nasm \
    && rm -rf /var/lib/apt/lists/*