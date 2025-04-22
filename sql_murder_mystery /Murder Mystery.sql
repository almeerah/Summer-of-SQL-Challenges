//Murder took place on Jan 15 in SQL City
SELECT * FROM crime_scene_report WHERE type = 'murder' AND city = 'SQL City' AND date = 20180115;

//Witness 1:
SELECT * FROM person WHERE name LIKE "%Annabel%" AND address_street_name = "Franklin Ave";

//Witness 2:
SELECT *, max(address_number) FROM person WHERE address_street_name = "Northwestern Dr";

//Find the interview transcripts
SELECT * FROM interview
WHERE person_id = 16371 OR person_id = 14887;

//Find the gym members that checked in on Jan 9th
SELECT get_fit_now_check_in.check_in_date, get_fit_now_check_in.membership_id, get_fit_now_member.person_id, get_fit_now_member.id, get_fit_now_member.name
FROM get_fit_now_check_in
JOIN get_fit_now_member ON get_fit_now_member.id = get_fit_now_check_in.membership_id
WHERE get_fit_now_member.id LIKE "48z%"
AND get_fit_now_check_in.check_in_date= 20180109;

//Find all the people with a license plate containing "H42W"
SELECT person.id, person.name, drivers_license.plate_number
FROM drivers_license
JOIN person ON drivers_license.id = person.license_id
WHERE drivers_license.plate_number LIKE "%H42W%";
  
//Finding the solution           
INSERT INTO solution VALUES (1, 'Jeremy Bowers');
        
        SELECT value FROM solution;
