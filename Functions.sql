Use [WorkerForm]
Go

Create or Alter Function [dbo].[wff_calculate_salary]
	(
	@employeeId int,
	@start Time(7),
	@end Time(7),
	@workingDayType int
	)
Returns money
As Begin
	Declare @salaryPerHour money
	Select @salaryPerHour = hourlySalary 
	From JobByWorkingDayType J
	Where (Select idJob From Employee E Where id = @employeeId) = J.idJob
	and
	J.idWorkigDayType = @workingDayType

	if @start = @end Begin
		Select @start = workingDayStart, @end = workingDayEnd
		From WorkingDayType Where id = @workingDayType
	End
		
	Select @salaryPerHour = @salaryPerHour * DatePart(HOUR,@end ) -  DatePart(HOUR,@start)
	Return @salaryPerHour

End
go

Create or Alter Function [dbo].[wff_calculate_extraHoursPayment]
	(
	@employeeId int,
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

	if @start = @end Begin
		return 0
	End
		
	Select @wdStart = workingDayStart, @wdEnd = workingDayEnd
	From WorkingDayType Where id = @workingDayType

	Select @salaryPerHour = @salaryPerHour * DatePart(HOUR,@end) -  DatePart(HOUR,@start)
	If (@start < @wdStart) Begin
		Select @hoursToPay = @hoursToPay + (DatePart(HOUR,@wdStart) - DatePart(HOUR,@Start))
	End
	If (@wdEnd < @end) Begin
		Select @hoursToPay = @hoursToPay + (DatePart(HOUR,@end) - DatePart(HOUR,@wdEnd))
	End
	
	Return @salaryPerHour * @hoursToPay
End
go