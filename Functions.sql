Use [WorkerForm]
Go

Create or Alter Function [dbo].[wff_calculate_salary]
	(
	@employeeId int,
	@date Date,
	@start Time(7),
	@end Time(7),
	@workingDayType int
	)
Returns money
As Begin
	Declare @salaryPerHour money
	Declare @wdStart Time(7)
	Declare @wdEnd Time(7)
	Declare @hoursToPay int
	Select @salaryPerHour = hourlySalary 
	From JobByWorkingDayType J
	Where (Select idJob From Employee E Where id = @employeeId) = J.idJob
	and
	J.idWorkigDayType = @workingDayType
	
	Select @wdStart = workingDayStart, @wdEnd = workingDayEnd
	From WorkingDayType Where id = @workingDayType

	If @start = @end Begin
		Select @start = workingDayStart, @end = workingDayEnd
		From WorkingDayType Where id = @workingDayType
	End
	
	If (@start < @wdStart) Begin
		Select @start = @wdStart
	End
	If (@wdEnd < @end) Begin
		Select @end = @wdEnd
	End

	-- MONTO A PAGAR VARÍA SI ES DOMINGO O FERIADO
	If DATEPART(DW, @date) = 1 or Exists(Select 1 From HolyDays H Where holyDayDate = @date) Begin
		Select @salaryPerHour = @salaryPerHour * 2.0
	End		

	If @start > @end 
		Select @hoursToPay = DatePart(HOUR,@end ) + 24 -  DatePart(HOUR,@start)
	Else
		Select @hoursToPay = DatePart(HOUR,@end ) -  DatePart(HOUR,@start)

	Return @salaryPerHour * @hoursToPay
End
go

Create or Alter Function [dbo].[wff_incapacityPay]
	(
	@employeeId int,
	@date Date,
	@workingDayType int
	)
Returns money
As Begin
	Declare @salaryPerHour money
	Declare @start Time(7)
	Declare @end Time(7)
	Declare @hoursToPay int
	Select @salaryPerHour = hourlySalary 
	From JobByWorkingDayType J
	Where (Select idJob From Employee E Where id = @employeeId) = J.idJob
	and
	J.idWorkigDayType = @workingDayType
	
	Select @start = workingDayStart, @end = workingDayEnd
	From WorkingDayType Where id = @workingDayType

	-- MONTO A PAGAR VARÍA SI ES DOMINGO 
	If DATEPART(DW, @date) = 1 or Exists(Select 1 From HolyDays H Where holyDayDate = @date) Begin
		Select @salaryPerHour = @salaryPerHour * 2.0
	End		

	If @start > @end 
		Select @hoursToPay = DatePart(HOUR,@end ) + 24 -  DatePart(HOUR,@start)
	Else
		Select @hoursToPay = DatePart(HOUR,@end ) -  DatePart(HOUR,@start)

	Return @salaryPerHour * @hoursToPay
End
go

Create or Alter Function [dbo].[wff_calculate_extraHoursPayment]
	(
	@employeeId int,
	@date Date,
	@start Time(7),
	@end Time(7),
	@workingDayType int
	)
Returns money
As Begin
	Declare @salaryPerHour money
	Declare @wdStart Time(7)
	Declare @wdEnd Time(7)
	Declare @hoursToPay int
	Select @hoursToPay = 0

	Select @salaryPerHour = hourlySalary 
	From JobByWorkingDayType J
	Where (Select idJob From Employee E Where id = @employeeId) = J.idJob
	and
	J.idWorkigDayType = @workingDayType
		
	Select @wdStart = workingDayStart, @wdEnd = workingDayEnd
	From WorkingDayType Where id = @workingDayType
	
	If (@wdEnd < @end) Begin
		If (@start > @end and @start > @wdEnd) or (@start < @end and @start < @wdEnd)
			Select @hoursToPay = DatePart(HOUR,@end) - DatePart(HOUR,@wdEnd)
		Else
			Select @hoursToPay = 24 - (DatePart(HOUR,@end) - DatePart(HOUR,@wdEnd))
	End
	
	If DATEPART(DW, @date) = 1 or Exists(Select 1 From HolyDays H Where holyDayDate = @date) Begin
		Select @salaryPerHour = @salaryPerHour * 2.0
	End							

	Return @salaryPerHour * @hoursToPay * 1.5
End
go

Create or Alter Function [dbo].[wff_fridaysOfMonth]
	(
	@date Date
	)
Returns int
As Begin
	Declare @numOfFridays int
	Declare @tDate date
	Select @numOfFridays = 0
	Select @date = DATEADD(DAY,1 - DATEPART(DAY,@date), @date)
	Select @tDate = @date

	While DATEPART(MONTH, @date) = DATEPART(MONTH, @tDate) Begin
		If DATEPART(DW, @tDate) = 6
			Select @numOfFridays = @numOfFridays + 1
		Select @tDate = DATEADD(DAY, 1, @tDate)
	End

	Return @numOfFridays
End
go
