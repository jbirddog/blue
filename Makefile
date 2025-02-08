USER_ID ?= $(shell id -u)
GROUP_ID ?= $(shell id -g)
ME ?= $(USER_ID):$(GROUP_ID)

RUN ?= docker run --rm -u $(ME) -v .:/app blue
RUN_IT ?= docker run --rm -u $(ME) -v .:/app -it blue

BLUE ?= ./a.out

all: img run

img:
	docker build -t blue .

build:
	$(RUN) cc -Wall -Wpedantic -std=c11 v5.c

run: build
	$(RUN) $(BLUE)

sh:
	$(RUN_IT) /bin/bash

scratch:
	fasm scratch.asm

.PHONY: img build run sh scratch
