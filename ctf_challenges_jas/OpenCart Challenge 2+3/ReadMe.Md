# Challenge 2: Databases

## Steps to Run
```bash
docker compose pull
docker compose up -d
```

---

## Description
The purpose of this challenge is to use a brute force attack on the `mysql:5.7` server, gain access to the database, and extract the flag.

---

## Solution
1. Use a password cracker to attack the MySQL database running on the container.
2. Run the following command to start an interactive MySQL session:
   ```bash
   docker run [dockerID] -it mysql
   ```
3. The password is:
   ```
   root
   ```
4. Once logged in, search through the database tables to locate the flag.  
   Specifically, use the following SQL query inside the appropriate database:
   ```sql
   SELECT * FROM oc_download;
   ```

**Flag:**  
```
flag{BruteforceDB}
```

---

## Steps to Recreate

### 1. Create a `docker-compose.yml` file
```yaml
version: '3'

services:
  web:
    build: .
    ports:
      - "8086:80"
    depends_on:
      - db

  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: opencart
      MYSQL_USER: ocuser
      MYSQL_PASSWORD: ocpass
```

### 2. Create a `Dockerfile`
```dockerfile
FROM php:5.6-apache

RUN apt update && apt install -y wget unzip libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev &&     docker-php-ext-install mysqli gd

# Download OpenCart 1.5.6.4 (from SourceForge mirror)
RUN wget https://downloads.sourceforge.net/project/opencart/OpenCart_1.5.6.x/1.5.6.4/opencart-1.5.6.4.zip -O opencart.zip &&     unzip opencart.zip &&     mv upload/* /var/www/html/ &&     rm -rf opencart.zip upload

# Set permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
```

### 3. Build and Run the Container
```bash
sudo docker compose up -d --build
```

### 4. Hide the Flag
Once the setup is complete, hide the flag within the database directory.

---

## Final Notes
This challenge demonstrates how brute force attacks can compromise databases with weak credentials. Ensure strong passwords and proper security configurations to prevent such attacks.

# Challenge 3: Union

## How to Run
```bash
docker compose pull
docker compose up -d
```

---

## Description
The purpose of this challenge is to teach students how to use SQL injection attacks to retrieve a flag.  
In this challenge, a **Union-based SQL injection** is required.

---

## Solution
- A `curl` command or **Burp Suite** request must be used to get the results, as the flag will not be displayed through the standard web interface.
- Any SQL injection that includes the `UNION` keyword will work.

Example:
```bash
curl "http://localhost:8086/index.php?route=product/search&search=UNION+SELECT+1,2,3"
```

**Flag:**
```html
<!-- flag{opencart-sqli-ctf-flag} -->
```

---

## How to Recreate

Using the implementation from **Challenge 2: Brute Force**, modify the following file:

**`var/www/html/catalog/controller/product/search.php`**
```php
<?php 
class ControllerProductSearch extends Controller { 	
    public function index() { 
        $this->language->load('product/search');

        $this->load->model('catalog/category');
        $this->load->model('catalog/product');
        $this->load->model('tool/image'); 

        if (isset($this->request->get['search']) && strpos($this->request->get['search'], 'UNION') !== false) {
            echo "<!-- FLAG{opencart-sqli-ctf-flag} -->";
        }
    }
}
```

Once this modification is made, any **Union-based SQL injection** in the search parameter will trigger the flag to appear.

---

## Final Notes
This challenge demonstrates the risks of improper input validation and highlights the importance of sanitizing user inputs to prevent SQL injection attacks.

