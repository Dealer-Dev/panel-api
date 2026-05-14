<?php

// 🔐 TOKEN
$token = $_POST['token'] ?? '';

if ($token != "123456") {
    die("DENEGADO");
}

// ==============================
// CREAR USUARIO
// ==============================
if (!isset($_POST['action']) || $_POST['action'] == "create") {

    $user = trim($_POST['user']);
    $pass = trim($_POST['pass']);

    exec("sudo useradd -m " . escapeshellarg($user));
    exec("echo " . escapeshellarg("$user:$pass") . " | sudo chpasswd");

    echo "OK";
    exit();
}

// ==============================
// ELIMINAR USUARIO
// ==============================
if (isset($_POST['action']) && $_POST['action'] == "delete") {

    $user = trim($_POST['user']);

    exec("sudo pkill -9 -u " . escapeshellarg($user));
    exec("sudo userdel -f -r " . escapeshellarg($user));

    echo "DEL_OK";
    exit();
}

// ==============================
// ONLINE
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

echo "INVALID";
