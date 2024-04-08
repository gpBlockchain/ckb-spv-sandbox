
#SPV_CONTRACT_CODE_HASH="0x955b2f3363d5ab1b28d6b38904e4b1c02bc16d3ec9180598800f674d6354eb1e"
#SPV_CONTRACT_OUT_POINT="0xa91551af69458a7cfa4f79373980d87392d816e2b54b8902ef331d205556b26e00000000"
#LOCK_CONTRACT_OUT_POINT="0xbbd2b2605b7f4c36881e634ef4d17f256bc211c7b710203da944a89d565d4ce600000000"
#
#
source .env
SPV_CONTRACT_TYPE_HASH=${SPV_CONTRACT_TYPE_HASH}
SPV_CONTRACT_OUT_POINT=${SPV_CONTRACT_OUT_POINT}
LOCK_CONTRACT_DATA_HASH=${LOCK_CONTRACT_DATA_HASH}
LOCK_CONTRACT_OUT_POINT=${LOCK_CONTRACT_OUT_POINT}

CKB_ENDPOINT="http://localhost:8114"
KEY_FILE="./script/output.bin"

SPV_OWNER="ckt1qrenum4xaek97sc53rkdqumvan9xxvr43se9e7dnk455t5sysfn7jqsqfsd67w"
DATA_DIR="./tmp/data5"
BTC_ENDPOINT="http://localhost:8334"
BTC_USERNAME="ckb"
BTC_PASSWORD="enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI"
BTC_START_HEIGHT=2016
SPV_CLIENTS_COUNT=10
LISTEN_ADDRESS="127.0.0.1:5000"
rm -rf $DATA_DIR
mkdir -p $DATA_DIR
set -e
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

sleep 10
echo "start spv server"

./ckb-bitcoin-spv-service/target/debug/ckb-bitcoin-spv-service serve -v \
        --data-dir                  "${DATA_DIR}" \
        --ckb-endpoint              "${CKB_ENDPOINT}" \
        --bitcoin-endpoint          "${BTC_ENDPOINT}" \
        --bitcoin-endpoint-username "${BTC_USERNAME}" \
        --bitcoin-endpoint-password "${BTC_PASSWORD}" \
        --listen-address            "${LISTEN_ADDRESS}" \
        --key-file                  "${KEY_FILE}"

