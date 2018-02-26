def bin_to_hex(str)
  str.unpack('H*').first
end

def btc_to_satoshi(value)
  value * 100_000_000
end
