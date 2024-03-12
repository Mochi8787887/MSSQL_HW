USE [TrainDB122484]
GO

/****** Object:  UserDefinedFunction [dbo].[func_GetValue]    Script Date: 2023/12/11 上午 10:36:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[func_GetValue](@DeptNo VARCHAR(10))
RETURNS VARCHAR(10)
AS
BEGIN
	--宣告總薪資
	DECLARE @TotalSalary INT

	--加總薪資總和並回傳顯示
	SELECT @TotalSalary = SUM(Salary)
	FROM Employee
	WHERE DeptNo = @DeptNo
	RETURN @TotalSalary
END
GO


