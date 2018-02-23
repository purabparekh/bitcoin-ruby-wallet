require 'bitcoin'
require 'open-uri'
require 'net/http'

Bitcoin.network =:regtest

include Bitcoin::Builder

require_relative '../bitcoinrpc.rb'
require_relative '../commonFunctions.rb'

$bitcoinRpc = BitcoinRPC.new('http://purab:purab9503@127.0.0.1:18443')

TRANSACTION_FEE = 1000

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

# Get balance ( Addition of all UTXOs )
def get_balance

  all_utxo = get_all_utxo

  balance = 0
  all_utxo.each { |utxo|

    balance += utxo[:value]
  }

  balance
end

# Send bitcoins to address
def send_to_address ( data )

  previous_transaction_hash = data[0]
  previous_transaction_vout = data[1].to_i
  amount_to_pay = btc_to_satoshi(data[2].to_f)
  payee_address = data[3]

  previous_transaction_hex = $bitcoinRpc.getrawtransaction previous_transaction_hash
  previous_transaction = Bitcoin::Protocol::Tx.new(previous_transaction_hex.htb)

  previous_transaction_value = previous_transaction.out[previous_transaction_vout].value

  previous_address = previous_transaction.out[previous_transaction_vout].parsed_script.get_address
  key = get_key ( previous_address )

  change_amount = previous_transaction_value - amount_to_pay - TRANSACTION_FEE
  change_address = previous_address

  new_transaction = Bitcoin::Protocol::Tx.new

  transaction_input = Bitcoin::Protocol::TxIn.from_hex_hash(previous_transaction_hash, previous_transaction_vout)
  new_transaction.add_in(transaction_input)

  # transaction_output_payee = Bitcoin::Protocol::TxOut.new(amount_to_pay, payee_script)
  transaction_output_payee = Bitcoin::Protocol::TxOut.value_to_address(amount_to_pay, payee_address)
  new_transaction.add_out(transaction_output_payee)
  
  # transaction_output_change = Bitcoin::Protocol::TxOut.new(change_amount, change_script)
  transaction_output_change = Bitcoin::Protocol::TxOut.value_to_address(change_amount, change_address)
  new_transaction.add_out(transaction_output_change)

  signature_hash = new_transaction.signature_hash_for_input(previous_transaction_vout, previous_transaction, Bitcoin::Script::SIGHASH_TYPE[:all])
  
  signature = key.sign(signature_hash)
  
  script_sig = Bitcoin::Script.to_signature_pubkey_script(signature, key.pub.htb, Bitcoin::Script::SIGHASH_TYPE[:all])
  
  new_transaction.in[0].script_sig = script_sig
  
  # Code to verify input signature
  # verify_transaction = Bitcoin::Protocol::Tx.new(new_transaction.to_payload)
  # p ({verify: verify_transaction.verify_input_signature(0, previous_transaction)})

  $transactionId = $bitcoinRpc.sendrawtransaction new_transaction.to_payload.bth

  $transactionId

end

# Send bitcoins from normal address to multisig address
def send_to_multisig ( data )

  previous_transaction_hash = data[0]
  previous_transaction_vout = data[1].to_i
  amount_to_pay = btc_to_satoshi(data[2].to_f)
  min_signatures_required = data[3].to_i

  previous_transaction_hex = $bitcoinRpc.getrawtransaction previous_transaction_hash
  previous_transaction = Bitcoin::Protocol::Tx.new(previous_transaction_hex.htb)

  previous_transaction_value = previous_transaction.out[previous_transaction_vout].value

  previous_address = previous_transaction.out[previous_transaction_vout].parsed_script.get_address
  key = get_key ( previous_address )

  change_amount = previous_transaction_value - amount_to_pay - TRANSACTION_FEE
  change_address = previous_address

  payee_addresses = data.slice(4..-1)

  payee_pubkeys = []

  payee_addresses.each { |address|

    payee_key = get_key ( address )
    payee_pubkeys << payee_key.pub
  }

  multisig_script = Bitcoin::Script.to_multisig_script(min_signatures_required, *payee_pubkeys)

  new_transaction = Bitcoin::Protocol::Tx.new

  transaction_input = Bitcoin::Protocol::TxIn.from_hex_hash(previous_transaction_hash, previous_transaction_vout)
  new_transaction.add_in(transaction_input)

  # transaction_output_payee = Bitcoin::Protocol::TxOut.new(amount_to_pay, payee_script)
  transaction_output_payee = Bitcoin::Protocol::TxOut.new(amount_to_pay, multisig_script)
  new_transaction.add_out(transaction_output_payee)
  
  # transaction_output_change = Bitcoin::Protocol::TxOut.new(change_amount, change_script)
  transaction_output_change = Bitcoin::Protocol::TxOut.value_to_address(change_amount, change_address)
  new_transaction.add_out(transaction_output_change)

  signature_hash = new_transaction.signature_hash_for_input(previous_transaction_vout, previous_transaction, Bitcoin::Script::SIGHASH_TYPE[:all])
  
  signature = key.sign(signature_hash)
  
  script_sig = Bitcoin::Script.to_signature_pubkey_script(signature, key.pub.htb, Bitcoin::Script::SIGHASH_TYPE[:all])
  
  new_transaction.in[0].script_sig = script_sig
  
  # puts new_transaction.to_payload.bth

  # Code to verify input signature
  # verify_transaction = Bitcoin::Protocol::Tx.new(new_transaction.to_payload)
  # p ({verify: verify_transaction.verify_input_signature(0, previous_transaction)})

  $transactionId = $bitcoinRpc.sendrawtransaction new_transaction.to_payload.bth

  $transactionId

end

# Send bitcoins from multisig address to normal address
def redeem_multisig_to_address ( data )

  previous_transaction_hash = data[0]
  previous_transaction_vout = data[1].to_i
  amount_to_pay = btc_to_satoshi(data[2].to_f)
  payee_address = data[3]

  previous_transaction_hex = $bitcoinRpc.getrawtransaction previous_transaction_hash
  previous_transaction = Bitcoin::Protocol::Tx.new(previous_transaction_hex.htb)

  previous_transaction_value = previous_transaction.out[previous_transaction_vout].value

  previous_addresses = previous_transaction.out[previous_transaction_vout].parsed_script.get_addresses
  min_signatures_required = previous_transaction.out[previous_transaction_vout].parsed_script.get_signatures_required

  previous_pubkeys = [] # To create change multisig script
  previous_keys = [] # To sign the previous inputs

  previous_addresses.each { |address|
    previous_key = get_key ( address )
    previous_pubkeys << previous_key.pub
    previous_keys << previous_key
  }

  change_amount = previous_transaction_value - amount_to_pay - TRANSACTION_FEE
  change_pubkeys = previous_pubkeys

  change_multisig_script = Bitcoin::Script.to_multisig_script(min_signatures_required, *change_pubkeys)

  new_transaction = Bitcoin::Protocol::Tx.new

  transaction_input = Bitcoin::Protocol::TxIn.from_hex_hash(previous_transaction_hash, previous_transaction_vout)
  new_transaction.add_in(transaction_input)

  transaction_output_payee = Bitcoin::Protocol::TxOut.value_to_address(amount_to_pay, payee_address)
  new_transaction.add_out(transaction_output_payee)
  
  transaction_output_change = Bitcoin::Protocol::TxOut.new(change_amount, change_multisig_script)
  new_transaction.add_out(transaction_output_change)

  signature_hash = new_transaction.signature_hash_for_input(previous_transaction_vout, previous_transaction, Bitcoin::Script::SIGHASH_TYPE[:all])

  previous_keys = previous_keys.reverse()
  key = previous_keys.shift()

  signature = key.sign(signature_hash)
  partially_signed = Bitcoin::Script.to_multisig_script_sig(signature)
  
  signed_by_signatures = 1

  while signed_by_signatures < min_signatures_required

    key = previous_keys.shift()
    signature = key.sign(signature_hash)
    partially_signed = Bitcoin::Script.add_sig_to_multisig_script_sig(signature, partially_signed)
    signed_by_signatures += 1
  end

  script_sig = partially_signed
  
  new_transaction.in[0].script_sig = script_sig

  # Code to verify input signature
  # verify_transaction = Bitcoin::Protocol::Tx.new(new_transaction.to_payload)
  # p ({verify: verify_transaction.verify_input_signature(0, previous_transaction)})

  $transactionId = $bitcoinRpc.sendrawtransaction new_transaction.to_payload.bth
  $transactionId

end

def get_transaction_from_utxo ( txid )

  all_utxo = get_all_utxo

  transaction = nil

  is_valid = false

  all_utxo.each { |utxo|

    if utxo[:trans_id] == txid

      transaction = utxo
    end
  }

  transaction
end