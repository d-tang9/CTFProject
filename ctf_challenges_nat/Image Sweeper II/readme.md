﻿

# Challenge 2 - Image Sweeper II

## Description

The objective of this challenge is to determine the target's Ethereum wallet address. 

# Solution
**1. Review the Target's Github**

Reviewing the target's github will reveal a repository called 'ETH'.
 
**2. Review Revision History**

After reviewing the revision history for the repository one will notice that original commit reveals all details realted 
to the Ethereum wallet, including the wallet address.

**3. Submitting the flag**

Now that the ETH wallet address has been found, one can simple enter the following flag to complete the challenge:
flag{0xa102397dbeeBeFD8cD2F73A89122fCdB53abB6ef}

# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

To recreate this challenge one can follow these steps:

1. Building on the Github created for challenge Image Sweeper I, create a repo with simple text file containing Ethereum wallet details.
2. Then commit a change to the file which only provides the format of the wallet details.

This completes the recreation of this CTF Challenge. 

