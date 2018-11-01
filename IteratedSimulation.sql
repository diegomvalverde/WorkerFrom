use [WorkerForm]
go

Set Dateformat dmy;

Declare @operations XML
Select  @operations = BulkColumn from OpenRowSet(Bulk'C:\Operaciones\FechaOperacion.XML',Single_blob) AS x;

Declare @dates Table (num int identity(1,1), date Date);

Declare @employees Table (num int identity(1,1), employeeName varchar(50), employeeDocumentId varchar(50), idJob int)
Declare @presences Table (num int identity(1,1), employeeDocumentId varchar(50), idWorkingDayType int, presenceStart time(7), presenceEnd time(7))
Declare @deductions Table (num int identity(1,1), employeeDocumentId varchar(50), idDeductionType int, amount money)
Declare @bonuses Table (num int identity(1,1), employeeDocumentId varchar(50), amount money)

Insert Into @dates SELECT xCol.value('@Fecha', 'Date') As Date
FROM @operations.nodes('/dataset/FechaOperacion') Type(xCol)

Declare @iLow int
Declare @iHigh int

Select @iLow = min(num) From @dates
Select @iHigh = max(num) From @dates

While @iLow <= @iHigh Begin
	Select date From @dates Where num = @iLow




	Select @iLow = @iLow + 1
End