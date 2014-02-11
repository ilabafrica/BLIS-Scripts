<?php
// Server in the this format: <computer>\<instance name> or 
// <server>,<port> when using a non default port number
//$server = 'KALLESPC\SQLEXPRESS';
//$server = 'SERVER\local';
$server = '192.168.1.101';
//$server = '192.168.184.121:1432';

// Connect to MSSQL

$link = mssql_connect($server, 'kapsabetAdmin', 'kapsabet');

if (!$link)
  {
  	die('Could not connect: ' . mssql_get_last_message() );
  }
else{ 	
	echo "<br>";
	echo 'Connected Successfuly.'. mssql_get_last_message();
	echo "<br>";	
}


if (!mssql_select_db('[Kapsabet]', $link)){
	die("Could not select DB: ". mssql_get_last_message());
}else
{
	echo "<br>";
	echo "selected database";
	echo "<br>";
}
$patient_id ="0109/2012";

$result = mssql_query("SELECT * FROM LabRequestQueryForBliss");
echo count($result);

while($row = mssql_fetch_assoc($result))
{
	echo $row['PatientNumber'] . " ============>" . $row['FullNames'];
	echo "<br>";
}

mssql_close($link); 
?>
