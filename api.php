<?php

// ==============================
// 🔐 CONFIG
// ==============================

$configFile = "/etc/panel-api.conf";

// crear config si no existe
if (!file_exists($configFile)) {
    file_put_contents($configFile, "TOKEN=123456");
}

$config = parse_ini_file($configFile);

$API_TOKEN = $config['TOKEN'] ?? '123456';

// ==============================
// 🔐 TOKEN
// ==============================

$token = $_POST['token'] ?? '';

if ($token != $API_TOKEN) {
    die("DENEGADO");
}

// ==============================
// 🔥 CREAR USUARIO
// ==============================

if (!isset($_POST['action']) || $_POST['action'] == "create") {

    $user = trim($_POST['user'] ?? '');
    $pass = trim($_POST['pass'] ?? '');

    if ($user == '' || $pass == '') {
        echo "ERROR_EMPTY";
        exit();
    }

    // validar si existe
    exec("id " . escapeshellarg($user) . " 2>/dev/null", $o, $r);

    if ($r == 0) {
        echo "EXISTS";
        exit();
    }

    exec("sudo useradd -m " . escapeshellarg($user) . " 2>&1", $out1, $r1);

    exec("echo " . escapeshellarg("$user:$pass") . " | sudo chpasswd 2>&1", $out2, $r2);

    if ($r1 === 0 && $r2 === 0) {
        echo "OK";
    } else {
        echo "ERROR_CREATE";
    }

    exit();
}

// ==============================
// 🔥 ELIMINAR USUARIO
// ==============================

if (isset($_POST['action']) && $_POST['action'] == "delete") {

    $user = trim($_POST['user'] ?? '');

    if ($user == '') {
        echo "ERROR_USER";
        exit();
    }

    exec("sudo pkill -9 -u " . escapeshellarg($user) . " 2>&1");

    exec("sudo userdel -f -r " . escapeshellarg($user) . " 2>&1", $out, $ret);

    if ($ret === 0) {
        echo "DEL_OK";
    } else {
        echo "ERROR_DELETE";
    }

    exit();
}

// ==============================
// 🔥 ONLINE
// ==============================

if (isset($_POST['action']) && $_POST['action'] == "online") {

    $output = [];

    exec("ps -eo user,cmd | grep -E 'sshd|dropbear' | grep -v root | grep -v grep", $ps);

    foreach ($ps as $line) {

        $parts = preg_split('/\s+/', trim($line));

        if (!empty($parts[0])) {
            $output[] = "USER: " . $parts[0];
        }
    }

    echo json_encode($output);
    exit();
}

// ==============================
// ❌ DEFAULT
// ==============================

echo "INVALID";
