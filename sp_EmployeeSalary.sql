USE [TrainDB122484]
GO

/****** Object:  StoredProcedure [dbo].[sp_EmployeeSalary]    Script Date: 2023/12/11 上午 10:34:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**********************************************************
功能說明: < sp三種功能說明。【1.無參數就加薪 < 25000的員工。】【2.代入一個員工編號參數，就是加薪該同仁10%薪資。】【3.代入兩個參數(員工編號、薪資)就是該同仁薪資為參數輸入的薪資】
建立人員: <>
建立日期: <2023.11.7>
修改紀錄: <2023.11.7>
範	  例: < 【1. EXEC sp_EmployeeSalary】【2. EXEC sp_EmployeeSalary @EmpNo = 0007】【3. EXEC sp_EmployeeSalary @EmpNo = 0007, @NewSalary = 20000】 >
參	  考: 
***********************************************************/
CREATE PROCEDURE [dbo].[sp_EmployeeSalary]
@EmpNo INT = NULL,
@NewSalary DECIMAL(10,2) = NULL
AS
BEGIN
   SET NOCOUNT ON;
   BEGIN TRY
       BEGIN TRANSACTION
       DECLARE @OldSalary DECIMAL(10,2)

       IF @EmpNo IS NULL
       BEGIN
           DECLARE @EmpNoCursor INT
           DECLARE @SalaryCursor DECIMAL(10,2)

           -- 使用子查詢獲得需要加薪的員工資料
           DECLARE EmployeeCursor CURSOR FOR
           SELECT EmpNo, Salary
           FROM Employee
           WHERE Salary < (SELECT MAX(Salary) FROM Employee)

           OPEN EmployeeCursor
           FETCH NEXT FROM EmployeeCursor INTO @EmpNoCursor, @SalaryCursor
           WHILE @@FETCH_STATUS = 0
           BEGIN
               SET @OldSalary = @SalaryCursor

			   -- 沒代入參數： 全部薪水小於25000的員工都加薪，其餘人薪水不動
               IF @SalaryCursor < 25000
               BEGIN
                   SET @NewSalary = 25000
               END

               ELSE
               BEGIN
                   SET @NewSalary = @SalaryCursor * 1
               END

               UPDATE Employee
               SET Salary = @NewSalary
               WHERE EmpNo = @EmpNoCursor

               -- 紀錄薪水的LOG
               INSERT INTO SalaryAdjustmentLog (EmpNo, OldSalary, NewSalary, AdjustDate)
               VALUES (@EmpNoCursor, @OldSalary, @NewSalary, GETDATE())

               FETCH NEXT FROM EmployeeCursor INTO @EmpNoCursor, @SalaryCursor
           END
           CLOSE EmployeeCursor
           DEALLOCATE EmployeeCursor
       END

	   --@EmpNo != NULL 表示有帶入@EmpNo參數
       ELSE
       BEGIN
           -- 代入一個員工編號參數：只加薪這個員工10%的薪資
		   --@EmpNo != NULL 和 @NewSalary = NULL
           IF @NewSalary IS NULL
           BEGIN
               -- 使用子查詢獲得需要加薪的員工資料
               SELECT @SalaryCursor = Salary
               FROM Employee
               WHERE EmpNo = @EmpNo

               -- 計算新的薪資
               SET @OldSalary = @SalaryCursor
               SET @NewSalary = @SalaryCursor * 1.1

               -- 更新員工薪水
               UPDATE Employee
               SET Salary = @NewSalary
               WHERE EmpNo = @EmpNo
			   --WHERE EmpNo = @EmpNoCursor

               -- 紀錄薪水的LOG
               INSERT INTO SalaryAdjustmentLog (EmpNo, OldSalary, NewSalary, AdjustDate)
               VALUES (@EmpNo, @OldSalary, @NewSalary, GETDATE())
           END

           -- 代入員工編號和薪資共兩個參數：更新該員工的薪資為代入的參數
		   --@EmpNo != NULL 和 @NewSalary != NULL
           ELSE
           BEGIN
               UPDATE Employee
               SET Salary = @NewSalary
               WHERE EmpNo = @EmpNo
           END
       END
       COMMIT
   END TRY
   BEGIN CATCH
       ROLLBACK
       INSERT INTO ErrorLog (ErrorMessage, ErrorDate)
       VALUES (ERROR_MESSAGE(), GETDATE())
   END CATCH
END
GO


