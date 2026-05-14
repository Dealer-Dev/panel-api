#!/bin/bash

rm -rf /var/www/html/panel

systemctl restart apache2

echo "Panel desinstalado con éxito"
