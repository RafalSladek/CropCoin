#!/bin/bash

curl https://getcaddy.com | bash -s personal hook.service,http.datadog,http.forwardproxy,http.login,http.minify,http.nobots,http.ratelimit

# config
mkdir /etc/caddy
chown -R root:www-data /etc/caddy
cat << EOF > /etc/caddy/Caddyfile
alpharack1.crypto-pool.net/monit {
	gzip
	log /var/log/caddy/access.log
	proxy / localhost:2812
	tls kryptoroger@gmail.com
	basicauth / user password
	datadog {
    		statsd 127.0.0.1:8125
    		tags loc:alpharack1 usecase:masternode role:monit
  	}
}
alpharack1.crypto-pool.net {
	gzip
	log /var/log/caddy/access.log
	root /var/www/html
	tls kryptoroger@gmail.com
	basicauth / user password
	datadog {
    		statsd 127.0.0.1:8125
    		tags loc:alpharack1 usecase:masternode role:monit
  	}      
}
EOF

# ssl
mkdir /etc/ssl/caddy
chown -R www-data /etc/ssl/caddy
chmod 0770 /etc/ssl/caddy

# log
mkdir /var/log/caddy
chown -R www-data /var/log/caddy
chmod 0770 /var/log/caddy

# firewall
ufw allow http
ufw allow https

# service unit file
curl -s https://raw.githubusercontent.com/mholt/caddy/master/dist/init/linux-systemd/caddy.service -o /etc/systemd/system/caddy.service

systemctl daemon-reload
systemctl enable caddy
systemctl start caddy
systemctl status caddy