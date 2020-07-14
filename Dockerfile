FROM node:12.18.2-alpine3.9

USER root

# Add needed packages to build container
RUN apk add --update ca-certificates \
  && apk add --update -t deps \
  docker \
  curl \
  unzip \
  git \ 
  openssl \
  bash \
  && apk add python3

# Install gcloud
RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-278.0.0-linux-x86_64.tar.gz > /tmp/google-cloud-sdk.tar.gz
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Install kip cli
RUN curl -LOk https://github.com/debugged-software/kip/releases/download/v0.0.14/kip--linux-386.zip \
  && unzip kip--linux-386.zip \
  && mv linux-386/kip /usr/local/bin \
  && rm kip--linux-386.zip

# Install helm
ENV HELM_LATEST_VERSION="v3.1.2"

RUN curl -LOk https://get.helm.sh/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
  && tar -xf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin \
  && rm -f /helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin/kubectl

# Install protoc
ARG PROTOC_ZIP="protoc-3.12.0-linux-x86_64.zip"
RUN curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.12.0/$PROTOC_ZIP
RUN unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
RUN unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
RUN rm -f $PROTOC_ZIP

ARG COMMON_PROTO_ZIP="common-protos-1_3_1.zip"
ARG COMMON_PROTO_ZIP_PATH="googleapis-common-protos-1_3_1"
RUN curl -OL https://github.com/googleapis/googleapis/archive/$COMMON_PROTO_ZIP
RUN unzip -o $COMMON_PROTO_ZIP -d /usr/local/include "$COMMON_PROTO_ZIP_PATH/google/api/*"
RUN mv /usr/local/include/$COMMON_PROTO_ZIP_PATH/google/api /usr/local/include/google/api
RUN rm -rf /usr/local/include/$COMMON_PROTO_ZIP_PATH
RUN rm -f $COMMON_PROTO_ZIP

# Cleanup
RUN apk del --purge deps \
  && rm /var/cache/apk/*