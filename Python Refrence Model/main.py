from Crypto.Cipher import AES
import binascii

file_verilog_output = open('C:/Users/ziada/OneDrive/Desktop/VerificationCourse/EncryptorUVM/verilogoutput.txt', 'r')
content = file_verilog_output.readline()
search_string_message = "Message:"
search_string_key = "Key:"
Message = []
Key     = []
iv = bytes.fromhex('000102030405060708090a0b0c0d0e0f')


# Find the index of the search_string
index_message = content.find(search_string_message)
index_key     = content.find(search_string_key)

if index_message != -1:  # Check if search_string was found
    result_m = content[index_message + len(search_string_message):].strip()  # Get the string after the search_string
    Message = result_m[:32]


if index_key != -1:  # Check if search_string was found
    result_K = content[index_key + len(search_string_key):].strip()  # Get the string after the search_string
    Key = result_K[:32]

Key = bytes.fromhex(Key)
Message = bytes.fromhex(Message)


obj = AES.new(Key, AES.MODE_ECB)
ciphertext = obj.encrypt(Message)

with open('C:/Users/ziada/OneDrive/Desktop/VerificationCourse/EncryptorUVM/PythonOutput.txt', 'w') as file:
    file.write(ciphertext.hex())

#with open('C:/Users/ziada/OneDrive/Desktop/VerificationCourse/EncryptorUVM/verilogoutput.txt', 'w') as file:
  #  pass

