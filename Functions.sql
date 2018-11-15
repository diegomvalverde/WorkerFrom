Use [WorkerForm]
Go

Create or Alter Function [dbo].[wff_calculate_salary]
	(
	@employeeDocumentId int,
	@start Time(7),
	@end Time(7),
	@workingDayType int
	)
Returns money
As Begin
	Declare @salaryPerHour money
	Select @salaryPerHour = hourlySalary 
	From JobByWorkingDayType J
	Where (Select idJob From Employee E Where employeeDocumentId = @employeeDocumentId) = J.idJob
	and
	J.idWorkigDayType = @workingDayType

	if @start = @end Begin
		Select @start = workingDayStart, @end = workingDayEnd
		From WorkingDayType Where id = @workingDayType

		Select @salaryPerHour = @salaryPerHour * DatePart(HOUR,@end - @start)
		Return @salaryPerHour
	End
		
	Select @salaryPerHour = @salaryPerHour * DatePart(HOUR,@end - @start)
	Return @salaryPerHour

End