#!/bin/bash

apt update && apt updgrade -y

apt install -y apache2 python3-flask mariadb-server

systemctl enable apache2

echo "<h1> -*- Hello from VM1! -*- </h1>" > /var/www/html/index.html

systemctl start apache2