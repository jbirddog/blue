MY_USER := $(shell id -u)
MY_GROUP := $(shell id -g)
ME := $(MY_USER):$(MY_GROUP)

BLUE := blue
DEMO := demo

DEV_CONTAINER ?= $(BLUE)-dev
DEV_DOCKER_FILE ?= dev.Dockerfile
DEV_IMAGE ?= blue-dev

IN_DEV_CONTAINER ?= docker exec $(DEV_CONTAINER)

LD ?= ld.gold

all: dev-env dev-start compile
	@true

dev-env: dev-stop
	docker build -t $(DEV_IMAGE) -f $(DEV_DOCKER_FILE) .

dev-start: dev-stop
	docker run -d -t -u $(ME) -v ./:/app --name $(DEV_CONTAINER) $(DEV_IMAGE)

dev-stop:
	docker rm -f $(DEV_CONTAINER) || true

compile:
	$(IN_DEV_CONTAINER) fasm $(BLUE).asm $(BLUE)

run:
	$(IN_DEV_CONTAINER) ./$(BLUE)

dis-demo:
	$(IN_DEV_CONTAINER) ndisasm -b64 demo

dis-out:
	$(IN_DEV_CONTAINER) ndisasm -b64 blue

dis: dis-out dis-demo
	@true

build-demo:
	$(IN_DEV_CONTAINER) nasm -felf64 $(DEMO).asm

link-demo:
	$(IN_DEV_CONTAINER) ld -o $(DEMO) $(DEMO).o

run-demo:
	$(IN_DEV_CONTAINER) ./$(DEMO)

start: run build-demo link-demo run-demo
	@true

.PHONY:
	dev-env dev-start dev-stop \
	compile run \
	build-demo link-demo run-demo \
	dis dis-out \
	start
