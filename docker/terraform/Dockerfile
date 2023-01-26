ARG IMAGE
FROM ${IMAGE}

RUN apk update && apk add --no-cache \
  curl \
  unzip \
  bash \
  aws-cli \
  gettext


RUN curl -s https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip -o /tmp/terraform_1.3.7_linux_amd64.zip && \
  unzip /tmp/terraform_1.3.7_linux_amd64.zip -d /tmp/ && \
  chmod +x /tmp/terraform && mv /tmp/terraform /usr/bin/ && \
  rm -rf /tmp/terraform_1.3.7_linux_amd64.zip

ENV TF_CLI_CONFIG_FILE=/home/terraformrc
WORKDIR /app
ENTRYPOINT ["/usr/bin/terraform"]