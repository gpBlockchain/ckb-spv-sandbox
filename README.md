


### ckb-miner 

```shell
curl --location 'localhost:8114/' \\n--header 'Content-Type: application/json' \\n--data '{\n  "jsonrpc":"2.0",\n  "method":"generate_epochs",\n  "params":["0x2"],\n  "id":64\n}'

```
### bitcoin 

command
```shell


curl -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc": "2.0", "method":"addnode", "params": ["bitcoind2:18444", "add"], "id": 1}' \
        http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334


node1 miner 

curl -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc": "2.0", "method":"generatetoaddress", "params": [3000,"bcrt1qjw7fr29qcxgd406hh6lhznj3q0lej9y0uugj3h"], "id": 1}' \
        http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334

node2 miner 


curl -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc": "2.0", "method":"generatetoaddress", "params": [3000,"bcrt1qjw7fr29qcxgd406hh6lhznj3q0lej9y0uugj3h"], "id": 1}' \
        http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8333



curl -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc": "2.0", "method":"setnetworkactive", "params": [false], "id": 1}' \
        http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334



```