ARG BCI_IMAGE=registry.suse.com/bci/bci-base
ARG GO_IMAGE=rancher/hardened-build-base:v1.22.5b1

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x && \
    apk --no-cache add \
    git \
    make
ARG TAG=v2.8.0
RUN git clone --depth=1 https://github.com/k8snetworkplumbingwg/sriov-cni
WORKDIR sriov-cni
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG}
RUN make clean && make build 

# Create the sriov-cni image
FROM ${BCI_IMAGE}
RUN zypper refresh && \
    zypper update -y && \
    zypper install -y gawk which && \
    zypper clean -a
WORKDIR /
COPY --from=builder /go/sriov-cni/build/sriov /usr/bin/
COPY --from=builder /go/sriov-cni/images/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
