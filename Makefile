USER_ID ?= $(shell id -u)
GROUP_ID ?= $(shell id -g)
ME ?= $(USER_ID):$(GROUP_ID)

RUN ?= docker run --rm -u $(ME) -v .:/app blue
RUN_IT ?= docker run --rm -u $(ME) -v .:/app -it blue

BLUE ?= build/blue
NINJA ?= ninja

all: img run

img:
	docker build -t blue .

build:
	$(RUN) $(NINJA)

run: build
	$(RUN) $(BLUE) test/exit.blue

sh:
	$(RUN_IT) /bin/bash

scratch:
	fasm scratch.asm

.PHONY: img build run sh scratch
