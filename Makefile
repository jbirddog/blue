USER_ID ?= $(shell id -u)
GROUP_ID ?= $(shell id -g)
ME ?= $(USER_ID):$(GROUP_ID)

RUN ?= docker run --rm -u $(ME) -v .:/app blue
RUN_IT ?= docker run --rm -u $(ME) -v .:/app -it blue

all: img run

img:
	docker build -t blue .

run:
	$(RUN) go run .

fmt:
	$(RUN) go fmt

sh:
	$(RUN_IT) /bin/bash

scratch:
	fasm scratch.asm

.PHONY: img run fmt sh scratch
