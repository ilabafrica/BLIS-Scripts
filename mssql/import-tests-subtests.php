<?php
// Server in the this format: <computer>\<instance name> or 
// <server>,<port> when using a non default port number
//$server = 'KALLESPC\SQLEXPRESS';
$server = '192.168.6.4';
//$server = '192.168.184.121:1432';

// Connect to MSSQL
$link = mssql_connect($server, 'kapsabetadmin', 'kapsabet');
echo "<html><body>";
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

$result = mssql_query("SELECT * 
						FROM SubTests 
						INNER JOIN Services on SubTests.MainTestID =Services.ID 
					    WHERE Services.Department = 2");

mysql_connect("localhost","root","admin123");
mysql_select_db("blis_302");

echo "<table border ='1'>";
echo "
	<thead>	
	<tr>
		<th>Test Name</th>
		<th>Parent Test</th>
	</tr>
	</thead>
	<tbody>";

while($row = mssql_fetch_assoc($result))
{
	echo "<tr>";
	echo "<td>".$row['SubTestName'] . "</td> <td style='width:200px'> ".$row['Name'] . " </td>";
	echo "</tr>";
 	$category = "null";
	$name = $row['SubTestName'];
	$parent_test= $row['Name'];
	$specimen = "null";
	
	$query_string =
 	"INSERT INTO sanitas_tests_live2(category, name, parent_test, specimen)
	
 	VALUES ('$category',
 			'$name',
 			'$parent_test',
 			'$specimen'
 			)";
	
	//echo $query_string;
	$mysql_results = mysql_query($query_string) or die(mysql_error()) ;
}
echo "</tbody></table></body></html>";
mssql_close($link);
mysql_close();
?>
