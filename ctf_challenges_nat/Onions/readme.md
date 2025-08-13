﻿

# Challenge 7 - Onions

## Description

The objective of this challenge is to decrypt the provided cyphertext: `R1UyRE1PQldIRTNUR01SUUdZNERNTUpYR01aREFOU0VHWVlUTVJKWEhFWkRBTlNER1lZVE9PSldHVTNURU5aVEdKQ1RFUkpTSVVaREFOQ0RHWTRUTVFSV0dVWkRBTlJSR1pDVEVNQldJWTNFS05SWkdaRERNUkpTSVU9PT09PT0=`

# Solution
**1. Review the Ciphertext**

Reviewing the ciphertext will make users realize that the cipher applied base64.
 
**2. Decoding the Cyphertext**

The user can then use a base64 decoder tool found with a quick google search to see the plaintext.  The user will then realize that the plaintext is still encrypted and that the
true plaintext is has been enveloped in multiple encryption layers. Decoding from base64 produces the following result: 
`GU2DMOBWHE3TGMRQGY4DMMJXGMZDANSEGYYTMRJXHEZDANSDGYYTOOJWGU3TENZTGJCTERJSIUZDANCDGY4TMQRWGUZDANRRGZCTEMBWIY3EKNRZGZDDMRJSIU======`

**3. Decoding the First Result**

From the previous decryption result, one can notice that the encoding method used at this layer is base32, so ciphertext will be decoded again using base32 this time.  This yields the
following result:
`5468697320686173206D616E79206C61796572732E2E2E204C696B6520616E206F6E696F6E2E`

**4. Decoding the Second Result**

Once again decoding yields another ciphertext, although at this point the user can infer that if the first two layers used base64 and base32 then the current ciphertext can be decoded with base16.
Applying this yields the following plaintext: 
`This has many layers... Like an onion.`

Therefore. the flag is `flag{This has many layers... Like an onion.}`

# Recreating this challenge 

To recreate this challenge one can follow these steps:

1. Create your plaintext and apply encoding in the following order: Base16 --> Base32 --> Base64.
2. Create the challenge on the CTF platform with the ciphertext provided in the challenge.

This completes the recreation of this CTF Challenge. 

