## Docker packaging of Flow Rosetta API implementation

This is a work in progress and subject to change. 

## Supported Flow networks

Use `Dockerfile` from a directory corresponding to chosen network.  

### Canary

 Name      | Lowest block | Highest block
-----------|--------------|---------------
Canary 8v2 | 41318422     | Live

### Mainnet 

 Name     | Lowest block | Highest block 
----------|--------------|--------------
Mainnet-5 | 12020337     | 12609236
Mainnet-6 | 12609237     | 13404173
Mainnet-7 | 13404174     | 13950741

### Testnet 

 Name      | Lowest block | Highest block 
-----------|--------------|--------------
Testnet-27 |              | Live

## Building and running

Dockerfile is self-contained - it downloads all code and configuration it needs from a git repository, as 
designated by Rosetta requirements.

NOTE - Docker BuildKit support is required!

It can be built without any extra arguments: 
`docker build .`

On first run the DPS index snapshots and/or bootstrap data will be downloaded and unpacked. Since those files are large 
it's advisable to provide a fixed mountpoint for running container under `/data/` path.

## Endpoints

HTTP endpoint is exposed on port 8080