-- Proc script
use WorkerForm
go

set dateformat dmy;  
go

create or alter procedure dbo.wfsp_generalQuery
@employeeId nvarchar(50),
@salida as nvarchar(1000) output

as
begin
begin try
	declare @low int = 1;
	declare @hi int = -1;

		select @hi = max(F.id)
			from (FormMovements F inner join WeeklyForm W on W.id = F.idWeeklyForm) join Employee E on W.idEmployee = E.id
			where idMovementType = 4 and weeklyFormDate is null and employeeDocumentId = @employeeId;
	
		select @salida = @salida + 'Posible bono a editar:' + CHAR(10);
		if(@hi = -1 or @hi is null)
			begin
				select @salida = @salida + 'No hay bonos que se puedan editar' + char(10);
			end
		else
			begin
			select @salida = @salida + 'Identificador de deduccion: ' + cast(@hi as nvarchar) + char(10)
													+ 'Identificador de tipo de deduccion: ' + cast(D.idMovementType as nvarchar) + char(10)
													+ 'Monto: ' + cast(D.salary as nvarchar) + char(10)
													+  'Identificación de emplado: ' + @employeeId + char(10)
				from FormMovements D
				where D.id = @hi;
			end;	
		set @hi = -1;

		select @hi = max(F.id)
			from (FormMovements F inner join WeeklyForm W on W.id = F.idWeeklyForm) join Employee E on W.idEmployee = E.id
			where (idMovementType > 5) and weeklyFormDate is null and employeeDocumentId = @employeeId;


		select @salida = @salida + char(10);

		select @salida = @salida + 'Posible deducción a editar' + char(10);

		if(@hi = -1 or @hi is null)
			begin
				select @salida = @salida + 'No hay deducciones que se puedan editar' + char(10);
			end
		else
			begin
				select @salida = @salida + 'Identificador de deduccion: ' + cast(@hi as nvarchar) + char(10)
												+ 'Identificador de tipo de deduccion: ' + cast(D.idMovementType as nvarchar) + char(10)
												+ 'Monto: ' + cast(D.salary as nvarchar) + char(10)
												+  'Identificación de emplado: ' + @employeeId + char(10)
					from FormMovements D
					where D.id = @hi;
			end;

		return 1;
	end try
	begin catch
		return -1
	end catch;
end;
go

-- Procedure to log in on web page
create or alter procedure dbo.wfsp_login
@valorDocId nvarchar(50),
@salida as int output

as
begin
	begin try

		select @salida = 1
			from Employee E
			where @valorDocId = E.employeeDocumentId;

			select @salida = 2
			from WorkerFormAdmins W
			where W.adminDocId = @valorDocId;

			return 1;
	end try
	begin catch
		select error_message();
		set @salida=-1;
		return -1;
	end catch
	
end;
go

-- Procedure edit a deduction given to an employee
create or alter procedure wfsp_editDeduction
@employeeId nvarchar(50),
@deductionId int,
@amount money,
@salida as int output

as
begin
	declare @hi int;
	set transaction isolation level read uncommitted 
	begin transaction;
	begin try

		select @hi = max(F.id)
			from (FormMovements F inner join WeeklyForm W on W.id = F.idWeeklyForm) join Employee E on W.idEmployee = E.id
			where (idMovementType = 4) and weeklyFormDate is null and employeeDocumentId = @employeeId;

		insert into WorkerFormEvents(eventDescription)
			select 'Se edita una deducción mal hecha al empleado con la identificación' + cast(idEmployee as nvarchar) + ', el identificador de ls deducción es ' + CAST(@deductionId as nvarchar) + ' y el nuevo monto es de ' +
					CAST(@amount as nvarchar)
			from FormMovements F, WeeklyForm W
			where F.id = @deductionId and W.id = F.id and W.weeklyFormDate is null;

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select	F.idMovementType, F.idWeeklyForm, F.movementDate, F.salary * -1
			from FormMovements F, WeeklyForm W
			where F.id = @deductionId and W.id = F.id and W.weeklyFormDate is null;

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select F.idMovementType, F.idWeeklyForm, F.movementDate, @amount
			from (FormMovements F inner join WeeklyForm W on W.id = F.idWeeklyForm)
			where idMovementType > 4 and (weeklyFormDate is null) and F.id = @deductionId and @deductionId = @hi;


		commit
		set @salida = 1;
		return 1;
	end try
	begin catch
		rollback;
		select error_message();
		set @salida = 0;
		return -1;
	end catch
end;
go

-- Procedure edit a given bonus to an employee
create or alter procedure wfsp_editBonus
@employeeId nvarchar(50),
@deductionId int,
@amount money,
@salida as int output

as
begin
	declare @hi int;
	set transaction isolation level read uncommitted 
	begin transaction;
	begin try

		select @hi = max(F.id)
			from (FormMovements F inner join WeeklyForm W on W.id = F.idWeeklyForm) join Employee E on W.idEmployee = E.id
			where (idMovementType = 4) and weeklyFormDate is null and employeeDocumentId = @employeeId;

		insert into WorkerFormEvents(eventDescription)
			values('Se edita un bono mal hecho, el identificador es ' + CAST(@deductionId as nvarchar) + ' y el monto editado es de ' +
					CAST(@amount as nvarchar));

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select	F.idMovementType, F.idWeeklyForm, F.movementDate, F.salary * -1
			from FormMovements F, WeeklyForm W
			where F.id = @deductionId and W.id = F.id and W.weeklyFormDate is null;

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select F.idMovementType, F.idWeeklyForm, F.movementDate, @amount
			from (FormMovements F inner join WeeklyForm W on W.id = F.idWeeklyForm)
			where idMovementType = 4 and (weeklyFormDate is null) and F.id = @deductionId and @deductionId = @hi;

		commit
		set @salida = 1;
		return 1;
	end try
	begin catch
		rollback;
		select error_message();
		set @salida = -1;
		return -1;
	end catch
end;
go

-- Procedure consult all the Forms of an employee and the movements
create or alter procedure wfsp_employeeFormsQuery
@employeeId nvarchar(50),
@salida as nvarchar(3000) output

as
begin

	begin try

		select @salida = @salida + 'Las planillas semanales son:' + char(10) + char(10);

		select @salida = @salida + 'Nombre de empleado: ' + cast(employeeName as nvarchar) + char(10)
								+ 'Id plantilla: ' + cast(W.id as nvarchar) + char(10)
								+ 'Fecha de plantilla: ' + cast(weeklyFormDate as nvarchar) + char(10)
								+ 'Salario sin rebajos: ' + cast(rawSalary as nvarchar) + char(10)
								+ 'Salario con rebajos: ' + cast(netSalary as nvarchar) + char(10) + char(10)
			from WeeklyForm W join Employee E on W.idEmployee = E.id
			where employeeDocumentId = @employeeId and weeklyFormDate is not null;

		select @salida = @salida + '***************************' + char(10) +
								'Las planillas mensuales son:' + char(10)+ char(10);

		select @salida = @salida + 'Nombre de empleado: ' + cast(employeeName as nvarchar) + char(10)
								+ 'Id plantilla: ' + cast(W.id as nvarchar) + char(10)
								+ 'Fecha de plantilla: ' + cast(monthlyFormDate as nvarchar) + char(10)
								+ 'Salario sin rebajos: ' + cast(rawSalary as nvarchar) + char(10)
								+ 'Salario con rebajos: ' + cast(netSalary as nvarchar) + char(10) + char(10)
			from MonthlyForm W join Employee E on W.idEmployee = E.id
			where employeeDocumentId = @employeeId and monthlyFormDate is not null;
	
		--set @salida = 1;
		return 1;
	end try
	begin catch
		select error_message();
		select @salida = ERROR_MESSAGE();
		return -1;
	end catch
end;
go

-- Procedure the value of an employee
create or alter procedure wfsp_editValue
@idvalue as int,
@amount as money,
@salida as int output

as
begin

	set transaction isolation level read uncommitted 
	begin transaction;
	begin try

		update JobByWorkingDayType 
			set hourlySalary = @amount
			where id = @idvalue;
		commit
		set @salida = 1;
		return 1;
	end try
	begin catch
		rollback;
		select error_message();
		set @salida = -1;
		return -1;
	end catch
end;
go

<<<<<<< HEAD
-- Procedure the value of an employee
create or alter procedure wfsp_valuesQuery
@salida as nvarchar(3000) output

as
begin
	begin try

	select @salida = @salida + 'Identificador de valor: ' + cast(J.id as nvarchar) + char(10)
							+ 'Valor por hora: ' + cast(J.hourlySalary as nvarchar) + char(10)

							+ 'Nombre del trabajo: ' + cast(JO.jobName as nvarchar) + char(10)
							+ 'Jornada: ' + cast(W.workingDayName as nvarchar) + char(10)
							+ 'Inicio de jornada: ' + cast(w.workingDayStart as nvarchar) + char(10)
							+ 'Fin de jornada: ' + cast(W.workingDayEnd as nvarchar) + char(10)
							+ char(10)
		from (JobByWorkingDayType J inner join Job JO on J.idJob = JO.id) join WorkingDayType W on W.id = J.idWorkigDayType order by JO.id

		return 1;
	end try
	begin catch
		select error_message();
		return -1;
	end catch
end;
go
=======
---- Procedure edit a bonus given to an employee
--create or alter procedure dbo.wfsp_editDeduction
--@deductionId int,
--@employeeId int,
--@deductionType int,
--@amount money,
--@salida as int output

--as
--begin

--	set transaction isolation level read uncommitted 
--	begin transaction;
--	begin try
--		update EmployeeDeduction 
--			set idEmployee = @employeeId, amount = @amount, idEmployeeDeductionType = @deductionType
--			where id = @deductionId;
--		set @salida = 1;
--		commit
--		set @salida = 1;
--		return 1;
--	end try
--	begin catch
--		rollback;
--		select error_message();
--		set @salida = -1;
--		return -1;
--	end catch
--end;


Create or Alter Procedure wfsp_getAguinaldo
@docIdEmpleado nvarchar(50)
As
Begin
	Declare @lastDecember date
	Select @lastDecember = DATEFROMPARTS(DATEPART(Year, GetDate()),12,1)

	Return Select Avg(netSalary) From MonthlyForm M Where M.monthlyFormDate is not null and M.monthlyFormDate > @lastDecember Order By M.monthlyFormDate Desc
End
Go

use master
go