drop table if exists LectureRooms , Employees , FullTimers ,PartTimers, Administrators, Managers,Instructors, CourseAreas, Courses,
CourseOfferings , CourseSessions, Customers, Owns, CreditCards, CoursePackages, Purchases, Pays, Redeems, FTSalaries, PTSalaries, 
Specialises, Cancels cascade; 

----------------------- EMPLOYEES AND SALARIES -----------------------

create table Employees (
	employeeId 				integer generated always as identity,
	ename 					text not null,
	homeAddress				text not null,
	contactNumber			integer unique not null,
	email 					text unique not null,
	joinDate 				date not null,
	departDate 				date,
	primary key (employeeId),
	constraint email_validity check (email LIKE '%@%.%' AND email NOT LIKE '@%' AND email NOT LIKE '%@%@%')

);

create table FullTimers (
	employeeId 				integer,
	monthlySalary			money not null,
	primary key (employeeId),
	foreign key (employeeId) references Employees (employeeId) on delete cascade on update cascade
);

create table PartTimers (
	employeeId 				integer,
	hourlyRate 				money not null,
	primary key (employeeId),
	foreign key (employeeId) references Employees (employeeId) on delete cascade on update cascade
);

create table Managers (
	employeeId 				integer,
	primary key (employeeId),
	foreign key (employeeId) references FullTimers (employeeId) on delete cascade on update cascade
);

create table Administrators (
	employeeId 				integer,
	primary key (employeeId),
	foreign key (employeeId) references FullTimers (employeeId) on delete cascade on update cascade
);

create table Instructors (
	employeeId 				integer,
	primary key (employeeId),
	foreign key (employeeId) references Employees (employeeId) on delete cascade on update cascade
);

create table FTSalaries (
	employeeId				integer,
	paymentDate 			date,
	numDays 				integer not null,
	salaryAmount 			money not null,
	primary key (employeeId, paymentDate),
	foreign key (employeeId) references FullTimers (employeeId) on delete cascade
);

create table PTSalaries (
	employeeId				integer,
	paymentDate 			date,
	numHours 				integer not null,
	salaryAmount 			money not null,
	primary key (employeeId, paymentDate),
	foreign key (employeeId) references PartTimers (employeeId) on delete cascade
);

-------------------------------- COURSES --------------------------------

create table LectureRooms (
	roomId 					integer generated always as identity,
	seatingCapacity			integer not null, 
	roomNumber 				integer not null, 
	roomFloor 				integer not null, 
	primary key (roomId),
	unique (roomNumber, roomFloor)
);

create table CourseAreas (
	areaName				text,
	employeeId				integer not null,
	primary key (areaName),
	foreign key (employeeId) references Managers (employeeId)
);

create table Specialises (
	employeeId				integer,
	areaName				text,
	primary key (employeeId, areaName),
	foreign key (employeeId) references Instructors (employeeId),
	foreign key (areaName) references CourseAreas (areaName)
);

create table Courses (
	courseId				integer generated always as identity,
	courseTitle				text unique not null,
	description				text not null,
	areaName				text not null,
	duration				integer not null,
	primary key (courseId),
	foreign key (areaName) references CourseAreas (areaName)
);


create table CourseOfferings (
	courseId				integer,
	launchDate				date,
	offeringId				integer not null,
	courseFee				money not null,
	numRegistrations		integer not null,
	registrationDeadline	date not null,
	employeeId				integer not null,
	startDate				date not null,
	endDate					date not null,
	seatingCapacity			integer not null,
	status					text not null check (status in ('available', 'fully booked')),
	primary key (courseId, offeringId),
	unique (courseId, launchDate),
	foreign key (courseId) references Courses (courseId) on delete cascade on update cascade,
	foreign key (employeeId) references Administrators (employeeId)
);

create table CourseSessions (
	courseId 				integer,
	launchDate 				date, 
	offeringId              integer,
	sessDate 				date,
	sessHour 				integer,
	weekday 				integer not null,
	sessionId 				integer not null, 
	employeeId				integer not null, 
	roomId 					integer not null,
	primary key (courseId, offeringId, sessDate, sessHour),
	unique (courseId, launchDate, sessionId),
	foreign key (courseId, offeringId) references CourseOfferings (courseId, offeringId) on delete cascade on update cascade,
	foreign key (employeeId) references Instructors (employeeId) on update cascade,
	foreign key (roomId) references LectureRooms (roomId) on update cascade,
	constraint weekday_validity check (weekday in (1,2,3,4,5)),
	constraint sessHour_validity check ((sessHour>=9) and (sessHour <=17) and (sessHour <> 12) and (sessHour <> 1))
);

create table CoursePackages (
	packageId				integer generated always as identity,
	packageName				text not null,
	numSessions				integer not null,
	startDate				date not null,
	endDate					date not null,
	price					money not null,
	primary key (packageId),
	constraint session_validity check (numSessions > 0),
	constraint date_validity check (startDate < endDate),
	constraint price_validity check (price > cast(0.00 as money))
);

----------------------------- CUSTOMERS -----------------------------

create table Customers (
	customerId 				integer generated always as identity,
	customerName 			text not null,
	address 				text not null,
	contactNum 				integer unique not null,
	email 					text unique not null,
	primary key (customerId),
	constraint email_validity check (email LIKE '%@%.%' AND email NOT LIKE '@%' AND email NOT LIKE '%@%@%')
);

create table CreditCards (
	ccNumber 				text,
	ccExpiryDate 			date not null,
	ccCVV 					text not null,
	primary key (ccNumber)
);

create table Owns (
	customerId 				integer,
	ccNumber 				text not null,
	primary key (customerId),
	foreign key (customerId) references Customers (customerId),
	foreign key (ccNumber) references CreditCards (ccNumber)
);

create table Purchases (
	customerId				integer,
	packageId				integer,
	purchaseDate			date,
	sessionsLeft			integer not null,
	primary key (customerId, packageId, purchaseDate),
	foreign key (customerId) references Customers (customerId),
	foreign key (packageId) references CoursePackages (packageId),
	constraint session_validity check (sessionsLeft >= 0)
);

create table Pays (
	paymentId				integer generated always as identity,
	customerId				integer,
	courseId				integer,
	offeringId				integer,
	courseSessionDate		date,
	courseSessionHour		integer,
	paymentDate 			date not null,
	primary key (paymentId, customerId, courseId, offeringId, courseSessionDate, courseSessionHour),
	foreign key (customerId) references Customers (customerId),
	foreign key (courseId, offeringId, courseSessionDate, courseSessionHour) references CourseSessions (courseId, offeringId, sessDate, sessHour)
);

create table Redeems (
	redeemId 				integer generated always as identity,
	customerId 				integer,
	packageId 				integer,
	purchaseDate 			date,
	courseId 				integer,
	offeringId 				integer,
	courseSessionDate 		date,
	courseSessionHour 		integer,
	redeemDate 				date not null,
	primary key (redeemId, customerId, packageId, purchaseDate, courseId, offeringId, courseSessionDate, courseSessionHour),
	foreign key (customerId, packageId, purchaseDate) references Purchases (customerId, packageId, purchaseDate),
	foreign key (courseId, offeringId, courseSessionDate, courseSessionHour) references CourseSessions (courseId, offeringId, sessDate, sessHour)
);

create table Cancels (
    customerId 				integer,
	courseId 				integer,
	offeringId 				integer,
	sessDate 				date,
	sessHour 				integer,
    cancellationTimestamp 	timestamp,
	paymentMode 			text not null,
    isEarlyCancellation 	boolean not null,
    refundAmt 				money,
    primary key (customerId, courseId, offeringId, sessDate, sessHour, cancellationTimestamp),
	foreign key (customerId) references Customers (customerId),
	foreign key (courseId, offeringId, sessDate, sessHour) references CourseSessions(courseId, offeringId, sessDate, sessHour),
	constraint paymentMode_validity check (paymentMode in ('redeems', 'pays')),
    constraint refund_validity check (paymentMode <> 'pays' or isEarlyCancellation = false or refundAmt is not null)
);

----------------------------- VIEWS -----------------------------

create or replace view RedeemAttendance (courseId, offeringId, numEnrolled) as
	select courseId, offeringId, count(*)
	from Redeems
	group by courseId, offeringId;

create or replace view PayAttendance (courseId, offeringId, numEnrolled) as
	select courseId, offeringId, count(*)
	from Pays
	group by courseId, offeringId;

create or replace view OfferingCapacity (courseId, offeringId, totalCapacity) as
	select courseId, offeringId, sum(seatingCapacity)
	from CourseOfferings
	group by courseId, offeringId;

create or replace view CourseAttendance (courseId, totalAttendance) as
	with UnionAttendance as (
		select * from RedeemAttendance
		union
		select * from PayAttendance
	)
	select courseId, sum(numEnrolled)
	from UnionAttendance
	group by courseId;


create view CountRegistrations(offeringId, totalRegistration) AS
    select offeringId, count(*) as totalRegistration
    FROM CourseOfferings NATURAL JOIN Redeems NATURAL JOIN Pays
    GROUP BY offeringId;

create or replace view PurchasesView as
with package_with_status as
(select packageId, case 
    when max(courseSessionDate) < (CURRENT_DATE + 7) and sessionsLeft = 0 THEN 'inactive'
    else 'active'
    end as packageStatus
from (select Redeems.packageId, courseSessionDate, sessionsLeft 
      from Redeems inner join Purchases on Redeems.packageId = Purchases.PackageId) as RedeemsPurchases
group by packageId, sessionsLeft)
select *
from package_with_status natural join Purchases;

