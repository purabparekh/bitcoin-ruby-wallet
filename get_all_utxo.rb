
# List all the UTXOs related to our wallet
def get_all_utxo

  best_block_hash = $bitcoinRpc.getbestblockhash

  block_details = $bitcoinRpc.getblock best_block_hash

  all_addresses_in_wallet = get_all_addresses

  all_transactions = []
  spent_transactions = []
  received_transactions = []

  unspent_transactions = []

  # Repeat the process till we do not reach genesis block
  while block_details["previousblockhash"] != nil

    block_details["tx"].each { |trans_id|

      begin

        # transaction = $bitcoinRpc.decoderawtransaction($bitcoinRpc.getrawtransaction trans_id)
        transaction = $bitcoinRpc.getrawtransaction trans_id, true

        all_transactions << trans_id

        transaction["vin"].each { |vin|

          if vin["txid"] != nil

            input_transaction = {
              'trans_id': vin["txid"],
              'vout_index': vin["vout"]
            }

            spent_transactions << input_transaction

          end
        }

        transaction["vout"].each { |vout|

          if vout["scriptPubKey"]["addresses"] != nil

            vout["scriptPubKey"]["addresses"].each { |address|

              if all_addresses_in_wallet.include? address

                wallet_transaction = {
                  'trans_id': trans_id,
                  'block_hash': block_details["hash"],
                  'value': vout["value"],
                  'vout_index': vout["n"],
                  'address': vout["scriptPubKey"]["addresses"]
                }
                received_transactions << wallet_transaction
                break

              end
            }
          end
        }

      rescue => ex
        # puts ex.to_s
        # puts "Transaction ID: " + trans_id.to_s
        # puts "Block ID: " + block_details["hash"].to_s
      end
    }

    block_details = $bitcoinRpc.getblock block_details["previousblockhash"]

  end

  received_transactions.each { |trans|

    unless spent_transactions.any? { |tx| tx[:trans_id] == trans[:trans_id] and tx[:vout_index] == trans[:vout_index] }
      unspent_transactions << trans
    end
  }

  unspent_transactions
end
