USER_ID ?= $(shell id -u)
GROUP_ID ?= $(shell id -g)
ME ?= $(USER_ID):$(GROUP_ID)

all: img compile

img:
	docker build -t blue .

compile:
	docker run --rm -u $(ME) -v .:/app blue gcc v5.c

.PHONY: img compile
