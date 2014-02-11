<?php
// Server in the this format: <computer>\<instance name> or 
// <server>,<port> when using a non default port number
//$server = 'KALLESPC\SQLEXPRESS';
$server = '192.168.6.4';
//$server = '192.168.184.121:1432';

// Connect to MSSQL
$link = mssql_connect($server, 'kapsabetadmin', 'kapsabet');

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

$result = mssql_query("SELECT * FROM Passwords WHERE Department = 2");
mysql_connect("localhost","root","admin123");
mysql_select_db("blis_revamp_302");


while($row = mssql_fetch_assoc($result))
{
	echo $row['UserName'] . " =====>" . $row['FirstName'] . " =====>" .$row['LastName'] ;
	echo "<br>";
	$username = $row['UserName'];
	$salt = "This comment should suffice as salt.";
	$password = sha1($row['UserName'].$salt);
	$actualname = $row['FirstName']." ".$row['LastName'];
	$level=0;
	$created_by = "1" ;
	$lab_config_id = "302";
 	$lang_id ='default';
 	$emr_user_id = $row['ID'];
	
	
	$query_string =
	
	"INSERT INTO user(username, password, actualname, level, created_by, lab_config_id, lang_id, emr_user_id)
	
	VALUES ('$username',
			'$password',
			'$actualname',
			'$level',
			'$created_by',
			'$lab_config_id',
			'$lang_id',
			'$emr_user_id'
			)";
	
	//echo $query_string;
	$mysql_results = mysql_query($query_string) or die(mysql_error()) ;
}

mssql_close($link);
mysql_close();
?>
