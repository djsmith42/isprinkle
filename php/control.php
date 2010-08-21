<html>
<head>
<title>iSprinkle - You've got rain</title>
<style>
  body {
    margin: 0;
    font-size: 2.5em;
    font-family: arial;
  }
  table {
    border-collapse: collapse;
    font-size: 2em;
    width: 100%;
  }
  table tr.state-on {
    background: #cfc;
  }
  table tr td {
    border-bottom: 1px solid #ccc;
  }
  table tr td.zone {
    font-weight: bold;
    text-align: left;
    padding-left: 0.4em;
  }
  table tr td.state-off {
    font-weight: bold;
    color: #610;
    text-align: left;
  }
  table tr td.state-on {
    font-weight: bold;
    color: #061;
    text-align: left;
  }
  table tr td.button {
    text-align: right;
    padding: 0.1em;
  }
  input {
    font-weight: bold;
    font-size: 0.7em;
    min-width: 5em;
  }

  input.run {
    color: green;
  }

  input.stop {
    color: red;
  }

  input:disabled {
    color: gray;
  }

  h2 {
    padding: 0.2em;
    padding-top: 0.05em;
    padding-bottom: 0.05em;
    margin: 0;
    font-size: 2.0em;
    background: #89f;
  }

  h4 {
    padding: 0.2em;
    margin: 0;
    font-size: 0.9em;
    background: #89f;
  }
</style>
<script type="text/javascript">
function submitForm(form)
{
    form.button.disabled = true;
    form.button.value = 'Working';
    return true;
}
</script>
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
    $any_zone_running = `isprinkle-control --query | grep -i 'on$'`;

    // Give the running zone a moment to turn off:
    if($any_zone_running)
    {
        `isprinkle-control --all-off`;
        sleep(3);
    }
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
	if($is_on)
	  echo "<tr class=\"state-on\">\n";
	else
	  echo "<tr>\n";
        echo "  <td class=\"zone\">Zone $zone</td>\n";
        echo "  <td class=\"" . ($is_on ? 'state-on' : 'state-off') . "\">$state</td>\n";
        echo "  <form name=\"form\" action=\"$self\" method=\"post\" onSubmit=\"return submitForm(this)\">\n";
        echo "  <td class=\"button\">\n";

        if(preg_match('/on/i', $state))
        {
            $some_zone_running=true;
            echo "    <input type=\"hidden\" name=\"action\" value=\"stop\"/>\n";
            echo "    <input type=\"submit\" name=\"button\" value=\"Turn off\" class=\"stop\"/>\n";
        }
        else
        {
            echo "    <input type=\"hidden\" name=\"action\" value=\"run\"/>\n";
            echo "    <input type=\"hidden\" name=\"zone\" value=\"$zone\"/>\n";
            echo "    <input type=\"submit\" name=\"button\" value=\"Turn on\" class=\"run\"/>\n";
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
