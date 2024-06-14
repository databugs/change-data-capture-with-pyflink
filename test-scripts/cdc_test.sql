--psql
--1 Select all records from the 'drivers' table
SELECT *
FROM flink.drivers d;



--2 Insert a single row into the 'drivers' table
INSERT INTO flink.drivers (first_name, last_name, date_of_birth)
VALUES('Kirk', 'Turdson', '2002-04-05');



--3 Update the 'gender' field for the driver with id 6
UPDATE flink.drivers 
SET gender = 'Male'
WHERE id = 6;

--4 Insert 5 rows into the 'drivers' table
INSERT INTO flink.drivers (first_name, last_name, gender, date_of_birth)
VALUES
    ('John', 'Doe', 'Male', '1990-01-01'),
    ('Jane', 'Smith', 'Female', '1995-02-02'),
    ('Michael', 'Johnson', 'Male', '1992-03-03'),
    ('Emily', 'Brown', 'Female', '1997-04-04'),
    ('David', 'Garcia', 'Male', '1994-05-05');


--5 We now have duplicate records in the db
-- Delete all drivers with id greater than 6
DELETE FROM flink.drivers 
WHERE id > 6;

--6 Insert 5 different rows into the 'drivers' table
INSERT INTO flink.drivers (first_name, last_name, gender, date_of_birth)
VALUES
    ('Alice', 'Williams', 'Female', '1988-08-08'),
    ('Bob', 'Martinez', 'Male', '1991-11-11'),
    ('Catherine', 'Davis', 'Female', '1985-05-05'),
    ('Daniel', 'Lopez', 'Male', '1993-03-03'),
    ('Eva', 'Hernandez', 'Female', '1998-12-12');
   
--7 Update the 'gender' and 'first_name' field for the driver with id 16  
UPDATE flink.drivers 
SET gender = 'Male',
	first_name = 'Xavier'
WHERE id = 16;