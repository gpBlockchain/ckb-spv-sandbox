import binascii

def hex_to_bin(hex_file, bin_file):
    with open(hex_file, 'r') as f_hex:
        hex_data = f_hex.read().strip()

    bin_data = binascii.unhexlify(hex_data)

    with open(bin_file, 'wb') as f_bin:
        f_bin.write(bin_data)


hex_file = 'input.hex'
bin_file = 'output.bin'
hex_to_bin(hex_file, bin_file)