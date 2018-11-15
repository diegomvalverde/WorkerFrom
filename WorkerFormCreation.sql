use master;

/*
The next code is to manage a error wich occurs when you try to create an exixting database.
*/

if(exists(select * from sysdatabases where name = 'WorkerForm'))
begin

	drop database [WorkerForm]
	
end


-- Database creation if doesn't exist.

create database [WorkerForm]
go

use [WorkerForm]
go


-- Tables creation.

create table WorkingDayType
(
	id int primary key identity(1,1) not null,
	workingDayName nvarchar(50) not null,
	workingDayStart time not null,
	workingDayEnd time not null
);

create table Job
(
	id int primary key identity(1,1) not null,
	jobName nvarchar(50) not null
);

create table JobByWorkingDayType
(
	id int primary key identity(1,1) not null,
	idWorkigDayType int constraint FKJobByWorkingDayType_WorkingDayType references WorkingDayType(id) not null, 
	idJob int constraint FKJobByWorkingDayType_Job references Job(id) not null, 
	hourlySalary money not null
);

create table Employee
(
	id int primary key identity(1,1) not null,
	idJob int constraint FKEmployee_Job references Job(id) not null,
	employeeDocumentId nvarchar(50) not null,
	employeeName nvarchar(50) not null
);

create table MonthlyForm
(
	id int identity(1,1) primary key not null,
	idEmployee int constraint FKMonthlyForm_Employee references Employee(id) not null,
	monthlyFormDate date not null,
	rawSalary money not null,
	netSalary money not null
);

create table MovementType
(
	id int identity(1,1) primary key not null,
	movementDescription nvarchar(50)
);

create table WeeklyForm
(
	id int identity(1,1) primary key not null,
	idEmployee int constraint FKWeeklyForm_Employee references Employee(id) not null,
	idMonthlyForm int constraint FKWeeklyForm_MonthlyFrom references MonthlyForm(id) not null,
	rawSalary money not null,
	netSalary money not null,
	weeklyFormDate date null
);

create table FormMovements
(
	id int identity(1,1) primary key not null,
	idWeeklyForm int constraint FKFormMovemets_WeeklyForm references WeeklyForm(id) null,
	idMovementType int constraint FKFormMovemets_MovementType references MovementType(id) not null,
	movementDate date not null,
	salary money not null
);

create table MovementJobHours
(
	id int identity(1,1) primary key not null,	
	idFormMovements int constraint FKMovementJobHours_FormMovements references FormMovements(id) not null
);

create table Presence
(
	id int primary key identity(1,1) not null,
	idEmployee int constraint FKPresence_Employee references Employee(id) not null,
	idWorkingDayType int constraint FKPresence_WorkingDayType references WorkingDayType(id) not null,
	idMovementJobHours int constraint FKPresence_MovementJobHours references MovementJobHours(id) not null,
	presenceDate date not null,
	presenceStart time not null,
	presenceEnd time not null,
	inhability bit not null
);

create table DeductionType
(
	id int identity(1,1) primary key not null,
	deductionName nvarchar(50) not null,
);

create table MonthlyDeduction
(
	id int identity(1,1) primary key not null,
	idDeductionType int constraint FKMonthlyDeduction_DeductionType references DeductionType(id) not null,
	idMonthlyForm int constraint FKMonthlyDeduction_MonthlyForm references MonthlyForm(id) not null,
	amount money not null
);

create table EmployeeDeduction
(
	id int identity(1,1) primary key not null,
	idEmployee int constraint FKEmployeeDeduction_Employee references Employee(id) not null,
	idDeductionType int constraint FKEmployeeDeduction_DeductionType references DeductionType(id) not null,
	amount money not null
);


-- Este c�digo es para no tener que reiniciar la DB si ocurre un error con MSQLMS
use [master];
go

