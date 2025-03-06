#!bin/bash

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd frappe-bench
    bench start
else
    echo "Creating new bench..."
fi

bench init --skip-redis-config-generation frappe-bench --version version-15

cd frappe-bench

# Use Kubernetes service names instead of localhost
bench set-mariadb-host frappe-mariadb  # Using Kubernetes service name
bench set-redis-cache-host frappe-redis-master:6379
bench set-redis-queue-host frappe-redis-master:6379
bench set-redis-socketio-host frappe-redis-master:6379

# Remove redis, watch from Procfile
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

bench get-app helpdesk --branch main

bench new-site helpdesk.localhost \
--force \
--mariadb-root-password DB123 \
--admin-password admin \
--no-mariadb-socket

bench --site helpdesk.localhost install-app helpdesk
bench --site helpdesk.localhost set-config developer_mode 1
bench --site helpdesk.localhost set-config mute_emails 1
bench --site helpdesk.localhost set-config server_script_enabled 1
bench --site helpdesk.localhost clear-cache
bench use helpdesk.localhost

bench start
