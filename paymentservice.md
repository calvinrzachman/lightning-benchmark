# Lightning Benchmark Test Environment Setup

This document outlines the steps to set up and run the test environment for benchmarking the Lightning Network using `pscli-debug`, `lncli`, and Docker containers.

## Table of Contents
- [Payment Service Setup](#payment-service-setup)
- [Payment Service Access](#payment-service-access)
- [Loadtest Container](#loadtest-container)
- [Loadtest Container Without Setup](#loadtest-container-without-setup)
- [Generate Blocks with bitcoin-cli](#generate-blocks-with-bitcoin-cli)

---

## Payment Service Setup

Use `pscli-debug` (output of `make build` in PS repo) to add an LND node to the payment service proxy. The credential information for the PS should be in the `./paymentservice` directory which is mounted as a volume to the container. NOTE: This command involves references to macaroon and TLS certificate for *both* the payment service itself and the *lnd* instance being configured for use with the payment service. See also `copy-alice-creds.sh`.

### Command:

```bash
./pscli-debug \
  --macaroonpath=/path/to/admin.macaroon \
  --tlscertpath=/path/to/tls.cert \
  addnode lnd-alice:10009 \
  /path/to/tls.cert \
  /path/to/admin.macaroon 3
```

## Payment Service Access

You can interact with the payment service via _*lncli*_.
```bash
lncli \
  --rpcserver=localhost:13010 \
  --network regtest \
  --tlscertpath=/path/to/tls.cert \
  --macaroonpath=/path/to/admin.macaroon \
  getinfo
```

## Loadtest Container

The load test container creates a wallet, funds lightning nodes and opens some channels. It is not idempotent so can only be run once.

NOTE: When running the setup, you *MUST* configure direct access to lnd instance in `loadtest-lnd.yaml`:
```yaml
sender:
  # NOTE(calvin): Uncomment to run test with Payment Service in the loop.
  # host: paymentservice:13010
  # lnd:
  #   rpcHost: paymentservice:13010
  #   tlsCertPath: /paymentservice/tls.cert
  #   macaroonPath: /paymentservice/admin.macaroon
  host: lnd-alice:9735
  lnd:
    tlsCertPath: /lnd-alice/tls.cert
    rpcHost: lnd-alice:10009
    macaroonPath: /lnd-alice/admin.macaroon
```

```bash
docker run --rm \
  --name loadtest \
  --network lightning-benchmark_default \
  --volume lightning-benchmark_lnd-alice:/lnd-alice \
  --volume lightning-benchmark_lnd-bob:/lnd-bob \
  --volume $(pwd)/loadtest-lnd.yml:/loadtest.yml \
  bottlepay/loadtest
```

To tear down/restart containers:
```bash
➜ ✗ echo $DOCKER_COMPOSE_FILE
docker-compose-paymentservice.yml
➜ ✗ docker-compose -f $DOCKER_COMPOSE_FILE up -d

➜ ✗ docker-compose -f $DOCKER_COMPOSE_FILE down -v --remove-orphans
```

## Loadtest Container Without Setup

This container was built with a modified version of the entry point such that it runs the load test only and performs no setup. Once the setup is complete, you can run repeated test iterations with this:

```bash
docker run --rm \
  --name loadtest \
  --network lightning-benchmark_default \
  --volume lightning-benchmark_lnd-alice:/lnd-alice \
  --volume lightning-benchmark_lnd-bob:/lnd-bob \
  --volume $(pwd)/loadtest-lnd.yml:/loadtest.yml \
  --volume /Users/calvinzachman/Documents/Workspace/src/github.com/bottlepay/lightning-benchmark/paymentservice:/paymentservice \
  bottlepay/loadtest-no-setup
```

## Generate Blocks with bitcoin-cli

When using `regtest`, _*lnd*_ will occasionally lose sync to chain. This can be remedied by mining a block. Run `docker exec` to access the bitcoind container and then run:
```bash
bitcoin-cli -regtest -rpcconnect=0.0.0.0 -rpcport=8332 -generate 2
```