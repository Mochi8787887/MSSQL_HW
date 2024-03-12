USE [TrainDB122484]
GO

/****** Object:  View [dbo].[EmployeeDeptView]    Script Date: 2023/12/11 上午 10:26:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create VIEW [dbo].[EmployeeDeptView] AS
select E.EmpNo, E.EmpName, E.Sex, D.DeptName
from Employee E
inner join Dept D on E.DeptNo = D.DeptNo
GO


