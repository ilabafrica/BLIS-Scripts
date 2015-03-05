-- USER MIGRATIONS
 
-- Script to migrate users data from old-blis to new blis
-- 0 warnings
-- The passwords from old - Blis are not functional in the new

insert into iblis.users
  (id, username, password, name, email)
select distinct user.user_id, username, password, 
if (actualname = '', username, actualname  ) as username, 
  if (email is NULL, '', email) as email
from blis_revamp_prod.user
left join blis_302.test 
on (test.user_id=user.user_id)
where test.user_id=user.user_id
group by user.user_id;

-- ROLES MIGRATIONS

INSERT INTO iblis.roles (id, name, description, created_at, updated_at) VALUES
(1, 'Superadmin', NULL, '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(2, 'Technologist', NULL, '2015-02-27 13:10:09', '2015-02-27 13:10:09'),
(3, 'Receptionist', NULL, '2015-02-27 13:10:09', '2015-02-27 13:10:09');

INSERT INTO iblis.assigned_roles (id, user_id, role_id) VALUES
(1, 1, 1);

-- PERMISSIONS MIGRATIONS

INSERT INTO iblis.permissions (id, name, display_name, created_at, updated_at) VALUES
(1, 'view_names', 'Can view patient names', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(2, 'manage_patients', 'Can add patients', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(3, 'receive_external_test', 'Can receive test requests', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(4, 'request_test', 'Can request new test', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(5, 'accept_test_specimen', 'Can accept test specimen', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(6, 'reject_test_specimen', 'Can reject test specimen', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(7, 'change_test_specimen', 'Can change test specimen', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(8, 'start_test', 'Can start tests', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(9, 'enter_test_results', 'Can enter tests results', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(10, 'edit_test_results', 'Can edit test results', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(11, 'verify_test_results', 'Can verify test results', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(12, 'send_results_to_external_system', 'Can send test results to external systems', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(13, 'refer_specimens', 'Can refer specimens', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(14, 'manage_users', 'Can manage users', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(15, 'manage_test_catalog', 'Can manage test catalog', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(16, 'manage_lab_configurations', 'Can manage lab configurations', '2015-02-27 13:10:08', '2015-02-27 13:10:08'),
(17, 'view_reports', 'Can view reports', '2015-02-27 13:10:08', '2015-02-27 13:10:08');


INSERT INTO iblis.permission_role (id, permission_id, role_id) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1),
(6, 6, 1),
(7, 7, 1),
(8, 8, 1),
(9, 9, 1),
(10, 10, 1),
(11, 11, 1),
(12, 12, 1),
(13, 13, 1),
(14, 14, 1),
(15, 15, 1),
(16, 16, 1),
(17, 17, 1);


-- PATIENTS MIGRATIONS

-- Script to migrate patients data from old-blis to new blis
-- 0 warnings
-- Some records have no calculatable date of birth, I have put the DOB as the timestamp


insert into iblis.patients 
  (patient_number, name, dob, gender, external_patient_number, created_at)
 
select  patient_id, name, 
  (case WHEN dob = '0000-00-00'
  THEN CONVERT( 
    date_sub(DATE_FORMAT(ts,  '%Y-%m-%d'), INTERVAL age year)
    USING latin1 )
  WHEN dob IS NULL 
  THEN  partial_dob 
ELSE dob 
END) as dob,
 
if(sex = 'M', 0, 1) as sex, surr_id, ts  from blis_302.patient;



-- SPECIMEN TYPES MIGRATIONS

-- Scripts to migrate specimen types
-- 0 errors 0 warnings
-- No anomalies

insert into iblis.specimen_types (id, name, description, created_at) 
  select specimen_type_id, name, description, ts from blis_302.specimen_type;

-- REJECTION REASONS MIGRATIONS

insert into iblis.rejection_reasons (id, reason) values
(1, 'Poorly labelled'),
(2, 'Over saturation'),
(3, 'Insufficient Sample'),
(4, 'Scattered'),
(5, 'Clotted Blood'),
(6, 'Two layered spots'),
(7, 'Serum rings'),
(8, 'Scratched'),
(9, 'Haemolysis'),
(10, 'Spots that cannot elute'),
(11, 'Leaking'),
(12, 'Broken Sample Container'),
(13, 'Mismatched sample and form labelling'),
(14, 'Missing Labels on container and tracking form'),
(15, 'Empty Container'),
(16, 'Samples without tracking forms'),
(17, 'Poor transport'),
(18, 'Lipaemic'),
(19, 'Wrong container/Anticoagulant'),
(20, 'Request form without samples'),
(21, 'Missing collection date on specimen / request form.'),
(22, 'Name and signature of requester missing'),
(23, 'Mismatched information on request form and specimen container.'),
(24, 'Request form contaminated with specimen'),
(25, 'Duplicate specimen received'),
(26, 'Delay between specimen collection and arrival in the laboratory'),
(27, 'Inappropriate specimen packing'),
(28, 'Inappropriate specimen for the test'),
(29, 'Inappropriate test for the clinical condition'),
(30, 'No Label'),
(31, 'Leaking'),
(32, 'No Sample in the Container'),
(33, 'No Request Form'),
(34, 'Missing Information Required');



-- SPECIMEN STATUSES MIGRATION

-- data is from the laravel seed
-- no errors

insert into iblis.specimen_statuses (id, name)
  values
    (1, "specimen-not-collected" ),
    (2, "specimen-accepted"),
    (3, "specimen-rejected");


-- TEST CATEGORY MIGRATIONS
 
-- Script to migrate test categories from old-blis to new blis
-- 0 warnings
insert into iblis.test_categories
  (id, name, description, created_at)
select test_category_id, name, description, ts 
from blis_302.test_category;
 

-- MEASURE TYPE MIGRATIONS
 
-- Script to migrate measure types from old-blis to new blis
-- 0 warnings
insert into iblis.measure_types
  (id, name) 
values
  ('1', 'Numeric Range'),
  ('2', 'Alphanumeric Values'),
  ('3', 'Autocomplete'),
  ('4', 'Free Text');

-- MEASURE MIGRATIONS
 
-- Script to migrate measures from old-blis to new blis
-- converting auto complete to alphanumeric
-- 0 warnings
insert into iblis.measures
  (id, measure_type_id, name, unit, description, created_at)
select measure_id,
(case 
  WHEN measure_range = '$freetext$$' THEN '4' 
  WHEN measure_range = ':' THEN '1' 
  ELSE '2' 
END) as measure_type_id,
name, 
if (unit is NULL, '', unit) as unit,
description, ts
from blis_302.measure;

-- Migration for alphanumeric and 'autocomplete' measure_ranges

CREATE TABLE iblis.tmp_ranges(id int not null primary key AUTO_INCREMENT, measure_id int, alphanumeric varchar(500));
INSERT into iblis.tmp_ranges(measure_id, alphanumeric)
  select measure_id, measure_range
  from blis_302.measure
  where measure_range != ':' and measure_range != '$freetext$$';

UPDATE iblis.tmp_ranges SET alphanumeric = REPLACE (alphanumeric, '_', '/');


DELIMITER $$
CREATE FUNCTION iblis.strSplit(x VARCHAR(65000), delim VARCHAR(12), pos INTEGER) 
RETURNS VARCHAR(65000)
BEGIN
  DECLARE output VARCHAR(65000);
  SET output = REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos)
                 , LENGTH(SUBSTRING_INDEX(x, delim, pos - 1)) + 1)
                 , delim
                 , '');
  IF output = '' THEN SET output = null; END IF;
  RETURN output;
END $$
 
CREATE PROCEDURE iblis.MeasureRanges2Alphanumeric()
BEGIN
  DECLARE i INTEGER;
 
  SET i = 1;
  REPEAT
    INSERT INTO iblis.measure_ranges (measure_id, alphanumeric)
      SELECT measure_id, strSplit(alphanumeric, '/', i) FROM iblis.tmp_ranges
      WHERE strSplit(alphanumeric, '/', i) IS NOT NULL ORDER BY measure_id ASC;
    SET i = i + 1;
    UNTIL ROW_COUNT() = 0
  END REPEAT;
END $$
DELIMITER ;
-- Call the procedure
CALL iblis.MeasureRanges2Alphanumeric;

-- TEST TYPE MIGRATIONS
 
-- Script to migrate test types from old-blis to new blis
-- 0 warnings
insert into iblis.test_types
  (id, name, description, test_category_id, targetTAT, prevalence_threshold, created_at)
select test_type_id, name, description, test_category_id, target_tat, prevalence_threshold, ts
from blis_302.test_type where disabled = 0;
 
-- TESTTYPE MASURE MIGRATIONS
 
-- Script to migrate test type measures types from old-blis to new blis
-- 0 warnings
insert into iblis.testtype_measures
  ( test_type_id, measure_id)
select ttm.test_type_id, ttm.measure_id
from blis_302.test_type_measure ttm
inner join blis_302.test_type tt
  on tt.test_type_id=ttm.test_type_id
join blis_302.measure m
  on m.measure_id=ttm.measure_id;



INSERT INTO iblis.test_phases (id, name) VALUES (1, "Pre-Analytical"),(2, "Analytical"),(3, "Post-Analytical");

INSERT INTO iblis.test_statuses(id, name, test_phase_id) VALUES (1, "not-received", 1),
  (2, "pending", 1),(3, "started", 2),(4, "completed", 3),(5, "verified", 3);
-- SPECIMEN MIGRATION SCRIPT

-- depends on referrals-script, specimen-types, specimen_statuses script 

insert into iblis.specimens 
  (id, specimen_type_id, specimen_status_id,  accepted_by, rejected_by,
    reject_explained_to, time_accepted, time_rejected )
    select specimen_id, specimen_type_id, 
    (CASE WHEN status_code_id = 0 THEN 2
        WHEN status_code_id = 1 THEN 2
        WHEN status_code_id = 6 THEN 3
        WHEN status_code_id = 8 THEN 1
    END) AS status_code_id,
    s.user_id, 
    if (s.aux_id = '', 0 , s.aux_id) as aux_id, 
    s.referred_to_name,
    ts_collected, 
    if(s.specimen_id = 6, ts, null) as ts
  from blis_302.specimen s;


-- EXTERNAL LAB REQUEST MIGRATIONS
 
-- Script to migrate eternal lab requests from old-blis to new blis
-- To speed up the migration the patientVisitNumber column is made an index first
-- 0 errors, 0 warnings

insert into iblis.external_dump 
  ( id,
    lab_no,
    parent_lab_no,
    test_id,
    requesting_clinician,
    investigation,
    provisional_diagnosis,
    request_date,
    order_stage,
    result,
    result_returned,
    patient_id,
    full_name,
    dob,
    gender,
    address,
    postal_code,
    phone_number,
    city,
    cost,
    receipt_number,
    receipt_type,
    waiver_no,
    system_id)
select id,
  labNo,
  parentLabNo,
  t.test_id,
  requestingClinician,
  investigation,
  provisionalDiagnosis,
  requestDate,
  orderStage,
  extr.result,
  result_returned,
  patient_id,
  full_name,
  dateOfBirth,
  gender,
  address,
  postalCode,
  phoneNumber,
  city,
  cost,
  receiptNumber,
  receiptType,
  waiverNo,
  system_id
from blis_revamp_prod.external_lab_request extr
left join blis_302.test t
on (extr.labNo = t.external_lab_no)
group by id;


-- Inserting external user_id's for sending back results 

-- 0 warnings

insert into iblis.external_users (internal_user_id, external_user_id)
  select user_id, emr_user_id from blis_revamp_prod.user s inner join iblis.users u on u.id = s.user_id
    order by user_id asc;


-- VISITS migration scripts

-- 0 warnings 0 errors

drop table if exists iblis.tmp_visits;

CREATE TABLE iblis.tmp_visits SELECT group_concat(t.test_id) test_ids, s.patient_id, 
IFNULL(x.orderStage,'op') AS order_stage, t.ts 
FROM blis_302.test t INNER JOIN blis_302.specimen s ON t.specimen_id = s.specimen_id 
LEFT JOIN blis_revamp_prod.external_lab_request x ON t.external_lab_no = x.labNo 
GROUP BY patient_id, substr(t.ts, 1, 10) ORDER BY t.test_id;  

INSERT INTO iblis.visits (patient_id, visit_type, created_at) 
SELECT patient_id, 
IF(order_stage='op','Out-Patient', 'In-Patient')ords, ts created_at FROM iblis.tmp_visits;

ALTER TABLE `iblis`.`tmp_visits` ADD COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
ADD PRIMARY KEY (`id`);

-- --------------------------------------------------------------------------------
-- PROCEURE Explode table
-- Note: Used as a pseudo explode() function, splits |1,3,5 | into separate rows |1|3|5
-- --------------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS iblis.explode_table $$

CREATE PROCEDURE iblis.explode_table(bound VARCHAR(255))

BEGIN

DECLARE id INT DEFAULT 0;
DECLARE value TEXT;
DECLARE occurance INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE splitted_value INT;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT tmp_visits.id, tmp_visits.test_ids
                                  FROM tmp_visits
                                  WHERE tmp_visits.test_ids != '';
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

DROP TABLE IF EXISTS test_visits;
CREATE TABLE test_visits(
`visit_id` INT NOT NULL,
`test_id` INT NOT NULL
) ENGINE=Memory;

OPEN cur1;
  read_loop: LOOP
    FETCH cur1 INTO id, value;
    IF done THEN
      LEAVE read_loop;
    END IF;

    SET occurance = (SELECT LENGTH(value)
                            - LENGTH(REPLACE(value, bound, ''))
                            +1);
    SET i=1;
    WHILE i <= occurance DO
      SET splitted_value =
      (SELECT REPLACE(SUBSTRING(SUBSTRING_INDEX(value, bound, i),
      LENGTH(SUBSTRING_INDEX(value, bound, i - 1)) + 1), ',', ''));

      INSERT INTO test_visits VALUES (id, splitted_value);
      SET i = i + 1;

    END WHILE;
  END LOOP;


 CLOSE cur1;
END; $$

DELIMITER ;

CALL iblis.explode_table(','); 


-- TESTS TABLE MIGRATION

-- 0 warnings 0 errors

insert into iblis.tests (id, visit_id, test_type_id, specimen_id, interpretation,
test_status_id, created_by, tested_by, verified_by, requested_by, time_created, time_started,
time_completed, time_verified, time_sent, external_id)
select test_id, 
  (select visit_id from iblis.test_visits tv where t.test_id = tv.test_id) as visit_id, 
  test_type_id,
  specimen_id,
  comments,
  (CASE WHEN status_code_id = 3 THEN 4 -- completed
        WHEN status_code_id = 7 THEN 3  -- started
        WHEN status_code_id = 9 THEN 5  -- verified
        WHEN status_code_id = 0 THEN 2  -- pending
    END) AS test_status_id,
  user_id as created_by,
  user_id as tested_by, -- assumption
  verified_by,
  (select doctor from blis_302.specimen s where s.specimen_id = t.specimen_id) as requested_by,
  (SELECT ts FROM blis_302.specimen WHERE blis_302.specimen.specimen_id = t.specimen_id limit 1) as time_created,
  ts_started,
  ts_result_entered,
  date_verified,
  null,
  if(external_lab_no = '', null, external_lab_no)
  
from blis_302.test t;

-- MIGRATION SCRIPTS FOR testtype_specimentypes TABLE

-- 0 errors

insert into iblis.testtype_specimentypes(test_Type_id, specimen_type_id)
select test_type_id, specimen_type_id from blis_302.specimen_test 
where test_type_id in (
select test_type_id from blis_302.test_type where
  disabled = 0)
and specimen_type_id != 0;


-- MIGRATION SCRIPT FOR TEST RESULTS
-- 0 errors
CREATE TABLE iblis.tmp_test_results (
  id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  test_id INT(6) NOT NULL,
  measure_id INT(6) NOT NULL,
  measure VARCHAR(100)  NOT NULL,
  result VARCHAR(250)  NOT NULL,
  time_entered TIMESTAMP
);

INSERT INTO iblis.tmp_test_results (test_id, measure_id, measure, result, time_entered)

SELECT t.test_id, ttm.measure_id, m.name as measure, t.result, t.ts_result_entered FROM blis_302.test t 
INNER JOIN blis_302.test_type tt ON t.test_type_id=tt.test_type_id
LEFT JOIN blis_302.test_type_measure ttm ON tt.test_type_id = ttm.test_type_id
LEFT JOIN blis_302.measure m ON m.measure_id = ttm.measure_id
WHERE t.status_code_id!=0;
--the final test_results table is generated using php

-- MIGRATION SCRIPT FOR MEASURE RANGES

CREATE TABLE iblis.tmp_ranges(id int not null primary key AUTO_INCREMENT, measure_id int, alphanumeric varchar(500));
INSERT into iblis.tmp_ranges(measure_id, alphanumeric)
  select measure_id, measure_range
  from blis_302.measure
  where measure_range like '%/%';


DELIMITER $$
CREATE FUNCTION iblis.strSplit(x VARCHAR(65000), delim VARCHAR(12), pos INTEGER) 
RETURNS VARCHAR(65000)
BEGIN
  DECLARE output VARCHAR(65000);
  SET output = REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos)
                 , LENGTH(SUBSTRING_INDEX(x, delim, pos - 1)) + 1)
                 , delim
                 , '');
  IF output = '' THEN SET output = null; END IF;
  RETURN output;
END $$
 
CREATE PROCEDURE iblis.MeasureRanges2Alphanumeric()
BEGIN
  DECLARE i INTEGER;
 
  SET i = 1;
  REPEAT
    INSERT INTO iblis.measure_ranges (measure_id, alphanumeric)
      SELECT measure_id, strSplit(alphanumeric, '/', i) FROM iblis.tmp_ranges
      WHERE strSplit(alphanumeric, '/', i) IS NOT NULL ORDER BY measure_id ASC;
    SET i = i + 1;
    UNTIL ROW_COUNT() = 0
  END REPEAT;
END $$
DELIMITER ;
-- Call the procedure
CALL iblis.MeasureRanges2Alphanumeric;


drop function if exists iblis.strSplit;
drop procedure if exists iblis.MeasureRanges2Alphanumeric;
DROP TABLE IF EXISTS iblis.tmp_ranges;
DROP TABLE IF EXISTS iblis.tmp_test_results;
DROP TABLE IF EXISTS iblis.test_visits;
DROP TABLE IF EXISTS iblis.tmp_visits;
DROP PROCEDURE IF EXISTS iblis.explode_table;
