#!/bin/bash

clear

echo "======================================"
echo "        INSTALADOR DE PANEL"
echo "======================================"

sleep 1

# ======================================
# ROOT CHECK
# ======================================

if [ "$(id -u)" != "0" ]; then
   echo ""
   echo "❌ Ejecuta como root"
   echo ""
   exit 1
fi

# ======================================
# VARIABLES
# ======================================

REPO="https://raw.githubusercontent.com/Dealer-Dev/panel-api/main"

API_PATH="/var/www/html/panel"

CONFIG_FILE="/etc/panel-api.conf"

# ======================================
# TOKEN
# ======================================

echo ""
read -p " Ingresa TOKEN API: " TOKEN

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
apt update -y

# ======================================
# INSTALL PACKAGES
# ======================================

echo ""
echo " Instalando paquetes..."

apt install apache2 php php-curl sudo curl wget net-tools -y

# ======================================
# CREATE PANEL DIR
# ======================================

mkdir -p $API_PATH

# ======================================
# DOWNLOAD FILES
# ======================================

echo ""
echo " Descargando archivos..."

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
# DONE
# ======================================

clear

echo "======================================"
echo "      INSTALACION COMPLETA"
echo "======================================"
echo ""
echo " API URL:"
echo "http://$IP/panel/api.php"
echo ""
echo " ONLINE URL:"
echo "http://$IP/panel/online.php"
echo ""
echo " TOKEN:"
echo "$TOKEN"
echo ""
