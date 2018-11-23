-- Proc script
use WorkerForm
go

--create or alter procedure dbo.wfsp_generalQuery
--@employeeId nvarchar(50),
--@salida as varchar(500) output
--as
--begin

--	--declare @deductionsTable table
--	--(
--	--	sec int identity(1,1),
--	--	id int,
--	--	idWeeklyForm int,
--	--	idMovementType int,
--	--	movementDate date ,
--	--	salary money
--	--)

--	--declare @bonusTable table
--	--(
--	--	sec int identity(1,1),
--	--	id int,
--	--	idWeeklyForm int,
--	--	idMovementType int,
--	--	movementDate date ,
--	--	salary money
--	--)

--	declare @low int = 1;
--	declare @hi int;
--	--set transaction isolation level read uncommitted 
--	--begin transaction;
--	select @salida = 'hola';
--		select @hi = max(F.id)
--			from FormMovements F, WeeklyForm W
--			where W.id = F.idWeeklyForm and W.idEmployee = @employeeId and F.idMovementType = 4;
--	select @salida = 'hola2';

--		set @salida = 'Identificador de deducción: ' + cast(20 as nvarchar)
--												+ 'Identificador de tipo de movimiento: ' 


--		--insert @bonusTable(idMovementType, idWeeklyForm, movementDate, salary, id)
--		--	select F.idMovementType, F.idWeeklyForm, F.movementDate, F.salary, F.id
--		--	from FormMovements F, WeeklyForm W
--		--	where F.id = max(F.id)

--		--insert @bonusTable(id, idMovementType, movementDate, salary, idWeeklyForm)
--		--	select B.id, B.idMovementType, B.movementDate, B.salary, W.id
--		--	from FormMovements B, WeeklyForm W
--		--	where W.idEmployee = @employeeId and W.id = B.idWeeklyForm and B.idMovementType = 4;

--		--select @hi = max(D.sec)
--		--	from @deductionsTable D;

--		--while(@low < @hi)
--		--	begin
--		--		select @salida = @salida + 'Identificador de deducción: ' + cast(D.id as nvarchar) + char(10)
--		--										+ 'Identificador de tipo de deducción: ' + cast(D.idDeductionType as nvarchar) + char(10)
--		--										+ 'Monto: ' + cast(D.amount as nvarchar) + char(10)
--		--										+  'Identificación de emplado: ' + cast(D.employeeId as nvarchar) + char(10)
--		--										+ CHAR(10)
--		--			from @deductionsTable D
--		--			where @low = D.sec;
--		--		set @low = @low + 1;
--		--	end;
--		--select @salida = @salida +'diego';
--		--set @low = 1;
--		--select @hi = max(B.sec)
--		--	from @bonusTable B;

--		--while(@low < @hi)
--		--	begin
--		--		select @salida = @salida + 'Identificador de bono: ' + cast(B.id as nvarchar) + char(10)
--		--										+ 'Identificador de planilla semanal: ' + cast(B.idWeeklyForm as nvarchar) + char(10)
--		--										+ 'Identificador del tipo de movimiento: ' + cast(B.idMovementType as nvarchar) + char(10)
--		--										+  'Fecha de movimiento: ' + cast(B.movementDate as nvarchar) + char(10)
--		--										+  'Monto del bono: ' + cast(B.salary as nvarchar) + char(10)
--		--										+ CHAR(10)
--		--			from @bonusTable B
--		--			where @low = B.sec;
--		--		set @low = @low + 1;
--		--	end;
--		--select @salida = 'Valor por hora: ' + hourlySalary
--		--	from Employee E
--		--	join JobByWorkingDayType J on E.idJob = J.idJob;
		
--end;
--go
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
@deductionId int,
@amount money,
@salida as int output

as
begin

	set transaction isolation level read uncommitted 
	begin transaction;
	begin try

		insert into WorkerFormEvents(eventDescription)
			values('Se edita una deducción mal hecha, el identificador es ' + CAST(@deductionId as nvarchar) + ' y el monto editado es de ' +
					CAST(@amount as nvarchar));

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select	F.idMovementType, F.idWeeklyForm, F.movementDate, F.salary * -1
			from FormMovements F, WeeklyForm W
			where F.id = @deductionId and W.id = F.id and W.weeklyFormDate is null;

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select F.idMovementType, F.idWeeklyForm, F.movementDate, @amount
			from FormMovements F, WeeklyForm W
			where F.id = @deductionId and (W.id = F.id and W.weeklyFormDate is null);

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

-- Procedure edit a deduction given to an employee
create or alter procedure wfsp_editBonus
@deductionId int,
@amount money,
@salida as int output

as
begin

	set transaction isolation level read uncommitted 
	begin transaction;
	begin try

		insert into WorkerFormEvents(eventDescription)
			values('Se edita un bono mal hecho, el identificador es ' + CAST(@deductionId as nvarchar) + ' y el monto editado es de ' +
					CAST(@amount as nvarchar));

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select	F.idMovementType, F.idWeeklyForm, F.movementDate, F.salary * -1
			from FormMovements F, WeeklyForm W
			where F.id = @deductionId and W.id = F.id and W.weeklyFormDate is null;

		insert into FormMovements(idMovementType, idWeeklyForm, movementDate, salary)
			select F.idMovementType, F.idWeeklyForm, F.movementDate, @amount
			from FormMovements F, WeeklyForm W
			where F.id = @deductionId and (W.id = F.id and W.weeklyFormDate is null);

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
use master
go