use [WorkerForm]
go

Set Dateformat dmy;

Declare @operations XML
Select  @operations = BulkColumn from OpenRowSet(Bulk'C:\Bases\FechaOperacion.XML',Single_blob) AS x;

Declare @dates Table (num int identity(1,1), date Date);

Declare @employees Table (num int identity(1,1), employeeName varchar(50), employeeDocumentId varchar(50), idJob int, date date)
Declare @presences Table (num int identity(1,1), employeeDocumentId varchar(50), idWorkingDayType int, presenceStart time(7), presenceEnd time(7), date date)
Declare @deductions Table (num int identity(1,1), employeeDocumentId varchar(50), idDeductionType int, amount money, date date)
Declare @bonuses Table (num int identity(1,1), employeeDocumentId varchar(50), amount money, date date)

Insert Into @employees 
	Select xCol.value('@nombre', 'varchar(50)') as employeeName,
		xCol.value('@DocId', 'varchar(50)') as emploeeDocumentId,
		xCol.value('@idPuesto', 'int') as idJob,
		xCol.value('(../@Fecha)', 'date') as date
	From @operations.nodes('/dataset/FechaOperacion/NuevoEmpleado') Type(xCol)

Insert into @presences
	Select xCol.value('@DocId', 'varchar(50)') as employeeDocumentId,
		xCol.value('@idTipoJornada', 'int') as idWorkingDayType,
		xCol.value('@HoraEntrada', 'time(7)') as presenceStart,
		xCol.value('@HoraEntrada', 'time(7)') as presenceEnd,
		xCol.value('(../@Fecha)', 'date') as date
	From @operations.nodes('/dataset/FechaOperacion/Asistencia') Type(xCol)

Insert into @deductions
	Select xCol.value('@DocId', 'varchar(50)') as employeeDocumentId,
		xCol.value('@idTipoDeduccion', 'int') as idDeductionType,
		xCol.value('@Valor', 'money') as amount,
		xCol.value('(../@Fecha)', 'date') as date
	From @operations.nodes('/dataset/FechaOperacion/Bono') Type(xCol)

Insert into @bonuses
	Select xCol.value('@DocId', 'varchar(50)') as employeeDocumentId,
		xCol.value('@Valor', 'money') as amount,
		xCol.value('(../@Fecha)', 'date') as date
	From @operations.nodes('/dataset/FechaOperacion/NuevaDeduccion') Type(xCol)

Insert Into @dates 
	Select xCol.value('@Fecha', 'Date') as date
	From @operations.nodes('/dataset/FechaOperacion') Type(xCol)

Declare @iLow int
Declare @iHigh int
Declare @jLow int
Declare @jHigh int

Select @iLow = min(num) From @dates
Select @iHigh = max(num) From @dates


While @iLow <= @iHigh Begin
	



	Select @iLow = @iLow + 1
End