use [WorkerForm]
go
 
Create or Alter Procedure [dbo].[wfsp_IteratedSimulation] As Begin

	Set Dateformat dmy;

	Declare @operations Xml
	Select  @operations = BulkColumn from OpenRowSet(Bulk'C:\Bases\FechaOperacion.XML',Single_blob) AS x;
	
	Declare @dates Table (num int identity(1,1), cDate Date);

	Declare @employees Table (num int identity(1,1), employeeName varchar(50), employeeDocumentId nvarchar(50), idJob int, cDate date)
	Declare @presences Table (num int identity(1,1), employeeDocumentId nvarchar(50), idWorkingDayType int, presenceStart time(7), presenceEnd time(7), cDate date)
	Declare @deductions Table (num int identity(1,1), employeeDocumentId nvarchar(50), idDeductionType int, amount money, cDate date)
	Declare @bonuses Table (num int identity(1,1), employeeDocumentId nvarchar(50), amount money, cDate date)
	Declare @incapacities Table (num int identity(1,1), employeeDocumentId nvarchar(50), idWorkingDayType int, cDate date)

Insert Into @employees 
		Select xCol.value('@nombre', 'varchar(50)') as employeeName,
			xCol.value('@DocId', 'varchar(50)') as emploeeDocumentId,
			xCol.value('@idPuesto', 'int') as idJob,
			xCol.value('(../@Fecha)', 'date') as cDate
		From @operations.nodes('/dataset/FechaOperacion/NuevoEmpleado') Type(xCol)

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
	Declare @employeeId int
	Declare @weeklyFormId int
	Declare @idWorkingDayType int
	Declare @presenceStart Time(7)
	Declare @presenceEnd Time(7)
	Declare @presenceId int
	Declare @formMovementId int
	Declare @salary money
	Declare @deductionType int
	Declare @amount float(10)
	Declare @numOfFridays int

	Select @iLow = min(num) From @dates
	Select @iHigh = max(num) From @dates
	
	While @iLow <= @iHigh Begin
		Select @currentDate = cDate From @dates Where num = @iLow

		-- Se inserta los empleados del Archivo.
		-- Adem�s se abren las planillas Semanales y Mensuales
		Select @jLow = min(num) From @employees
		Select @jHigh = max(num) From @employees
		While @jLow <= @jHigh Begin

			If (Select E.cDate From @employees E Where E.num = @jLow) = @currentDate Begin

				-- Se inserta el empleado
				Insert Into [dbo].[Employee] Select idJob, employeeDocumentId, employeeName
				From @employees Where num = @jLow

				-- Se inserta la planilla mensual
				Insert Into [dbo].[MonthlyForm] 
				(idEmployee, monthlyFormDate, rawSalary, netSalary) 
				Values (@jLow, null, 0,0)

				-- Se inserta la planilla semanal
				Declare @monthlyFormId int
				Select @monthlyFormId = max(id) From MonthlyForm Where idEmployee = @jLow
				Insert Into [dbo].[WeeklyForm]
				(idEmployee, weeklyFormDate, idMonthlyForm, rawSalary, netSalary) 
				Values (@jLow, null, @monthlyFormId, 0, 0)

			End
			Select @jLow = @jLow + 1
		End

		-- Se insertan deducciones de Empleado
		Select @jLow = min(num) From @deductions
		Select @jHigh = max(num) From @deductions
		While @jLow <= @jHigh Begin
			If (Select D.cDate From @deductions D Where D.num = @jLow) = @currentDate Begin
				Select @employeeId = E.id From Employee E
				Where E.employeeDocumentId = (Select employeeDocumentId From @deductions D Where D.num = @jLow)
				Select @deductionType = idDeductionType From @deductions D Where D.num = @jLow
				Select @amount = amount From @deductions Where num = @jLow
				Insert Into EmployeeDeduction (idEmployee, idDeductionType, amount)
				Values (@employeeId, @deductionType, @amount)
			End
			Select @jLow = @jLow + 1
		End

		--Se inserta las horas de asistencia del archivo.
		Select @jLow = min(num) From @presences
		Select @jHigh = max(num) From @presences
		While @jLow <= @jHigh Begin
			If (Select P.cDate From @presences P Where P.num = @jLow) = @currentDate Begin
				Select @employeeId = E.id From Employee E
				Where E.employeeDocumentId = (Select employeeDocumentId From @presences P Where P.num = @jLow)
				Select @idWorkingDayType = idWorkingDayType From @presences Where num = @jLow
				Select @presenceStart = presenceStart From @presences Where num = @jLow
				Select @presenceEnd = presenceEnd From @presences Where num = @jLow
				Select @weeklyFormId = max(id) From WeeklyForm Where idEmployee = @employeeId

				Insert Into [dbo].[Presence] (idEmployee, idWorkingDayType, inhability, presenceDate,presenceStart, presenceEnd)
				Values (@employeeId, @idWorkingDayType,  0, @currentDate, @presenceStart, @presenceEnd)

				-- Horas normales
				Select @salary = [dbo].[wff_calculate_salary] (@employeeId, @currentDate, @presenceStart, @presenceEnd, @idWorkingDayType)
					
				Insert Into [dbo].[FormMovements] (idWeeklyForm, idMovementType, movementDate, salary)
				Values (@weeklyFormId, 1, @currentDate, @salary)

				Update WeeklyForm 
				Set rawSalary = rawSalary + @salary, netsalary = netsalary + @salary
				Where idEmployee = @employeeId and weeklyFormDate is null

				Select @formMovementId = max(id) From FormMovements
				Insert Into [dbo].[MovementJobHours] (id, presenceId) 
				Values (@formMovementId, @jLow)

				-- Horas extra
				Select @salary = [dbo].[wff_calculate_extraHoursPayment] (@employeeId, @currentDate, @presenceStart, @presenceEnd, @idWorkingDayType)
				
				If @salary > 0 Begin
					Insert Into [dbo].[FormMovements] (idWeeklyForm, idMovementType, movementDate, salary)
					Values (@weeklyFormId, 2, @currentDate, @salary)

					Update WeeklyForm 
					Set rawSalary = rawSalary + @salary, netsalary = netsalary + @salary
					Where idEmployee = @employeeId and weeklyFormDate is null

					Select @formMovementId = max(id) From FormMovements
					Insert Into [dbo].[MovementJobHours] (id, presenceId) 
					Values (@formMovementId, @jLow)
				End	
			End
			Select @jLow = @jLow + 1
		End

		--Se inserta las incapacidades del archivo.
		Select @jLow = min(num) From @incapacities
		Select @jHigh = max(num) From @incapacities
		While @jLow <= @jHigh Begin
			If (Select I.cDate From @incapacities I Where I.num = @jLow) = @currentDate Begin
				Select @employeeId = E.id From Employee E
				Where E.employeeDocumentId = (Select employeeDocumentId From @incapacities I Where I.num = @jLow)
				Select @idWorkingDayType = idWorkingDayType From @incapacities Where num = @jLow
				Select @weeklyFormId = max(id) From WeeklyForm Where idEmployee = @employeeId

				Insert Into [dbo].[Presence] (idEmployee, idWorkingDayType, inhability, presenceDate,presenceStart, presenceEnd)
				Values (@employeeId, @idWorkingDayType,  1, @currentDate,'0:00', '0:00')

				Select @salary = 0.6 * [dbo].[wff_incapacityPay] (@employeeId, @currentDate, @idWorkingDayType)

				Insert Into [dbo].[FormMovements] (idWeeklyForm, idMovementType, movementDate, salary)
				Values (@weeklyFormId, 3, @currentDate, @salary)

				Update WeeklyForm 
				Set rawSalary = rawSalary + @salary, netsalary = netsalary + @salary
				Where idEmployee = @employeeId and weeklyFormDate is null

				Select @formMovementId = max(id) From FormMovements
				Insert Into [dbo].[MovementJobHours] (id, presenceId) 
				Values (@formMovementId, @jLow)
						
			End
			Select @jLow = @jLow + 1
		End
		


		-- Se insertan los bonos
		Select @jLow = min(num) From @bonuses
		Select @jHigh = max(num) From @bonuses
		While @jLow <= @jHigh Begin
			If (Select B.cDate From @bonuses B Where B.num = @jLow) = @currentDate Begin
				Select @employeeId = E.id From Employee E
				Where E.employeeDocumentId = (Select employeeDocumentId From @bonuses B Where B.num = @jLow)
				Select @weeklyFormId = max(id) From WeeklyForm Where idEmployee = @employeeId
				Select @salary = amount From @bonuses Where num = @jLow

				-- Se actualizan los montos con los bonos
				Update WeeklyForm 
				Set rawSalary = rawSalary + @salary, netsalary = netsalary + @salary
				Where idEmployee = @employeeId and weeklyFormDate is null

				-- Se inserta el movimiento tipo BONO
				Insert Into [dbo].[FormMovements] (idWeeklyForm, idMovementType, movementDate, salary)
				Values (@weeklyFormId, 4, @currentDate, @salary)
			End
			Select @jLow = @jLow + 1
		End




		-- CIERRE DE PLANILLAS SEMANALES / MENSUALES
		-- Si es viernes
		If DatePart(DW, @currentDate) = 6 Begin
			
			-- Se aplican las deducciones por empleado.

			Select @numOfFridays = [dbo].[wff_fridaysOfMonth] (@currentDate)

			Select @jLow = min(id) From EmployeeDeduction
			Select @jHigh = max(id) From EmployeeDeduction
			While @jLow <= @jHigh Begin
				Select @deductionType = idDeductionType From EmployeeDeduction Where id = @jLow
				Select @employeeId = idEmployee From EmployeeDeduction Where id = @jLow
				Select @amount = amount From EmployeeDeduction Where id = @jLow
				-- DEDUCCIONES PORCENTUALES
				If @deductionType = 1 or @deductionType = 2 Begin
					Select @amount = @amount * (Select rawSalary From WeeklyForm Where idEmployee = @employeeId and weeklyFormDate is null) / 100
					Insert Into FormMovements 
					Select id as idWeeklyForm,
					@deductionType + 5 as idDeductionType,
					@currentDate as movementDate,
					@amount as salary
					From WeeklyForm W Where idEmployee = @employeeId and weeklyFormDate is null

					Update WeeklyForm 
					Set netSalary = netSalary - @amount
					Where idEmployee = @employeeId and weeklyFormDate is null
				End Else
				-- DEDUCCIONES FIJAS
				Begin
					Select @amount = @amount / @numOfFridays

					Insert Into FormMovements 
					Select id as idWeeklyForm,
					@deductionType + 5 as idDeductionType,
					@currentDate as movementDate,
					@amount as salary
					From WeeklyForm W Where idEmployee = @employeeId and weeklyFormDate is null

					Update WeeklyForm 
					Set netSalary = netSalary - @amount
					Where idEmployee = @employeeId and weeklyFormDate is null
				End


				Select @jLow = @jLow + 1
			End

			-- Se aplican los saldos de la planilla semanal a la planilla mensual.		
			Select @jLow = min(id) From WeeklyForm Where weeklyFormDate is null
			Select @jHigh = max(id) From WeeklyForm Where weeklyFormDate is null
			While @jLow <= @jHigh Begin
				
				Update MonthlyForm
				Set rawSalary = rawSalary + (Select rawSalary From WeeklyForm Where id = @jLow)
				Where id = (Select idMonthlyForm From WeeklyForm Where id = @jLow)

				Update MonthlyForm
				Set netSalary = netSalary + (Select netSalary From WeeklyForm Where id = @jLow)
				Where id = (Select idMonthlyForm From WeeklyForm Where id = @jLow)

				Select @jLow = @jLow + 1
			End
			
			-- Se cierran las planillas semanales
			Update WeeklyForm
			Set weeklyFormDate = @currentDate
			Where weeklyFormDate is null

			-- Si es el �ltimo viernes del mes
			If DatePart(MONTH, @currentDate) != DatePart(MONTH, DateAdd(Week, 1, @currentDate)) Begin 

				-- Se borran las deducciones mensuales.

				Delete From EmployeeDeduction

				-- Se cierran las planillas mensuales
				Update MonthlyForm
				Set monthlyFormDate = @currentDate
				Where monthlyFormDate is null

				-- Se abren las nuevas planillas mensuales
				Select @jLow = min(id) From Employee
				Select @jHigh = max(id) From Employee
				While @jLow <= @jHigh Begin
					Insert Into MonthlyForm (idEmployee, monthlyFormDate, rawSalary, netSalary)
					Values (@jLow, null, 0, 0)
					Select @jLow = @jLow + 1
				End

			End

			-- Se abren las nuevas planillas semanales
			Select @jLow = min(id) From Employee
			Select @jHigh = max(id) From Employee
			While @jLow <= @jHigh Begin
				Select @monthlyFormId = max(id) From MonthlyForm Where idEmployee = @jLow
				Insert Into WeeklyForm (idEmployee, weeklyFormDate, idMonthlyForm, rawSalary, netSalary)
				Values (@jLow, null, @monthlyFormId, 0, 0)
				Select @jLow = @jLow + 1
			End

		End

		Select @iLow = @iLow + 1
	End
End
go
