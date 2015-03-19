# Remove spaces, new line, tab etc from test types
SET SQL_SAFE_UPDATES=0; # Disable safe updates
UPDATE test_types set name = TRIM(Replace(Replace(Replace(name,'\t',''),'\n',''),'\r',''));
SET SQL_SAFE_UPDATES=1; # Enable safe updates
