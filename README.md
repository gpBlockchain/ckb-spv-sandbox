
## CKB-SPV-SandBox

### clone 
```shell
git clone --recurse-submodules https://github.com/gpBlockchain/ckb-spv-sandbox.git
```

### [prepare_linux](script%2Fprepare_linux.sh)

- build  [ckb-bitcoin-spv-service](ckb-bitcoin-spv-service)
```shell
cd ckb-bitcoin-spv-service
cargo build
```
- build [ckb-bitcoin-spv-contracts](ckb-bitcoin-spv-contracts) 
```shell
cd ckb-bitcoin-spv-contracts
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 16
rm llvm.sh
rustup toolchain install 1.76.0 --profile minimal
rustup override set 1.76.0
rustup target add riscv64imac-unknown-none-elf
make build
cp build/release/ckb-bitcoin-spv-type-lock ../contracts/ckb-bitcoin-spv-type-lock
```
- tar ckb data
```shell
cd ckb
tar -zxvf data.tar.gz
```
- python install 
```shell
pip install python-dotenv
```

### [start_node](script%2Fstart_node.sh)
- start node by docker
```shell
docker-compose up -d
```
- link bitcoin node2---node1
```shell
curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc": "2.0", "method":"addnode", "params": ["bitcoind2:18444", "add"], "id": 1}' \
    http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334
```
- Mining BTC blocks
```shell
curl -s -X POST -H "Content-Type: application/json"   -d '{"jsonrpc": "2.0", "method":"generatetoaddress", "params": [2026,"bcrt1qjw7fr29qcxgd406hh6lhznj3q0lej9y0uugj3h"], "id": 1}'  http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334
```
- check btc node status
```shell
curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc": "2.0", "method":"getchaintips", "params": [], "id": 1}' \
    http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334
    

curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc": "2.0", "method":"getchaintips", "params": [], "id": 1}' \
    http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8333
```
- check ckb node status
```shell
curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc": "2.0", "method":"get_tip_block_number", "params": [], "id": 1}' \
    http://localhost:8114
```
### [deploy_contract](script%2Fdeploy_contract.sh)
- deploy ckb-bitcoin-spv-type-lock
```shell
CKB_ENDPOINT="http://localhost:8114"
KEY_FILE="./script/output.bin"
CKB_BITCOIN_SPV_TYPE_LOCK_PATH="./contracts/ckb-bitcoin-spv-type-lock"
CONTRACT_OWNER="ckt1qq5wswsjwl2g4hvwwtad42fys4v7rd3jh2et6c9j0927h3xq8qq22qsrd2tlg"

./ckb-bitcoin-spv-service/target/debug/ckb-bitcoin-spv-service deploy \
  --ckb-endpoint "${CKB_ENDPOINT}" \
  --key-file "${KEY_FILE}" \
  --contract-file "${CKB_BITCOIN_SPV_TYPE_LOCK_PATH}" \
  --contract-owner "${CONTRACT_OWNER}" --enable-type-id 
```
- deploy can-update-without-ownership-lock
```shell

CKB_ENDPOINT="http://localhost:8114"
KEY_FILE="./script/output.bin"
CKB_CAN_UPDATE_LOCK_PATH="./contracts/can-update-without-ownership-lock"
CONTRACT_OWNER="ckt1qq5wswsjwl2g4hvwwtad42fys4v7rd3jh2et6c9j0927h3xq8qq22qsrd2tlg"

./ckb-bitcoin-spv-service/target/debug/ckb-bitcoin-spv-service deploy \
  --ckb-endpoint "${CKB_ENDPOINT}" \
  --key-file "${KEY_FILE}" \
  --contract-file "${CKB_CAN_UPDATE_LOCK_PATH}" \
  --contract-owner "${CONTRACT_OWNER}"
```
### [start_spv_server](script%2Fstart_spv_server.sh)
- init
```shell
SPV_CONTRACT_TYPE_HASH=${SPV_CONTRACT_TYPE_HASH}
SPV_CONTRACT_OUT_POINT=${SPV_CONTRACT_OUT_POINT}
LOCK_CONTRACT_DATA_HASH=${LOCK_CONTRACT_DATA_HASH}
LOCK_CONTRACT_OUT_POINT=${LOCK_CONTRACT_OUT_POINT}

CKB_ENDPOINT="http://localhost:8114"
KEY_FILE="./script/output.bin"

SPV_OWNER="ckt1qrenum4xaek97sc53rkdqumvan9xxvr43se9e7dnk455t5sysfn7jqsqfsd67w"
DATA_DIR="./tmp/data5"
BTC_ENDPOINT="http://localhost:80"
BTC_USERNAME="ckb"
BTC_PASSWORD="enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI"
BTC_START_HEIGHT=2016
SPV_CLIENTS_COUNT=10
LISTEN_ADDRESS="127.0.0.1:5000"
rm -rf $DATA_DIR
mkdir -p $DATA_DIR
./ckb-bitcoin-spv-service/target/debug/ckb-bitcoin-spv-service  init -v \
        --data-dir                  "${DATA_DIR}" \
        --ckb-endpoint              "${CKB_ENDPOINT}" \
        --bitcoin-endpoint          "${BTC_ENDPOINT}" \
        --bitcoin-endpoint-username "${BTC_USERNAME}" \
        --bitcoin-endpoint-password "${BTC_PASSWORD}" \
        --bitcoin-start-height      "${BTC_START_HEIGHT}" \
        --spv-clients-count         "${SPV_CLIENTS_COUNT}" \
        --spv-contract-type-hash    "${SPV_CONTRACT_TYPE_HASH}" \
        --spv-contract-out-point    "${SPV_CONTRACT_OUT_POINT}" \
        --lock-contract-out-point   "${LOCK_CONTRACT_OUT_POINT}" \
        --spv-owner                 "${SPV_OWNER}" \
        --key-file                  "${KEY_FILE}" --disable-difficulty-check

```
- start spv server
```shell

SPV_CONTRACT_TYPE_HASH=${SPV_CONTRACT_TYPE_HASH}
SPV_CONTRACT_OUT_POINT=${SPV_CONTRACT_OUT_POINT}
LOCK_CONTRACT_DATA_HASH=${LOCK_CONTRACT_DATA_HASH}
LOCK_CONTRACT_OUT_POINT=${LOCK_CONTRACT_OUT_POINT}

CKB_ENDPOINT="http://localhost:8114"
KEY_FILE="./script/output.bin"

SPV_OWNER="ckt1qrenum4xaek97sc53rkdqumvan9xxvr43se9e7dnk455t5sysfn7jqsqfsd67w"
DATA_DIR="./tmp/data5"
BTC_ENDPOINT="http://localhost:80"
BTC_USERNAME="ckb"
BTC_PASSWORD="enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI"
BTC_START_HEIGHT=2016
SPV_CLIENTS_COUNT=10
LISTEN_ADDRESS="127.0.0.1:5000"
./ckb-bitcoin-spv-service/target/debug/ckb-bitcoin-spv-service serve -v \
        --data-dir                  "${DATA_DIR}" \
        --ckb-endpoint              "${CKB_ENDPOINT}" \
        --bitcoin-endpoint          "${BTC_ENDPOINT}" \
        --bitcoin-endpoint-username "${BTC_USERNAME}" \
        --bitcoin-endpoint-password "${BTC_PASSWORD}" \
        --listen-address            "${LISTEN_ADDRESS}" \
        --key-file                  "${KEY_FILE}"


```

- [reorg](script%2Freorg.py)
```shell
python script/reorg.py
```