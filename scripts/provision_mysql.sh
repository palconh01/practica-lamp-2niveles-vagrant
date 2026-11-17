#!/bin/bash

# --- VARIABLES DE ENTORNO ---
REPO_URL="https://github.com/josejuansanchez/iaw-practica-lamp.git"
TEMP_DIR="/tmp/app_temp"
WEB_IP="192.168.56.10"

DB_NAME="lamp_db"
DB_USER="lamp_user"
DB_PASS="lamp_password"
# ----------------------------

# 1. Actualizar e instalar servicios
apt-get update -y
apt-get install -y mariadb-server git

# 2. Exponer MariaDB modificando directamente la directiva bind-address
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb

# 3. Descargar el repositorio para obtener el script de la base de datos
rm -rf $TEMP_DIR
git clone $REPO_URL $TEMP_DIR

# 4. Importar el esquema SQL
mysql -u root < ${TEMP_DIR}/db/database.sql

# 5. Crear el usuario remoto y asignar privilegios (usando un bloque EOF)
mysql -u root <<EOF
DROP USER IF EXISTS '${DB_USER}'@'${WEB_IP}';
CREATE USER '${DB_USER}'@'${WEB_IP}' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${WEB_IP}';
FLUSH PRIVILEGES;
EOF

# 6. Limpieza final
rm -rf $TEMP_DIR

# 7. Aislar la red de la máquina (eliminar salida a Internet)
ip route del default