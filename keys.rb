require 'csv'

FILE_NAME = 'keys.csv'

# Generate new key
def generate_key ( isCompressed )

  key = Bitcoin::Key.generate ( opts = { compressed: isCompressed } )

  # key_info = [key.addr, key.pub, key.priv]
  key_info = [key.addr, key.pub, key.to_base58]

  # Import newly created address into Bitcoin-RPC
  $bitcoinRpc.importprivkey key.to_base58

  CSV.open(FILE_NAME, "a+") do |csv|
    csv << key_info
  end

  response = {
    'address' => key.addr,
    'pubkey' => key.pub
  }

  response
end

# Retrieve all the available keys in the wallet
def get_all_keys ( required_data )

  response = []

  if required_data.length > 0 and !required_data.include? 'address' and !required_data.include? 'pubkey' and !required_data.include? 'privkey'
    required_data = []
  end

  if required_data.length > 0
    CSV.foreach(FILE_NAME) do |row|

      key = {}

      if ( required_data.include? 'address' )
        key["address"] = row[0]
      end

      if ( required_data.include? 'pubkey' )
        key["pubkey"] = row[1]
      end

      if ( required_data.include? 'privkey' )
        key["privkey"] = row[2]
      end

      if key.length > 0
        response << key
      end
    end
  else 
    CSV.foreach(FILE_NAME) do |row|

      key = {
        'address' => row[0],
        'pubkey' => row[1],
        'privkey' => row[2]
      }
      response << key
    end
  end 

  response
end

# Get list of all addresses available in the wallet
def get_all_addresses

  response = []

  CSV.foreach(FILE_NAME) do |row|

    response << row[0]
  end

  response
end


# Get private key from the address
def get_private_key ( address )

  private_key = nil

  CSV.foreach(FILE_NAME) do |row|

    if address == row[0]

      private_key = row[2]
      break
    end
  end

  private_key

end


# Get Bitcoin::Key object from the address
def get_key ( address )

  privkey = get_private_key address
  key = Bitcoin::Key.from_base58 ( privkey )
  key

end

# Checks if the address is present in our wallet
def is_valid_address ( address )

  all_addresses = get_all_addresses
  all_addresses.include? address
end