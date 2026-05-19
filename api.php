<?php

// ======================================
// CONFIG
// ======================================

$configFile = "/etc/panel-api.conf";

if(!file_exists($configFile)){

    die("CONFIG_NOT_FOUND");
}

$config = parse_ini_file($configFile);

if(
    !isset($config['TOKEN']) ||
    empty($config['TOKEN'])
){

    die("TOKEN_INVALID");
}

$API_TOKEN = trim($config['TOKEN']);

// ======================================
// TOKEN
// ======================================

$token = $_POST['token'] ?? '';

if($token != $API_TOKEN){

    die("DENEGADO");
}

// ======================================
// ACTION
// ======================================

$action = $_POST['action'] ?? '';

// ======================================
// CREAR USUARIO
// ======================================

if(
    $action == "create" ||
    empty($action)
){

    $user =
    trim($_POST['user'] ?? '');

    $pass =
    trim($_POST['pass'] ?? '');

    if(
        empty($user) ||
        empty($pass)
    ){

        echo "ERROR_EMPTY";

        exit();
    }

    // VALIDAR USER

    exec(
        "id "
        . escapeshellarg($user)
        . " 2>/dev/null",
        $o,
        $r
    );

    if($r == 0){

        echo "EXISTS";

        exit();
    }

    // CREAR USER

    exec(
        "sudo useradd -m "
        . escapeshellarg($user)
        . " 2>&1",
        $out1,
        $r1
    );

    // PASSWORD

    exec(
        "echo "
        . escapeshellarg("$user:$pass")
        . " | sudo chpasswd 2>&1",
        $out2,
        $r2
    );

    if(
        $r1 === 0 &&
        $r2 === 0
    ){

        echo "OK";

    } else {

        echo "ERROR_CREATE";
    }

    exit();
}

// ======================================
// ELIMINAR USUARIO
// ======================================

if($action == "delete"){

    $user =
    trim($_POST['user'] ?? '');

    if(empty($user)){

        echo "ERROR_USER";

        exit();
    }

    exec(
        "sudo pkill -9 -u "
        . escapeshellarg($user)
        . " 2>&1"
    );

    exec(
        "sudo userdel -f -r "
        . escapeshellarg($user)
        . " 2>&1",
        $out,
        $ret
    );

    if($ret === 0){

        echo "DEL_OK";

    } else {

        echo "ERROR_DELETE";
    }

    exit();
}

// ======================================
// ONLINE USERS
// ======================================

if($action == "online"){

    $output = [];

    exec(
        "ps -eo user,cmd | grep -E 'sshd|dropbear' | grep -v root | grep -v grep",
        $ps
    );

    foreach($ps as $line){

        $parts =
        preg_split(
            '/\s+/',
            trim($line)
        );

        if(!empty($parts[0])){

            $output[] =
            "USER: "
            . $parts[0];
        }
    }

    echo json_encode($output);

    exit();
}

// ======================================
// INVALID
// ======================================

echo "INVALID";
