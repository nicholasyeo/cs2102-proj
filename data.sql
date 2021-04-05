----------------------------- CALLS TO ADD EMPLOYEES -----------------------------
call add_employee('Alice'::text, 'NUS'::text, 90000001, 'alice@gmail.com'::text, 2000::money, null, current_date, 'manager'::text, array['Network', 'Security']);
call add_employee('Bob'::text, 'NUS'::text, 90000002, 'bob@gmail.com'::text, 3000::money, null, current_date, 'administrator'::text, array[]::text[]);
call add_employee('Charlie'::text, 'NTU'::text, 90000003, 'charlie@gmail.com'::text, 2500::money, null, current_date, 'administrator'::text, array[]::text[]);
call add_employee('Derek'::text, 'SMU'::text, 90000004, 'derek@gmail.com'::text, 4000::money, null, current_date, 'administrator'::text, array[]::text[]);
call add_employee('Eric'::text, 'Hougang'::text, 90000005, 'eric@gmail.com'::text, 4000::money, null, current_date, 'manager'::text, array['Algorithms', 'Database']);
call add_employee('Felix'::text, 'Sengkang'::text, 90000006, 'felix@gmail.com'::text, 2000::money, null, current_date, 'manager'::text, array['Artificial Intelligence', 'Software Engineering']);
call add_employee('Gerald'::text, 'Punggol'::text, 90000007, 'gerald@gmail.com'::text, 2500::money, null, current_date, 'instructor'::text, array['Database']);
call add_employee('Harry'::text, 'Woodlands'::text, 90000008, 'harry@gmail.com'::text, null, 20::money, current_date, 'instructor'::text, array['Algorithms']);
call add_employee('Ivy'::text, 'Kovan'::text, 90000009, 'ivy@gmail.com'::text, null, 15::money, current_date, 'instructor'::text, array['Network']);
call add_employee('Jay'::text, 'Serangoon'::text, 90000010, 'jay@gmail.com'::text, null, 20::money, current_date, 'instructor'::text, array['Artificial Intelligence']);

----------------------------- CALLS TO REMOVE EMPLOYEES -----------------------------
call remove_employee(2, date '2021-06-01');

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

----------------------------- CALLS TO UPDATE CREDIT CARD -----------------------------
call update_credit_card(10, '0000 0000 0000 0010', date '2025-01-01', '0000');

----------------------------- CALLS TO ADD COURSES -----------------------------
call add_course('Introduction to Artificial Intelligence', 'Search, knowledge representation, decision making', 'Artificial Intelligence', 2);
call add_course('Machine Learning', 'Decision Trees, Neural Networks, Bayesian Inference', 'Artificial Intelligence', 3);
call add_course('AI Planning & Decision Making', 'Planning, Uncertainty, MDP, Game Theory', 'Artificial Intelligence', 2);
call add_course('Knowledge Representation', 'Knowledge, Logic, FOL', 'Artificial Intelligence', 2);
call add_course('Software Engineering', 'OOP, UML, Code quality, Design patterns', 'Software Engineering', 2);
call add_course('Data Structures & Algorithms', 'Searching, Sorting, Hashing, Trees, Graphs, SSSP, MST', 'Algorithms', 2);
call add_course('Design & Analysis of Algorithms', 'Master theorem, Greedy algorithms, Dynamic Programming', 'Algorithms', 2);
call add_course('Introduction to Computer Networks', 'Application, Transport, Network, Link, Physical layers', 'Network', 3);
call add_course('Introduction to Information Security', 'Classical/historical ciphers, Modern ciphers, Cryptosystems', 'Security', 2);
call add_course('Database Systems', 'Relational Algebra, SQL, ER, Normal Forms', 'Database', 2);

---------------------------- CALLS TO ADD COURSE PACKAGES ----------------------------

call add_course_package('Package A', 5, date '2021-02-01', date '2021-03-01', 100::money);
call add_course_package('Package B', 10, date '2021-03-01', date '2021-04-01', 180::money);
call add_course_package('Package C', 15, date '2021-04-01', date '2021-05-01', 250::money);
call add_course_package('Package E', 5, date '2021-04-15', date '2021-08-01', 190::money);
call add_course_package('Package F', 10, date '2021-05-01', date '2021-07-01', 260::money);

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

----------------------------- MANUALLY ADD CourseOfferings  -----------------------------
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-01-01', 50, 100, '2021-01-15', 'available', 100 , '2021-02-01', '2021-02-20', 1, 2);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-01-01', 50, 100, '2021-01-15', 'available', 125 , '2021-02-02', '2021-02-20', 3, 2);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-01-01', 50, 100, '2021-01-15', 'available', 150 , '2021-02-03', '2021-02-20', 4, 2);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (1, '2021-01-01', 50, 100, '2021-01-15', 'available', 200 , '2021-02-04', '2021-02-20', 5, 2);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (2, '2021-02-01', 100, 99, '2021-02-15', 'available', 150 , '2021-03-01', '2021-03-20', 2, 3);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (2, '2021-02-01', 100, 99, '2021-02-15', 'available', 170 , '2021-03-02', '2021-03-20', 6, 3);
	
INSERT INTO CourseOfferings (offeringId, launchDate, numRegistrations, courseFee, registrationDeadline, status,
							 seatingCapacity, startDate, endDate, courseId, employeeId)
	values (2, '2021-02-01', 100, 99, '2021-02-15', 'available', 190 , '2021-03-03', '2021-03-20', 7, 3);
	
----------------------------- CALL TO ADD CourseSession -----------------------------
-- _courseId integer, _launchDate date, _offeringId integer,  _weekday integer, _courseSessionDate date, _courseSessionHour integer, _sessionId integer,
--    _instructorId integer, _roomId integer

call add_session(2, date '2021-02-01', 2, 1, date '2023-02-02', 10, 1, 8, 1);  -- Test: session > offering endDate. Expect endDate of CourseOffering to change as well
call add_session(1, date '2021-01-01', 1, 3, date '2021-02-01', 10, 1, 9, 1);  -- Test: session < offering startDate. Expect startDate of CourseOffering to change as well
call add_session(1, date '2021-01-01', 1, 2, date '2021-02-16', 15, 2, 9, 1);  -- Test: session < offering startDate. Expect startDate of CourseOffering to change as well
call add_session(3, date '2021-01-01', 1, 4, date '2021-03-15', 15, 1, 9, 3); 
call add_session(4, date '2021-01-01', 1, 2, date '2021-02-16', 15, 1, 9, 2); 

call add_session(6, date '2021-02-01', 2, 4, date '2021-03-15', 15, 1, 9, 2); 
call add_session(6, date '2021-02-01', 2, 5, date '2021-03-16', 14, 2, 9, 6); 
call add_session(5, date '2021-01-01', 1, 4, date '2021-03-22', 11, 1, 9, 4); 
call add_session(5, date '2021-01-01', 1, 4, date '2021-03-22', 15, 2, 9, 5); 
call add_session(7, date '2021-02-01', 2, 5, date '2021-03-12', 15, 1, 9, 2); 

-- call add_session(1, date '2021-01-01', 1, 3, date '2021-01-16', 10, 3, 9, 1);  -- Test: session < offering startDate. Expect startDate of CourseOffering to change as well


----------------------------- UPDATE CourseSession Room -----------------------------
call update_room(1, 1, date '2021-01-16', 10, 3 ,4);

----------------------------- UPDATE CourseSession Instructor -----------------------------
call update_instructor(1, 1, date '2021-01-16', 10, 9);

----------------------------- CALL TO BUY CoursePackages -----------------------------
call buy_course_package(1, 1);
call buy_course_package(2, 2);
call buy_course_package(10, 1);

-- Error testing
-- Non existing customer
-- call buy_course_package(50, 2);

-- Non existing package
-- call buy_course_package(2, 10);

-- already owns a package
-- call buy_course_package(2, 2);


----------------------------- CALL TO BUY CoursePackages -----------------------------

-- select * from get_my_course_package(1);
-- select * from get_my_course_package(2);

----------------------------- CALL TO register for sessions -----------------------------

-- Pays
call register_session(1, 1, 1, 1, 0);
call register_session(2, 1, 1, 1, 0);
call register_session(3, 2, 2, 1, 0);
call register_session(4, 2, 2, 1, 0);
call register_session(5, 1, 1, 1, 0);

-- Redeems
call register_session(1, 2, 2, 1, 1);
call register_session(2, 2, 2, 1, 1);
-- call register_session(10, 1, 1, 4, 1);

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
