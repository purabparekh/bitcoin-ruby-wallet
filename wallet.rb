require 'json'

require_relative 'help.rb'
require_relative 'keys.rb'
require_relative 'transactions.rb'
require_relative 'validations.rb'

if !ARGV.empty?

  command, *data = ARGV

  command = command.downcase

  case command

  # Generate new key, and store it in CSV file
  when 'generatekey'

    key_info = generate_key(!data.empty? && data[0].casecmp('compressed').zero?)

    puts 'New key generated: '
    puts JSON.pretty_generate(key_info)

  # List all the keys in CSV file
  when 'listkey'

    all_keys = get_all_keys(data)

    puts 'List of all the keys available in your wallet: '
    puts JSON.pretty_generate(all_keys)

    puts 'Total keys available: ' + all_keys.length.to_s

  # List all the addresses in CSV file
  when 'listaddresses'

    all_addresses = get_all_addresses

    puts 'List of all the addresses available in your wallet: '
    puts JSON.pretty_generate(all_addresses)

    puts 'Total addresses available: ' + all_addresses.length.to_s

  # List all the unspent transactions
  when 'listutxo'

    all_utxo = get_all_utxo

    puts 'List of all UTXOs: '
    puts JSON.pretty_generate(all_utxo)

    puts 'Total UTXOs available: ' + all_utxo.length.to_s

    balance = 0
    all_utxo.each { |utxo| balance += utxo['value'] }

    puts 'Total balance: ' + balance.to_s

  # Get total balance of all the unspent transactions
  when 'getbalance'

    balance = get_balance

    puts 'Total balance: ' + balance.to_s

  # Send transactions from UTXO to particular address
  when 'sendtoaddress'

    validation = validate_sendtoaddress_inputs(data)

    if validation['status']

      new_transaction_id = send_to_address(data)

      puts 'Transaction successful. New transaction id: '
      puts new_transaction_id

      puts 'Note: Execute following command' \
           'to see this transaction in listutxo output.'
      puts 'bitcoin-cli -regtest generate 1'

    else
      puts validation['err_msg']
    end

  # Send transactions from UTXO to multisig address
  when 'sendtomultisig'

    validation = validate_sendtomultisig_inputs(data)

    if validation['status']

      new_transaction_id = send_to_multisig(data)

      puts 'Transaction successful. New transaction id: '
      puts new_transaction_id

      puts 'Note: Execute following command' \
           'to see this transaction in listutxo output.'
      puts 'bitcoin-cli -regtest generate 1'

    else
      puts validation['err_msg']
    end

  # Redeem transactions sent to multisig address
  when 'redeemtoaddress'

    validation = validate_redeemtoaddress_inputs(data)

    if validation['status']

      new_transaction_id = redeem_multisig_to_address(data)

      puts 'Transaction successful. New transaction id: '
      puts new_transaction_id

      puts 'Note: Execute following command' \
           'to see this transaction in listutxo output.'
      puts 'bitcoin-cli -regtest generate 1'

    else
      puts validation['err_msg']
    end

  # Help section
  when 'help'

    if !data.empty?
      show_help_for_command(data[0])
    else
      puts 'Command missing!'
      show_available_commands
    end

  # For testing purpose
  when 'test'

    puts validate_redeemtoaddress_inputs(data)

  # default case
  else
    puts 'Invalid command!'
    show_available_commands
  end

else
  puts 'Command missing!'
  show_available_commands
end
