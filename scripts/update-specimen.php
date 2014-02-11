<?php 
mysql_connect("localhost","root","admin123");
mysql_select_db("blis_302");
//$sql=mysql_query("select * from loc");

$query = 'SELECT * FROM test_type';

$sql=mysql_query($query) or die(mysql_error()) ;


while ($row = @mysql_fetch_assoc($sql)){
	
	echo "<br>".$row["test_type_id"]." - ".$row["name"];
	
	$test_type_id = $row["test_type_id"];
	$specimen_name = $row["specimen"];
	$current_ts = date("Y-m-d H:i:s");
	$query1 = "SELECT specimen_type_id FROM specimen_type WHERE name = '$specimen_name'";
	$sql1=mysql_query($query1) or die(mysql_error());
	$row1=mysql_fetch_assoc($sql1);
	$specimen_id = $row1["specimen_type_id"];
	
			
   $query2 = "INSERT INTO specimen_test (test_type_id, specimen_type_id, ts) 
   				VALUES ('$test_type_id','$specimen_id', '$current_ts')";
 	$sql2=mysql_query($query2) or die(mysql_error());
	
	echo "<br>Specimen_name = ".$row["specimen"]." = specimen_id = ".$specimen_id;
	echo "<br><br>";
	
}

mysql_close();

?>