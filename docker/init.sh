#!/bin/bash
echo "Waiting for MariaDB and Redis services to be ready..."

# Wait for MariaDB
while [[ -z $(kubectl get pods -n frappe --selector=app.kubernetes.io/name=frappe-helpdesk-mariadb --field-selector=status.phase=Running -o jsonpath="{.items[0].metadata.name}") ]]; do
    echo "MariaDB is not ready yet. Retrying in 10s..."
    sleep 10
done

# Wait for Redis Master
while [[ -z $(kubectl get pods -n frappe --selector=app.kubernetes.io/name=frappe-helpdesk-redis-master --field-selector=status.phase=Running -o jsonpath="{.items[0].metadata.name}") ]]; do
    echo "Redis Master is not ready yet. Retrying in 10s..."
    sleep 10
done

echo "All required services are running. Proceeding with Frappe initialization..."
# Check if Bench already exists
if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd frappe-bench
    bench start
else
    echo "Creating new bench..."
    bench init --skip-redis-config-generation frappe-bench --version version-15
fi

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

bench new-site frappe.dev.umsglobal.net \  # Using provided hostname
--force \
--mariadb-root-password DB123 \
--admin-password admin \
--no-mariadb-socket

bench --site #!/bin/bash

# Check if Bench already exists
if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd frappe-bench
    bench start
else
    echo "Creating new bench..."
    bench init --skip-redis-config-generation frappe-bench --version version-15
fi

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

bench new-site frappe.abcd.com \  # Using provided hostname
--force \
--mariadb-root-password 123 \
--admin-password admin \
--no-mariadb-socket

bench --site frappe.dev.umsglobal.net install-app helpdesk
bench --site frappe.dev.umsglobal.net set-config developer_mode 1
bench --site frappe.dev.umsglobal.net set-config mute_emails 1
bench --site frappe.dev.umsglobal.net set-config server_script_enabled 1
bench --site frappe.dev.umsglobal.net clear-cache
bench use frappe.dev.umsglobal.net

bench start install-app helpdesk
bench --site frappe.dev.umsglobal.net set-config developer_mode 1
bench --site frappe.dev.umsglobal.net set-config mute_emails 1
bench --site frappe.dev.umsglobal.net set-config server_script_enabled 1
bench --site frappe.dev.umsglobal.net clear-cache
bench use frappe.dev.umsglobal.net

bench start
