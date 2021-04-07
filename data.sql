----------------------------- CALLS TO ADD EMPLOYEES -----------------------------
call add_employee('Alice'::text, 'NUS'::text, 90000001, 'alice@gmail.com'::text, 2000::money, null, '2021-02-04'::date, 'manager'::text, array['Network', 'Security']);
call add_employee('Bob'::text, 'NUS'::text, 90000002, 'bob@gmail.com'::text, 3000::money, null, '2021-02-04'::date, 'administrator'::text, array[]::text[]);
call add_employee('Charlie'::text, 'NTU'::text, 90000003, 'charlie@gmail.com'::text, 2500::money, null, '2021-02-04'::date, 'administrator'::text, array[]::text[]);
call add_employee('Derek'::text, 'SMU'::text, 90000004, 'derek@gmail.com'::text, 4000::money, null, '2021-02-04'::date, 'administrator'::text, array[]::text[]);
call add_employee('Eric'::text, 'Hougang'::text, 90000005, 'eric@gmail.com'::text, 4000::money, null, '2021-03-04'::date, 'manager'::text, array['Algorithms', 'Database', 'Outdated Course Area']);
call add_employee('Felix'::text, 'Sengkang'::text, 90000006, 'felix@gmail.com'::text, 2000::money, null, '2021-03-04'::date, 'manager'::text, array['Artificial Intelligence', 'Software Engineering']);
call add_employee('Gerald'::text, 'Punggol'::text, 90000007, 'gerald@gmail.com'::text, 2500::money, null, '2021-03-04'::date, 'instructor'::text, array['Algorithms', 'Artificial Intelligence', 'Database', 'Software Engineering', 'Network']);
call add_employee('Harry'::text, 'Woodlands'::text, 90000008, 'harry@gmail.com'::text, 3000::money, null, '2021-03-04'::date, 'instructor'::text, array['Algorithms', 'Artificial Intelligence', 'Software Engineering','Security']);
call add_employee('Ivy'::text, 'Kovan'::text, 90000009, 'ivy@gmail.com'::text, null, 15::money, '2021-04-07'::date, 'instructor'::text, array['Network', 'Artificial Intelligence', 'Algorithms', 'Software Engineering']);
call add_employee('Jay'::text, 'Serangoon'::text, 90000010, 'jay@gmail.com'::text, null, 20::money, '2021-04-07'::date, 'instructor'::text, array['Algorithms', 'Artificial Intelligence', 'Network', 'Outdated Course Area', 'Database']);
call add_employee('Kelvin'::text, 'Serangoon'::text, 90000011, 'kelvin@gmail.com'::text, null, 20::money, '2021-04-07'::date, 'instructor'::text, array['Algorithms', 'Artificial Intelligence']);
call add_employee('Larry'::text, 'Serangoon'::text, 90000012, 'larry@gmail.com'::text, null, 25::money, '2021-04-07'::date, 'instructor'::text, array['Algorithms', 'Artificial Intelligence']);

----------------------------- CALLS TO REMOVE EMPLOYEES -----------------------------
call remove_employee(2, date '2021-06-01');
call remove_employee(3, date '2021-03-15');
call remove_employee(11, date '2021-04-22');

----------------------------- CALLS TO ADD CUSTOMERS -----------------------------
call add_customer('Alex', 'Sengkang', 80000001, 'alex@gmail.com', '0000 0000 0000 0000', date '2025-01-01', '000');
call add_customer('Beth', 'Hougang', 80000002, 'beth@gmail.com', '0000 0000 0000 0001', date '2025-01-01', '111');
call add_customer('Charles', 'Punggol', 80000003, 'charles@gmail.com', '0000 0000 0000 0002', date '2025-01-01', '222');
call add_customer('Dave', 'Tampines', 80000004, 'dave@gmail.com', '0000 0000 0000 0003', date '2025-01-01', '333');
call add_customer('Emily', 'Changi', 80000005, 'emily@gmail.com', '0000 0000 0000 0004', date '2025-01-01', '444');
call add_customer('Felicia', 'Loyang', 80000006, 'felicia@gmail.com', '0000 0000 0000 0005', date '2025-01-01', '555');
call add_customer('Grace', 'Bedok', 80000007, 'grace@gmail.com', '0000 0000 0000 0006', date '2025-01-01', '666');
call add_customer('Hazel', 'Bugis', 80000008, 'hazel@gmail.com', '0000 0000 0000 0007', date '2025-01-01', '777');
call add_customer('Ian', 'Orchard', 80000009, 'ian@gmail.com', '0000 0000 0000 0008', date '2025-01-01', '888');
call add_customer('Jerry', 'Chinatown', 80000010, 'jerry@gmail.com', '0000 0000 0000 0009', date '2025-01-01', '999');
call add_customer('Kelly', 'Yishun', 80000011, 'kelly@gmail.com', '0000 0000 0000 0010', date '2025-01-01', '991');
call add_customer('Leonard', 'Kent Ridge', 80000012, 'leonard@gmail.com', '0000 0000 0000 0011', date '2025-01-01', '992');
call add_customer('Matthew', 'Clementi', 80000013, 'matthew@gmail.com', '0000 0000 0000 0012', date '2025-01-01', '993');
call add_customer('Nicholas', 'Bishan', 80000014, 'nicholas@gmail.com', '0000 0000 0000 0013', date '2025-01-01', '994');
call add_customer('Owen', 'Aljunied', 80000015, 'owen@gmail.com', '0000 0000 0000 0014', date '2025-01-01', '995');
call add_customer('Peter', 'Marine Parade', 80000016, 'peter@gmail.com', '0000 0000 0000 0015', date '2025-01-01', '996');
call add_customer('Richard', 'Changi', 80000017, 'richard@gmail.com', '0000 0000 0000 0016', date '2025-01-01', '997');
call add_customer('Samuel', 'Tampines', 80000018, 'samuel@gmail.com', '0000 0000 0000 0017', date '2025-01-01', '999');
call add_customer('Terry', 'Changi', 80000019, 'terry@gmail.com', '0000 0000 0000 0018', date '2025-01-01', '990');
call add_customer('Uman', 'Tampines', 80000020, 'uman@gmail.com', '0000 0000 0000 0019', date '2025-01-01', '910');

----------------------------- CALLS TO UPDATE CREDIT CARD -----------------------------
call update_credit_card(10, '0000 0000 0000 0090', date '2025-01-01', '0000');

----------------------------- CALLS TO ADD COURSES -----------------------------
call add_course('Introduction to Artificial Intelligence', 'Search, knowledge representation, decision making', 'Artificial Intelligence', 1);
call add_course('Machine Learning', 'Decision Trees, Neural Networks, Bayesian Inference', 'Artificial Intelligence', 2);
call add_course('AI Planning & Decision Making', 'Planning, Uncertainty, MDP, Game Theory', 'Artificial Intelligence', 1);
call add_course('Knowledge Representation', 'Knowledge, Logic, FOL', 'Artificial Intelligence', 2);
call add_course('Software Engineering', 'OOP, UML, Code quality, Design patterns', 'Software Engineering', 2);
call add_course('Data Structures & Algorithms', 'Searching, Sorting, Hashing, Trees, Graphs, SSSP, MST', 'Algorithms', 1);
call add_course('Design & Analysis of Algorithms', 'Master theorem, Greedy algorithms, Dynamic Programming', 'Algorithms', 1);
call add_course('Introduction to Computer Networks', 'Application, Transport, Network, Link, Physical layers', 'Network', 3);
call add_course('Introduction to Information Security', 'Classical/historical ciphers, Modern ciphers, Cryptosystems', 'Security', 2);
call add_course('Database Systems', 'Relational Algebra, SQL, ER, Normal Forms', 'Database', 2);

call add_course('Outdated Course', 'Teaches outdated material', 'Artificial Intelligence', 2);
call add_course('Outdated Course1', 'Teaches outdated material', 'Database', 2);
call add_course('Outdated Course2', 'Teaches outdated material', 'Algorithms', 2);
call add_course('Outdated Course3', 'Teaches outdated material', 'Network', 2);
call add_course('Parallel Networks', 'Parallel networking between computers', 'Network', 3);

---------------------------- CALLS TO ADD COURSE PACKAGES ----------------------------

-- Expired packages
call add_course_package('Package A', 5, date '2021-02-01', date '2021-03-01', 100::money);
call add_course_package('Package B', 10, date '2021-03-01', date '2021-04-01', 180::money);
call add_course_package('Package C', 15, date '2021-04-01', date '2021-05-01', 250::money);
call add_course_package('Package E', 5, date '2021-04-15', date '2021-08-01', 190::money);
call add_course_package('Package F', 10, date '2021-05-01', date '2021-07-01', 260::money);

-- Packages still for sale
call add_course_package('Package G', 10, date '2021-01-01', date '2021-07-01', 260::money);
call add_course_package('Package H', 5, date '2021-01-01', date '2021-07-01', 260::money);
call add_course_package('Package I', 4, date '2021-01-01', date '2021-07-01', 260::money);
call add_course_package('Package J', 3, date '2021-01-01', date '2021-07-01', 260::money);
call add_course_package('Package K', 2, date '2021-01-01', date '2021-07-01', 260::money);
call add_course_package('Package L', 1, date '2021-01-01', date '2021-07-01', 260::money);

---------------------------- MANUAL DATA INSERTION FOR LECTURE ROOMS ----------------------------
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (20, 2, 1);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (30, 2, 2);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (40, 2, 3);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (50, 3, 1);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (60, 3, 2);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (70, 3, 3);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (20, 4, 1);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (30, 4, 2);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (40, 5, 3);
INSERT INTO LectureRooms(seatingCapacity, roomNumber, roomFloor)
VALUES (50, 5, 1);


---------------------------- CALLS TO INSERT COURSE OFFERINGS -------------------------
-- add_course_offering (IN offeringId INT, IN courseId INT, IN courseFee MONEY, IN launchDate DATE, 
--						IN registrationDeadline DATE, IN adminId INT, IN numTarget INT, 
--						IN sessionDate DATE[], IN sessionStartHr INT[], IN roomId INT[])

 call add_course_offering (2,1,150::MONEY, '2021-01-10'::DATE, 
 						  '2021-07-20'::DATE, 2, 100, 
 						  ARRAY['2021-08-02', '2021-08-10', '2021-08-20'::DATE], ARRAY[10,9,15], ARRAY[3,4,5]);
						  
 call add_course_offering (3,1,200::MONEY, '2021-03-15'::DATE, 
 						 '2021-10-15'::DATE, 2, 150, 
 						  ARRAY['2021-10-26', '2021-10-28', '2021-11-05', '2021-11-08'::DATE], ARRAY[11,9,15,14], ARRAY[5,9,2,6]);

-- call add_course_offering (1,2,100::MONEY, '2021-01-31'::DATE, 
  						--   '2021-05-05'::DATE, 3, 80, 
  						--   ARRAY['2021-05-18', '2021-05-21','2021-05-27'::DATE], ARRAY[9,10,14], ARRAY[7,8,4]);

 call add_course_offering (2,3,150::MONEY, '2021-02-17'::DATE, 
  						  '2021-08-20'::DATE, 3, 110, 
  						  ARRAY['2021-09-02', '2021-09-06', '2021-09-10'::DATE], ARRAY[10,14,15], ARRAY[2,6,8]);

 call add_course_offering (3,3,200::MONEY, '2021-03-18'::DATE, 
  						  '2021-09-25'::DATE, 2, 150, 
  						  ARRAY['2021-10-05', '2021-10-07', '2021-10-15' ::DATE], ARRAY[9,10,11], ARRAY[10,4,4]);


 call add_course_offering (2,4,150::MONEY, '2021-03-10'::DATE, 
   						  '2021-08-20'::DATE, 2, 150, 
  						  ARRAY['2021-09-06', '2021-09-07', '2021-09-14' ::DATE], ARRAY[9,10,14], ARRAY[6,6,5]);			  
 call add_course_offering (3,4,200::MONEY, '2021-04-03'::DATE, 
   						  '2021-09-13'::DATE, 2, 100, 
   						  ARRAY['2021-09-24', '2021-09-27'::DATE], ARRAY[10,14], ARRAY[4,5]);					  

 call add_course_offering (2,5,150::MONEY, '2021-02-10'::DATE, 
   						  '2021-07-15'::DATE, 2, 70, 
   						  ARRAY['2021-08-02', '2021-08-05', '2021-08-10' ::DATE], ARRAY[9,10,14], ARRAY[9,5,1]);

 call add_course_offering (1,6,100::MONEY, '2021-01-15'::DATE, 
   						  '2021-05-07'::DATE, 3, 100, 
   						  ARRAY['2021-05-20', '2021-05-25', '2021-05-27' ::DATE], ARRAY[11,14,15], ARRAY[6,3,7]);
	
-- call add_course_offering (1,9,100::MONEY, '2021-03-16'::DATE, 
  						--   '2021-06-13'::DATE, 3, 90, 
  						--   ARRAY['2021-06-25', '2021-06-26', '2021-06-27' ::DATE], ARRAY[19,14,9], ARRAY[9,10,10]);

----------------------------- MANUALLY ADD CourseOfferings  -----------------------------
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-01-01', 50, 100, '2021-06-16', 'available', 100 , '2021-07-01', '2021-07-20', 1, 2);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-01-01', 50, 100, '2021-06-17', 'available', 125 , '2021-07-02', '2021-07-20', 3, 2);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-01-01', 50, 100, '2021-06-18', 'available', 150 , '2021-07-03', '2021-07-20', 4, 2);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-01-01', 50, 100, '2021-06-18', 'available', 200 , '2021-07-04', '2021-07-20', 5, 2);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (2, '2021-02-01', 100, 99, '2021-06-14', 'available', 150 , '2021-07-01', '2021-07-20', 2, 3);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (2, '2021-02-01', 100, 99, '2021-06-16', 'available', 170 , '2021-07-02', '2021-07-20', 6, 3);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (2, '2021-02-01', 100, 99, '2021-06-15', 'available', 190 , '2021-07-03', '2021-07-20', 7, 3);

INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (3, '2021-02-02', 100, 99, '2021-06-15', 'available', 150 , '2021-07-01', '2021-07-20', 2, 3);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-02-02', 100, 99, '2021-06-17', 'available', 150 , '2021-07-01', '2021-07-20', 10, 3);

INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-02-02', 100, 99, '2021-06-18', 'available', 150 , '2021-07-01', '2021-07-20', 8, 3);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-02-02', 100, 99, '2021-06-19', 'available', 150 , '2021-07-01', '2021-07-20', 15, 3);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-02-02', 100, 99, '2021-06-14', 'available', 150 , '2021-07-01', '2021-07-20', 7, 3);

INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (3, '2021-04-03', 100, 99, '2021-04-8', 'available', 150 , '2021-04-10', '2021-07-20', 6, 3);

call add_session(6, date '2021-04-03', 3, 5, date '2021-04-11', 9, 1, 9, 2); 

-- more recent offerings
-- INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
-- 							 seatingCapacity, startDate, endDate, courseId, employeeId)
-- 	values (4, '2021-02-03', 100, 99, '2021-04-15', 'available', 150 , '2021-04-01', '2021-07-20', 2, 3);

-- Outdated CourseOffering for promote_courses()
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
 							 seatingCapacity, startDate, endDate, courseId, employeeId)
 	values (1, '2020-02-02', 100, 99, '2020-06-15', 'available', 150 , '2020-07-01', '2020-07-20', 11, 4);

INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
 							 seatingCapacity, startDate, endDate, courseId, employeeId)
 	values (1, '2020-02-02', 100, 99, '2020-06-15', 'available', 150 , '2020-07-01', '2020-07-20', 12, 4);
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
 							 seatingCapacity, startDate, endDate, courseId, employeeId)
 	values (1, '2020-02-02', 100, 99, '2020-06-15', 'available', 150 , '2020-07-01', '2020-07-20', 13, 4);
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
 							 seatingCapacity, startDate, endDate, courseId, employeeId)
 	values (1, '2020-02-02', 100, 99, '2020-06-15', 'available', 150 , '2020-07-01', '2020-07-20', 14, 4);
	
----------------------------- CALL TO ADD CourseSession -----------------------------
-- _courseId integer, _launchDate date, _offeringId integer, _courseSessionDate date, _courseSessionHour integer, _sessionId integer,
--    _instructorId integer, _roomId integer

call add_session(2, date '2021-02-01', 2, date '2023-02-02', 14, 1, 8, 1);  -- Test: session > offering endDate. Expect endDate of CourseOffering to change as well

call add_session(2, date '2021-02-02', 3, date '2023-02-03', 10, 1, 8, 1);
call add_session(1, date '2021-01-01', 1, date '2021-07-01', 10, 1, 9, 1);  -- Test: session < offering startDate. Expect startDate of CourseOffering to change as well
call add_session(1, date '2021-01-01', 1, date '2021-07-16', 15, 2, 7, 1);  -- Test: session < offering startDate. Expect startDate of CourseOffering to change as well
call add_session(3, date '2021-01-01', 1, date '2021-07-15', 15, 1, 9, 3); 
call add_session(4, date '2021-01-01', 1, date '2021-07-16', 15, 1, 10, 2); 

call add_session(6, date '2021-02-01', 2, date '2021-07-15', 15, 1, 8, 2); 
call add_session(6, date '2021-02-01', 2, date '2021-07-16', 14, 2, 9, 6); 
call add_session(5, date '2021-01-01', 1, date '2021-07-22', 10, 1, 7, 4); 
call add_session(5, date '2021-01-01', 1, date '2021-07-22', 15, 2, 8, 5); 
call add_session(7, date '2021-02-01', 2, date '2021-07-12', 15, 1, 9, 2);
call add_session(10, date '2021-02-02', 1, date '2021-07-12', 15, 1, 10, 3); 
call add_session(8, date '2021-02-02', 1, date '2021-07-12', 15, 1, 7, 4); 
call add_session(7, date '2021-02-02', 1, date '2021-07-12', 15, 1, 8, 5);

call add_session(15, date '2021-02-02', 1, date '2021-07-12', 9, 1, 9, 2); 

-- more recent sessions to test PurchasesView inactive package
-- call add_session(2, date '2021-02-03', 4, date '2021-04-09', 15, 1, 9, 2); 
-- call add_session(2, date '2021-02-03', 4, date '2021-04-09', 14, 2, 8, 2); 
-- call add_session(2, date '2021-02-03', 4, date '2021-04-09', 9, 3, 10, 2); 
-- call add_session(2, date '2021-02-03', 4, date '2021-04-09', 10, 4, 7, 2); 
-- call add_session(2, date '2021-02-03', 4, date '2021-04-09', 11, 5, 8, 2); 

-- call add_session(1, date '2021-01-01', 1, date '2021-01-16', 10, 3, 9, 1);  -- Test: session < offering startDate. Expect startDate of CourseOffering to change as well

-- Outdated session
call add_session(11, date '2020-02-02', 1, date '2020-07-02', 15, 1, 10, 2);
call add_session(12, date '2020-02-02', 1, date '2020-07-02', 10, 1, 10, 2);
call add_session(13, date '2020-02-02', 1, date '2020-07-02', 14, 1, 7, 5);
call add_session(14, date '2020-02-02', 1, date '2020-07-06', 15, 1, 10, 2);

----------------------------- UPDATE CourseSession Room -----------------------------
-- ERROR: current date is past course session date
-- call update_room(1, 1, date '2021-01-16', 10, 3 ,4);

----------------------------- UPDATE CourseSession Instructor -----------------------------
-- ERROR: current date is past course session date
-- call update_instructor(1, 1, date '2021-01-16', 10, 9);

----------------------------- CALL TO BUY CoursePackages -----------------------------
call buy_course_package(1, 6);
call buy_course_package(2, 7);
call buy_course_package(3, 8);
call buy_course_package(4, 9);
call buy_course_package(5, 10);
call buy_course_package(6, 11);
call buy_course_package(7, 6);
call buy_course_package(8, 7);
call buy_course_package(9, 8);
call buy_course_package(10, 9);
call buy_course_package(11, 7);

-- Error testing
-- Non existing customer
-- call buy_course_package(50, 2);

-- Non existing package
-- call buy_course_package(2, 10);

-- already owns a package
-- call buy_course_package(2, 2);

-- try buying expired package
-- call buy_course_package(11, 1);


----------------------------- CALL TO view a customer's course packages -----------------------------

-- select * from get_my_course_package(1);
-- select * from get_my_course_package(2);

----------------------------- CALL TO register for sessions -----------------------------

-- Pays
call register_session(1, 2, 2, date '2023-02-02', 14, 0);

call register_session(1, 1, 1, date '2021-07-01', 10, 0);

call register_session(2, 1, 1, date '2021-07-01', 10, 0);
call register_session(2, 2, 3, date '2023-02-03', 10, 0);

call register_session(13, 2, 2, date '2023-02-02', 14, 0);
call register_session(13, 6, 2, date '2021-07-16', 14, 0);

call register_session(14, 4, 1, date '2021-07-16', 15,  0);
call register_session(14, 3, 1, date '2021-07-15', 15,  0);

call register_session(15, 7, 2, date '2021-07-12', 15,  0);
call register_session(15, 5, 1, date '2021-07-22', 15,  0);



-- Redeems

call register_session(1, 2, 3, date '2023-02-03', 10, 1);

call register_session(2, 2, 2, date '2023-02-02', 14, 1);

call register_session(3, 2, 2, date '2023-02-02', 14, 1);
call register_session(3, 6, 2, date '2021-07-16', 14, 1);

call register_session(4, 4, 1, date '2021-07-16', 15, 1);
call register_session(4, 3, 1, date '2021-07-15', 15, 1);

call register_session(5, 7, 2, date '2021-07-12', 15, 1);
call register_session(5, 5, 1, date '2021-07-22', 15, 1);

call register_session(6, 2, 3, date '2023-02-03', 10, 1); 

call register_session(7, 5, 1, date '2021-07-22', 15, 1);
call register_session(7, 3, 1, date '2021-07-15', 15, 1);

call register_session(4, 7, 2, date '2021-07-12', 15, 1);

call register_session(8, 15, 1, date '2021-07-12', 9, 0);


call register_session(9, 8, 1, date '2021-07-12', 15, 0);
-- Customer 8 and 9 will register for outdated sessions for promote_courses,
-- This requires disabling trigger to register for past sessions.

/* Hazel registers for courses under AI, Database, Algo 
call register_session(8, 11, 1, date '2020-07-02', 15, 1);
call register_session(8, 12, 1, date '2020-07-03', 15, 1);
call register_session(8, 13, 1, date '2020-07-04', 15, 1); */

/* Ian registers for courses under AI, Network and Algo 
call register_session(9, 11, 1, date '2020-07-02', 15, 0); */
 /*
call register_session(9, 13, 1, date '2020-07-04', 15, 0);
call register_session(9, 14, 1, date '2020-07-05', 15, 0);

/* 	
	Ian registers for courses under AI, Database, Algo and Network.
	Expected to only see Database, Algo and Network because they are 3 most recent areas.
*/
call register_session(9, 11, 1, date '2020-07-02', 15, 0);
call register_session(9, 12, 1, date '2020-07-03', 15, 0);
call register_session(9, 13, 1, date '2020-07-04', 15, 0);
call register_session(9, 14, 1, date '2020-07-05', 15, 0);

*/

-- Register for recent sessions to test inactive package in PurchasesView
-- call register_session(11, 2, 4, date '2021-04-09', 15, 1);
-- call register_session(11, 2, 4, date '2021-04-09', 14, 1);
-- call register_session(11, 2, 4, date '2021-04-09', 11, 1);
-- call register_session(11, 2, 4, date '2021-04-09', 10, 1);
-- call register_session(11, 2, 4, date '2021-04-09', 9, 1);

-- Test if customer can buy more packages once his package becomes inactive
-- call buy_course_package(11, 8);


------------------- Error testing -----------------------------


/* Customer tries paying for the same session again */
-- call register_session(1, 1, 1, 1, 0);
-- call register_session(2, 1, 1, 1, 0);


/* Customer tries redeeming for the same session again */
-- call register_session(1, 2, 2, 1, 1);


/* Customer does not exist */
-- call register_session(-1, 1, 1, 1, 0);


/* CourseOffering does not exist */
-- call register_session(1, 1, 10, 1, 0);

/* For each CourseOffering, customer can register for at most 1 session */

-- Try paying for another session in the same offering
-- call register_session(1, 1, 1, 4, 0);
-- call register_session(1, 2, 2, 4, 0);

-- Try redeeming for another session in the same offering
-- call register_session(1, 1, 1, 4, 1);

/* Try using invalid payment number */
-- call register_session(1, 1, 1, 2, 10);

/* A customer with no more sessions should not be able to redeem again */
-- call register_session(6, 2, 2, date '2023-02-02', 10, 1);


------------------------------- Cancel Registration for Pays ----------------------------
-- To be cancelled (Pays)

call register_session(13, 4, 1, date '2021-07-16', 15,  0);
call register_session(13, 3, 1, date '2021-07-15', 15,  0);

call register_session(14, 2, 2, date '2023-02-02', 14, 0);
call register_session(14, 6, 2, date '2021-07-16', 14, 0);

call register_session(15, 1, 1, date '2021-07-01', 10, 0);
call register_session(15, 2, 3, date '2023-02-03', 10, 0);


call cancel_registration(13, 4, 1);
call cancel_registration(13, 3, 1);

call cancel_registration(14, 2, 2);
call cancel_registration(14, 6, 2);

call cancel_registration(15, 1, 1);
call cancel_registration(15, 2, 3);

------------------------------ Cancel Registration for Redeems ----------------------------

-- To be cancelled (Redeems)
call register_session(1, 5, 1, date '2021-07-22', 15, 1);

call register_session(7, 2, 3, date '2023-02-03', 10, 1);
call register_session(7, 7, 2, date '2021-07-12', 15, 1);


call register_session(1, 6, 2, date '2021-07-16', 14, 1);

--evnetuall here
call register_session(1, 6, 3, date '2021-04-11', 9, 0);


call cancel_registration(1, 5, 1);

call cancel_registration(7, 2, 3);
call cancel_registration(7, 7, 2);

call cancel_registration(1, 6, 2);

----------------------------- CALL TO get available course offerings -----------------------------

-- select * from get_available_course_offerings();

----------------------------- CALL TO get available course sessions -----------------------------
-- select * from get_available_course_sessions(1,1);
-- select * from get_available_course_sessions(2,2);


----------------------------- CALL TO get a customer's registrations -----------------------------

-- select * from get_my_registrations(1);
-- select * from get_my_registrations(2);
-- select * from get_my_registrations(10);

----------------------------- CALL TO get potential Course to promote -----------------------------
-- select * from promote_courses();

----------------------------- CALL TO VIEW MANAGERS' REPORT -----------------------------
-- select * from view_manager_report();

-- Cases tested:
-- 1. Area with courses with no offerings
-- 2. Tied courses with no registrations
-- 3. Check last year offerings and next year is excluded
-- 4. Pays and redeems sum correct
