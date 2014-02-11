<?php
// Server in the this format: <computer>\<instance name> or 
// <server>,<port> when using a non default port number
//$server = 'KALLESPC\SQLEXPRESS';
//$server = 'SERVER\local';
$server = '192.168.6.4';
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


$sql = file_get_contents('update_scripts.sql');


$result = mssql_query($sql);

if (!$result){
	die("<br>Could complete update: ". mssql_get_last_message());
}else
{
	echo "<br>";
	echo "Completed Successfuly".mssql_get_last_message();
}

mssql_close($link); 
?>
