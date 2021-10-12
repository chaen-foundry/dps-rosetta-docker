FROM golang:1.17-buster AS build-setup

RUN apt-get update
RUN apt-get -y install cmake zip sudo git

#ENV FLOW_DPS_REPO="https://github.com/optakt/flow-dps"
ENV FLOW_DPS_REPO="https://github.com/dapperlabs/flow-dps"
# v1.4.3 with some flag changes
ENV FLOW_DPS_BRANCH=m4ksio/existing

ENV DPS_ROSETTA_DOCKER_REPO="https://github.com/dapperlabs/dps-rosetta-docker"
ENV DPS_ROSETTA_DOCKER_BRANCH=v0.22-debug

ENV FLOW_ROSETTA_REPO="https://github.com/dapperlabs/flow-rosetta"
ENV FLOW_ROSETTA_BRANCH=wait

ENV FLOW_GO_REPO="https://github.com/onflow/flow-go"
ENV FLOW_GO_BRANCH=v0.22


ENV ROSETTA_DISPATCHER_BRANCH=master

RUN mkdir /dps /docker /flow-go /flow-rosetta

WORKDIR /dps

# clone repos and create links
RUN git clone --branch $FLOW_DPS_BRANCH $FLOW_DPS_REPO /dps
RUN git clone --branch $DPS_ROSETTA_DOCKER_BRANCH $DPS_ROSETTA_DOCKER_REPO /docker
RUN git clone --branch $FLOW_GO_BRANCH $FLOW_GO_REPO /flow-go
RUN git clone --branch $FLOW_ROSETTA_BRANCH $FLOW_ROSETTA_REPO /flow-rosetta

RUN ln -s /flow-go /dps/flow-go
RUN ln -s /flow-go /flow-rosetta/flow-go

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build  \
    make -C /flow-go crypto/relic/build #prebuild crypto dependency

FROM build-setup AS build-live

WORKDIR /dps
RUN  --mount=type=cache,target=/go/pkg/mod \
     --mount=type=cache,target=/root/.cache/go-build  \
     go build -o /dps-live-index -tags relic -ldflags "-extldflags -static" ./cmd/flow-dps-live && \
     chmod a+x /dps-live-index

FROM build-setup AS build-restore-index

WORKDIR /dps
RUN  --mount=type=cache,target=/go/pkg/mod \
     --mount=type=cache,target=/root/.cache/go-build  \
     go build -o /restore-index-snapshot -ldflags "-extldflags -static" ./cmd/restore-index-snapshot && \
     chmod a+x /restore-index-snapshot


FROM build-setup AS build-rosetta

WORKDIR /flow-rosetta
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build  \
     go build -o /app-rosetta -ldflags "-extldflags -static" ./cmd/flow-rosetta-server && \
    chmod a+x /app-rosetta

## Add the statically linked binary to a distroless image
FROM ubuntu:latest as production

RUN apt-get update
RUN apt-get -y install supervisor wget

COPY --from=build-live /dps-live-index /bin/dps-live-index
COPY --from=build-rosetta /app-rosetta /bin/rosetta

#RUN chmod a+x  \
#    /bin/dps-live-index \
#    /bin/rosetta

COPY --from=build-setup /docker/mainnet/supervisord.conf /supervisord.conf
COPY --from=build-setup /docker/common.sh /common.sh
COPY --from=build-setup /docker/mainnet/run.sh /run.sh

RUN chmod a+x /run.sh

EXPOSE 8080 8099 9000

CMD ["bash", "-x", "/run.sh"]