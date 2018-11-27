use [WorkerForm]
go
 
Create or Alter Procedure [dbo].[wfsp_MassSimulation] As Begin

	Set Dateformat dmy;

	Declare @operations Xml
	Select  @operations = BulkColumn from OpenRowSet(Bulk'C:\Bases\FechaOperacion.XML',Single_blob) AS x;
	
	Declare @dates Table (num int identity(1,1), cDate Date);

	Declare @employees Table (num int identity(1,1), employeeName varchar(50), employeeDocumentId nvarchar(50), idJob int, cDate date)
	Declare @presences Table (num int identity(1,1), employeeDocumentId nvarchar(50), idWorkingDayType int, presenceStart time(7), presenceEnd time(7), cDate date)
	Declare @deductions Table (num int identity(1,1), employeeDocumentId nvarchar(50), idDeductionType int, amount money, cDate date)
	Declare @bonuses Table (num int identity(1,1), employeeDocumentId nvarchar(50), amount money, cDate date)
	Declare @incapacities Table (num int identity(1,1), employeeDocumentId nvarchar(50), idWorkingDayType int, cDate date)

	Begin Try 
		Insert Into @employees 
			Select xCol.value('@nombre', 'varchar(50)') as employeeName,
				xCol.value('@DocId', 'varchar(50)') as emploeeDocumentId,
				xCol.value('@idPuesto', 'int') as idJob,
				xCol.value('(../@Fecha)', 'date') as cDate
			From @operations.nodes('/dataset/FechaOperacion/NuevoEmpleado') Type(xCol)
	End Try
	Begin Catch
		print('Could not insert employees')
	End Catch

	Insert into @presences
		Select xCol.value('@DocId', 'nvarchar(50)') as employeeDocumentId,
			xCol.value('@idTipoJornada', 'int') as idWorkingDayType,
			xCol.value('@HoraEntrada', 'time(7)') as presenceStart,
			xCol.value('@HoraSalida', 'time(7)') as presenceEnd,
			xCol.value('(../@Fecha)', 'date') as cDate
		From @operations.nodes('/dataset/FechaOperacion/Asistencia') Type(xCol)

	Insert into @incapacities
		Select xCol.value('@DocId', 'nvarchar(50)') as employeeDocumentId,
			xCol.value('@idTipoJornada', 'int') as idWorkingDayType,
			xCol.value('(../@Fecha)', 'date') as cDate
		From @operations.nodes('/dataset/FechaOperacion/Incapacidad') Type(xCol)

	Insert into @deductions
		Select xCol.value('@DocId', 'nvarchar(50)') as employeeDocumentId,
			xCol.value('@idTipoDeduccion', 'int') as idDeductionType,
			xCol.value('@Valor', 'money') as amount,
			xCol.value('(../@Fecha)', 'date') as cDate
		From @operations.nodes('/dataset/FechaOperacion/NuevaDeduccion') Type(xCol)

	Insert into @bonuses
		Select xCol.value('@DocId', 'nvarchar(50)') as employeeDocumentId,
			xCol.value('@Monto', 'money') as amount,
			xCol.value('(../@Fecha)', 'date') as cDate
		From @operations.nodes('/dataset/FechaOperacion/Bono') Type(xCol)

	Insert Into @dates 
		Select xCol.value('@Fecha', 'Date') as cDate
		From @operations.nodes('/dataset/FechaOperacion') Type(xCol)

	Declare @iLow int
	Declare @iHigh int
	Declare @jLow int
	Declare @jHigh int
	Declare @currentDate date
	Declare @numOfFridays int

	Select @iLow = min(num) From @dates
	Select @iHigh = max(num) From @dates

	While @iLow <= @iHigh Begin
		Select @currentDate = cDate From @dates Where num = @iLow
		
		-- Se inserta los empleados
		Insert Into Employee
		Select idJob, employeeDocumentId, employeeName
		From @employees Where cDate = @currentDate

		-- Se inserta la planilla mensual
		Insert Into MonthlyForm (idEmployee, rawSalary, netSalary)
		Select id as idEmployee,
		0 as rawSalary,
		0 as netSalary
		From @employees te Join Employee E on te.employeeDocumentId = E.employeeDocumentId
		Where te.cDate = @currentDate

		-- Se inserta la planilla semanal
		Insert Into WeeklyForm (idEmployee, rawSalary, netSalary, idMonthlyForm)
		Select E.id as idEmployee,
		0 as rawSalary,
		0 as netSalary,
		M.id as idMonthlyForm
		From @employees te Join Employee E on te.employeeDocumentId = E.employeeDocumentId Join MonthlyForm M on E.id = M.idEmployee
		Where te.cDate = @currentDate and M.monthlyFormDate is null

		-- Se insertan deducciones de Empleado
		
		Insert Into EmployeeDeduction
		Select id as idEmployee,
		idDeductionType,
		amount
		From @deductions td Join Employee E on td.employeeDocumentId = E.employeeDocumentId
		Where td.cDate = @currentDate

		-- Se insertan las horas de asistencia del archivo.
		
		Insert Into Presence
		Select E.id as idEmployee,
		idWorkingDayType,
		@currentDate as presenceDate,
		tp.presenceStart,
		tp.presenceEnd,
		0 as inhability
		From Employee E join @presences tp on E.employeeDocumentId = tp.employeeDocumentId 
		Where tp.cDate = @currentDate

		Insert Into Presence
		Select E.id as idEmployee,
		idWorkingDayType,
		@currentDate as presenceDate,
		'0:00' as presenceStart,
		'0:00' as presenceEnd,
		1 as inhability
		From Employee E join @incapacities ic on E.employeeDocumentId = ic.employeeDocumentId 
		Where ic.cDate = @currentDate

		-- Se inserta el movimiento de la asistencia.

		Insert Into FormMovements
		Select W.id as idWeeklyForm,
		1 as idMovementType,
		@currentDate as movementDate,
		[dbo].[wff_calculate_salary] (E.id, @currentDate, tp.presenceStart, tp.presenceEnd, tp.idWorkingDayType) as salary 
		From WeeklyForm W Join Employee E on W.idEmployee = E.id join @presences tp on E.employeeDocumentId = tp.employeeDocumentId 
		Where tp.cDate = @currentDate and W.weeklyFormDate is null
		
		-- Se inserta el movimiento de las horas extras.

		Insert Into FormMovements
		Select W.id as idWeeklyForm,
		2 as idMovementType,
		@currentDate as movementDate,
		[dbo].[wff_calculate_extraHoursPayment] (E.id, @currentDate, tp.presenceStart, tp.presenceEnd, tp.idWorkingDayType) as salary 
		From WeeklyForm W Join Employee E on W.idEmployee = E.id join @presences tp on E.employeeDocumentId = tp.employeeDocumentId 
		Where tp.cDate = @currentDate and W.weeklyFormDate is null and [dbo].[wff_calculate_extraHoursPayment] (E.id, @currentDate, tp.presenceStart, tp.presenceEnd, tp.idWorkingDayType) > 0

		-- Se insertan las incapacidades del archivo.
		
		Insert Into FormMovements
		Select W.id as idWeeklyForm,
		3 as idMovementType,
		@currentDate as movementDate,
		[dbo].[wff_calculate_salary] (E.id, @currentDate, '0:00', '0:00', ti.idWorkingDayType) as salary 
		From WeeklyForm W Join Employee E on W.idEmployee = E.id join @incapacities ti on E.employeeDocumentId = ti.employeeDocumentId 
		Where ti.cDate = @currentDate and W.weeklyFormDate is null

		-- Movimientos Hora

		-- FIX!!!

		--Insert Into MovementJobHours
		--Select M.id as id,
		--P.id as presenceId
		--From WeeklyForm W Join FormMovements M On W.id = M.idWeeklyForm Join Presence P On W.idEmployee = P.idEmployee
		--Where P.presenceDate = @currentDate

		-- Se insertan los bonos
		
		Insert Into FormMovements
		Select W.id as idWeeklyForm,
		4 as idMovementType,
		@currentDate as movementDate,
		td.amount as salary 
		From WeeklyForm W Join Employee E on W.idEmployee = E.id join @bonuses td on E.employeeDocumentId = td.employeeDocumentId 
		Where td.cDate = @currentDate and W.weeklyFormDate is null

		Update WF
		Set rawSalary = rawSalary + R.credits, netSalary = netSalary + R.credits
		From WeeklyForm WF
		Join 
		(Select W.id, sum(M.salary) as credits
		From WeeklyForm W Join FormMovements M On W.id = M.idWeeklyForm 
		Where M.idMovementType < 6 and M.movementDate = @currentDate and weeklyFormDate is null Group By W.id) R On WF.id = R.id


		-- CIERRE DE PLANILLAS SEMANALES / MENSUALES
		-- Si es viernes
		If DatePart(DW, @currentDate) = 6 Begin
			
			-- Se aplican las deducciones por empleado.

			-- Porcentuales
			Insert Into FormMovements
			Select
			W.id as idWeeklyForm,
			D.idDeductionType + 5 as idMovementType,
			@currentDate as movementDate,
			W.rawSalary * D.amount / 100 as salary
			From EmployeeDeduction D Join WeeklyForm W On D.idEmployee = W.idEmployee
			Where W.weeklyFormDate is null and D.idDeductionType < 3

			-- Fijas
			Select @numOfFridays = [dbo].[wff_fridaysOfMonth] (@currentDate)
			Insert Into FormMovements
			Select
			W.id as idWeeklyForm,
			D.idDeductionType + 5 as idMovementType,
			@currentDate as movementDate,
			D.amount / @numOfFridays as salary
			From EmployeeDeduction D Join WeeklyForm W On D.idEmployee = W.idEmployee
			Where W.weeklyFormDate is null and D.idDeductionType > 2

			-- Se aplican los saldos netos a la planilla semanal

			Update WF
			Set netSalary = netSalary - R.credits
			From WeeklyForm WF
			Join 
			(Select W.id, sum(M.salary) as credits
			From WeeklyForm W Join FormMovements M On W.id = M.idWeeklyForm 
			Where M.idMovementType > 5 and M.movementDate = @currentDate and weeklyFormDate is null Group By W.id) R On WF.id = R.id

			-- Se aplican los saldos de la planilla semanal a la planilla mensual.		
			
			Update MF
			Set rawSalary = R.rawSalary
			From MonthlyForm MF
			Join 
			(Select M.id as id, sum(W.rawSalary) as rawSalary
			From MonthlyForm M Join WeeklyForm W On M.id = W.idMonthlyForm 
			Where M.monthlyFormDate is null Group By M.id) R On MF.id = R.id
			
			Update MF
			Set netSalary = R.netSalary
			From MonthlyForm MF
			Join 
			(Select M.id as id, sum(W.netSalary) as netSalary
			From MonthlyForm M Join WeeklyForm W On M.id = W.idMonthlyForm 
			Where M.monthlyFormDate is null Group By M.id) R On MF.id = R.id


			-- Se cierran las planillas semanales
			Update WeeklyForm
			Set weeklyFormDate = @currentDate
			Where weeklyFormDate is null

			-- Si es el último viernes del mes
			If DatePart(MONTH, @currentDate) != DatePart(MONTH, DateAdd(Week, 1, @currentDate)) Begin 

				-- Se borran las deducciones mensuales.

				Delete From EmployeeDeduction
				
				-- Se cierran las planillas mensuales
				Update MonthlyForm
				Set monthlyFormDate = @currentDate
				Where monthlyFormDate is null

				-- Se abren las nuevas planillas mensuales
				
				Insert Into MonthlyForm (idEmployee, rawSalary, netSalary)
				Select id as idEmployee,
				0 as rawSalary,
				0 as netSalary
				From Employee

			End

			-- Se abren las nuevas planillas semanales
			
			Insert Into WeeklyForm (idEmployee, rawSalary, netSalary, idMonthlyForm)
			Select E.id as idEmployee,
			0 as rawSalary,
			0 as netSalary,
			M.id as idMonthlyForm
			From Employee E Join MonthlyForm M on E.id = M.idEmployee
			Where M.monthlyFormDate is null

		End

		Select @iLow = @iLow + 1
	End
End