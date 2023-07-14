#!/bin/bash
apt update
apt install wget
wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb
dpkg -i zabbix-release_6.4-1+debian11_all.deb
apt update
apt install -y postgresql=13+225 zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
sudo -u postgres createuser -w zabbix
sudo -u postgres psql -c "ALTER ROLE zabbix WITH PASSWORD '$ZABBIX_DB_PASS';"
sudo -u postgres createdb -O zabbix zabbix
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix
sed -i 's/^.*DBPassword=.*$/DBPassword=$ZABBIX_DB_PASS/' /etc/zabbix/zabbix_server.conf
sed -i 's/#\s*listen\s*8080;/listen 8080;/' /etc/nginx/conf.d/zabbix.conf
sed -i 's/#\s*server_name\s*example.com;/server_name example.com;/' /etc/nginx/conf.d/zabbix.conf
systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm
