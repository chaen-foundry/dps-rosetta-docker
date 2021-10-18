FROM golang:1.17-buster AS build-setup

RUN apt-get update
RUN apt-get -y install cmake zip sudo git

#ENV FLOW_DPS_REPO="https://github.com/optakt/flow-dps"
ENV FLOW_DPS_REPO="https://github.com/dapperlabs/flow-dps"
# v1.4.6 with some flag changes
#ENV FLOW_DPS_BRANCH=m4ksio/existing-v0.22
ENV FLOW_DPS_MAINNET13_BRANCH="m4ksio/v1.4.6"
ENV FLOW_DPS_MAINNET14_BRANCH="m4ksio/v1.4.6-v0.22"

ENV DPS_ROSETTA_DOCKER_REPO="https://github.com/dapperlabs/dps-rosetta-docker"
ENV DPS_ROSETTA_DOCKER_BRANCH=v0.22-debug

ENV FLOW_ROSETTA_REPO="https://github.com/dapperlabs/flow-rosetta"
ENV FLOW_ROSETTA_BRANCH=wait

ENV FLOW_GO_REPO="https://github.com/onflow/flow-go"
ENV FLOW_GO_BRANCH=v0.22.10

ENV ROSETTA_DISPATCHER_REPO="https://github.com/dapperlabs/rosetta-dispatcher"
ENV ROSETTA_DISPATCHER_BRANCH=master

ENV LOGLEVEL="info"

RUN mkdir /dps /docker /flow-go /flow-rosetta

WORKDIR /dps

# clone repos and create links
RUN git clone $FLOW_DPS_BRANCH $FLOW_DPS_REPO /dps
RUN git clone --branch $DPS_ROSETTA_DOCKER_BRANCH $DPS_ROSETTA_DOCKER_REPO /docker
RUN git clone --branch $FLOW_GO_BRANCH $FLOW_GO_REPO /flow-go
RUN git clone --branch $FLOW_ROSETTA_BRANCH $FLOW_ROSETTA_REPO /flow-rosetta
RUN git clone --branch $ROSETTA_DISPATCHER_BRANCH $ROSETTA_DISPATCHER_REPO /rosetta-dispatcher

RUN ln -s /flow-go /dps/flow-go
RUN ln -s /flow-go /flow-rosetta/flow-go

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build  \
    make -C /flow-go crypto/relic/build #prebuild crypto dependency

FROM build-setup AS build-mainnet-13

WORKDIR /dps
RUN  --mount=type=cache,target=/go/pkg/mod \
     --mount=type=cache,target=/root/.cache/go-build  \
     git checkout $FLOW_DPS_MAINNET13_BRANCH \
     go build -o /dps-mainnet-13 -ldflags "-extldflags -static" ./cmd/flow-dps-server && \
     chmod a+x /dps-mainnet-13


FROM build-setup AS build-live

WORKDIR /dps
RUN  --mount=type=cache,target=/go/pkg/mod \
     --mount=type=cache,target=/root/.cache/go-build  \
     git checkout $FLOW_DPS_MAINNET14_BRANCH \
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

FROM build-setup AS build-rosetta-dispatcher

WORKDIR /rosetta-dispatcher
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build  \
     go build -o /rosetta-dispatcher -ldflags "-extldflags -static" ./ && \
    chmod a+x /rosetta-dispatcher



## Add the statically linked binary to a distroless image
FROM ubuntu:latest as production

RUN apt-get update
RUN apt-get -y install supervisor wget

COPY --from=build-mainnet-13 /dps-mainnet-13 /bin/dps-mainnet-13
COPY --from=build-live /dps-live-index /bin/dps-live-index
COPY --from=build-rosetta /app-rosetta /bin/rosetta
COPY --from=build-rosetta-dispatcher /rosetta-dispatcher /bin/rosetta-dispatcher

COPY --from=build-setup /docker/mainnet/supervisord.conf /supervisord.conf
COPY --from=build-setup /docker/common.sh /common.sh
COPY --from=build-setup /docker/mainnet/run.sh /run.sh

RUN chmod a+x /run.sh

EXPOSE 8080 8013 8099 9000

CMD ["bash", "-x", "/run.sh"]