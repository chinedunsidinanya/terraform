#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo service httpd start
sudo chkconfig httpd on
echo "Hello this is my terraform server....." > /var/www/html/index.html