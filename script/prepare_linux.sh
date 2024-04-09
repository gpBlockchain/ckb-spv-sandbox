echo "ckb-bitcoin-spv-service"

cd ckb-bitcoin-spv-service
cargo build
cd ../

echo "contract"
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
cd ../
echo "tar ckb data"
cd ckb
tar -zxvf data.tar.gz
echo "install python "
pip install python-dotenv