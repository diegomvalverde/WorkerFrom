
use WorkerForm;
go

set dateformat dmy;  
go  

set nocount on 

/*
XML variables
*/

declare @xmlJobs xml
set @xmlJobs = 
(
	select * from openrowset(bulk 'C:\Bases\Puesto.xml', single_blob) as x
);


declare @xmlHourSalary xml
set @xmlHourSalary = 
(
	select * from openrowset(bulk 'C:\Bases\SalarioxHora.xml', single_blob) as x
);


declare @xmlDeductionType xml
set @xmlDeductionType = 
(
	select * from openrowset(bulk 'C:\Bases\TipoDeduccion.xml', single_blob) as x
);

declare @xmlWorkingDayType xml
set @xmlWorkingDayType = 
(
	select * from openrowset(bulk 'C:\Bases\TipoJornadas.xml', single_blob) as x
);

declare @xmlMovementType xml
set @xmlMovementType = 
(
	select * from openrowset(bulk 'C:\Bases\TipoMovimiento.xml', single_blob) as x
);

declare @xmlHolyDay xml
set @xmlHolyDay = 
(
	select * from openrowset(bulk 'C:\Bases\Feriados.xml', single_blob) as x
);

--Variables del xml
declare @handle int;  
declare @PrepareXmlStatus int;  
declare @low1 int;
declare @hi1 int;

/*
Jobs upload from xml
*/ 

exec @PrepareXmlStatus= sp_xml_preparedocument @handle output, @xmlJobs; 

insert into Job(jobName)
	select nombre
	from openxml(@handle, '/dataset/Puesto') with (nombre nvarchar(50));

/*
WorkingDayType upload from xml
*/ 

exec @PrepareXmlStatus= sp_xml_preparedocument @handle output, @xmlWorkingDayType;

insert into WorkingDayType(workingDayEnd, workingDayName, workingDayStart)
		select HoraFin, nombre, HoraInicio
		from openxml(@handle, '/dataset/TipoJornadas') with (HoraFin time, nombre nvarchar(50), HoraInicio time);


/*
JobByWorkingDayType upload from xml
*/

exec @PrepareXmlStatus= sp_xml_preparedocument @handle output, @xmlHourSalary;

insert into JobByWorkingDayType(idWorkigDayType, hourlySalary, idJob)
	select idTipoJornada, valorHora, idPuesto
	from openxml(@handle, '/dataset/SalarioxHora') with (idTipoJornada int, valorHora money, idPuesto int);

/*
DeductionType upload from xml
*/ 

exec @PrepareXmlStatus= sp_xml_preparedocument @handle output, @xmlDeductionType;

insert into DeductionType(deductionName)
		select nombre
		from openxml(@handle, '/dataset/TipoDeduccion') with (nombre nvarchar(50));


/*
MovementType upload from xml
*/ 

exec @PrepareXmlStatus= sp_xml_preparedocument @handle output, @xmlMovementType;

insert into MovementType(movementDescription)
		select nombre
		from openxml(@handle, '/dataset/TipoMovimiento') with (nombre nvarchar(100));


/*
HolyDays upload from xml
*/ 

exec @PrepareXmlStatus= sp_xml_preparedocument @handle output, @xmlHolyDay;

insert into HolyDays (holyDayDescription, holyDayDate)
		select NombreFeriado, Fecha
		from openxml(@handle, '/dataset/Feriados') with (NombreFeriado varchar(150), Fecha date);




set nocount off
use master
go