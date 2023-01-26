SHELL = /bin/bash

PROJECT            = nttdata
ENV                = demo
SERVICE            = actions
DOCKER_UID         = $(shell id -u)
DOCKER_GID         = $(shell id -g)
DOCKER_USER        = $(shell whoami)
AWS_DEFAULT_REGION = us-east-1
TF_ORGANIZATION    = nttdata-masterclass

base:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:base -f docker/base/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:build --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -f docker/build/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:codecov --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -f docker/codecov/Dockerfile .

build:
	@echo '${DOCKER_USER}:x:${DOCKER_UID}:${DOCKER_GID}::/app:/sbin/nologin' > passwd
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/app:/app ${PROJECT}-${ENV}-${SERVICE}:build install

compress:
	@rm -rf terraform/app.zip && rm -rf app/app.zip
	@cd app/ && zip -rq app.zip ./*
	@mv app/app.zip terraform/
	@rm -rf app/app.zip

jest:
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/app:/app ${PROJECT}-${ENV}-${SERVICE}:build test

codecov:
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}:/app -e CODECOV_TOKEN=${CODECOV_TOKEN} ${PROJECT}-${ENV}-${SERVICE}:codecov -t ${CODECOV_TOKEN}

snyk:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:snyk -f docker/snyk/Dockerfile .
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/app:/app ${PROJECT}-${ENV}-${SERVICE}:snyk auth ${SNYK_TOKEN}
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/app:/app ${PROJECT}-${ENV}-${SERVICE}:snyk code test

tf_base:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:terraform --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -f docker/terraform/Dockerfile .
	@rm -rf terraformrc
	@rm -rf backend.hcl
	@cp configs/terraformrc terraformrc
	@cp configs/backend.hcl backend.hcl
	@sed -i "s|{{TF_TOKEN}}|${TF_TOKEN}|g" terraformrc
	@sed -i "s|{{WORKSPACES}}|${PROJECT}-${ENV}-${SERVICE}|g" backend.hcl
	@sed -i "s|{{TF_ORGANIZATION}}|${TF_ORGANIZATION}|g" backend.hcl
	@echo '${DOCKER_USER}:x:${DOCKER_UID}:${DOCKER_GID}::/app:/sbin/nologin' > passwd

tf_init:
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/backend.hcl:/home/backend.hcl:ro -v ${PWD}/terraformrc:/home/terraformrc:ro -v ${PWD}/terraform:/app \
	  ${PROJECT}-${ENV}-${SERVICE}:terraform init -backend-config=/home/backend.hcl
	@curl -s --header "Authorization: Bearer ${TF_TOKEN}" --header "Content-Type: application/vnd.api+json" --request PATCH --data '{"data":{"type":"workspaces","attributes":{"execution-mode":"local"}}}' "https://app.terraform.io/api/v2/organizations/${TF_ORGANIZATION}/workspaces/${PROJECT}-${ENV}-${SERVICE}"

tf_apply:
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/backend.hcl:/home/backend.hcl:ro -v ${PWD}/terraformrc:/home/terraformrc:ro -v ${PWD}/terraform:/app \
      -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
      -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
      -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
    ${PROJECT}-${ENV}-${SERVICE}:terraform apply -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve

slack:
	@curl -X POST \
	  -d 'payload={"blocks":[{"type":"section","text":{"type":"plain_text","text":"Repositorio desplegado:","emoji":true}},{"type":"section","fields":[{"type":"plain_text","text":"Name:","emoji":true},{"type":"plain_text","text":"${GITHUB_REPOSITORY}","emoji":true},{"type":"plain_text","text":"Env:","emoji":true},{"type":"plain_text","text":"${ENV}","emoji":true}]},{"type":"section","text":{"type":"mrkdwn","text":"Para acceder al despliegue:"},"accessory":{"type":"button","text":{"type":"plain_text","text":"GitHub","emoji":true},"value":"click_me_123","url":"https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}/","action_id":"button-action"}}]}' \
	"${SLACK_WEBHOOK}"

tf_destroy:
	@docker run --rm -u ${DOCKER_UID}:${DOCKER_GID} -v ${PWD}/passwd:/etc/passwd:ro -v ${PWD}/backend.hcl:/home/backend.hcl:ro -v ${PWD}/terraformrc:/home/terraformrc:ro -v ${PWD}/terraform:/app \
      -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
      -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
      -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
    ${PROJECT}-${ENV}-${SERVICE}:terraform destroy -var="name=${PROJECT}-${ENV}-${SERVICE}" -auto-approve