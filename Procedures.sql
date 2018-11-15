-- Proc script
use WorkerForm
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
			return 1;
	end try
	begin catch
		select error_message();
		set @salida=-1;
		return -1;
	end catch
	
end;
go;

-- Procedure to query deductions, bonus and value x hour of an employee
create or alter procedure dbo.wfsp_bonus_deduction_valuexHourQuery
@employeeId int,
@bonus as nvarchar(500) output,
@value as nvarchar(500) output,
@deductions as nvarchar(50) output,
@salida as int output

as
begin
	declare @deductionsTable table
	(
		sec int identity(1,1),
		id int,
		idDeductionType int,
		amount money,
		employeeId int
	)

	declare @bonusTable table
	(
		sec int identity(1,1),
		id int,
		idWeeklyForm int,
		idMovementType int,
		movementDate date ,
		salary money
	)

	declare @low int = 1;
	declare @hi int;
	--set transaction isolation level read uncommitted 
	--begin transaction;
	begin try
		insert @deductionsTable(id, idDeductionType, amount, employeeId)
			select ED.id, ED.idEmployeeDeductionType, ED.amount, ED.idEmployee
			from EmployeeDeduction ED
			where ED.idEmployee =  @employeeId;
		
		insert @bonusTable(id, idMovementType, movementDate, salary, idWeeklyForm)
			select B.id, B.idMovementType, B.movementDate, B.salary, W.id
			from FormMovements B, WeeklyForm W
			where W.idEmployee = @employeeId and W.id = B.idWeekelyForm and B.idMovementType = 4;

		select @hi = max(D.sec)
			from @deductionsTable D;

		while(@low < @hi)
			begin
				select @deductions = @deductions + 'Identificador de deducción: ' + cast(D.id as nvarchar) + char(10)
												+ 'Identificador de tipo de deducción: ' + cast(D.idDeductionType as nvarchar) + char(10)
												+ 'Monto: ' + cast(D.amount as nvarchar) + char(10)
												+  'Identificación de emplado: ' + cast(D.employeeId as nvarchar) + char(10)
												+ CHAR(10)
					from @deductionsTable D
					where @low = D.sec;
				set @low = @low + 1;
			end;

		set @low = 1;
		select @hi = max(B.sec)
			from @bonusTable B;

		while(@low < @hi)
			begin
				select @deductions = @deductions + 'Identificador de bono: ' + cast(B.id as nvarchar) + char(10)
												+ 'Identificador de planilla semanal: ' + cast(B.idWeeklyForm as nvarchar) + char(10)
												+ 'Identificador del tipo de movimiento: ' + cast(B.idMovementType as nvarchar) + char(10)
												+  'Fecha de movimiento: ' + cast(B.movementDate as nvarchar) + char(10)
												+  'Monto del bono: ' + cast(B.salary as nvarchar) + char(10)
												+ CHAR(10)
					from @bonusTable B
					where @low = B.sec;
				set @low = @low + 1;
			end;
		select @value = 'Valor por hora: ' + hourlySalary
			from Employee E
			join JobByWorkingDayType J on E.idJob = J.idJob;

		set @salida = 1;
		return 1;
	end try
	begin catch
		set @salida = 0;
		return -1;
	end catch
end;
go; 

-- Procedure edit a deduction given to an employee
create or alter procedure dbo.wfsp_editDeduction
@deductionId int,
@employeeId int,
@amount money,
@salida as int output

as
begin

	set transaction isolation level read uncommitted 
	begin transaction;
	begin try

		
		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select	F.idMovementType, F.idWeeklyForm, F.movementDate, F.salary * -1
			from FormMovements F
			where F.id = @deductionId;

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select F.idMovementType, F.idWeeklyForm, F.movementDate, @amount
			from FormMovements F
			where F.id = @deductionId;

		--update EmployeeDeduction 
		--	set idEmployee = @employeeId, amount = @amount, idEmployeeDeductionType = @deductionType
		--	where id = @deductionId;

		set @salida = 1;
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
go;

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