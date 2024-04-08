prepare:
    bash script/prepare.sh

test:
    bash script/start_node.sh
    bash script/deploy_contract.sh
    bash script/start_spv_server.sh > spv.log 2>&1 &
    python script/reorg.py
