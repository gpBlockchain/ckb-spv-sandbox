display_error() {
    echo "Error: $1" >&2
    exit 1
}

# Start BTC and CKB containers
echo "Starting BTC and CKB containers..."
docker-compose up -d || display_error "Failed to start containers"

# wait docker start
sleep 5
# Link BTC network to CKB
echo "Linking BTC network to CKB..."
curl_output=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc": "2.0", "method":"addnode", "params": ["bitcoind2:18444", "add"], "id": 1}' \
    http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334)
if [[ $curl_output != *"result"* ]]; then
    display_error "Failed to link BTC network to CKB"
fi

# Mine BTC blocks
echo "Mining BTC blocks..."
curl_output=$(curl -s -X POST -H "Content-Type: application/json"   -d '{"jsonrpc": "2.0", "method":"generatetoaddress", "params": [2116,"bcrt1qjw7fr29qcxgd406hh6lhznj3q0lej9y0uugj3h"], "id": 1}'  http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334)
if [[ $curl_output != *"result"* ]]; then
    display_error "Failed to mine BTC blocks"
fi

# check btc node status
echo "check btc node status"
curl_output=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc": "2.0", "method":"getchaintips", "params": [], "id": 1}' \
    http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334)
if [[ $curl_output != *"result"* ]]; then
    display_error "Failed to check btc node status"
fi
echo $curl_output
curl_output=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc": "2.0", "method":"getchaintips", "params": [], "id": 1}' \
    http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8333)
echo $curl_output
if [[ $curl_output != *"result"* ]]; then
    display_error "Failed to check btc node status"
fi

# check ckb node status
echo "check ckb node status"
curl_output=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc": "2.0", "method":"get_tip_block_number", "params": [], "id": 1}' \
    http://localhost:8114)
echo $curl_output
if [[ $curl_output != *"result"* ]]; then
    display_error "Failed to check ckb node status"
fi