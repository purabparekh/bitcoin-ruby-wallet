# Input validations for `sendtoaddress` method
def validate_sendtoaddress_inputs(data)
  response = {}
  response['status'] = false

  if data.length != 4
    response['err_msg'] = 'Insufficient number of parameters!'
    return response
  end

  begin
    data[1] = Integer(data[1])
    data[2] = btc_to_satoshi(Float(data[2]))

    transaction = retrieve_transaction_from_utxo(data[0], data[1])

    if transaction.nil?
      response['err_msg'] =
        'Either invalid, non-wallet or already spent Transaction ID,' \
        'or incorrect vout index'
      return response
    end

    if multisig_transaction?(transaction['trans_id'], transaction['vout_index'])
      response['err_msg'] =
        'Transaction ID provided is a multisig transaction.' \
        'Please use `redeemtoaddress` command for this.'
      return response
    end

    if btc_to_satoshi(transaction['value']) < (data[2] + TRANSACTION_FEE)
      response['err_msg'] =
        'Amount to transfer must be less than the transaction amount'
      return response
    end

    unless valid_address? data[3]
      response['err_msg'] = 'Either invalid or non-wallet payee address'
      return response
    end

    response['status'] = true
    return response
  rescue
    response['err_msg'] = 'Invalid parameter values!'
    return response
  end
end

# Input validations for `sendtomultisig` method
def validate_sendtomultisig_inputs(data)
  response = {}
  response['status'] = false

  if data.length < 6
    response['err_msg'] = 'Insufficient number of parameters!'
    return response
  end

  begin
    data[1] = Integer(data[1])
    data[2] = btc_to_satoshi(Float(data[2]))
    data[3] = Integer(data[3])

    transaction = retrieve_transaction_from_utxo(data[0], data[1])

    if transaction.nil?
      response['err_msg'] =
        'Either invalid, non-wallet or already spent Transaction ID,' \
        'or incorrect vout index'
      return response
    end

    if btc_to_satoshi(transaction['value']) < (data[2] + TRANSACTION_FEE)
      response['err_msg'] =
        'Amount to transfer must be less than the transaction amount'
      return response
    end

    payee_addresses = data.slice(4..-1)

    if data[3] > payee_addresses.length
      response['err_msg'] =
        'Minimum signatures required must be less than or equal to' \
        'the number of payee addresses provided'
      return response
    end

    payee_addresses.each { |address|
      next if valid_address? address
      response['err_msg'] =
        'Either invalid or non-wallet payee address: ' + address
      return response
    }

    response['status'] = true
    return response
  rescue
    response['err_msg'] = 'Invalid parameter values!'
    return response
  end
end

# Input validations for `redeemtoaddress` method
def validate_redeemtoaddress_inputs(data)
  response = {}
  response['status'] = false

  if data.length != 4
    response['err_msg'] = 'Insufficient number of parameters!'
    return response
  end

  begin
    data[1] = Integer(data[1])
    data[2] = btc_to_satoshi(Float(data[2]))

    transaction = retrieve_transaction_from_utxo(data[0], data[1])

    if transaction.nil?
      response['err_msg'] =
        'Either invalid, non-wallet or already spent Transaction ID,' \
        'or incorrect vout index'
      return response
    end

    unless multisig_transaction?(
      transaction['trans_id'],
      transaction['vout_index']
    )

      response['err_msg'] =
        'Transaction ID provided is not multisig transaction.' \
        'Please use `sendtoaddress` command for this.'
      return response
    end

    if btc_to_satoshi(transaction['value']) < (data[2] + TRANSACTION_FEE)
      response['err_msg'] =
        'Amount to transfer must be less than the transaction amount'
      return response
    end

    unless valid_address? data[3]
      response['err_msg'] = 'Either invalid or non-wallet payee address'
      return response
    end

    response['status'] = true
    return response
  rescue
    response['err_msg'] = 'Invalid parameter values!'
    return response
  end
end
