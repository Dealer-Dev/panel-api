#!/bin/bash

clear

echo "======================================"
echo "      INSTALADOR DE PANEL"
echo "======================================"

sleep 1

# ======================================
# ROOT CHECK
# ======================================

if [ "$(id -u)" != "0" ]; then
   echo ""
   echo " Ejecuta como root"
   echo ""
   exit 1
fi

# ======================================
# VARIABLES
# ======================================

REPO="https://raw.githubusercontent.com/Dealer-Dev/panel-api/main"

API_PATH="/var/www/html/panel"

CONFIG_FILE="/etc/panel-api.conf"

APACHE_PORT="85"

# ======================================
# TOKEN
# ======================================

echo ""
read -p "🔐 Ingresa TOKEN API: " TOKEN

if [ -z "$TOKEN" ]; then
    echo ""
    echo "❌ Token inválido"
    exit 1
fi

# ======================================
# UPDATE
# ======================================

echo ""
echo "📦 Actualizando sistema..."


# ======================================
# INSTALL PACKAGES
# ======================================

echo ""
echo "📦 Instalando paquetes..."

apt install apache2 php php-curl sudo curl wget net-tools -y

# ======================================
# APACHE PORT
# ======================================

echo ""
echo " Configurando Apache en puerto $APACHE_PORT..."

sed -i "s/Listen 80/Listen $APACHE_PORT/g" /etc/apache2/ports.conf

sed -i "s/<VirtualHost \*:80>/<VirtualHost *:$APACHE_PORT>/g" /etc/apache2/sites-enabled/000-default.conf

# ======================================
# FIREWALL
# ======================================

echo ""
echo " Abriendo puerto $APACHE_PORT..."

ufw allow $APACHE_PORT/tcp >/dev/null 2>&1

# ======================================
# CREATE PANEL DIR
# ======================================

mkdir -p $API_PATH

# ======================================
# DOWNLOAD FILES
# ======================================

echo ""
echo " Descargando archivos necesarios..."

wget -O $API_PATH/api.php \
$REPO/api.php

wget -O $API_PATH/online.php \
$REPO/online.php

# ======================================
# CREATE CONFIG
# ======================================

echo ""
echo " Configurando token..."

echo "TOKEN=$TOKEN" > $CONFIG_FILE

chmod 600 $CONFIG_FILE

# ======================================
# PERMISSIONS
# ======================================

chmod 755 $API_PATH/api.php
chmod 755 $API_PATH/online.php

# ======================================
# SUDOERS
# ======================================

echo ""
echo " Configurando permisos sudo..."

if ! grep -q "www-data ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
    echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# ======================================
# ENABLE SERVICES
# ======================================

systemctl enable apache2
systemctl restart apache2

# ======================================
# GET IP
# ======================================

IP=$(curl -s ipv4.icanhazip.com)

# ======================================
# TEST APACHE
# ======================================

sleep 2

STATUS=$(systemctl is-active apache2)

# ======================================
# DONE
# ======================================

clear

echo "======================================"
echo "       INSTALACION COMPLETA"
echo "======================================"
echo ""

if [ "$STATUS" = "active" ]; then
    echo "🟢 Apache funcionando correctamente"
else
    echo "🔴 Apache NO pudo iniciar"
fi

echo ""
echo " API URL:"
echo "http://$IP:$APACHE_PORT/panel/api.php"
echo ""

echo " ONLINE URL:"
echo "http://$IP:$APACHE_PORT/panel/online.php"
echo ""

echo " TOKEN:"
echo "$TOKEN"
echo ""

echo "======================================"
echo "         INSTALACION FINALIZADA"
echo "======================================"
echo ""
