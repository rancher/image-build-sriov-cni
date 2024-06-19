ARG TAG=v2.8.0
ARG COMMIT="14fbf4a4addb9e946698edc7c5ea4cf20fe498e5"
ARG BCI_IMAGE=registry.suse.com/bci/bci-base
ARG GO_IMAGE=rancher/hardened-build-base:v1.21.11b3

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
RUN git checkout ${COMMIT} -b ${TAG} 
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
