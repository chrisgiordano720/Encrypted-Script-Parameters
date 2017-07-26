#!/bin/bash
# Use 'openssl' to create an encrypted Base64 string for script parameters
# Additional layer of security when passing account credentials from the JSS to a client

# Use GenerateEncryptedString() locally - DO NOT include in the script!
# The 'Encrypted String' will become a parameter for the script in the JSS
# The unique 'Salt' and 'Passphrase' values will be present in your script
function GenerateEncryptedString() {
    # Usage ~$ GenerateEncryptedString "String"
    local STRING="${1}"
    local SALT=$(openssl rand -hex 8)
    local K=$(openssl rand -hex 12)
    local ENCRYPTED=$(echo "${STRING}" | openssl enc -aes256 -a -A -S "${SALT}" -k "${K}")
    echo "Encrypted String: ${ENCRYPTED}"
    echo "Salt: ${SALT} | Passphrase: ${K}"
}

# Include DecryptString() with your script to decrypt the password sent by the JSS
# The 'Salt' and 'Passphrase' values would be present in the script
function DecryptString() {
    # Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
    echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

# Alternative format for DecryptString function
#function DecryptString() {
#    # Usage: ~$ DecryptString "Encrypted String"
#    local SALT=""
#    local K=""
#    echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "$SALT" -k "$K"
#}

enterUNPW() {
clear

echo "What is username or password that you'd like to encrypt?"
read unPW

echo "
You said that the username or password is: 

$unPW

Is that correct? [Y/N]"
read unPWConfirm
}

encryptDecrypt() {
clear

echo "Would you like to encrpyt a string or decrypt a string?

[1] Encrypt
[2] Decrypt

Please enter the number 1 or 2"
read crypt
}

strings (){
echo "
What is the encrypted string?"
read estring

echo "
What is the SALT?"
read SALT

echo "
What is the passphrase?"
read phrase
echo "
Your decrypted string is:"
}

encryptDecrypt

if [[ $crypt = "1" ]]; then
	enterUNPW
	until [[ $unPWConfirm = "Y" ]]; do
		enterUNPW
	done

	GenerateEncryptedString "$unPW"
elif [[ $crypt = "2" ]]; then
	strings
	DecryptString "$estring" "$SALT" "$phrase"
else
	echo "The option you chose isn't applicable.  Please re-run the script to try again."
fi
