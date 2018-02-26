def read_data_for_command(command)
  data = []
  command = command.downcase

  case command
  when 'sendtoaddress'
    puts '--------- Gettings inputs: ---------'
    print '> Transaction ID: '
    data << $stdin.gets.chomp
    print '> VOUT index: '
    data << $stdin.gets.chomp
    print '> Amount to transfer: '
    data << $stdin.gets.chomp
    print '> Payee address: '
    data << $stdin.gets.chomp
    puts '------------------------------------'

  when 'sendtomultisig'
    puts '--------- Gettings inputs: ---------'
    print '> Transaction ID: '
    data << $stdin.gets.chomp
    print '> VOUT index: '
    data << $stdin.gets.chomp
    print '> Amount to transfer: '
    data << $stdin.gets.chomp
    print '> Minimum signatures required: '
    data << $stdin.gets.chomp
    puts '> Payee addresses: (Enter `n` to stop)'
    count = 1
    loop do
      print "   > Address #{count}: "
      address = $stdin.gets.chomp
      break if address.downcase == 'n'
      data << address
      count += 1
    end
    puts '------------------------------------'

  when 'redeemtoaddress'
    puts '--------- Gettings inputs: ---------'
    print '> Transaction ID: '
    data << $stdin.gets.chomp
    print '> VOUT index: '
    data << $stdin.gets.chomp
    print '> Amount to transfer: '
    data << $stdin.gets.chomp
    print '> Payee address: '
    data << $stdin.gets.chomp
    puts '------------------------------------'

  else
    puts 'Invalid command!'
    show_available_commands
  end

  data
end
