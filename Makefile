MY_USER := $(shell id -u)
MY_GROUP := $(shell id -g)
ME := $(MY_USER):$(MY_GROUP)

BLUE := blue
DEMO := demo

DEV_CONTAINER ?= $(BLUE)-dev

COMPOSE_FILES ?= -f dev.compose.yml
DOCKER_COMPOSE ?= RUN_AS=$(ME) docker compose $(COMPOSE_FILES)
IN_DEV_CONTAINER ?= $(DOCKER_COMPOSE) exec $(DEV_CONTAINER)

LD ?= ld.gold

all: dev-env build link run
	@true

dev-env: dev-stop
	$(DOCKER_COMPOSE) build

dev-start: dev-stop
	$(DOCKER_COMPOSE) up -d

dev-stop:
	$(DOCKER_COMPOSE) down

build:
	$(IN_DEV_CONTAINER) nasm -felf64 $(BLUE).asm -l $(BLUE).lst

link:
	$(IN_DEV_CONTAINER) $(LD) -o $(BLUE) $(BLUE).o

compile: build link
	@true

run:
	$(IN_DEV_CONTAINER) ./$(BLUE)

dis-demo:
	$(IN_DEV_CONTAINER) ndisasm -b64 demo

dis-out:
	$(IN_DEV_CONTAINER) ndisasm -b64 out.bin

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
	comile build link run \
	build-demo link-demo run-demo \
	dis dis-out \
	start
