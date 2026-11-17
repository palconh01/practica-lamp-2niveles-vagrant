#!/bin/bash

# --- VARIABLES DE ENTORNO ---
REPO_URL="https://github.com/josejuansanchez/iaw-practica-lamp.git"
WEB_DIR="/var/www/html"
TEMP_DIR="/tmp/app_temp"

DB_HOST="192.168.56.11"
DB_NAME="lamp_db"
DB_USER="lamp_user"
DB_PASS="lamp_password"


# 1. Actualizar e instalar dependencias (todo en un paso)
apt-get update -y
apt-get install -y apache2 php libapache2-mod-php php-mysql git

# 2. Descargar la aplicación en una carpeta temporal
rm -rf $TEMP_DIR
git clone $REPO_URL $TEMP_DIR

# 3. Mover la aplicación a la carpeta web y limpiar
rm -rf ${WEB_DIR}/*
mv ${TEMP_DIR}/src/* $WEB_DIR/

# 4. Configurar la conexión a la base de datos
cd $WEB_DIR
sed -i "s/'localhost'/'${DB_HOST}'/" config.php
sed -i "s/'database_name_here'/'${DB_NAME}'/" config.php
sed -i "s/'username_here'/'${DB_USER}'/" config.php
sed -i "s/'password_here'/'${DB_PASS}'/" config.php

# 5. Aplicar permisos y reiniciar servicios
chown -R www-data:www-data $WEB_DIR
rm -rf $TEMP_DIR
systemctl restart apache2