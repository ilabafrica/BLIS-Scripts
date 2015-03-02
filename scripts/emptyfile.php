<?php

$thefile = "celtac-results.txt";

$f = @fopen($thefile, "r+");

if($f !== false) {
	ftruncate($f, 0);
	fclose($f);
	echo "file truncated";
}

?>
