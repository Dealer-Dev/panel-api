#!/bin/bash

clear

echo "==================================================="
echo "   INSTALADOR DE PANEL by @DealerServices235"
echo "==================================================="

sleep 1

# ROOT
if [ "$(id -u)" != "0" ]; then
   echo "Ejecuta como root"
   exit 1
fi

# ACTUALIZAR
apt update -y

# INSTALAR
apt install apache2 php php-curl sudo curl wget -y

# CREAR CARPETA
mkdir -p /var/www/html/panel

# DESCARGAR API
wget -O /var/www/html/panel/api.php \
https://raw.githubusercontent.com/TUUSUARIO/panel-api/main/api.php

# DESCARGAR ONLINE
wget -O /var/www/html/panel/online.php \
https://raw.githubusercontent.com/TUUSUARIO/panel-api/main/online.php

# PERMISOS
chmod 755 /var/www/html/panel/api.php
chmod 755 /var/www/html/panel/online.php

# SUDO
if ! grep -q "www-data ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# APACHE
systemctl enable apache2
systemctl restart apache2

IP=$(curl -s ipv4.icanhazip.com)

clear

echo "================================="
echo "   INSTALACION COMPLETADA"
echo "================================="
echo ""
echo "API:"
echo "http://$IP/panel/api.php"
echo ""
echo "ONLINE:"
echo "http://$IP/panel/online.php"
echo ""
