#!/bin/bash
sudo apt update && sudo apt install nginx unzip wget -y

cd /tmp
wget -O 2106_soft_landing.zip https://www.tooplate.com/download/2106_soft_landing.zip
unzip 2106_soft_landing.zip
cp -r 2106_soft_landing/* /var/www/html/

systemctl start nginx
systemctl enable nginx
