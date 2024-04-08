
echo "deploy can-update-without-ownership-lock"

CKB_ENDPOINT="http://localhost:8114"
KEY_FILE="./script/output.bin"
CKB_BITCOIN_SPV_TYPE_LOCK_PATH="./contracts/ckb-bitcoin-spv-type-lock"
CKB_CAN_UPDATE_LOCK_PATH="./contracts/can-update-without-ownership-lock"
CONTRACT_OWNER="ckt1qq5wswsjwl2g4hvwwtad42fys4v7rd3jh2et6c9j0927h3xq8qq22qsrd2tlg"

SPV_OWNER="ckt1qrenum4xaek97sc53rkdqumvan9xxvr43se9e7dnk455t5sysfn7jqsqfsd67w"
DATA_DIR="./tmp/data5"
BTC_ENDPOINT="http://localhost:8334"
BTC_USERNAME="ckb"
BTC_PASSWORD="enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI"
BTC_START_HEIGHT=2016
SPV_CLIENTS_COUNT=10
LISTEN_ADDRESS="127.0.0.1:5000"
tmp_file=$(mktemp)
echo "deploy:${CKB_BITCOIN_SPV_TYPE_LOCK_PATH}"
./ckb-bitcoin-spv-service/target/debug/ckb-bitcoin-spv-service deploy \
  --ckb-endpoint "${CKB_ENDPOINT}" \
  --key-file "${KEY_FILE}" \
  --contract-file "${CKB_BITCOIN_SPV_TYPE_LOCK_PATH}" \
  --contract-owner "${CONTRACT_OWNER}" --enable-type-id > "$tmp_file" 2>&1
deploy_output=$(cat "$tmp_file")

type_hash_regex='The contract type hash is 0x([a-fA-F0-9]+)'
data_hash_regex='The contract data hash is 0x([a-fA-F0-9]+)'
transaction_hash_regex='Transaction hash: 0x([a-fA-F0-9]+)'

# 使用正则表达式匹配并提取 Type Hash 和 Transaction Hash
if [[ $deploy_output =~ $type_hash_regex ]]; then
    echo "----BASH_REMATCH:-----${BASH_REMATCH}"
    type_hash="0x${BASH_REMATCH[1]}"
else
    echo "Failed to extract Type Hash" >&2
    exit 1
fi

if [[ $deploy_output =~ $transaction_hash_regex ]]; then
    transaction_hash="0x${BASH_REMATCH[1]}"
else
    echo "Failed to extract Transaction Hash" >&2
    exit 1
fi

echo "Type Hash: $type_hash"
echo "Transaction Hash: $transaction_hash"


echo "SPV_CONTRACT_TYPE_HASH=${type_hash}" > .env
echo "SPV_CONTRACT_OUT_POINT=${transaction_hash}00000000" >> .env
sleep 10
echo "deploy ${CKB_BITCOIN_SPV_TYPE_LOCK_PATH}"

deploy_output=$(./ckb-bitcoin-spv-service/target/debug/ckb-bitcoin-spv-service deploy \
  --ckb-endpoint "${CKB_ENDPOINT}" \
  --key-file "${KEY_FILE}" \
  --contract-file "${CKB_CAN_UPDATE_LOCK_PATH}" \
  --contract-owner "${CONTRACT_OWNER}" 2>&1)


#echo " get deploy message "
#
## 使用正则表达式匹配并提取 Type Hash 和 Transaction Hash
if [[ $deploy_output =~ $data_hash_regex ]]; then
    data_hash="0x${BASH_REMATCH[1]}"
else
    echo "Failed to extract Type Hash" >&2
    exit 1
fi


if [[ $deploy_output =~ $transaction_hash_regex ]]; then
    transaction_hash="0x${BASH_REMATCH[1]}"
else
    echo "Failed to extract Transaction Hash" >&2
    exit 1
fi

# 输出 Type Hash 和 Transaction Hash
echo "data Hash: $data_hash"
echo "Transaction Hash: $transaction_hash"
#LOCK_CONTRACT_OUT_POINT="0xbbd2b2605b7f4c36881e634ef4d17f256bc211c7b710203da944a89d565d4ce600000000"

echo "LOCK_CONTRACT_DATA_HASH=${data_hash}" >> .env
echo "LOCK_CONTRACT_OUT_POINT=${transaction_hash}00000000" >> .env


#SPV_CONTRACT_CODE_HASH="0x955b2f3363d5ab1b28d6b38904e4b1c02bc16d3ec9180598800f674d6354eb1e"
#SPV_CONTRACT_OUT_POINT="0xa91551af69458a7cfa4f79373980d87392d816e2b54b8902ef331d205556b26e00000000"
#LOCK_CONTRACT_OUT_POINT="0xbbd2b2605b7f4c36881e634ef4d17f256bc211c7b710203da944a89d565d4ce600000000"
#
#
#echo "init spv server"
#
#./ckb-bitcoin-spv-service/target/debug/ckb-bitcoin-spv-service  init -v \
#        --data-dir                  "${DATA_DIR}" \
#        --ckb-endpoint              "${CKB_ENDPOINT}" \
#        --bitcoin-endpoint          "${BTC_ENDPOINT}" \
#        --bitcoin-endpoint-username "${BTC_USERNAME}" \
#        --bitcoin-endpoint-password "${BTC_PASSWORD}" \
#        --bitcoin-start-height      "${BTC_START_HEIGHT}" \
#        --spv-clients-count         "${SPV_CLIENTS_COUNT}" \
#        --spv-contract-type-hash    "${SPV_CONTRACT_CODE_HASH}" \
#        --spv-contract-out-point    "${SPV_CONTRACT_OUT_POINT}" \
#        --lock-contract-out-point   "${LOCK_CONTRACT_OUT_POINT}" \
#        --spv-owner                 "${SPV_OWNER}" \
#        --key-file                  "${KEY_FILE}" --disable-difficulty-check
#
#
#echo "start spv server"
#
# ./ckb-bitcoin-spv-service serve -v \
#        --data-dir                  "${DATA_DIR}" \
#        --ckb-endpoint              "${CKB_ENDPOINT}" \
#        --bitcoin-endpoint          "${BTC_ENDPOINT}" \
#        --bitcoin-endpoint-username "${BTC_USERNAME}" \
#        --bitcoin-endpoint-password "${BTC_PASSWORD}" \
#        --listen-address            "${LISTEN_ADDRESS}" \
#        --key-file                  "${KEY_FILE}"
#
