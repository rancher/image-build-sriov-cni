ARG TAG="2.6.2"
ARG BCI_IMAGE=registry.suse.com/bci/bci-base:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.18.1b7

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x && \
    apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone --depth=1 https://github.com/k8snetworkplumbingwg/sriov-cni && \
    cd sriov-cni && \
    git fetch --all --tags --prune && \
    git checkout ${TAG} && \
    make clean && \
    make build

# Create the sriov-cni image
FROM ${BCI_IMAGE}
WORKDIR /
COPY --from=builder /go/sriov-cni/build/sriov /usr/bin/
COPY --from=builder /go/sriov-cni/images/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
