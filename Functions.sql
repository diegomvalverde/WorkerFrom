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