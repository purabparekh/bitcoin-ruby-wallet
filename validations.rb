def validate_sendtoaddress_inputs ( data )

  response = {}
  response["status"] = false

  if data.length != 4
    response["err_msg"] = "Insufficient number of parameters!"
    return response
  end

  begin
    
    data[1] = Integer(data[1])
    data[2] = btc_to_satoshi(Float(data[2])) + TRANSACTION_FEE

    transaction = get_transaction_from_utxo(data[0])

    if transaction == nil
      response["err_msg"] = "Either invalid, non-wallet or already spent Transaction ID"
      return response
    end

    if transaction[:vout_index] != data[1] or btc_to_satoshi(transaction[:value]) < data[2]
      response["err_msg"] = "Incorrect vout index or transaction amount"
      return response
    end

    if !is_valid_address data[3]
      response["err_msg"] = "Either invalid or non-wallet payee address"
      return response
    end

    response["status"] = true
    return response

  rescue
    response["err_msg"] = "Invalid parameter values!"
    return response
  end

end

def validate_sendtomultisig_inputs ( data )

  if data.length >= 6
    true
  else
    false
  end
end

def validate_redeemtoaddress_inputs ( data )

  if data.length == 4
    true
  else
    false
  end
end
