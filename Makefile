TOOLS_DOCKERFILE := docker/tools.dockerfile
DEPLOY_DOCKERFILE := docker/deploy.dockerfile

TOOLS_NAME  := ambient-zephyr-tools:latest
DEPLOY_NAME := ambient-zephyr:latest

MOUNT_DIR := /project
MOUNT     := -v $(CURDIR):$(MOUNT_DIR)

RUN_FLAGS   := --init --rm -w $(MOUNT_DIR) $(MOUNT)
CHOWN_FLAGS := --rm --entrypoint "" -u 0 -w $(MOUNT_DIR) $(MOUNT)

BUILD_DIR := $(MOUNT_DIR)/build
BUILD_CMD := west build -b alif_e7_dk_rtss_hp $(MOUNT_DIR) --build-dir $(BUILD_DIR)

HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

.PHONY: all build deploy tools prep clean fix-permissions

all: deploy

prep:
	@mkdir -p build
	@chmod -R a+rwX build

build: prep tools src/main.c
	docker run $(RUN_FLAGS) $(TOOLS_NAME) $(BUILD_CMD)
	docker run $(CHOWN_FLAGS) $(TOOLS_NAME) \
		chown -R $(HOST_UID):$(HOST_GID) $(BUILD_DIR)

deploy: $(DEPLOY_DOCKERFILE) build
	docker build -t $(DEPLOY_NAME) -f $(DEPLOY_DOCKERFILE) build


tools: $(TOOLS_DOCKERFILE)
	docker build -t $(TOOLS_NAME) -f $(TOOLS_DOCKERFILE) docker

clean:
	rm -rf build

fix-permissions:
	docker run $(CHOWN_FLAGS) $(TOOLS_NAME) \
		chown -R $(HOST_UID):$(HOST_GID) $(BUILD_DIR)
