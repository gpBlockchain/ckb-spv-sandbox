import time

import json
import requests
from dotenv import dotenv_values

config = dotenv_values(".config.env")
BTC_NODE1_RPC_URL = "http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8334"
BTC_NODE2_RPC_URL = "http://ckb:enyVBdd7XOJ_t2RjaR2L13tCPSSNYxbzIS9xtlWycCI@localhost:8333"
CKB_RPC_URL = "http://localhost:5000"


def convert_int(value):
    try:
        return int(value)
    except ValueError:
        return int(value, base=16)
    except Exception as exp:
        raise exp


class BTCRPCClient:
    def __init__(self, url):
        self.url = url

    def getbestblockhash(self):
        return call(self.url, "getbestblockhash", [])

    def getchaintips(self):
        return call(self.url, "getchaintips", [])

    def getblockheader(self, blockhash):
        return call(self.url, "getblockheader", [blockhash])

    def getblock(self, blockhash):
        return call(self.url, "getblock", [blockhash])

    def getconnectioncount(self):
        return call(self.url, "getconnectioncount", [])

    def generatetoaddress(self, block, address):
        return call(self.url, "generatetoaddress", [block, address])

    def getnetworkinfo(self):
        return call(self.url, "getnetworkinfo", [])

    def setnetworkactive(self, status):
        return call(self.url, "setnetworkactive", [status])


class CKBSPVRPCClient:

    def __init__(self, url):
        self.url = url

    def getTxProof(self, btcId, index, confor):
        return call(self.url, "getTxProof", [btcId, index, confor])


class MonitRPCClient:
    def __init__(self, url):
        self.url = url

    def get_ckb_client_message(self, ckb_url, code_hash, arg):
        return call(self.url, "get_ckb_client_message", [ckb_url, code_hash, arg])

    def verify_tx(self, proof, btc_id, ckb_client_data):
        return call(self.url, "verify_tx", [proof, btc_id, ckb_client_data])


def call(url, method, params, try_count=5):
    headers = {'content-type': 'application/json'}
    data = {
        "id": 42,
        "jsonrpc": "2.0",
        "method": method,
        "params": params
    }

    for i in range(try_count):
        try:
            # print(f"request:url:{url},data:\n{json.dumps(data)}")
            response = requests.post(url, data=json.dumps(data), headers=headers, timeout=10)

            if response.status_code == 502:
                raise requests.exceptions.ConnectionError("502 ,try again")
            response = response.json()
            # print(f"response:\n{json.dumps(response)}")
            if 'error' in response.keys() and response['error'] != None:
                # print(f"err request:url:{url},data:\n{json.dumps(data)}")
                # print(f"err response:\n{json.dumps(response)}")
                error_message = response['error'].get('message', 'Unknown error')
                raise Exception(f"Error: {error_message}")
            return response.get('result', None)
        except requests.exceptions.ConnectionError as e:
            print(e)
            # print(f"err request:url:{url},data:\n{json.dumps(data)}")
            print("request too quickly, wait 2s")
            time.sleep(2)
            continue
        except Exception as e:
            raise e
    raise Exception("request time out")


btcNode1Rpc = BTCRPCClient(BTC_NODE1_RPC_URL)
btcNode2Rpc = BTCRPCClient(BTC_NODE2_RPC_URL)
spvRpc = CKBSPVRPCClient(CKB_RPC_URL)


def reorg(count):
    # wait spv sync tip
    print("wait spv sync tip")
    wait_spv_sync(60 * 5)
    # close node1 and node2
    print("close node1 and node2")
    btcNode1Rpc.setnetworkactive(False)
    wait_connection_count(btcNode1Rpc, 0, 60)
    for i in range(count):
        print(f"miner and wait spv sync:{i}/{count}")
        # node1 miner block
        btcNode1Rpc.generatetoaddress(1, "bcrt1qjw7fr29qcxgd406hh6lhznj3q0lej9y0uugj3h")
        # wait spv sync
        wait_spv_sync(3 * 60)

    print("miner node2 ,recon node1")
    tip1Message = btcNode1Rpc.getchaintips()
    tip2Message = btcNode2Rpc.getchaintips()
    node2_miner_block = tip1Message[0]['height'] - tip2Message[0]['height'] + 1
    if node2_miner_block <= 0:
        raise Exception(f"btc2 node block:{tip2Message[0]['height']} > btc node1:{tip1Message['height']}")
    # node2 miner > node1 height
    btcNode2Rpc.generatetoaddress(node2_miner_block, "bcrt1qjw7fr29qcxgd406hh6lhznj3q0lej9y0uugj3h")
    # active node1 and node2
    btcNode1Rpc.setnetworkactive(True)
    wait_connection_count(btcNode1Rpc, 1, 3 * 60)
    # until node1 sync
    wait_nodes_sync(3 * 60)
    print("wait recon successful")
    #  until spv sync
    wait_spv_sync(5 * 60)


def wait_nodes_sync(wait_time):
    for i in range(wait_time):
        tip1Message = btcNode1Rpc.getchaintips()
        tip2Message = btcNode2Rpc.getchaintips()
        if tip2Message[0]['height'] == tip1Message[0]['height']:
            return
        time.sleep(1)
    raise Exception(f"wait time:{wait_time} not sync,node1:{tip1Message['height']},node2:{tip2Message['height']}")


def wait_spv_sync(wait_time):
    bestBlockHash = btcNode1Rpc.getbestblockhash()
    block = btcNode1Rpc.getblock(bestBlockHash)
    for i in range(wait_time):
        try:
            proof = spvRpc.getTxProof(block['tx'][0], 0, 0)
            return
        except Exception as e:
            time.sleep(1)
            # print(f"wait sync:{i}/{wait_time},err:{e}")
            err = e
    raise Exception(f"wait_spv_sync:{wait_time},err:{err.args}")


def wait_connection_count(node, count, wait_time):
    for i in range(wait_time):
        current_count = node.getconnectioncount()
        if current_count == count:
            return
        time.sleep(1)

    raise Exception(f"wait_connection_count time out:{wait_time}")


if __name__ == '__main__':
    print("--- wait_spv_sync -- ")
    wait_spv_sync(60 * 5)
    light_sync_count = 20
    for i in range(light_sync_count):
        print(f"miner and wait spv sync:{i}/{light_sync_count}")
        # node1 miner block
        btcNode1Rpc.generatetoaddress(1, "bcrt1qjw7fr29qcxgd406hh6lhznj3q0lej9y0uugj3h")
        # wait spv sync
        wait_spv_sync(3 * 60)
    print("---reorg-----")
    for i in range(1, 10):
        reorg(i)
