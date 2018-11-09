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

go 

-- Procedure edit a bonus given to a employee
create or alter procedure dbo.wfsp_editDeduction
@deductionId int,
@employeeId int,
@deductionType int,
@amount money,
@salida as int output

as
begin

	set transaction isolation level read uncommitted 
	begin transaction;
	begin try
		update EmployeeDeduction 
			set idEmployee = @employeeId, amount = @amount, idEmployeeDeductionType = @deductionType
			where id = @deductionId;
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
