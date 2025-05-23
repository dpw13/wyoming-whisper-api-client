DOCKER_REPO := docker.smokeybear.duckdns.org
WHISPER_CPP_VERSION := 1.7.5

all:
	docker build --build-arg WHISPER_CPP_VERSION=${WHISPER_CPP_VERSION} . -t ${DOCKER_REPO}/wmw/wyoming-whisper-api-client:v${WHISPER_CPP_VERSION}
