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

sh:
	$(RUN_IT) /bin/sh

.PHONY: img run sh
