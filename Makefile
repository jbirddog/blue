MY_USER := $(shell id -u)
MY_GROUP := $(shell id -g)
ME := $(MY_USER):$(MY_GROUP)

BLUE := blue
DEMO := demo

DEV_CONTAINER ?= $(BLUE)-dev

COMPOSE_FILES ?= -f dev.compose.yml
DOCKER_COMPOSE ?= RUN_AS=$(ME) docker compose $(COMPOSE_FILES)
IN_DEV_CONTAINER ?= $(DOCKER_COMPOSE) run --rm $(DEV_CONTAINER)

LD ?= ld

all: dev-env build link run
	@true

dev-env:
	$(DOCKER_COMPOSE) build

build:
	$(IN_DEV_CONTAINER) nasm -felf64 $(BLUE).asm -l $(BLUE).lst

link:
	$(IN_DEV_CONTAINER) $(LD) -o $(BLUE) $(BLUE).o

compile: build link
	@true

run:
	./$(BLUE)

dis-demo:
	ndisasm -b64 demo

dis-out:
	ndisasm -b64 out.bin

dis: dis-out dis-demo
	@true

build-demo:
	nasm -felf64 $(DEMO).asm

link-demo:
	ld -o $(DEMO) $(DEMO).o

run-demo:
	./$(DEMO)

start: run build-demo link-demo run-demo
	@true

.PHONY:
	dev-env \
	compile \
	build link run \
	build-demo link-demo run-demo \
	dis dis-out \
	start
