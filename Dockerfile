FROM golang:1.10-alpine3.7 as builder

# ENV GIT_REPO_URL https://github.com/Praqma/helmsman.git
# ENV GIT BRANCH master

RUN mkdir /go/src/helmsman
WORKDIR /go/src/helmsman
COPY . /go/src/helmsman
RUN apk --no-cache add make git

# RUN git clone https://github.com/bobhenkel/helmsman.git; cd helmsman; git checkout no_ns

#  build a statically linked binary so that it works on stripped linux images such as alpine/busybox.
RUN LastTag=$(git describe --abbrev=0 --tags) \
    && TAG=$LastTag-$(date +"%d%m%y") \
    && LT_SHA=$(git rev-parse ${LastTag}^{}) \
    && LC_SHA=$(git rev-parse HEAD) \
    && if [ ${LT_SHA} != ${LC_SHA} ]; then TAG=latest-$(date +"%d%m%y"); fi \
    && make dependencies \
    && CGO_ENABLED=0 GOOS=linux go install -a -ldflags '-X main.version='$TAG' -extldflags "-static"' .


# The image to keep
FROM alpine:3.7
COPY ./tests /tmp

RUN apk add --update --no-cache ca-certificates git

ARG HELM_VERSION=v2.11.0
ARG KUBE_VERSION="v1.10.3"
ARG GOSS_VERSION=v0.3.6

RUN apk --no-cache update \
    && rm -rf /var/cache/apk/* \
    && apk add --update -t deps curl tar gzip make bash \
    && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -L http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar zxv -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf /tmp/linux-amd64 \
    && curl -L https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64 -o /usr/local/bin/goss \
    && chmod +x /usr/local/bin/goss




COPY --from=builder /go/bin/helmsman   /bin/helmsman

#RUN adduser -D -g '' helmsman
#USER helmsman

RUN mkdir -p ~/.helm/plugins \
    && helm plugin install https://github.com/hypnoglow/helm-s3.git \
    && helm plugin install https://github.com/nouney/helm-gcs \
    && helm plugin install https://github.com/databus23/helm-diff \
    && helm plugin install https://github.com/futuresimple/helm-secrets \
    && rm -r /tmp/helm-diff /tmp/helm-diff.tgz \
    && cd /tmp; wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64; mv heptio-authenticator-aws_0.3.0_linux_amd64 heptio-authenticator-aws; chmod +x heptio-authenticator-aws; mv heptio-authenticator-aws /usr/local/bin

WORKDIR /tmp
# ENTRYPOINT ["/bin/helmsman"]
