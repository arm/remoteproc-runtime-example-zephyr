TOOLS_DOCKERFILE = docker/tools.dockerfile
DEPLOY_DOCKERFILE = docker/deploy.dockerfile

TOOLS_NAME = ambient-zephyr-tools:latest
DEPLOY_NAME = ambient-zephyr:latest

MOUNT = -v $(PWD):/workdir/project
BUILD_CMD = west build -b alif_e7_dk_rtss_he project --build-dir project/build

deploy: ${DEPLOY_DOCKERFILE} build
	docker build -t ${DEPLOY_NAME} -f ${DEPLOY_DOCKERFILE} build

build: tools
	docker run --init --rm $(MOUNT) $(TOOLS_NAME) $(BUILD_CMD)

tools: ${TOOLS_DOCKERFILE}
	docker build -t ${TOOLS_NAME} -f ${TOOLS_DOCKERFILE} docker
