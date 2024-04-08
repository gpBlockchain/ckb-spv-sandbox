echo "todo clone contract "
echo "clone "
git clone https://github.com/ckb-cell/ckb-bitcoin-spv-service.git
cd ckb-bitcoin-spv-service
cargo build
cd ../
#echo "clone ckb-spv-monit"
#git clone https://github.com/cryptape/ckb-spv-monit.git
#cd ckb-spv-monit
#cargo build
echo "tar ckb data"
cd ../
cd ckb
tar -zxvf data.tar.gz
echo "install python "
pip install python-dotenv