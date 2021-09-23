FROM golang:1.17-buster AS build-setup

RUN apt-get update
RUN apt-get -y install cmake zip sudo git

ENV DPS_ROSETTA_DOCKER_BRANCH=v0.1
ENV FLOW_GO_BRANCH=v0.21
ENV RESTORE_INDEX_BRANCH=v1.3.2
ENV ROSETTA_DISPATCHER_BRANCH=master
ENV DPS_LIVE_BRANCH=m4ksio/rosetta-wait

RUN mkdir /dps /docker
WORKDIR /dps

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build  \
    git clone https://github.com/dapperlabs/flow-dps /dps && \
    git clone --branch $DPS_ROSETTA_DOCKER_BRANCH https://github.com/dapperlabs/dps-rosetta-docker /docker && \
    git clone --branch $FLOW_GO_BRANCH https://github.com/onflow/flow-go /dps/flow-go && \
    make -C /dps/flow-go crypto/relic/build #prebuild crypto dependency

FROM build-setup AS build-live

WORKDIR /dps
RUN  --mount=type=cache,target=/go/pkg/mod \
     --mount=type=cache,target=/root/.cache/go-build  \
     git checkout $DPS_LIVE_BRANCH &&  \
     go build -o /dps-live-index -tags relic -ldflags "-extldflags -static" ./cmd/flow-dps-live && \
     go build -o /app-rosetta -ldflags "-extldflags -static" ./cmd/flow-rosetta-server

## Add the statically linked binary to a distroless image
FROM ubuntu:latest as production

RUN apt-get update
RUN apt-get -y install supervisor wget

COPY --from=build-live /dps-live-index /bin/dps-live-index
COPY --from=build-live /app-rosetta /bin/rosetta-live

RUN chmod a+x  \
    /bin/dps-live-index \
    /bin/rosetta-live 

COPY --from=build-setup /docker/testnet/supervisord.conf /supervisord.conf
COPY --from=build-setup /docker/common.sh /common.sh
COPY --from=build-setup /docker/testnet/run.sh /run.sh

RUN chmod a+x /run.sh

EXPOSE 8080 8099

CMD ["bash", "-x", "/run.sh"]