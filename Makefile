MY_USER := $(shell id -u)
MY_GROUP := $(shell id -g)
ME := $(MY_USER):$(MY_GROUP)

BLUE := blue
WHAT ?= $(BLUE)
ARGS ?=

DEV_CONTAINER ?= $(BLUE)-dev
DEV_DOCKER_FILE ?= dev.Dockerfile
DEV_IMAGE ?= blue-dev

IN_DEV_CONTAINER ?= docker exec $(DEV_CONTAINER)
DISASM ?= $(IN_DEV_CONTAINER) objdump -D -M intel -m i386:x86-64 $(ARGS)

FASM ?= fasm

all: dev-env dev-start compile
	@true

dev-env: dev-stop
	docker build -t $(DEV_IMAGE) -f $(DEV_DOCKER_FILE) .

dev-start: dev-stop
	docker run -d -t -u $(ME) -v ./:/app --name $(DEV_CONTAINER) $(DEV_IMAGE)

dev-stop:
	docker rm -f $(DEV_CONTAINER) || true

compile:
	$(IN_DEV_CONTAINER) $(FASM) $(WHAT).asm $(WHAT) && chmod +x $(WHAT)

run:
	$(IN_DEV_CONTAINER) ./$(WHAT)

dis:
	$(DISASM) $(WHAT)

disb: ARGS=-b binary
disb: dis
	@true

discb: WHAT=code_buffer_dump.out
discb: disb
	@true

clean:
	rm -f $(BLUE) *.out
	
.PHONY:
	dev-env dev-start dev-stop \
	compile run dis disb discb clean
