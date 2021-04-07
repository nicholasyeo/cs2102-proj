-------------------------------- ROUTINES -----------------------------------

-- 1. add_employee
create or replace procedure add_employee(ename text, homeAddress text,
    contactNumber integer, eEmail text, monthlySalary money, hourlyRate money,
    joinDate date, category text, courseAreas text[]) as $$
declare
    eid integer;
    arrayLength integer;
    temp integer;
begin
    -- Check that category input is valid
    if (category not in ('manager', 'instructor', 'administrator')) then
        raise exception 'Invalid employee category input.';
    end if;

    -- Check that salary information is valid
    if ((monthlySalary is null and hourlyRate is null) or 
        (monthlySalary is not null and hourlyRate is not null)) then
        raise exception 'Exactly 1 of monthlySalary or hourlyRate must be null.';
    end if;

    -- Check that full-timers are either manager or administrator
    if (category in ('manager', 'administrator') and monthlySalary is null) then
        raise exception 'Managers and administrators must have a valid monthly salary.';
    end if;

    -- Check that courseAreas input is valid
    arrayLength := coalesce(array_length(courseAreas, 1), 0); -- outputs null when input is an empty array
    if (category = 'administrator' and arrayLength > 0) then
        raise exception 'Course areas must be empty for administrators.';
    elsif (category ='instructor' and arrayLength = 0) then
        raise exception 'Course areas cannot be empty for instructors.';
    end if;

    insert into Employees (ename, homeAddress, contactNumber, email, joinDate)
    values (ename, homeAddress, contactNumber, eEmail, joinDate);

    select employeeId into eid from Employees E where E.email = eEmail; 
    if (monthlySalary is null) then
        insert into PartTimers values (eid, hourlyRate);
    else
        insert into FullTimers values (eid, monthlySalary);
    end if;

    temp := 1;
    if (category = 'manager') then
        insert into Managers values (eid);
        loop
            exit when temp > arrayLength;
            insert into CourseAreas values (courseAreas[temp], eid);
            temp := temp + 1;
        end loop;
    elsif (category = 'instructor') then
        insert into Instructors values (eid);
        loop
            exit when temp > arrayLength;
            insert into Specialises values (eid, courseAreas[temp]);
            temp := temp + 1;
        end loop;
    else
        insert into Administrators values (eid);
    end if;
end;
$$ language plpgsql;

-- 2. remove_employee
create or replace procedure remove_employee(eid integer, departureDate date) as $$
begin
    if (departureDate < any (
        select registrationDeadline from CourseOfferings where employeeId = eid
    ) or departureDate < any (
        select sessDate from CourseSessions where employeeId = eid
    ) or eid in (select employeeId from CourseAreas)) then
        raise exception 'The conditions required to remove employee is not fulfilled.';
    end if;

    update Employees
    set departDate = departureDate
    where employeeId = eid;
end;
$$ language plpgsql;

-- 3. add_customer
create or replace procedure add_customer(cname text, homeAddress text,
    contactNumber integer, customerEmail text, ccNum text,
    expiryDate date, cvv text) as $$
declare
    cid integer;
begin
    insert into Customers (email, contactNum, address, customerName)
    values (customerEmail, contactNumber, homeAddress, cname);

    insert into CreditCards
    values (ccNum, expiryDate, cvv);

    select customerId into cid from Customers C where C.email = customerEmail;
    insert into Owns values (cid, ccNum);
end;
$$ language plpgsql;

-- 4. update_credit_card
create or replace procedure update_credit_card(cid integer,
    ccNum text, expiryDate date, cvv text) as $$

    insert into CreditCards values (ccNum, expiryDate, cvv);

    update Owns set ccNumber = ccNum where customerId = cid;
    -- Not sure if need to delete the old credit card?
$$ language sql;

-- 5. add_course
create or replace procedure add_course(cTitle text, cDescription text,
    cArea text, duration integer) as $$
    
    insert into Courses(description, duration, courseTitle, areaName)
    values (cDescription, duration, cTitle, cArea);
$$ language sql;

-- 7. get_available_instructors //done
CREATE OR REPLACE FUNCTION get_available_instructors(IN course INT, IN startDate DATE, IN endDate DATE) 
RETURNS TABLE (employeeId INT, instructorName TEXT, monthlyHours INT, selectedDay DATE, selectedHours INT[]) 
AS $$

DECLARE 
	area TEXT;
	curs CURSOR FOR (SELECT * FROM Specialises s INNER JOIN Employees e ON s.employeeId = e.employeeId ORDER BY s.employeeId ASC);
	r RECORD;
	getMonth INT;
	availDay DATE;
	adjHours INT[] := '{9,10,11,14,15,16,17}';
	counter INT;
	selectedHr INT;
	selectedDuration INT;
	temprow RECORD;
	totalHours INT;

BEGIN
	area := (SELECT cr.areaName FROM Courses cr WHERE cr.courseId = course);
	
	getMonth := (SELECT EXTRACT(MONTH FROM startDate));

	OPEN curs;
	LOOP	
		FETCH curs INTO r;
		EXIT WHEN NOT FOUND;
		
		IF (r.areaName = area) THEN
			employeeId := r.employeeId;
			instructorName := r.ename;

			SELECT SUM(duration) INTO totalHours 
			FROM CourseSessions cs INNER JOIN Courses cr ON cr.courseId = cs.courseId
			WHERE cs.employeeId = r.employeeId AND EXTRACT(MONTH FROM cs.sessDate) = getMonth;
			
			monthlyHours := coalesce(totalHours, 0);
			
			availDay := (SELECT startDate - INTERVAL '1 day');

			LOOP 
				availDay := (SELECT availDay + INTERVAL '1 day');
				IF availDay > endDate THEN EXIT;
				END IF;
				selectedDay := availDay;

				FOR temprow IN
					SELECT * 
					FROM CourseSessions cs INNER JOIN Courses cr ON cs.courseId = cr.courseId
					where cs.employeeId = r.employeeId AND cs.sessDate = availDay
				LOOP 
					counter := temprow.sessHour - 1;
					LOOP 
						EXIT WHEN counter >= temprow.sessHour + temprow.duration + 1;
						adjHours := (SELECT array_remove(adjHours, counter));
						counter := counter + 1;
					END LOOP;
				END LOOP;
				selectedHours := adjHours;
				RETURN NEXT;
				adjHours := '{9,10,11,14,15,16,17}';
			END LOOP;
		END IF;
		
	END LOOP;
	CLOSE curs;	
END;

$$ LANGUAGE plpgsql;

-- 8. find_rooms //done
CREATE OR REPLACE FUNCTION find_rooms(IN selectedDate DATE, IN selectedHour INT, IN selectedDuration INT) 
RETURNS TABLE (roomId INT) 
AS $$
DECLARE 
    curs CURSOR FOR (SELECT * FROM LectureRooms lr LEFT JOIN (CourseSessions cs INNER JOIN Courses cr on cr.courseId = cs.courseId) ON lr.roomId = cs.roomId);
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        IF ((r.sessDate IS NULL) OR (r.sessDate <> selectedDate) OR (r.sessDate = selectedDate AND r.sessHour + r.duration <= selectedHour) OR  (r.sessDate = selectedDate AND selectedHour + selectedDuration <= r.sessHour)) THEN
            roomId := r.roomId;
            RETURN NEXT;
        END IF;
    END LOOP;
    CLOSE CURS;
END;
$$ LANGUAGE plpgsql;

-- 8. find_rooms //done
CREATE OR REPLACE FUNCTION find_rooms(IN selectedDate DATE, IN selectedHour INT, IN selectedDuration INT) 
RETURNS TABLE (roomId INT) 
AS $$
DECLARE 
    curs CURSOR FOR (SELECT * FROM LectureRooms lr LEFT JOIN (CourseSessions cs INNER JOIN Courses cr on cr.courseId = cs.courseId) ON lr.roomId = cs.roomId);
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        IF ((r.sessDate IS NULL) OR (r.sessDate <> selectedDate) OR (r.sessDate = selectedDate AND r.sessHour + r.duration <= selectedHour) OR  (r.sessDate = selectedDate AND selectedHour + selectedDuration <= r.sessHour)) THEN
            roomId := r.roomId;
            RETURN NEXT;
        END IF;
    END LOOP;
    CLOSE CURS;
END;
$$ LANGUAGE plpgsql;


-- 9. get_available_rooms //done
CREATE OR REPLACE FUNCTION get_available_rooms(IN startDate DATE, IN endDate DATE) 
RETURNS TABLE (roomId INT, seatingCapacity INT, selectedDay DATE, selectedHours INT[]) 
AS $$

DECLARE
	curs CURSOR FOR (SELECT * FROM LectureRooms);
	r RECORD;
	availDay DATE;
	adjHours INT[] := '{9,10,11,12,13,14,15,16,17}';
	counter INT;
	temprow RECORD;
	
BEGIN
	OPEN curs;
	LOOP 
		FETCH curs INTO r;
		EXIT WHEN NOT FOUND;
		roomId := r.roomId;
		seatingCapacity := r.seatingCapacity;
		availDay := (SELECT startDate - INTERVAL '1 day');
		LOOP 
			availDay := (SELECT availDay + INTERVAL '1 day');
			IF availDay > endDate THEN EXIT;
			END IF;
			selectedDay := availDay;
			
			FOR temprow IN
				SELECT *
				FROM CourseSessions cs INNER JOIN Courses cr ON cs.courseId = cr.courseId
				where cs.roomId = r.roomId AND cs.sessDate = availDay
			LOOP 
				counter := temprow.sessHour;
				LOOP 
					EXIT WHEN counter >= temprow.sessHour + temprow.duration;
					adjHours := (SELECT array_remove(adjHours, counter));
					counter := counter + 1;
				END LOOP;
			END LOOP;
			
			selectedHours := adjHours;
			RETURN NEXT;
			adjHours := '{9,10,11,12,13,14,15,16,17}';
		END LOOP;
	END LOOP;
	CLOSE curs;
END;
$$ LANGUAGE plpgsql;

--10. add_course_offering
CREATE OR REPLACE PROCEDURE add_course_offering (IN offeringId INT, IN courseId INT, IN courseFee MONEY, IN launchDate DATE, 
						IN registrationDeadline DATE, IN adminId INT, IN numTarget INT, 
						IN sessionDate DATE[], IN sessionStartHr INT[], IN roomId INT[])
AS $$
DECLARE
	counter INT;
	countCapacity INT;
	addDate DATE;
	addStartHr INT;
	addRoomId INT;
	addInstructorId INT;
	tempCap INT;
	getDay INT;
	
BEGIN 
	
	counter := 1;
	countCapacity := 0;
	addDate := sessionDate[counter];
	
	LOOP 
		IF sessionDate[counter] IS NULL THEN EXIT;
		END IF;
		
		addDate := sessionDate[counter];
		addStartHr := sessionStartHr[counter];
		addRoomId := roomId[counter];

		SELECT I.employeeId INTO addInstructorId
		FROM get_available_instructors(courseId, addDate, addDate) AS I
		WHERE I.selectedDay = addDate AND addStartHr = ANY (I.selectedHours)
		LIMIT 1;
		
		IF (addInstructorId IS NOT NULL) THEN
			IF (counter = 1) THEN 
				INSERT INTO CourseOfferings (courseId, launchDate, offeringId, courseFee, numRegistrations, registrationDeadline, employeeId, startDate, endDate, seatingCapacity, status)
				VALUES (courseId, launchDate, offeringId, courseFee, numTarget, registrationDeadline, adminId, 	sessionDate[1], sessionDate[1], 0, 'available');
			END IF;
			SELECT EXTRACT(DOW FROM addDate) INTO getDay;
			INSERT INTO CourseSessions(offeringId, launchDate, sessionId, sessDate, sessHour, employeeId, roomId,courseId, weekday)
			VALUES(offeringId, launchDate, counter, addDate, addStartHr, addInstructorId, addRoomId,courseId, getDay); 
			
			countCapacity := countCapacity + tempCap;

		ELSE 
			RAISE NOTICE 'Unable to find instructors! Course offering addition aborted.';
			ROLLBACK;
			EXIT;
		END IF;
		
		COUNTER := COUNTER + 1;
		
	END LOOP;
    
    IF (countCapacity < numTarget) THEN 
        RAISE NOTICE 'Current seating capacity of Course Offering is less than target number of registration!';
    END IF;

END;		
                                                 
$$ LANGUAGE plpgsql;

-- 11. add_course_packages //done
CREATE OR REPLACE PROCEDURE add_course_package (packageName TEXT, numSessions INT, startDate DATE, endDate DATE, price MONEY)
AS $$
		INSERT INTO CoursePackages (price, startDate, endDate, numSessions, packageName)
		VALUES (price, startDate, endDate, numSessions, packageName); 				 
$$ LANGUAGE SQL; 

-- 12.get_available_course_pacakages //donegit
CREATE OR REPLACE FUNCTION get_available_course_packages ()
RETURNS TABLE (packageName TEXT, numSessions INT, endDate DATE, price MONEY)
AS $$
DECLARE 
    curs CURSOR FOR (SELECT * FROM CoursePackages);
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        IF (r.startDate <= CURRENT_DATE AND r.endDate >= CURRENT_DATE) THEN
            packageName := r.packageName;
            numSessions := r.numSessions;
            endDate := r.endDate;
            price := r.price;
            RETURN NEXT;
        END IF;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;

--Function 13

create or replace procedure buy_course_package(
    customer INT, pid INT 
) AS $$
declare
    customerCC INT;
    newPackage INT;
    num_of_active_pactive INT;
	num_sessions INT;
begin
	select numSessions into num_sessions
	from CoursePackages
	where packageId = pid;
	
	insert into Purchases(customerId, packageId, purchaseDate, sessionsLeft)
	values(customer, pid, CURRENT_DATE, num_sessions);
END;
$$ language plpgsql;

--Function 14

create or replace function get_my_course_package(
    customer INT
) returns json AS $$
declare
    pid INT;
    pName text;
    purchase_date date;
    packagePrice money;
    numFreeSessions int;
    numNotRedeemed int;
    sess record;
    sessionInfo json[];
	courseName text;
	sessionDate date;
	sessionStartHour int;
    curs cursor for (
		select *
		from Redeems
		where customerId = customer
		order by sessionDate, sessionStartHour asc
	);
begin
    
 	
	-- Every customer can have only 1 active or partially active
	-- package so this is scalar
	select sessionsLeft, purchaseDate, packageId into numNotRedeemed, purchase_date, pid
	from Purchases
	where customer = CustomerId and sessionsLeft > 0;

	if (pid is null) then
		raise exception 'This customer has no package under his name!';
	else
		select packageName, price, numSessions into pName, packagePrice, numFreeSessions
		from CoursePackages
		where packageId = pid;

		OPEN curs;
		LOOP
			FETCH curs into sess;
			EXIT WHEN NOT FOUND;
			if (sess.packageId = pid) then
				sessionInfo = array_append(sessionInfo,
							 row_to_json(row(
								 courseName, sessionDate, sessionStartHour)
										)
							);
			end if;
		END LOOP;
		CLOSE curs;
		
		return json_build_object(
			'packageName', pName,
			'purchaseDate', purchase_date,
			'packagePrice', packagePrice,
			'numFreeSessions', numFreeSessions,
			'sessionsLeft', numNotRedeemed,
			'sessionInfo', sessionInfo
		);
	end if;

END;
$$ language plpgsql;

-- Function 15

create or replace function get_available_course_offerings()
returns table(
    cTitle text,
    cArea text,
    startingDate date,
    endDate date,
    registrationDeadline date,
    fee money,
    numRemainingSeats int
) as $$
declare
	curs CURSOR for (
		select *
		from CourseOfferings natural join Courses
		order by registrationDeadline, courseTitle asc
		
	);
    r record;
    totalRedeems int;
    totalPayment int;
    totalRegistrations int;
begin
    
    open curs;
    LOOP
		
        fetch curs into r;
        exit when not FOUND;

		select numEnrolled into totalRedeems
		from RedeemAttendance
		where r.courseId = courseId and r.offeringId = offeringId;
		
		select numEnrolled into totalPayment
		from PayAttendance
		where r.courseId = courseId and r.offeringId = offeringId;

        totalRegistrations = coalesce(totalPayment,0) + coalesce(totalRedeems,0);

        if (totalRegistrations < r.seatingCapacity) then
			
            select courseTitle, areaName into cTitle, cArea
            from Courses
            where r.courseId = courseId;

            startingDate := r.startDate;
            endDate := r.endDate;
            registrationDeadline := r.registrationDeadline;
            fee := r.courseFee;
            numRemainingSeats := r.seatingCapacity - totalRegistrations;
            return next;
		end if;
	end loop;
END;
$$ language plpgsql;

--function 16

create or replace function get_available_course_sessions(
	course_id int,
    course_offering_id INT
) returns table (
    sessionDate date,
    sessionStartHour int,
    instructorName text,
    numRemainingSeats int
) as $$
declare

    curs cursor for (
		select *
		from CourseSessions
		where course_offering_id = offeringId and courseId = course_id
		order by sessDate, sessHour asc
	);
    r record;
    remainingSeats int;
	totalRedemption int;
	totalPayment int;
	totalRegistrations int;
begin
    open curs;
    LOOP
        fetch curs into r;
        exit when not found;

        -- Count the total number of registrations for this
        -- particular CourseSession
        select count(redeemId) into totalRedemption
        from Redeems
        where r.courseId = courseId AND
        r.offeringId = offeringId AND
        r.sessDate = courseSessionDate AND
        r.sessHour = courseSessionHour;
		
		select count(paymentId) into totalPayment
        from Pays
        where r.courseId = courseId AND
        r.offeringId = offeringId AND
        r.sessDate = courseSessionDate AND
        r.sessHour = courseSessionHour;
		
		totalRegistrations = coalesce(totalPayment,0) + coalesce(totalRedemption,0);
		
        select seatingCapacity into remainingSeats
        from LectureRooms
        where r.roomId = roomId;

        if remainingSeats > totalRegistrations then
            sessionDate := r.sessDate;
            sessionStartHour := r.sessHour;
            numRemainingSeats := remainingSeats - totalRegistrations;

            select eName into instructorName
            from Employees e
            where e.employeeId = (
				select employeeId
				from CourseSessions cs
				where cs.sessDate = r.sessDate and cs.sessHour = r.sessHour and
				cs.courseId = r.courseId and cs.offeringId = r.offeringId
			);

            return next;
		end if;
	end loop;
END;
$$ language plpgsql;

--Function 17

create or replace procedure register_session(
    customer int, course_id int, offering_id int, sess_date date, sess_hour int, payment_method int
) as $$
declare
    customerPackageId int;
    alreadyRedeemedSessions int;
    purchase_date date;
    csDate date;
    csHour int;
begin
    
    
    if payment_method = 1 then
        select packageId, purchaseDate into customerPackageId, purchase_date
        from Purchases
        where  customerId = customer;

        insert into Redeems (customerId, packageId, redeemDate, purchaseDate, courseId, offeringId, courseSessionDate, courseSessionHour)
        values(customer, customerPackageId, CURRENT_DATE, purchase_date, course_id, offering_id, sess_date, sess_hour);
		
		update Purchases
		set sessionsLeft = sessionsLeft - 1
		where customerId = customer and packageId = customerPackageId;
                
    elseif payment_method = 0 then

        insert into Pays (customerId, courseId, offeringId, courseSessionDate, courseSessionHour, paymentDate)
        values(customer, course_id, offering_id, sess_date, sess_hour, CURRENT_DATE);
	else
		raise exception 'Incorrect parameters for payment method!';
	end if;
END;
$$ language plpgsql;

--Function 18

create or replace function get_my_registrations(
    customer INT
) returns table (
    course_name text,
    course_fee money,
    session_date date,
    session_start_hour int,
    session_duration int,
    instructor_name text
) as $$
declare
    cRedeems cursor for (
        select *
        from Redeems R
        where R.customerId = customer AND (
            R.courseSessionDate > CURRENT_DATE OR (R.courseSessionDate = CURRENT_DATE
			AND R.courseSessionHour >= extract(hour from CURRENT_TIME))
		)
        
	);
    cPays cursor for (
        select *
        from Pays P
        where P.customerId = customer AND (
            P.courseSessionDate > CURRENT_DATE OR (P.courseSessionDate = CURRENT_DATE
			AND P.courseSessionHour >= extract(hour from CURRENT_TIME))
		)
    );

    r record;

begin

    open cRedeems;
    loop
		raise notice 'Checking';
        fetch cRedeems into r;
        exit when not found;
        select courseTitle into course_name from Courses where r.courseId = courseId;
        select courseFee into course_fee from CourseOfferings where r.courseId = courseId and offeringId = r.offeringId;
        session_date := r.courseSessionDate;
        session_start_hour := r.courseSessionHour;
        select duration into session_duration from Courses where r.courseId = courseId;
		
		select eName into instructor_name
		from Employees
		where employeeId = (
			select employeeId
			from CourseSessions
			where r.courseId = courseId and offeringId = r.offeringId and
			r.courseSessionDate = sessDate and r.courseSessionHour = sessHour
			);
        return next;
	
	end loop;
    close cRedeems;
    open cPays;
    loop
		raise notice 'Checking2';
        fetch cPays into r;
        exit when not found;
        select courseTitle into course_name from Courses where r.courseId = courseId;
        select courseFee into course_fee from CourseOfferings where r.courseId = courseId and offeringId = r.offeringId;
        session_date := r.courseSessionDate;
        session_start_hour := r.courseSessionHour;
        select duration into session_duration from Courses where r.courseId = courseId;
		
        select eName into instructor_name
		from Employees
		where employeeId = (
			select employeeId
			from CourseSessions
			where r.courseId = courseId and offeringId = r.offeringId and
			r.courseSessionDate = sessDate and r.courseSessionHour = sessHour
			);
        return next;
	end loop;
    close cPays;

END;
$$ language plpgsql;

--idea for function 26
-- find inactive custoemrs by group by then sort by desc. the latest date must not be in the recent 6 months
-- then find their most recent 3 courses -> find the areas of these courses
-- use function 15 to find all available course offerings then use these courses area to sift through then return from there

--function 26

create or replace function promote_courses()
returns table (
    customer_id int,
    customer_name text,
    course_area text,
    course_id int,
    course_title text,
    launch_date date,
    registration_deadline date,
    fees money
) as $$
declare
    cur cursor for (
        with InactiveC as (
			select distinct customerId
			from Redeems r1
			where r1.customerId not in (
				select customerId
				from Redeems r2
				where r1.customerId = r2.customerId and
				(current_date - interval '6 months') <= r2.courseSessionDate
			)
			union
			select distinct customerId
			from Pays p1
			where p1.customerId not in (
				select customerId
				from Pays p2
				where p1.customerId = p2.customerId and
				(current_date - interval '6 months') <= p2.courseSessionDate
			)            
			order by customerId asc
		), InactivePackageCustomers as (
			select customerId, courseId, offeringId, courseSessionDate, courseSessionHour
			from InactiveC natural join Redeems
			order by customerId asc
		), InactivePayCustomers as (
			select customerId, courseId, offeringId, courseSessionDate, courseSessionHour
			from InactiveC natural join Pays
			order by customerId asc
		), InactiveCustomers as (
			select * from InactivePayCustomers
			union
			select * from InactivePackageCustomers
		), EmptyCustomers as (
			select C.customerId, R.courseId, R.offeringId, R.courseSessionDate, R.courseSessionHour
			from Customers C left outer join Redeems R on C.customerId = R.customerId
			where C.customerId not in (
				select distinct customerId
				from Redeems 
			) and C.customerId not in (
				select distinct customerId
				from Pays 
			)
			order by customerId asc
		)

		select customerId, courseId, offeringId, courseSessionDate, courseSessionHour
		from InactiveCustomers
		union
		select customerId, courseId, offeringId, courseSessionDate, courseSessionHour
		from EmptyCustomers
		order by customerId asc , courseSessionDate desc
	);

    r record;
	customer_name text;
    currentCustomer int;
    currentArea  text;
    courseOfferingArr int[];
    coursesArr int[];
	courseAreasArr text[];
    countCustomer int;
	i text;
	x int;
	b int;
begin

    currentCustomer = -1;
    open cur;
    loop
        fetch cur into r;
        exit when not found;

        if currentCustomer = r.customerId then

            if countCustomer < 3 then
                countCustomer = countCustomer + 1;

                if currentArea <> (select areaName from Courses where courseId = r.courseId) then
					select customerName into customer_name
						from Customers
						where r.customerId = customerId;
					
					select areaName into currentArea from Courses where courseId = r.courseId;
					
					return query (
					select case when true then r.customerId end customer_id,
						case when true then customer_name end customer_name,
						areaName as course_area,
						courseId as course_id,
						courseTitle as course_title, 
						launchDate as launch_date,
						registrationDeadline as registration_deadline,
						courseFee as fees
					from Courses natural join CourseOfferings
					where launchDate <= current_date and
						registrationDeadline >= current_date and
						areaName = currentArea
					order by registrationDeadline asc
					);
				end if;
			end if;
        else

            currentCustomer = r.customerId;
            countCustomer = 1;

            if r.courseId is null then
				currentArea = NULL;
				select customerName into customer_name
				from Customers
				where r.customerId = customerId;
				return query (
					select case when true then r.customerId end customer_id,
						case when true then customer_name end customer_name,
						areaName as course_area,
						courseId as course_id,
						courseTitle as course_title, 
						launchDate as launch_date,
						registrationDeadline as registration_deadline,
						courseFee as fees
					from Courses natural join CourseOfferings
					where launchDate <= current_date and
						registrationDeadline >= current_date
					order by registrationDeadline asc
				);
			else
				select customerName into customer_name
						from Customers
						where r.customerId = customerId;
					
				select areaName into currentArea from Courses where courseId = r.courseId;

				return query (
				select case when true then r.customerId end customer_id,
					case when true then customer_name end customer_name,
					areaName as course_area, courseId as course_id,
					courseTitle as course_title, 
					launchDate as launch_date,
					registrationDeadline as registration_deadline,
					courseFee as fees
				from Courses natural join CourseOfferings
				where launchDate <= current_date and
					registrationDeadline >= current_date and
					areaName = currentArea
				order by registrationDeadline asc
				);
            end if;
        end if;
	end loop;
	close cur;
end;
$$ language plpgsql;

-- 27
DROP FUNCTION IF EXISTS top_packages;
create or replace function top_packages(IN N integer)
RETURNS TABLE (packageId integer, numSessions integer, price money,
    startDate date, endDate date, numSold BIGINT) as $$
BEGIN
    RETURN QUERY (with TopN as
        (select distinct Purchases.packageId, count(Purchases.packageId) as numSold 
        from Purchases 
        where (EXTRACT(YEAR FROM purchaseDate) = date_part('year', CURRENT_DATE))
        group by Purchases.packageId
        order by numSold DESC
        limit N)
    , PackagesWithTopN as
        (select * from CoursePackages natural join TopN)
    select PackagesWithTopN.packageId, PackagesWithTopN.numSessions, 
        PackagesWithTopN.price, PackagesWithTopN.startDate, PackagesWithTopN.endDate, PackagesWithTopN.numSold
    from PackagesWithTopN
    where exists (
        select 1 
        from TopN
        where PackagesWithTopN.numSold = TopN.numSold
    ));
END;
$$ language plpgsql;

create or replace function view_manager_report()
returns table (
    manager_name text,
    num_managed_courses int,
    offering_ending_this_year int,
    net_registration_fee money,
    highest_course_title text[]
) as $$
declare
    cur cursor for (
        select employeeId, eName
        from Managers natural join Employees
        order by eName asc
    );

    r record;
    managedAreas text[];
    courseArr int[];
    offeringArr int[];
    i text;
    m int;
    n int;
    ccPayment money;
    redemptionPayment money;
	cancelledPayment money;
	totalAmount money;
    highestYet money;
    top_performing_courses text[];
	enrollment int;
begin
    
    open cur;
    loop
        fetch cur into r;
        exit when not found;
        
        net_registration_fee := 0.00;
        ccPayment = 0.00;
        redemptionPayment = 0.00;
        highestYet = 0;
		num_managed_courses := 0;
		manager_name := r.eName;
		offering_ending_this_year = 0;
		
        -- Array of areas managed by manager X
        managedAreas = array(
            select areaName
            from CourseAreas ca
            where ca.employeeId = r.employeeId
        );
        -- For each of the areas managed, loop
        foreach i in array managedAreas
        loop
            -- Array of courses corresponding to course area Y, managed by manager X
			raise notice 'Managed Area: %', i;
            courseArr = array (
                select courseId
                from Courses c
                where c.areaName = i
            );
            -- loop over every course of course area Y that is managed by manager X
            foreach m in array courseArr
            loop
				num_managed_courses := num_managed_courses + 1;
                offeringArr = array (
                    select offeringId
                    from CourseOfferings co
                    where co.courseId = m and extract(year from co.endDate) = extract(year from current_date) 
                );

                
                -- loop over every offering of course Z of course area Y that is managed by manager X
                foreach n in array offeringArr
                loop
					raise notice 'Manager ID: %', r.employeeId;
					raise notice 'Course ID: %', m;
					raise notice 'Offering ID: %', n;
					offering_ending_this_year := offering_ending_this_year + 1;
					
					select numEnrolled into enrollment
					from PayAttendance oa
					where oa.courseId = m and oa.offeringId = n;
                        
                    ccPayment := coalesce((
                        select courseFee * enrollment
                        from CourseOfferings co1
                        where co1.courseId = m and co1.offeringId = n
                        ), 0.00::money);
					
					-- This is summing of late cancellation (no refund)
					ccPayment := ccPayment + coalesce((
                        select sum(courseFee)
                        from CourseOfferings natural join Cancels
                        where courseId = m and offeringId = n and paymentMode = 'pays'
						and isEarlyCancellation = false
                        ), 0.00::money);
					
					-- This is summing of early cancellation (90% refund)
					ccPayment := ccPayment + coalesce((
                        select sum(courseFee - refundAmt)
                        from CourseOfferings natural join Cancels
                        where courseId = m and offeringId = n and paymentMode = 'pays'
						and isEarlyCancellation = true
                        ), 0.00::money);
						
                    redemptionPayment := coalesce((
                        select sum(price/numSessions)
                        from (Redeems natural join CoursePackages) as rp
                        where rp.courseId = m and rp.offeringId = n
                    ), 0.00::money);
					
					raise notice 'Redemption final amount: %', redemptionPayment;
					raise notice 'Payment final amount: %', ccPayment;
					
					-- This is summing up redemptions that were cancelled late
					-- because this is counting as one redemption
					
					redemptionPayment := redemptionPayment + coalesce((
                        select sum(price/numSessions)
                        from (Cancels natural join Purchases natural join CoursePackages) as cp
                        where cp.courseId = m and cp.offeringId = n and isEarlyCancellation = false
                    ), 0.00::money);
					
					totalAmount := ccPayment + redemptionPayment;
					
					net_registration_fee := net_registration_fee + totalAmount;
                    if totalAmount > highestYet then
                        highestYet = totalAmount;
                        top_performing_courses = array(
                            select coursetitle
                            from Courses c1
                            where c1.courseId = m
                        );
                    elseif totalAmount = highestYet then
                        top_performing_courses = array_append(top_performing_courses, (
                            select courseTitle
                            from Courses c1
                            where c1.courseId = m
                        ));
                    end if;
                end loop;
            end loop;
        end loop;
		highest_course_title := top_performing_courses;
		return next;
    end loop;
    close cur;
end;
$$ language plpgsql;


-- 19. update_course_session
DROP PROCEDURE IF EXISTS update_course_session;
create or replace procedure update_course_session(_customerId integer, _courseId integer, _offeringId integer, _courseSessionDate date,
    _courseSessionHour integer, newCourseSessionDate date, newCourseSessionHour integer, newSessionId integer)
as $$
DECLARE
    _roomId integer;
    _seatingCapacity integer;
    payingCustomers integer;
    redeemingCustomers integer;
    totalRegistered integer;
    checkPaymentMode integer;
BEGIN
    -- Get seating capacity of the lecture room 
    select roomId into _roomId from CourseSessions where courseId = _courseId and offeringId = _offeringId 
                and sessDate = newCourseSessionDate and sessHour = newCourseSessionHour;
    select seatingCapacity into _seatingCapacity from LectureRooms where roomId = _roomId;
    select count(customerId) into payingCustomers from Pays where courseId = _courseId and offeringId = _offeringId 
                and courseSessionDate = newCourseSessionDate and courseSessionHour = newCourseSessionHour;
    select count(customerId) into redeemingCustomers from Redeems where courseId = _courseId and offeringId = _offeringId 
                and courseSessionDate = newCourseSessionDate and courseSessionHour = newCourseSessionHour;
    totalRegistered := payingCustomers + redeemingCustomers;

    select 1 into checkPaymentMode from Redeems where customerId = _customerId and courseId = _courseId and offeringId = _offeringId 
        and courseSessionDate = _courseSessionDate and courseSessionHour = _courseSessionHour;
    
    -- Allow updating if seats are available
    IF totalRegistered >= _seatingCapacity THEN
		RAISE EXCEPTION 'There are no more available seats for this session.';
	ELSE
        If checkPaymentMode = 1 THEN
            -- Customer redeemed session
            update Redeems
            set sessDate = newCourseSessionDate, sessHour = newCourseSessionHour, redeemDate = CURRENT_DATE
            where customerId = customerId and courseId = courseId and offeringId = _offeringId
                and courseSessionDate = courseSessionDate and courseSessionHour = courseSessionHour;
        ELSE 
            -- Customer paid for session
            update Pays
            set courseSessionDate = newCourseSessionDate, courseSessionHour = newCourseSessionHour, paymentDate = CURRENT_DATE
            where customerId = _customerId and courseId = _courseId and offeringId = _offeringId
                and courseSessionDate = _courseSessionDate and courseSessionHour = _courseSessionHour;
        END IF;
    END IF;
END;
$$ language plpgsql;

-- 20. cancel_registration
DROP PROCEDURE IF EXISTS cancel_registration;
create or replace procedure cancel_registration(_customerId integer, _courseId integer, _offeringId integer)
as $$
    -- check if customer redeemed or paid for session
    -- check if current date < session date
    -- if valid, delete from TABLE
    -- handle refunds
DECLARE
    checkPaymentMode integer;
    _isEarlyCancellation boolean;
    _courseFee money;
    _courseSessionDate date;
    _courseSessionHour integer;
    _purchaseDate date;
    _packageId integer;
BEGIN
    -- check payment mode
    select 1 into checkPaymentMode from Redeems where customerId = _customerId and courseId = _courseId and offeringId = _offeringId;
    -- Get session details
    IF checkPaymentMode = 1 THEN 
        select courseSessionDate, courseSessionHour into _courseSessionDate, _courseSessionHour
        from Redeems
        where customerId = customerId and courseId = _courseId and offeringId = _offeringId;
    ELSE
        select courseSessionDate, courseSessionHour into _courseSessionDate, _courseSessionHour
        from Pays
        where customerId = _customerId and courseId = _courseId and offeringId = _offeringId;
    END IF;

    -- check if session is cancell early
    _isEarlyCancellation := FALSE;
    IF CURRENT_DATE <= _courseSessionDate - 7 THEN
        _isEarlyCancellation := TRUE;
    END IF; 

    -- Only cancel if current date is before session date
    IF CURRENT_DATE < _courseSessionDate THEN
        If checkPaymentMode = 1 THEN
            -- customer redeemed session
            delete from Redeems
            where customerId = _customerId and courseId = _courseId and offeringId = _offeringId
                and courseSessionDate = _courseSessionDate and courseSessionHour = _courseSessionHour;
            
            IF _isEarlyCancellation = TRUE THEN
                -- update his package only if cancelled 7 days before session date. 
                -- No need to check if current status is active or partially active
                -- because as long as sessionsLeft > 0, packageStatus will be active
                select purchaseDate, packageId into _purchaseDate, _packageId
                from PurchasesView 
                where customerId = _customerId and (packageStatus = 'active' or packageStatus = 'partially active');

                update Purchases
                set sessionsLeft = sessionsLeft + 1
                where customerId = _customerId and purchaseDate = _purchaseDate and packageId = _packageId;
                
                insert into Cancels (customerId, courseId, offeringId, sessDate, sessHour, cancellationTimestamp, paymentMode, isEarlyCancellation, refundAmt)
                values (_customerId, _courseId, _offeringId, _courseSessionDate, _courseSessionHour, CURRENT_TIMESTAMP, 'redeems', _isEarlyCancellation, null);
            ELSE 
                insert into Cancels (customerId, courseId, offeringId, sessDate, sessHour, cancellationTimestamp, paymentMode, isEarlyCancellation, refundAmt)
                values (_customerId, _courseId, _offeringId, _courseSessionDate, _courseSessionHour, CURRENT_TIMESTAMP, 'redeems', FALSE, null);
            END IF;
        ELSE
            -- Customer paid for session
            delete from Pays
            where customerId = _customerId and courseId = _courseId and offeringId = _offeringId
                and courseSessionDate = _courseSessionDate and courseSessionHour = _courseSessionHour;
            
            IF _isEarlyCancellation = TRUE THEN
                select courseFee into _courseFee from CourseOfferings where courseId = _courseId and offeringId = _offeringId;

                insert into Cancels (customerId, courseId, offeringId, sessDate, sessHour, cancellationTimestamp, paymentMode, isEarlyCancellation, refundAmt)
                values (_customerId, _courseId, _offeringId, _courseSessionDate, _courseSessionHour, CURRENT_TIMESTAMP, 'pays', TRUE, _courseFee * 0.9);
            ELSE 
                insert into Cancels (customerId, courseId, offeringId, sessDate, sessHour, cancellationTimestamp, paymentMode, isEarlyCancellation, refundAmt)
                values (_customerId, _courseId, _offeringId, _courseSessionDate, _courseSessionHour, CURRENT_TIMESTAMP, 'pays', FALSE, null);
            END IF;
        END IF;
    ELSE 
        RAISE EXCEPTION 'Cannot cancel a session that has already ended.';    
    END IF;
END;
$$ language plpgsql;

-- Q21. update_instructor
DROP PROCEDURE IF EXISTS update_instructor;
create or replace procedure update_instructor(_courseId integer, _offeringId integer, _courseSessionDate date, 
    _courseSessionHour integer, _newInstructorId integer)
as $$
BEGIN
    IF CURRENT_DATE >= _courseSessionDate THEN
		RAISE EXCEPTION 'Cannot update the instructor when the course session has already started.';
	ELSE
        update CourseSessions
        set employeeId = _newInstructorId
        where courseId = _courseId and offeringId = _offeringId and sessDate = _courseSessionDate and sessHour = _courseSessionHour;
    END IF;
END;
$$ language plpgsql;


-- Q22. update_room
DROP PROCEDURE IF EXISTS update_room;
create or replace procedure update_room(_courseId integer, _offeringId integer, _courseSessionDate date, 
    _courseSessionHour integer, _sessionId integer, _newRoomId integer)
as $$
DECLARE
    _seatingCapacity integer;
    payingCustomers integer;
    redeemingCustomers integer;
    totalRegistered integer;
BEGIN
    select seatingCapacity into _seatingCapacity from LectureRooms where roomId = _newRoomId;
    select count(customerId) into payingCustomers from Pays where courseId = _courseId and offeringId = _offeringId 
                and courseSessionDate = _courseSessionDate and courseSessionHour = _courseSessionHour;
    select count(customerId) into redeemingCustomers from Redeems where courseId = _courseId 
                and courseSessionDate = _courseSessionDate and courseSessionHour = _courseSessionHour;
    totalRegistered := payingCustomers + redeemingCustomers;

    IF _seatingCapacity < totalRegistered THEN
		Raise Exception 'Seating capacity of room is too small.';
	ELSEIF CURRENT_DATE >= _courseSessionDate THEN
		Raise Exception 'Current date is past session date';  
    ELSE 
        update CourseSessions
        set roomId = _newRoomId
        where courseId = _courseId and offeringId = _offeringId 
            and sessDate = _courseSessionDate and sessHour = _courseSessionHour and sessionId = _sessionId;
    END IF;
END;
$$ language plpgsql;

-- 23. remove_session
DROP PROCEDURE IF EXISTS remove_session;
create or replace procedure remove_session(_courseId integer, _offeringId integer, _courseSessionDate date, _courseSessionHour integer)
as $$
DECLARE
    payingCustomers integer;
    redeemingCustomers integer;
    totalRegistered integer;
BEGIN
    select count(customerId) into payingCustomers from Pays where courseId = _courseId and offeringId = _offeringId 
                and courseSessionDate = _courseSessionDate and courseSessionHour = _courseSessionHour;
    select count(customerId) into redeemingCustomers from Redeems where courseId = _courseId and offeringId = _offeringId 
                and courseSessionDate = _courseSessionDate and courseSessionHour = _courseSessionHour;
    totalRegistered := payingCustomers + redeemingCustomers;

    IF totalRegistered <> 0 THEN
		RAISE EXCEPTION 'Cannot remove a session that has registrations.';
	ELSEIF CURRENT_DATE >= _courseSessionDate THEN
		RAISE EXCEPTION 'Current date is past session date';
	ELSE
        delete from CourseSessions
        where courseId = courseId and offeringId = _offeringId  
            and sessDate = _courseSessionDate and sessHour = _courseSessionHour;
    END IF;
END;
$$ language plpgsql;

-- 24. add_session
create or replace procedure add_session(_courseId integer, _launchDate date, _offeringId integer,  _weekday integer, _courseSessionDate date, _courseSessionHour integer, _sessionId integer,
    _instructorId integer, _roomId integer)
as $$
DECLARE
    registDeadline date;
	sDate date;
    eDate date;
BEGIN
    select registrationDeadline, startDate, endDate into registDeadline, sDate, eDate from CourseOfferings where courseId = _courseId 
        and launchDate = _launchDate and offeringId = _offeringId;
 	
	IF registDeadline is NULL or sDate is NULL THEN
		RAISE EXCEPTION 'Course Offering not found.';
	END IF;
	
--     IF _courseSessionDate >= registDeadline + 10 THEN
        insert into CourseSessions (courseId, launchDate, offeringId, sessDate, sessHour, weekday, sessionId, employeeId, roomId)
        values (_courseId, _launchDate, _offeringId, _courseSessionDate, _courseSessionHour, _weekday, _sessionId, _instructorId, _roomId);
-- 	ELSE 
-- 		RAISE EXCEPTION 'Session date must be at least 10 days after registration deadline.';
--     END IF;

    IF _courseSessionDate < sDate THEN
        update CourseOfferings
        set startDate = _courseSessionDate
        where courseId = _courseId and launchDate = _launchDate;
    END IF;

    IF _courseSessionDate > eDate THEN
        update CourseOfferings
        set endDate = _courseSessionDate
        where courseId = _courseId and launchDate = _launchDate;
    END IF;
END;
$$ language plpgsql;

--28. popular_courses

CREATE OR REPLACE FUNCTION popular_courses () 
RETURNS TABLE (courseId INT, courseTitle TEXT, areaName TEXT, numOfferings INT, numRegistrations INT)
AS $$
DECLARE
	currYear INT;
	curs CURSOR FOR (SELECT * FROM Courses);
	r RECORD;
	temprow RECORD;
	countOfferings INT;
	countReg INT;
	prevReg INT;
	counter INT;
BEGIN
	currYear := (SELECT EXTRACT(YEAR FROM CURRENT_TIMESTAMP));
	OPEN curs;
	LOOP 
		FETCH curs INTO r;
		EXIT WHEN NOT FOUND;
		
		countOfferings := 0;
		prevReg := 0;
		
		SELECT COUNT(offeringId) INTO countOfferings
		FROM CourseOfferings co
		WHERE co.courseId = r.courseId AND currYear = EXTRACT(YEAR FROM co.launchDate);
		
		IF (countOfferings >= 2) THEN 
			counter := 0;
			FOR temprow IN 
				SELECT * 
				FROM CourseOfferings co LEFT JOIN CountRegistrations crg ON co.offeringId = crg.offeringId
				WHERE co.courseId = r.courseId AND currYear = EXTRACT(YEAR FROM co.startDate)
				ORDER BY co.startDate ASC
			LOOP
				IF (temprow.totalRegistration IS NULL OR temprow.totalRegistration <= prevReg) THEN
					EXIT;
				ELSE
					countReg := temprow.totalRegistration + prevReg;
					prevReg := temprow.totalRegistration;
					counter := counter + 1;
				END IF;
				
				IF (counter = countOfferings) THEN
					courseId := r.courseId;
					courseTitle := r.courseTitle;
					areaName := r.areName;
					numOfferings := countOfferings;
					numRegistrations := countReg;
					RETURN NEXT;
				END IF;
			END LOOP;
		END IF;
		
	END LOOP;
	CLOSE curs;
	
END;
$$ LANGUAGE plpgsql;

-------------------------------- TRIGGERS -----------------------------------

-- Trigger to capture the constraint that if a person is an employee, he has to be either a part-timer or full-timer,
-- and he has to be either a manager, administrator, or instructor.
create or replace function employee_check_function()
returns trigger as $$
begin
    if not (new.employeeId in (select employeeId from FullTimers)
        or new.employeeId in (select employeeId from PartTimers)) then
        raise exception 'New employee added, but not in either full-timers or part-timers table.';
    end if;

    if not (new.employeeId in (select employeeId from Managers)
        or new.employeeId in (select employeeId from Administrators)
        or new.employeeId in (select employeeId from Instructors)) then
        raise exception 'New employee added, but not in either managers, administrators, or instructors table.';
    end if;

    return null;
end;
$$ language plpgsql;

create constraint trigger employee_check_trigger
after insert or update on Employees
deferrable initially deferred
for each row execute function employee_check_function();

-- Trigger to capture the constraint that an employee is either a fulltimer or parttimer, but not both. 
create or replace function fulltimer_parttimer_function()
returns trigger as $$
begin
    if (new.employeeId in (select employeeId from FullTimers)) then
        raise exception 'Employee is already a fulltimer.';
        return null;
    end if;

    if (new.employeeId in (select employeeId from PartTimers)) then
        raise exception 'Employee is already a parttimer.';
        return null;
    end if;

    return new;
end;
$$ language plpgsql;

create trigger fulltimer_trigger
before insert or update on FullTimers
for each row execute function fulltimer_parttimer_function();

create trigger parttimer_trigger
before insert or update on PartTimers
for each row execute function fulltimer_parttimer_function();

-- Trigger to capture the constraint that an employee is either a manager, administrator, or instructor exclusively.
create or replace function manager_admin_instructor_function()
returns trigger as $$
begin
    if (new.employeeId in (select employeeId from Managers)) then
        raise exception 'Employee is already a manager.';
        return null;
    end if;

    if (new.employeeId in (select employeeId from Administrators)) then
        raise exception 'Employee is already an administrator.';
        return null;
    end if;

    if (new.employeeId in (select employeeId from Instructors)) then
        raise exception 'Employee is already an instructor.';
        return null;
    end if;

    return new;
end;
$$ language plpgsql;

create trigger manager_trigger
before insert or update on Managers
for each row execute function manager_admin_instructor_function();

create trigger admin_trigger
before insert or update on Administrators
for each row execute function manager_admin_instructor_function();

create trigger instructor_trigger
before insert or update on Instructors
for each row execute function manager_admin_instructor_function();

-- Trigger to capture the constraint that managers and administrators have to be full-timers.
create or replace function manager_admin_fulltimer_function()
returns trigger as $$
begin
    if (new.employeeId not in (select employeeId from FullTimers)) then
        raise exception 'Managers and administrators have to be full-timers.';
        return null;
    end if;

    return new;
end;
$$ language plpgsql;

create trigger manager_fulltimer_trigger
before insert or update on Managers
for each row execute function manager_admin_fulltimer_function();

create trigger admin_fulltimer_trigger
before insert or update on Administrators
for each row execute function manager_admin_fulltimer_function();


--Trigger to ensure course offering start and end date attributes match sessions start and end dates

CREATE OR REPLACE FUNCTION offering_dates_func() RETURNS TRIGGER 
AS $$
DECLARE 
	oldStart DATE;
	oldEnd DATE;
	nextStart DATE;
	nextEnd DATE;
	
BEGIN
	SELECT startDate, endDate INTO oldStart, oldEnd
	FROM CourseOfferings 
	WHERE offeringId = NEW.offeringId;
	
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN 

        IF (oldStart > NEW.sessDate) THEN
            UPDATE CourseOfferings
            SET startDate = NEW.sessDate 
            WHERE courseId = new.courseId and offeringId = NEW.offeringId;
        END IF;

        IF (oldEnd < NEW.sessDate) THEN
            UPDATE CourseOfferings
            SET endDate = NEW.sessDate 
            WHERE courseId = new.courseId and offeringId = NEW.offeringId;
        END IF;
		
	ELSIF (TG_OP = 'DELETE') THEN 
		IF (OLD.sessDate = oldStart) THEN
		
			SELECT sessDate INTO nextStart
			FROM CourseSessions
            WHERE offeringId = OLD.offeringId AND sessDate <> oldStart
			ORDER BY sessDate ASC
			LIMIT 1;
			
			UPDATE CourseOfferings 
			SET startDate = nextStart 
			WHERE courseId = cid;
			
		END IF;
		IF (OLD.sessDate = oldEnd) THEN
		
			SELECT sessDate INTO nextEnd
			FROM CourseSessions 
            WHERE offeringId = OLD.offeringId AND sessDate <> oldEnd
			ORDER BY sessDate DESC
			LIMIT 1;
			
			UPDATE CourseOfferings 
			SET endDate = nextEnd 
			WHERE courseId = cid;
			
		END IF;	
	END IF;
	RETURN NEW;
	
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER offering_dates_trigger
AFTER INSERT OR UPDATE OR DELETE ON CourseSessions
FOR EACH ROW EXECUTE FUNCTION offering_dates_func();

-- Trigger to update seating capacity od course offering and the sessions

CREATE OR REPLACE FUNCTION update_seatingcapacity_func() RETURNS TRIGGER 
AS $$
DECLARE
	newSeats INT;
	oldSeats INT;
	calSeats INT;
	currSeats INT;
	currReg INT;
BEGIN

	SELECT lr.seatingCapacity INTO newSeats
	FROM CourseSessions cs INNER JOIN LectureRooms lr ON cs.roomId = lr.roomId
	WHERE cs.courseId = NEW.courseId;
	
	SELECT lr.seatingCapacity INTO oldSeats
	FROM CourseSessions cs INNER JOIN LectureRooms lr ON cs.roomId = lr.roomId
	WHERE cs.courseId = OLD.courseId;
	
 
	
	SELECT totalRegistration INTO currReg
	FROM CountRegistrations r
	WHERE r.offeringId = NEW.offeringId;
		
	IF (TG_OP = 'INSERT') THEN 
		SELECT seatingCapacity INTO currSeats
		FROM CourseOfferings co
		WHERE co.offeringId = NEW.offeringId;
		
		calSeats := currSeats + newSeats;
		UPDATE CourseOfferings co
		SET seatingCapacity = calSeats
		WHERE co.courseId = NEW.courseId;
	ELSEIF (TG_OP = 'UPDATE') THEN 
		SELECT seatingCapacity INTO currSeats
		FROM CourseOfferings co
		WHERE co.offeringId = NEW.offeringId;
		
		calSeats := currSeats - oldSeats + newSeats;
		IF (calSeats < currReg) THEN 
			RAISE EXCEPTION 'Unable to update Course Sessions as number of registrations is more than seating capacity of Course Offering.';
			RETURN NULL;
		END IF;
		UPDATE CourseOfferings co
		SET seatingCapacity = calSeats
		WHERE co.couseId = NEW.courseId;	
	ELSEIF (TG_OP='DELETE') THEN
		SELECT seatingCapacity INTO currSeats
		FROM CourseOfferings co
		WHERE co.offeringId = OLD.offeringId;
		
		calSeats := currSeats - oldSeats;
		IF (calSeats < currReg) THEN 
			RAISE EXCEPTION 'Unable to delete Course Sessions as number of registrations is more than seating capacity of Course Offering.';
			RETURN NULL;
		END IF;
		UPDATE CourseOfferings co
		SET co.seatingCapacity = calSeats
		WHERE couseId = OLD.courseId;	
	END IF;
	RETURN NEW;
	
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER update_seatingcapacity_trigger
AFTER INSERT OR UPDATE OR DELETE ON CourseSessions
FOR EACH ROW EXECUTE FUNCTION update_seatingcapacity_func();

/*
-- Trigger to ensure registration deadline is 10 days before start date

CREATE OR REPLACE FUNCTION regDeadline_offering_func() RETURNS TRIGGER 
AS $$
DECLARE
	calDate DATE;
	
BEGIN
	calDate := (SELECT NEW.startDate - INTERVAL '10 days');
	If (calDate < NEW.registrationDeadline) THEN
		RAISE NOTICE 'Registration deadline should be 10 days before start date. Amendments made.';
		NEW.registrationDeadline := calDate;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER regDeadline_offering_trigger
BEFORE INSERT OR UPDATE ON CourseOfferings 
FOR EACH ROW EXECUTE FUNCTION regDeadline_offering_func();
*/
CREATE OR REPLACE FUNCTION parttimers_hours_func() RETURNS TRIGGER
AS $$
DECLARE
	totalHrs INT;
	newHrs INT;
	oldHrs INT;
	selectedMonth INT;
	selectedYear INT;
	
BEGIN
	
	IF EXISTS (SELECT 1 FROM PartTimers pt WHERE pt.employeeId = NEW.employeeId) THEN 
		selectedMonth := EXTRACT(MONTH FROM NEW.sessDate);
		selectedYear := EXTRACT(YEAR FROM NEW.sessDate);

		SELECT SUM(cr.duration) INTO totalHrs
		FROM Courses cr NATURAL JOIN CourseOfferings co NATURAL JOIN CourseSessions cs
		WHERE cs.employeeId = NEW.employeeId AND selectedMonth = EXTRACT(MONTH FROM cs.sessDate)
		AND selectedYear = EXTRACT(YEAR FROM cs.sessDate);
		
		SELECT duration INTO newHrs
		FROM Courses cr 
		WHERE cr.courseId = NEW.courseId;
		
		IF (TG_OP = 'INSERT') THEN 
			IF (totalHrs + newHrs > 30) THEN 
				RAISE EXCEPTION 'Part Timer working hours will exceed 30 hours this month!';
				RETURN NULL;
			END IF;
			
		ELSIF (TG_OP = 'UPDATE') THEN
			SELECT duration INTO oldhrs
			FROM Courses cr 
			WHERE cr.courseId = OLD.courseId;
			
			IF (totalHrs - oldHrs + newHrs > 30) THEN 
				RAISE EXCEPTION 'Part Timer working hours exceed 30 hours this month!';
				RETURN NULL;
			END IF;
		END IF;
        RETURN NEW;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER parttimers_hours_tigger
BEFORE INSERT OR UPDATE ON CourseSessions
FOR EACH ROW EXECUTE FUNCTION parttimers_hours_func();

CREATE OR REPLACE FUNCTION check_instructor_hours_func() RETURNS TRIGGER 
AS $$
DECLARE
	selectedDate DATE;
	startHr INT;
	endHr INT;
	teachingDuration INT;
	counter INT;
	
BEGIN
	selectedDate := NEW.sessDate;
	startHr := NEW.sessHour;
	SELECT duration INTO teachingDuration
	FROM Courses
	WHERE courseId = NEW.courseId;
	endHr := startHr + teachingDuration;
	counter := startHr - 1;
	LOOP
		IF EXISTS (SELECT 1 FROM CourseSessions cs WHERE cs.employeeId = NEW.employeeId 
						   AND cs.sessDate = NEW.sessDate AND cs.sessHour = counter) THEN 
			RAISE EXCEPTION 'Instructor unavailable';
			RETURN NULL;
		END IF;
		counter := counter + 1;
		
		IF (counter > endHr + 1) THEN 
		RETURN NEW;
		END IF;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER instructor_hours_trigger
BEFORE INSERT OR UPDATE ON CourseSessions
FOR EACH ROW EXECUTE FUNCTION check_instructor_hours_func();

-- Trigger to check session timings
CREATE OR REPLACE FUNCTION check_sessiontimings_func() RETURNS TRIGGER
AS $$
DECLARE
	teachingDuration INT;
	startTime INT;
	endTime INT;
	counter INT;
BEGIN
	startTime := NEW.sessHour;
	SELECT duration INTO teachingDuration
	FROM Courses
	WHERE courseId = NEW.courseId;
	endTime := startTime + teachingDuration;
	counter := startTime;
	-- raise notice 'Start time is: %', startTime;
	-- raise notice 'End time is: %', endTime;
	
	if (startTime < 9 or startTime > 17) then
		raise exception 'Unsuitable start/end timing';
	elseif (startTime = 12 or startTime = 13) then
		raise exception 'Sessions are not allowed to be held between 12pm-2pm';
	elseif (startTime < 12 and endTime > 12) then
		raise exception 'Sessions cannot extend past 12pm.';
	else
		return new;
	end if;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER check_sessiontimings_trigger
BEFORE INSERT OR UPDATE ON CourseSessions
FOR EACH ROW EXECUTE FUNCTION check_sessiontimings_func();

-- Trigger to check that lecture room holds 1 session at a time

CREATE OR REPLACE FUNCTION check_room_hours_func() RETURNS TRIGGER 
AS $$
DECLARE
	selectedDate DATE;
	startHr INT;
	endHr INT;
	teachingDuration INT;
	counter INT;
	
BEGIN
	selectedDate := NEW.sessDate;
	startHr := NEW.sessHour;
	SELECT duration INTO teachingDuration
	FROM Courses
	WHERE courseId = NEW.courseId;
	endHr := startHr + teachingDuration;
	counter := startHr;
	LOOP
		IF EXISTS (SELECT 1
				   FROM LectureRooms lr INNER JOIN CourseSessions cs ON lr.roomId = cs.roomId
				   WHERE lr.roomId = NEW.roomId 
					AND cs.sessDate = NEW.sessDate AND cs.sessHour = counter) THEN 
			RAISE EXCEPTION 'Lecture room unavailable.';
			RETURN NULL;
		END IF;
		counter := counter + 1;
		
		IF (counter > endHr) THEN 
		RETURN NEW;
		END IF;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER room_hours_trigger
BEFORE INSERT OR UPDATE ON CourseSessions
FOR EACH ROW EXECUTE FUNCTION check_room_hours_func();


-- Trigger to take care of offering id sequence

CREATE OR REPLACE FUNCTION set_offeringId_func() RETURNS TRIGGER
AS $$
DECLARE
	currMaxId INT;
	newId INT;
BEGIN
	SELECT MAX(offeringId) INTO currMaxId
	FROM CourseOfferings;
	
	newId = currMaxId +1;
	
	IF (NEW.offeringId <> newId) THEN
		SET NEW.offeringId = newId;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER offeringId_trigger 
BEFORE INSERT ON CourseOfferings
FOR EACH ROW EXECUTE FUNCTION set_offeringId_func();

-- Trigger to take care of session id sequence

CREATE OR REPLACE FUNCTION set_sessionId_func() RETURNS TRIGGER
AS $$
DECLARE
	currMaxId INT;
	newId INT;
BEGIN
	SELECT MAX(sessionId) INTO currMaxId
	FROM CourseSessions;
	
	newId = currMaxId +1;
	
	IF (NEW.sessionId <> newId) THEN
		SET NEW.sessionId = newId;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER sessionId_trigger 
BEFORE INSERT ON CourseSessions
FOR EACH ROW EXECUTE FUNCTION set_sessionId_func();

--------------------------- Trigger to limit 1 active/partially active packages in Purchases --------------

DROP TRIGGER IF EXISTS limit_oneActiveOrPartiallyActive_trigger ON Purchases;
DROP FUNCTION IF EXISTS packageStatus_oneActiveOrPartiallyActive;
create or replace function packageStatus_oneActiveOrPartiallyActive()
returns trigger as $$
DECLARE
    activePackages integer;
    partiallyActivePackages integer;
BEGIN
    select count(packageStatus) into activePackages from PurchasesView where customerId = NEW.customerId 
        and packageStatus = 'active';
    select count(packageStatus) into partiallyActivePackages from PurchasesView where customerId = NEW.customerId 
        and packageStatus = 'partially active';
 
    IF activePackages >= 1 or partiallyActivePackages >= 1 THEN
        IF NEW.sessionsLeft = 0 THEN
        -- Only allow insertion of inactive packages 
            RETURN NEW;
        ELSE
            -- If TG_OP is update
            IF OLD.sessionsLeft = 0 and NEW.sessionsLeft > 0 THEN
                -- When active/partially packages already exists 
                -- and trying to update an inactive package to active/partially active
                RAISE EXCEPTION 'Customer can only have 1 active or partially active packages!';
            ELSIF OLD.sessionsLeft > 0 THEN
                RETURN NEW;
            END IF;
        END IF;
        RAISE EXCEPTION 'Customer can only have 1 active or partially active packages!';
    END IF;
    RETURN NEW;
END;
$$ language plpgsql;
 
create trigger limit_oneActiveOrPartiallyActive_trigger
BEFORE INSERT OR UPDATE ON Purchases
for each row execute function packageStatus_oneActiveOrPartiallyActive();

/*
------------------------- Triggers to prevent duplicates in Pays and Redeems

DROP TRIGGER IF EXISTS Redeems_checkDuplicateInPays_trigger on Redeems;
DROP FUNCTION IF EXISTS Redeems_checkDuplicateInPays;

create or replace function Redeems_checkDuplicateInPays()
returns trigger as $$
DECLARE
    existsInPays integer;
BEGIN
    select 1 into existsInPays
    from Pays
    where courseId = NEW.courseId and offeringId = NEW.offeringId 
        and courseSessionDate = NEW.courseSessionDate and courseSessionHour = NEW.courseSessionHour;

    IF existsInPays = 1 THEN
        RAISE EXCEPTION 'Customer has already paid for this course session.';
    ELSE
        RETURN NEW;
    END IF; 
END;
$$ language plpgsql;

create trigger Redeems_checkDuplicateInPays_trigger
BEFORE INSERT OR UPDATE ON Redeems
for each row execute function Redeems_checkDuplicateInPays();

DROP TRIGGER IF EXISTS Pays_checkDuplicateInRedeems_trigger on Pays;
DROP FUNCTION IF EXISTS Pays_checkDuplicateInRedeems;
create or replace function Pays_checkDuplicateInRedeems()
returns trigger as $$
DECLARE
    existsInPays integer;
BEGIN
    select 1 into existsInPays
    from Redeems
    where courseId = NEW.courseId and offeringId = NEW.offeringId 
        and courseSessionDate = NEW.courseSessionDate and courseSessionHour = NEW.courseSessionHour;

    IF existsInPays = 1 THEN
        RAISE EXCEPTION 'Customer has already redeemed this course session.';
    ELSE
        RETURN NEW;
    END IF; 
END;
$$ language plpgsql;

create trigger Pays_checkDuplicateInRedeems_trigger
BEFORE INSERT OR UPDATE ON Pays
for each row execute function Pays_checkDuplicateInRedeems();
*/


create or replace function redeem_session_check() returns trigger as $$
declare
    customerPackageId int;
    pStatus text;
BEGIN
    if NEW.customerId not in (select customerId from Customers) then
        raise exception 'Customer does not exist';
	elseif (select courseId from Courses where new.courseId = courseId) is null then
		raise exception 'Course does not exist';
    elseif (select count(courseId) from CourseOfferings where courseId = NEW.courseId and NEW.offeringId = offeringId)  != 1 then
        raise exception 'CourseOffering does not exist';
    elseif not(row(NEW.courseSessionDate, new.courseSessionHour) in (select sessDate, sessHour from CourseSessions where courseId = NEW.courseId and NEW.offeringId = offeringId)) then
        raise exception 'This session does not exist';
    elseif exists (select 1 from Redeems where NEW.customerId = customerId and courseId = NEW.courseId and NEW.offeringId = offeringId) then
        raise exception 'Customer already has an existing redemption of this offering' ;
    elseif exists (select 1 from Pays where NEW.customerId = customerId and courseId = NEW.courseId and NEW.offeringId = offeringId) then
        raise exception 'Customer has already paid for a session in this course offering';
	elseif (select sessionsLeft from Purchases where NEW.customerId = customerId and new.packageId = packageId) = 0 then
        raise exception 'This customer has no more sessions left in his package!';
	elseif current_date > (select registrationDeadline from CourseOfferings where new.courseId = courseId and new.offeringId = offeringId) then
		raise exception 'The registration deadline for this course has passed!';
	elseif current_date < (select launchDate from CourseOfferings where new.courseId = courseId and new.offeringId = offeringId) then
		raise exception 'The registration for this course has not started yet!';
    else
		return new;
	end if;
	
END;

$$ language plpgsql;

create or replace function pay_session_check() returns trigger as $$
declare
    customerPackageId int;
    pStatus text;
BEGIN
    if NEW.customerId not in (select customerId from Customers) then
        raise exception 'Customer does not exist';
	elseif (select courseId from Courses where new.courseId = courseId) is null then
		raise exception 'Course does not exist';
    elseif (select count(courseId) from CourseOfferings where courseId = NEW.courseId and NEW.offeringId = offeringId)  != 1 then
        raise exception 'CourseOffering does not exist';
    elseif not(row(NEW.courseSessionDate, new.courseSessionHour) in (select sessDate, sessHour from CourseSessions where courseId = NEW.courseId and NEW.offeringId = offeringId)) then
        raise exception 'This session does not exist';
    elseif exists (select 1 from Redeems where NEW.customerId = customerId and courseId = NEW.courseId and NEW.offeringId = offeringId) then
        raise exception 'Customer already has an existing redemption of this offering' ;
    elseif exists (select 1 from Pays where NEW.customerId = customerId and courseId = NEW.courseId and NEW.offeringId = offeringId) then
        raise exception 'Customer has already paid for a session in this course offering';
--  	elseif current_date > (select registrationDeadline from CourseOfferings where new.courseId = courseId and new.offeringId = offeringId) then
--  		raise exception 'The registration deadline for this course has passed!';
--  	elseif current_date < (select launchDate from CourseOfferings where new.courseId = courseId and new.offeringId = offeringId) then
--  		raise exception 'The registration for this course has not started yet!';
    else
		return new;
	end if;
	
END;

$$ language plpgsql;

create or replace function check_customer_packages_exists() returns trigger as $$
declare
	cid int;
 	customerCC text;
 	newPackage int;
 	num_of_active_pactive int;
	start_date date;
	end_date date;
begin
     -- Check if customer already exists
     select customerId into cid
     from Customers
     where new.customerId = customerId;

     -- check if customer credit card already exists
     select ccNumber into customerCC
     from Owns
     where customerid = new.customerId;

     --check if package already exists
     select packageId, startDate, endDate into newPackage, start_date, end_date
     from CoursePackages
     where packageId = new.packageId;
    
     --check constraint "Each customer can have at most one active or partially active package."
     select count(customerid) into num_of_active_pactive
     from Purchases
     where customerId = new.customerId AND sessionsLeft > 0;

     if (customerCC is null) or (newPackage is null) or (cid is null)  then
         raise exception 'Invalid details given';
	elseif num_of_active_pactive > 0 then
	 	raise exception 'Customer already has an active/ partially active package';
	elseif current_date < start_date then
		raise exception 'This package is not for sale yet!';
	elseif CURRENT_DATE > end_date then
		raise exception 'This package is no longer for sale!';
	end if;
	 return new;
end;
$$ language plpgsql;

create trigger for_session_redeem_check
before insert or update on Redeems
for each row execute function redeem_session_check();

create trigger for_session_pay_check
before insert or update on Pays
for each row execute function pay_session_check();

create trigger for_buying_package_check
before insert on Purchases
for each row execute function check_customer_packages_exists();

create or replace function session_instructor_specialises_check() returns trigger as $$
declare
    instructorId int;
    _areaName text;
BEGIN
	select areaName into _areaName from Courses where courseId = NEW.courseId;
    
	if NEW.employeeId not in (select employeeId from Instructors) then
        raise exception 'Instructor does not exist';
	elseif (select 1 from Specialises where areaName = _areaName and employeeId = NEW.employeeId) is null then
		raise exception 'The instructor does not teach this course area';
    else
		return new;
	end if;
END;
$$ language plpgsql;

create trigger session_instructor_specialises_check_trigger
before insert or update on CourseSessions
for each row execute function session_instructor_specialises_check();
