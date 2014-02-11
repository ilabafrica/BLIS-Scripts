<?php

mysql_connect("localhost","root","admin123");
mysql_select_db("blis_301");
//$sql=mysql_query("select * from loc");

$query = 'SELECT p.surr_id, tt.name 
			FROM test t, test_type tt, specimen s, patient p  
			WHERE 
			t.test_type_id = tt.test_type_id AND 
			t.specimen_id = s.specimen_id AND 
			p.patient_id = s.patient_id';

$sql=mysql_query($query) or die(mysql_error()) ;


while ($row = @mysql_fetch_assoc($sql)){

	echo "<br>".$row["surr_id"]." - ".$row["name"];	
	$patient_id = $row["surr_id"];
	$test_name = $row["name"];
	
	$query2 = "UPDATE test SET external_parent_lab_no = 
			(SELECT parentLabNo FROM external_lab_request
				WHERE patient_id='$patient_id' AND investigation='$test_name' AND (test_status = 8 or test_status = 0)";
	
	mysql_select_db("blis_rev");
	$sql2=mysql_query($query2) or die(mysql_error());

	echo "<br>parent_test_id = ".$parent_test_id." = parent_test_name = ".$parent_test_name;

}
mysql_close();
?>