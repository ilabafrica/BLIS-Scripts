<?php 
mysql_connect("localhost","root","admin123");
mysql_select_db("blis_302");
//$sql=mysql_query("select * from loc");

$query = 'SELECT * FROM test_type';

$sql=mysql_query($query) or die(mysql_error()) ;


while ($row = @mysql_fetch_assoc($sql)){
	
	echo "<br>".$row["test_type_id"]." - ".$row["name"];
	
	$test_type_id = $row["test_type_id"];
	$parent_test_name = $row["parent_test_name"];
	
	if($parent_test_name=="null" || $parent_test_name==""){
		$parent_test_id = 0;
	} else{
		$query1 = "SELECT test_type_id, name FROM test_type_copy WHERE name = '$parent_test_name'";
		$sql1=mysql_query($query1) or die(mysql_error());
		$row=mysql_fetch_assoc($sql1);
		$parent_test_id = $row["test_type_id"];
	}
			
	$query2 = "UPDATE test_type SET parent_test_type_id = '$parent_test_id' WHERE test_type_id = $test_type_id";
	$sql2=mysql_query($query2) or die(mysql_error());
	
	echo "<br>parent_test_id = ".$parent_test_id." = parent_test_name = ".$parent_test_name;
	
}




mysql_close();

?>