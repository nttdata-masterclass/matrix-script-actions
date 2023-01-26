SHELL = /bin/bash

PROJECT = nttdata
ENV     = demo
SERVICE = actions

DOCKER_UID  = $(shell id -u)
DOCKER_GID  = $(shell id -g)
DOCKER_USER = $(shell whoami)

base:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:base -f docker/base/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:build --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -f docker/build/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:codecov --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -f docker/codecov/Dockerfile .

build:
	@echo '${DOCKER_USER}:x:${DOCKER_UID}:${DOCKER_GID}::/app:/sbin/nologin' > passwd
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/app:/app ${PROJECT}-${ENV}-${SERVICE}:build install

jest:
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/app:/app ${PROJECT}-${ENV}-${SERVICE}:build test

codecov:
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}:/app -e CODECOV_TOKEN=${CODECOV_TOKEN} ${PROJECT}-${ENV}-${SERVICE}:codecov -t ${CODECOV_TOKEN}

snyk:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:snyk -f docker/snyk/Dockerfile .
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/app:/app ${PROJECT}-${ENV}-${SERVICE}:snyk auth ${SNYK_TOKEN}
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/app:/app ${PROJECT}-${ENV}-${SERVICE}:snyk code test

terraform:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:terraform --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -f docker/terraform/Dockerfile .

slack:
	curl -X POST \
	  -d 'payload={"blocks":[{"type":"section","text":{"type":"plain_text","text":"Repositorio desplegado:","emoji":true}},{"type":"section","fields":[{"type":"plain_text","text":"Name:","emoji":true},{"type":"plain_text","text":"${GITHUB_REPOSITORY}","emoji":true},{"type":"plain_text","text":"Env:","emoji":true},{"type":"plain_text","text":"${ENV}","emoji":true}]},{"type":"section","text":{"type":"mrkdwn","text":"Para acceder al despliegue:"},"accessory":{"type":"button","text":{"type":"plain_text","text":"GitHub","emoji":true},"value":"click_me_123","url":"https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}/","action_id":"button-action"}}]}' \
	"${SLACK_WEBHOOK}"
