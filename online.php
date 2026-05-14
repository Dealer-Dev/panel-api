<?php

$url = "http://127.0.0.1/panel/api.php";

$data = [
    'token' => '123456',
    'action' => 'online'
];

$options = [
    'http' => [
        'header'  => "Content-type: application/x-www-form-urlencoded",
        'method'  => 'POST',
        'content' => http_build_query($data),
    ],
];

$result = file_get_contents($url, false, stream_context_create($options));

echo $result;
