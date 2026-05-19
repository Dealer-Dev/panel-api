#!/bin/bash

clear

echo "======================================"
echo "      INSTALADOR PANEL WEB DEALER"
echo "======================================"

sleep 1

# ======================================
# ROOT
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

APACHE_PORT="8888"

VHOST_FILE="/etc/apache2/sites-available/panel-api.conf"

# ======================================
# TOKEN
# ======================================

echo ""

read -p "Ingresa TOKEN para tu vps: " TOKEN

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
echo "🌐 Configurando Apache..."

if ! grep -q "Listen $APACHE_PORT" /etc/apache2/ports.conf; then

    echo "Listen $APACHE_PORT" \
    >> /etc/apache2/ports.conf
fi

# ======================================
# CREATE PANEL DIR
# ======================================

mkdir -p $API_PATH

# ======================================
# DOWNLOAD FILES
# ======================================

echo ""
echo "📥 Descargando archivos..."

wget -O $API_PATH/api.php \
$REPO/api.php

wget -O $API_PATH/online.php \
$REPO/online.php

# ======================================
# CONFIG TOKEN
# ======================================

echo ""
echo "🔐 Configurando TOKEN..."

echo "TOKEN=$TOKEN" > $CONFIG_FILE

chmod 644 $CONFIG_FILE

# ======================================
# PERMISSIONS
# ======================================

chmod 755 $API_PATH/api.php
chmod 755 $API_PATH/online.php

chown -R www-data:www-data $API_PATH

# ======================================
# VIRTUAL HOST
# ======================================

echo ""
echo "⚡ Creando VirtualHost..."

cat > $VHOST_FILE <<EOF
<VirtualHost *:$APACHE_PORT>

    ServerAdmin localhost

    DocumentRoot /var/www/html

    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

</VirtualHost>
EOF

# ======================================
# ENABLE SITE
# ======================================

a2ensite panel-api.conf >/dev/null 2>&1

# ======================================
# SUDOERS
# ======================================

echo ""
echo "⚡ Configurando sudo..."

if ! grep -q \
"www-data ALL=(ALL) NOPASSWD:ALL" \
/etc/sudoers; then

    echo \
"www-data ALL=(ALL) NOPASSWD:ALL" \
>> /etc/sudoers
fi

# ======================================
# FIREWALL
# ======================================

echo ""
echo "🔥 Abriendo puerto..."

ufw allow $APACHE_PORT/tcp >/dev/null 2>&1

# ======================================
# APACHE TEST
# ======================================

apachectl configtest

# ======================================
# RESTART
# ======================================

systemctl enable apache2

systemctl restart apache2

# ======================================
# STATUS
# ======================================

sleep 2

STATUS=$(systemctl is-active apache2)

IP=$(curl -s ipv4.icanhazip.com)

# ======================================
# FINAL
# ======================================

clear

echo "======================================"
echo "      INSTALACION COMPLETA"
echo "======================================"
echo ""

if [ "$STATUS" = "active" ]; then

    echo "🟢 Panel instalado con éxito"

else

    echo "🔴 No se pudo instalar el panel"
fi

echo ""
echo "🌐 API URL:"
echo "http://$IP:$APACHE_PORT/panel/api.php"
echo ""

echo "🌐 ONLINE URL:"
echo "http://$IP:$APACHE_PORT/panel/online.php"
echo ""

echo "🔐 TOKEN:"
echo "$TOKEN"
echo "(este token va en lugar de contraseña de tu vps en el panel)"
echo ""

echo "======================================"
echo "        SCRIPT FINALIZADO"
echo "======================================"
echo ""
