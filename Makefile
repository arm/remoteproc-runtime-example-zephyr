TOOLS_DOCKERFILE = docker/tools.dockerfile
DEPLOY_DOCKERFILE = docker/deploy.dockerfile

TOOLS_NAME = ambient-zephyr-tools:latest
DEPLOY_NAME = ambient-zephyr:latest

MOUNT_DIR = /project
MOUNT = -v $(PWD):${MOUNT_DIR}

BUILD_DIR = ${MOUNT_DIR}/build
BUILD_CMD = west build -b alif_e7_dk_rtss_he ${MOUNT_DIR} --build-dir ${BUILD_DIR}

deploy: ${DEPLOY_DOCKERFILE} build
	docker build -t ${DEPLOY_NAME} -f ${DEPLOY_DOCKERFILE} build

build: tools src/main.c
	docker run --init --rm $(MOUNT) $(TOOLS_NAME) $(BUILD_CMD)

tools: ${TOOLS_DOCKERFILE}
	docker build -t ${TOOLS_NAME} -f ${TOOLS_DOCKERFILE} docker
