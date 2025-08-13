

# Challenge 9 PDFofSecrets

## Description

The objective of this challenge is extract Javascript code from a PDF file which when executed reveals the flag. 

# Solution
**1. List the assets within the pdf file**
To analyze this file we can use the `pdfdetach` tool to list all of the files saved within the PDF file. As shown in the output below, the PDF contains a single embedded file called reader.  

    └─$ pdfdetach -list challenge9.pdf                           
    1 embedded files
    1: reader
          
**2. Extract embedded file**

We now extract the embedded file using the following command:

    └─$ pdfdetach -saveall challenge9.pdf 
                                                                                                                                                                                                        
    ┌──(kali㉿kali)-[~/Desktop/ctf_challenges/challenge 9 - PDF JS Binary Analysis]
    └─$ ls 
     challenge9.pdf  'dev files'   reader
                                                                                                          
 We can `cat` the reader file to see the contents and notice that it appears as obfuscated JavaScript code as shown below. 
                                                                                           
    └─$ cat reader       
    function _0x59dd(){const _0x591f90=['4fOEnoW','gAAAAABoc_UNVsie6IMciiUFyK8YCDJfxHJipMpXVQlODJaVTlkAFYH4VA5Ocjo-Flq0m32q9Gjr8nUp98imVmb0H4B8c76iWVLJtsbFns7ikcvDzuNdGfc=','13205862CnMFxR','6832661kcZfDT','8hGbhDt','Decryption\x20failed:','fernet','7831271IftdyX','error','12UBEXHy','log','94903doJCdc','decode','5iIMkYM','10EojTBR','Token','2138862WAiuUE','40297595AyCzoO','3527229AwMzyq','Secret','10wzArFa'];_0x59dd=function(){return _0x591f90;};return _0x59dd();}const _0x33c62f=_0x2b28;(function(_0xd3cb7,_0x40a494){const _0x1441cb=_0x2b28,_0x217490=_0xd3cb7();while(!![]){try{const _0x55c1fe=parseInt(_0x1441cb(0x1c7))/0x1*(-parseInt(_0x1441cb(0x1ca))/0x2)+parseInt(_0x1441cb(0x1b9))/0x3*(-parseInt(_0x1441cb(0x1bc))/0x4)+-parseInt(_0x1441cb(0x1c9))/0x5*(parseInt(_0x1441cb(0x1b7))/0x6)+parseInt(_0x1441cb(0x1c3))/0x7*(-parseInt(_0x1441cb(0x1c0))/0x8)+-parseInt(_0x1441cb(0x1be))/0x9*(-parseInt(_0x1441cb(0x1bb))/0xa)+-parseInt(_0x1441cb(0x1bf))/0xb*(parseInt(_0x1441cb(0x1c5))/0xc)+parseInt(_0x1441cb(0x1b8))/0xd;if(_0x55c1fe===_0x40a494)break;else _0x217490['push'](_0x217490['shift']());}catch(_0x37662d){_0x217490['push'](_0x217490['shift']());}}}(_0x59dd,0xc850e));function _0x2b28(_0x47eb3f,_0x263abe){const _0x59dd27=_0x59dd();return _0x2b28=function(_0x2b283e,_0x59c892){_0x2b283e=_0x2b283e-0x1b6;let _0x895d48=_0x59dd27[_0x2b283e];return _0x895d48;},_0x2b28(_0x47eb3f,_0x263abe);}const Fernet=require(_0x33c62f(0x1c2)),secret=new Fernet[(_0x33c62f(0x1ba))]('ZUi8GPTPsdUX7IhgBjT9CY8AiD4R9Qhof3tdfgerdf4'),token=_0x33c62f(0x1bd),f=new Fernet[(_0x33c62f(0x1b6))]({'secret':secret,'token':token,'ttl':0x0});try{const plaintext=f[_0x33c62f(0x1c8)]();console[_0x33c62f(0x1c6)]('Decrypted:',plaintext);}catch(_0x1d6254){console[_0x33c62f(0x1c4)](_0x33c62f(0x1c1),_0x1d6254);}



**3. Run JavaScript code**

Executing the code (not recommended for unknown code!) provides the flag as shown below:

    └─$ node reader
    Decrypted: flag{fMy_nam3_J3ff}

From above we can see that the flag is `flag{fMy_nam3_J3ff}`
The challenge is solved!


# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

**1. Encrypt the flag**

The Javascript code contains the flag encrypted using fernet encryption. This encryption scheme was selected arbitrary. The purpose of encrypting the flag within the Javascript code is to ensure that no one can use a tool like `strings` to find the flag without solving the challenge. 

Using CyberChef I encrypted the flag `flag{fMy_nam3_J3ff}` with the following 32 bit key ` ZUi8GPTPsdUX7IhgBjT9CY8AiD4R9Qhof3tdfgerdf4` resulting in the following encrypted flag.

    gAAAAABoc_UNVsie6IMciiUFyK8YCDJfxHJipMpXVQlODJaVTlkAFYH4VA5Ocjo-Flq0m32q9Gjr8nUp98imVmb0H4B8c76iWVLJtsbFns7ikcvDzuNdGfc=

**2. Create the JavaScript code**
The following is the super simple Javascript code which decodes and prints Ferret encryption to the console. This code contains the secret key as well as the encrypted flag. Feel free to modify the `secret` and the `token` variables to be consistent with your flag. 

    const Fernet = require('fernet');
    
    // your 32-byte Base64-URL key:
    const secret = new Fernet.Secret('ZUi8GPTPsdUX7IhgBjT9CY8AiD4R9Qhof3tdfgerdf4');
    
    const token = 'gAAAAABoc_UNVsie6IMciiUFyK8YCDJfxHJipMpXVQlODJaVTlkAFYH4VA5Ocjo-Flq0m32q9Gjr8nUp98imVmb0H4B8c76iWVLJtsbFns7ikcvDzuNdGfc=';
    const f = new Fernet.Token({ secret, token, ttl:0 });
    
    try {
      const plaintext = f.decode();
      console.log('Decrypted:', plaintext);
    } catch (err) {
      console.error('Decryption failed:', err);
    }

**3. Obfuscate the JavaScript code**

Next we obfuscate the code to make it less obvious at what the code actually does. Not a strict requirement. To do this, we used the following resource:
https://obfuscator.io/

Resulting in the following code:

     function _0x59dd(){const _0x591f90=['4fOEnoW','gAAAAABoc_UNVsie6IMciiUFyK8YCDJfxHJipMpXVQlODJaVTlkAFYH4VA5Ocjo-Flq0m32q9Gjr8nUp98imVmb0H4B8c76iWVLJtsbFns7ikcvDzuNdGfc=','13205862CnMFxR','6832661kcZfDT','8hGbhDt','Decryption\x20failed:','fernet','7831271IftdyX','error','12UBEXHy','log','94903doJCdc','decode','5iIMkYM','10EojTBR','Token','2138862WAiuUE','40297595AyCzoO','3527229AwMzyq','Secret','10wzArFa'];_0x59dd=function(){return _0x591f90;};return _0x59dd();}const _0x33c62f=_0x2b28;(function(_0xd3cb7,_0x40a494){const _0x1441cb=_0x2b28,_0x217490=_0xd3cb7();while(!![]){try{const _0x55c1fe=parseInt(_0x1441cb(0x1c7))/0x1*(-parseInt(_0x1441cb(0x1ca))/0x2)+parseInt(_0x1441cb(0x1b9))/0x3*(-parseInt(_0x1441cb(0x1bc))/0x4)+-parseInt(_0x1441cb(0x1c9))/0x5*(parseInt(_0x1441cb(0x1b7))/0x6)+parseInt(_0x1441cb(0x1c3))/0x7*(-parseInt(_0x1441cb(0x1c0))/0x8)+-parseInt(_0x1441cb(0x1be))/0x9*(-parseInt(_0x1441cb(0x1bb))/0xa)+-parseInt(_0x1441cb(0x1bf))/0xb*(parseInt(_0x1441cb(0x1c5))/0xc)+parseInt(_0x1441cb(0x1b8))/0xd;if(_0x55c1fe===_0x40a494)break;else _0x217490['push'](_0x217490['shift']());}catch(_0x37662d){_0x217490['push'](_0x217490['shift']());}}}(_0x59dd,0xc850e));function _0x2b28(_0x47eb3f,_0x263abe){const _0x59dd27=_0x59dd();return _0x2b28=function(_0x2b283e,_0x59c892){_0x2b283e=_0x2b283e-0x1b6;let _0x895d48=_0x59dd27[_0x2b283e];return _0x895d48;},_0x2b28(_0x47eb3f,_0x263abe);}const Fernet=require(_0x33c62f(0x1c2)),secret=new Fernet[(_0x33c62f(0x1ba))]('ZUi8GPTPsdUX7IhgBjT9CY8AiD4R9Qhof3tdfgerdf4'),token=_0x33c62f(0x1bd),f=new Fernet[(_0x33c62f(0x1b6))]({'secret':secret,'token':token,'ttl':0x0});try{const plaintext=f[_0x33c62f(0x1c8)]();console[_0x33c62f(0x1c6)]('Decrypted:',plaintext);}catch(_0x1d6254){console[_0x33c62f(0x1c4)](_0x33c62f(0x1c1),_0x1d6254);}
     
This code was saved to a file called `reader.js`

**4. Embed JavaScript code within PDF file**
Select an arbitrary PDF file that you want to provide to participants. We have selected a random PDF from NASA found here:
https://pwg.gsfc.nasa.gov/polar/telecons/archive/PR_E-PO/Aurora_flyer/aurora-flyer_p2.doc.pdf

This file was renamed to `base.pdf` and it contains a lot of pictures which may trick participants into believing that stenography is required to solve this challenge. 

To embed the JavaScript tool into the PDF use the `pdftk` tool as shown below:

     └─$ pdftk base.pdf attach_files reader output challenge9.pdf
    Picked up _JAVA_OPTIONS: -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true


Perform the steps from the solution to validate that this challenge has been successfully created. 
This completes the recreation of this CTF Challenge. 

















