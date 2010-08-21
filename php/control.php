<?php

$action = isset($_GET['action']) ? $_GET['action'] : null;

switch($action)
{
case 'run':
    $zone = isset($_GET['zone']) ? $_GET['zone'] : null;
    `isprinkle-control --run-zone $zone`;
    break;
case 'all-off':
    `isprinkle-control --all-off`;
    break;
default:
    $output = `isprinkle-control --query`;
    echo "<pre>$output</pre>";
}

?>
