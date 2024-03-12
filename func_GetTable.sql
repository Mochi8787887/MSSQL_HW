USE [TrainDB122484]
GO

/****** Object:  UserDefinedFunction [dbo].[func_GetTable]    Script Date: 2023/12/11 上午 10:34:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[func_GetTable](@EmpNo INT)
RETURNS TABLE
AS
RETURN (
		SELECT e.EmpNo, e.EmpName, a.AbsName, ad.AbsDate, ad.AbsHour
		FROM Employee e
		left join AbsDetail ad on e.EmpNo = ad.EmpNo
		left join Absent a on ad.AbsType = a.AbsType
		where e.EmpNo = @EmpNo
		)
GO


