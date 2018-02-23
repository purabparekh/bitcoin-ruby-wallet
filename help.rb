
MAIN_FILE_NAME = 'wallet.rb'

def show_available_commands
  puts 'List of available commands: '
  puts ' |-> generatekey'
  puts ' |-> listkey'
  puts ' |-> listaddresses'
  puts ' |-> listutxo'
  puts ' |-> getbalance'
  puts ' |-> sendtoaddress'
  puts ' |-> sendtomultisig'
  puts ' |-> redeemtoaddress'
  puts 'For more details, you can use: ruby ' + MAIN_FILE_NAME + ' help <command>'
end

def show_help_for_command ( command )

  command = command.downcase

  case command

    when 'generatekey'
      puts '------ Help for generatekey command ------'
      puts 'Generates a new key, and stores it in your wallet.'
      puts '# Parameters:'
      puts '  > compressed: To generate compressed key. If not provided, it will create non-compressed key.'
      puts '# Examples:'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' generatekey'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' generatekey compressed'

    when 'listkey'
      puts '------ Help for listkey command ------'
      puts 'Lists all the keys available in your wallet.'
      puts '# Parameters:'
      puts '  > address: To display address'
      puts '  > privkey: To display private key'
      puts '  > pubkey: To display public key'
      puts '# Examples:'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' listkey'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' listkey address pubkey'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' listkey pubkey privkey'

    when 'listaddresses'
      puts '------ Help for listaddresses command ------'
      puts 'Lists all the addresses available in your wallet.'
      puts '# Examples:'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' listaddresses'

    when 'listutxo'
      puts '------ Help for listutxo command ------'
      puts 'Lists all the unspent transactions related to your wallet, and get the total balance of UTXO'
      puts '# Examples:'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' listutxo'

    when 'getbalance'
      puts '------ Help for getbalance command ------'
      puts 'Displays total balance available in your wallet'
      puts '# Examples:'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' getbalance'

    when 'sendtoaddress'
      puts '------ Help for sendtoaddress command ------'
      puts 'Sends bitcoins from normal address to another normal address'
      puts '# Parameters:'
      puts '  > {transaction_id}: ID of a transaction to spend'
      puts '  > {vout_index}: vout index of above transaction that should be spent'
      puts '  > {amount}: Amount to be transferred (in BTC)'
      puts '  > {payee_address}: Address of the payee'
      puts '# Examples:'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' sendtoaddress b806a66153863113b21a08cdf46146364040006a8a4b5e070f5bd4b71a81997b 1 15 n1V4mwnm1cC42zcxVdcaepnFFSRHyyqPxE'

    when 'sendtomultisig'
      puts '------ Help for sendtomultisig command ------'
      puts 'Sends bitcoins from normal address to multisig script'
      puts '# Parameters:'
      puts '  > {transaction_id}: ID of a transaction to spend'
      puts '  > {vout_index}: vout index of above transaction that should be spent'
      puts '  > {amount}: Amount to be transferred (in BTC)'
      puts '  > {min_signatures_required}: Minimum signatures required to spend money'
      puts '  > {payee_addresses}: Addresses of the payee, seperated by space'
      puts '# Examples:'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' sendtomultisig b806a66153863113b21a08cdf46146364040006a8a4b5e070f5bd4b71a81997b 1 15 2 n1V4mwnm1cC42zcxVdcaepnFFSRHyyqPxE mjQNsXeN89Pq36jzNjf5BT5W69Qe1NC8f6 n1UezyhE23vES4Vb1wP4QWYxrD6Lbztf2J'

    when 'redeemtoaddress'
      puts '------ Help for redeemtoaddress command ------'
      puts 'Sends bitcoins from multisig script to normal address'
      puts '# Parameters:'
      puts '  > {transaction_id}: ID of a multisig transaction to spend'
      puts '  > {vout_index}: vout index of above transaction that should be spent'
      puts '  > {amount}: Amount to be transferred (in BTC)'
      puts '  > {payee_address}: Address of the payee'
      puts '# Examples:'
      puts '  $ ruby ' + MAIN_FILE_NAME + ' redeemtoaddress b806a66153863113b21a08cdf46146364040006a8a4b5e070f5bd4b71a81997b 1 15 n1V4mwnm1cC42zcxVdcaepnFFSRHyyqPxE'
    
    else
      puts 'Invalid command!'
      show_available_commands
    end

end
