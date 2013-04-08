makeToken = () ->
  alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
  output = ""
  for i in [0..6]
    rand = Math.floor(Math.random() * alphabet.length)
    output += alphabet[rand]
  return output
