# Remove spaces, new line, tab etc from test types
UPDATE test_types set name = TRIM(Replace(Replace(Replace(name,'\t',''),'\n',''),'\r',''));
