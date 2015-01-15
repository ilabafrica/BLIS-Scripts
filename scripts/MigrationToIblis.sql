 
-- USER MIGRATIONS
 
-- Script to migrate users data from old-blis to new blis
-- 0 warnings
-- The passwords from old - Blis are not functional in the new

insert into iblis.users
	(id, username, password, name, email)
select distinct user.user_id, username, password, actualname, 
	if (email is NULL, '', email) as email
from blis_revamp_prod.user
left join blis_301.test 
on (test.user_id=user.user_id)
where test.user_id=user.user_id
group by user.user_id;


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
 
if(sex = 'M', 0, 1) as sex, surr_id, ts  from blis_301.patient;



-- SPECIMEN TYPES MIGRATIONS

-- Scripts to migrate specimen types
-- 0 errors 0 warnings
-- No anomalies

insert into iblis.specimen_types (id, name, description, created_at) 
	select specimen_type_id, name, description, ts from blis_301.specimen_type;


-- FACILITIES MIGRATIONS

-- 0 errors 0 warnings
-- This is the simplest way I could think of given the table structure

insert into iblis.facilities (name, created_at)  
values 
('BUNGOMA DISTRICT HOSPITAL CCC', now()),
('KEMRI ALUPE', now()),
('ST.DAMIANO MEDICAL CENTRE', now()),
('AGA KHAN UNIVERSITY HOSPITAL', now()),
('AMPATH', now()),
('AKUH NAIROBI', now()),
('BULONDO DISPENSARY', now()),
('BUMULA HEALTH CENTRE', now()),
('CBM NALONDO MODEL', now()),
('CHEBUKAKA MISSION HOSPITAL', now()),
('CHEMWA BRIDGE DISPENSARY', now()),
('CHEPTAIS SUBDISTRICT HOSPITAL', now()),
('CHWELE SUB COUNTY HOSPITAL', now()),
('EKITALE DISPENSARY', now()),
('ELGON VIEW MEDICAL COTTAGE', now()),
('GK PRISON DISPENSARY, BUNGOMA SOUTH', now()),
('KABUCHAI HEALTH CENTRE', now()),
('KABULA DISPENSARY', now()),
('KAPTANAI DISPENSARY', now()),
('KEMRI NAIROBI', now()),
('KHASOKO HC', now()),
('KHACHONGE DISPENSARY', now()),
('KIBABII  HEALTH CENTRE', now()),
('KIBUKE DISPENSARY', now()),
('KIMAETI DISPENSARY', now()),
('KIMILILI DISTRICT HOSPITAL', now()),
('KITALE DISTRICT HOSPITAL', now()),
('KOROSIANDET DISPENSARY', now()),
('LUMBOKA MEDICAL SERVICES', now()),
('LUUYA DISPENSARY', now()),
('MACHWELE DISPENSARY', now()),
('MALAKISI HEALTH CENTRE', now()),
('MAYANJA DISPENSARY', now()),
('MECHIMERU DISPENSARY', now()),
('MILUKI DISPENSARY', now()),
('MUMBULE DISPENSARY', now()),
('NALONDO MODEL HEALTH CENTRE', now()),
('NASIANDA DISPENSARY', now()),
('NGALASIA DISPENSARY', now()),
('NZOIA MEDICAL CENTRE', now()),
('NZOIA SUGAR DISPENSARY', now()),
('SIBOTI MODEL HEALTH CENTRE', now()),
('SIRISIA SUBDISTRICT HOSPITAL', now()),
('TAMLEGA DISPENSARY', now()),
('NOT AVAILABLE', now());


-- REFFERALS TABLE SCRIPT

-- depends on facilites, users, patients
-- blank/unknown facilities are linked to the `NOT AVAILABLE` facility, 19 records affected

drop table if exists blis_301.tmp3;

create temporary table blis_301.tmp3 (`id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY)
select 
	(CASE WHEN s.referred_to = 2 THEN 0
	WHEN s.referred_to = 3 THEN 1
	END) AS status,
	s.specimen_id,
	(select id from iblis.facilities f where scd.field_value = f.name ) as facility_id,
	(select scd1.field_value from blis_301.specimen_custom_data scd1 
		where scd.specimen_id = scd1.specimen_id and scd1.field_id = 2 ) as person,  
	(select scd1.field_value from blis_301.specimen_custom_data scd1 
		where scd.specimen_id = scd1.specimen_id and scd1.field_id = 3 ) as contacts,
	s.user_id,
	s.ts
	FROM blis_301.specimen s 
	INNER JOIN blis_301.specimen_custom_data scd
	ON s.specimen_id = scd.specimen_id
	where s.referred_to != 0
	and scd.field_id = 1;

insert into iblis.referrals 
	select id, status, 
	if (facility_id is null, (select id from iblis.facilities where name = 'NOT AVAILABLE'), facility_id) , 
	person, contacts, user_id, ts, null from blis_301.tmp3;


-- PRELIMINARY MIGRATION BEFORE MIGRATING REJECTION REASONS AND SPECIMEN

delete from blis_301.rejection_reasons where rejection_reason_id = 32;

insert into blis_301.rejection_reasons (rejection_reason_id, rejection_phase, rejection_code, description, disabled, ts )
	values (36, 1, 036, 'Machine is out of order', 0, now() ),
	 (37, 1, 037, 'Test currently not being done', 0, now() ),
	 (38, 1, 038, 'Sample contaminated', 0, now() ),
	 (39, 1, 039, 'Empty container, no sample', 0, now() ),
	 (40, 1, 040, 'Double entry', 0, now() );

update blis_301.specimen set comments = 'Clotted Blood' where comments = 'clotted sample';
update blis_301.specimen set comments = 'Clotted Blood' where comments = 'blood clotted';
update blis_301.specimen set comments = 'Machine is out of order' where comments = 'MACHINE IS OUT OF ORDER';
update blis_301.specimen set comments = 'Sample contaminated' where comments = 'Blood staned';
update blis_301.specimen set comments = 'Sample contaminated' where comments = 'contaminated';
update blis_301.specimen set comments = 'Haemolysis' where comments = 'sample heamolysed';
update blis_301.specimen set comments = 'Haemolysis' where comments = 'haemolysed sample';
update blis_301.specimen set comments = 'Haemolysis' where comments = 'haemolysed';
update blis_301.specimen set comments = 'Haemolysis' where comments = 'haemolysed ';
UPDATE blis_301.specimen SET comments = 'Haemolysis' WHERE `specimen_id`='25424';
update blis_301.specimen set comments = 'Wrong container/Anticoagulant' where comments = 'sample in purple top';
update blis_301.specimen set comments = 'Empty container, no sample' where comments = 'no sample empty container';
update blis_301.specimen set comments = 'Double entry' where comments = 'double entry';

-- Updating the comments that were text into the corresponding id's

update  blis_301.specimen s, blis_301.rejection_reasons rr
set s.comments = rr.rejection_reason_id
	where s.comments = rr.description and char_length(s.comments) > 4;


-- REJECTION REASONS SCRIPTS

-- made changes to the rejection reasons thus they need updating 
-- no errors

insert into iblis.rejection_reasons (id, reason)
	(select rejection_reason_id, description from   blis_301.rejection_reasons);


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
from blis_301.test_category;
 
 
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
from blis_301.measure;


-- MEASURE RANGE MIGRATIONS
 
-- Script to migrate measures ranges from old-blis to new blis
-- 0 warnings
-- Numeric Ranges(non has a corresponding measure)
-- Alphanumeric Ranges
insert into iblis.measure_ranges (measure_id, alphanumeric)
select measure_id, measure_range
from blis_301.measure
where measure_range like '%/%';


-- TEST TYPE MIGRATIONS
 
-- Script to migrate test types from old-blis to new blis
-- 0 warnings
insert into iblis.test_types
	(id, name, description, test_category_id, targetTAT, prevalence_threshold, created_at)
select test_type_id, name, description, test_category_id, target_tat, prevalence_threshold, ts
from blis_301.test_type;
 
-- TESTTYPE MASURE MIGRATIONS
 
-- Script to migrate test type measures types from old-blis to new blis
-- 0 warnings
insert into iblis.testtype_measures
	(id, test_type_id, measure_id, ordering, nesting)
select ttm_id, test_type_id, measure_id, ordering, nesting
from blis_301.test_type_measure;

INSERT INTO iblis.test_phases (id, name) VALUES (1, "Pre-Analytical"),(2, "Analytical"),(3, "Post-Analytical");

INSERT INTO iblis.test_statuses(id, name, test_phase_id) VALUES (1, "not-received", 1),
	(2, "pending", 1),(3, "started", 2),(4, "completed", 3),(5, "verified", 3);


-- SPECIMEN MIGRATION SCRIPT

-- depends on referrals-script, specimen-types, specimen_statuses script 

insert into iblis.specimens 
	(id, specimen_type_id, specimen_status_id,  accepted_by, rejected_by,
	 rejection_reason_id, reject_explained_to, referral_id, time_accepted, time_rejected )
		select specimen_id, specimen_type_id, 
		(CASE WHEN status_code_id = 0 THEN 2
			  WHEN status_code_id = 1 THEN 2
			  WHEN status_code_id = 6 THEN 3
			  WHEN status_code_id = 8 THEN 1
		END) AS status_code_id,
		s.user_id, 
		if (s.aux_id = '', 0 , s.aux_id) as aux_id, 
		if (s.comments = '', null, s.comments)  as rejection_reason_id, 
		s.referred_to_name,  
		IF (s.referred_to = 2||3, (select id from blis_301.tmp3 t where s.specimen_id = t.specimen_id), NULL )
		as referral_id,
		ts_collected, 
		if(s.specimen_id = 6, ts, null) as ts
	from blis_301.specimen s;



-- INDEXING TEST TABLE 

-- Helps improve performance

alter table blis_301.test add index (patientvisitnumber);


-- EXTERNAL LAB REQUEST MIGRATIONS
 
-- Script to migrate eternal lab requests from old-blis to new blis
-- To speed up the migration the patientVisitNumber column is made an index first
-- 0 errors, 0 warnings

 
insert into iblis.external_dump ( id, labNo, parentLabNo, test_id, requestingClinician, investigation, provisional_diagnosis, 
		requestDate, orderStage, result, result_returned, patientVisitNumber, patient_id, fullName, dateOfBirth, gender, address, 
		postalCode, phoneNumber, city, cost, receiptNumber, receiptType, waiver_no, system_id)
select id, labNo, parentLabNo, blis_301.test.test_id, requestingClinician, investigation, provisionalDiagnosis, requestDate, orderStage, blis_revamp_prod.external_lab_request.result, result_returned, blis_revamp_prod.external_lab_request.patientVisitNumber, patient_id, full_name, dateOfBirth, gender, address, postalCode, phoneNumber, city, cost, receiptNumber, receiptType, waiverNo, system_id
from blis_revamp_prod.external_lab_request 
left join blis_301.test
on (external_lab_request.patientVisitNumber=test.patientVisitNumber)
group by id;


-- VISITS migration scripts

-- 0 warnings 0 errors

drop table if exists iblis.tmp_visits;

CREATE TABLE iblis.tmp_visits SELECT group_concat(t.test_id) test_ids, s.patient_id, 
t.patientVisitNumber visit_number, IFNULL(x.orderStage,'op') AS order_stage, t.ts 
FROM blis_301.test t INNER JOIN blis_301.specimen s ON t.specimen_id = s.specimen_id 
LEFT JOIN blis_revamp_prod.external_lab_request x ON t.external_lab_no = x.labNo 
GROUP BY patient_id, substr(t.ts, 1, 10) ORDER BY t.test_id;  

INSERT INTO iblis.visits (patient_id, visit_number, visit_type, created_at) 
SELECT patient_id, IF(visit_number='',NULL,visit_number) vn, 
IF(order_stage='ip','Out-Patient', 'In-Patient')ords, ts created_at FROM iblis.tmp_visits;

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

DROP TEMPORARY TABLE IF EXISTS test_visits;
CREATE TEMPORARY TABLE test_visits(
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
	(select doctor from blis_301.specimen s where s.specimen_id = t.specimen_id) as requested_by,
	ts,
	ts_started,
	ts_result_entered,
	date_verified,
	null,
	if(external_lab_no = '', null, external_lab_no)
	
from blis_301.test t;


-- Migration scripts for test results

INSERT IGNORE INTO iblis.test_results (test_id, measure_id, result, time_entered) 
SELECT tm.test_id, tm.measure_id, tm.result, t.ts_result_entered FROM blis_301.test_measure tm INNER 
JOIN blis_301.measure m ON tm.measure_id = m.measure_id LEFT JOIN blis_301.test t ON tm.test_id = t.test_id 
ORDER BY tm.tm_id;


DROP TEMPORARY TABLE IF EXISTS iblis.test_visits;
DROP TEMPORARY TABLE IF EXISTS iblis.tmp_visits;
DROP TABLE IF EXISTS blis_301.tmp3;
