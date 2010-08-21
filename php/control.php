<html>
<head>
<title>iSprinkle - You've got rain</head>
<style>
  body {
    margin: 0;
    font-size: 2.5em;
    font-family: arial;
  }
  table {
    border-collapse: collapse;
    font-size: 2em;
  }
  table tr td {
    padding: 0.2em;
    padding-left: 0.5em;
    padding-right: 0.5em;
    border-bottom: 1px solid #ccc;
  }
  table tr td.zone {
    font-weight: bold;
  }
  table tr td.state-off {
    font-weight: bold;
    color: #610;
  }

  table tr td.state-on {
    font-weight: bold;
    color: #061;
  }

  input {
    font-weight: bold;
    font-size: 0.7em;
  }

  input.run {
    color: green;
  }

  input.stop {
    color: red;
  }

  h2 {
    padding: 0.2em;
    padding-top: 0.05em;
    padding-bottom: 0.05em;
    margin: 0;
    font-size: 2.5em;
    background: #89f;
  }

  h4 {
    padding: 0.2em;
    margin: 0;
    font-size: 0.9em;
    background: #89f;
  }

</style>
</head>

<body>
<h2>iSprinkle<span style="color: #eef; float: right; font-size: 0.5em">"You've got rain!"</span></h2>

<?php

error_reporting(E_STRICT);
ini_set('display_errors', 'On');

$action = isset($_POST['action']) ? $_POST['action'] : null;
$self = $_SERVER['PHP_SELF'];

switch($action)
{
case 'run':
    $zone = isset($_POST['zone']) ? $_POST['zone'] : null;
    `isprinkle-control --run-zone $zone`;
    header("location: $self");
    break;
case 'stop':
    `isprinkle-control --all-off`;
    header("location: $self");
    break;
default:
    echo "<table>";
    $some_zone_running=false;
    foreach(get_zone_status() as $zone => $state)
    {
        $is_on = (strtolower($state) == 'on');
        echo "<tr>\n";
        echo "  <td class=\"zone\">Zone $zone</td>\n";
        echo "  <td class=\"" . ($is_on ? 'state-on' : 'state-off') . "\">$state</td>\n";
        echo "  <form action=\"$self\" method=\"post\">\n";
        echo "  <td>\n";

        if(preg_match('/on/i', $state))
        {
            $some_zone_running=true;
            echo "    <input type=\"hidden\" name=\"action\" value=\"stop\"/>\n";
            echo "    <input type=\"submit\" value=\"Turn off\" class=\"stop\"/>\n";
        }
        else
        {
            echo "    <input type=\"hidden\" name=\"action\" value=\"run\"/>\n";
            echo "    <input type=\"hidden\" name=\"zone\" value=\"$zone\"/>\n";
            echo "    <input type=\"submit\" value=\"Turn on\" class=\"run\" />\n";
        }

        echo "  </td>\n";
        echo "  </form>\n";
        echo "</tr>\n";
    }
    echo "</table>\n";
}

function get_zone_status()
{
    $output = `isprinkle-control --query`;

    $retmap = array();

    foreach(preg_split("/\n/", $output) as $line)
    {
        $matches = array();
        if(preg_match('/zone (\d+): (on|off)/i', $line, $matches))
        {
            $zone  = $matches[1];
            $state = strtolower($matches[2]);
            $retmap[$zone] = $state;
        }
    }

    return $retmap;
}

?>
</body>
</html>
