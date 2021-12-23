#!/bin/bash

sudo cat <<EOF > /etc/nginx/sites-available/default
      server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/xxx;
        index index.php;
        server_name _;
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }
      }
EOF

sudo systemctl restart nginx.service

git clone https://github.com/blongden/phpinfo.git /var/www/xxx

timewait=$(shuf -i1-100 -n1)
sleep $timewait
