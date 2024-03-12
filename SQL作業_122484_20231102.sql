USE [TrainDB122484]
--==========================================【作業一】==================================================
/* 1.計算每一部門所需的部門名稱、薪資總額、平均薪資，並照薪資總額由高到低排序
(每一部門的定義：若有部門轄下都無同仁，則薪資總額與平均薪資皆顯示為0)*/
select D.DeptNo, D.DeptName, sum(E.Salary) SumSalary, avg(E.Salary) AvgSalary
from Dept D
left join Employee E on D.DeptNo = E.DeptNo
group by D.DeptNo, D.DeptName
order by SumSalary DESC

-- 2.計算每一部門的部門名稱、總人數
select D.DeptNo, D.DeptName, count(E.EmpNo) CountEmpNo
from Dept D
left join Employee E on D.DeptNo = E.DeptNo
group by D.DeptNo, D.DeptName
order by DeptNo

-- 3.計算公司裡男女生的人數總人數
select Sex, count(Sex) CompanySex
from Employee
group by Sex

-- 4.計算每一員工的員工姓名、2021/03/15以後(含)請假的總時數(某員工03/15後沒請假需顯示0)
select E.EmpNo, E.EmpName, coalesce(sum(AD.AbsHour), 0) SumHour
from Employee E
left join AbsDetail AD on E.EmpNo = AD.EmpNo and AD.AbsDate >= '2021-03-15'
group by E.EmpNo, E.EmpName
order by EmpNo

-- 5.計算每一員工的員工姓名、2017/12/15以後(含)請假的總時數，總時數超過6小時的才顯示
select E.EmpNo, E.EmpName, sum(AD.AbsHour) SumHour
from Employee E
left join AbsDetail AD on E.EmpNo = AD.EmpNo and AD.AbsDate >= '2017-12-15'
group by E.EmpNo, E.EmpName
having sum(AD.AbsHour) > 6
order by EmpNo

-- 6.計算每一員工每一種假別的請假總時數(某員工的某假別沒請假需顯示0)
select E.EmpNo, E.EmpName, A.AbsType, A.AbsName, coalesce(sum(AD.AbsHour), 0) SumHour
from Employee E
cross join Absent A
left join AbsDetail AD on E.EmpNo = AD.EmpNo and A.AbsType = AD.AbsType
group by E.EmpNo, E.EmpName, A.AbsType, A.AbsName
order by EmpNo

-- 7.計算每一部門男女生總人數各多少(某部門沒人員請顯示無)
select D.DeptName, Sex, count(Sex) CompanySex
from Employee E
left join Dept D on E.DeptNo = D.DeptNo
group by D.DeptName, Sex
order by DeptName, Sex

-- 8.計算公司內各月過生日的總人數
select DatePart(Month, Birth) BirthMonth, Count(*) TotalPerson
from Employee
group by DatePart(Month, Birth)
order by BirthMonth

-- 9.將每一員工、每一種假別，在2017年以後請假總時數大於5小時的人顯示出來
select E.EmpNo, E.EmpName, A.AbsType, A.AbsName, coalesce(sum(AD.AbsHour), 0) SumHour
from Employee E
cross join Absent A
left join AbsDetail AD on E.EmpNo = AD.EmpNo and A.AbsType = AD.AbsType and AD.AbsDate >= '2017-01-01'
group by E.EmpNo, E.EmpName, A.AbsType, A.AbsName
having sum(AD.AbsHour) > 5
order by EmpNo

--==========================================【作業二】==================================================
/* 10.請寫一個STORE PROCEDURE，INPUT(@date as varchar(8),@feq as varchar(1) )
—m/s/y找出上月底/上季底/上年底的日期，回傳8字元，ex:20210630*/
EXEC sp_ResultDate '20231015', 'm'

EXEC sp_ResultDate '20230615', 's'

EXEC sp_ResultDate '20231015', 'y'

/* 11.請寫一個Function，取得字串中,以分隔符號區隔的資料
select dbo.fun_SplitToTable('AB,CD,EF,G',',','4') --=> G*/
select dbo.func_Split('AB,CD,EF,G' , ',',4)
select dbo.func_Split('今天,溫度是,非常,熱' , ',' ,3)

-- 12.請寫一個View，至少串起來2個table資料表
Create VIEW EmployeeDeptView AS
select E.EmpNo, E.EmpName, E.Sex, D.DeptName
from Employee E
inner join Dept D on E.DeptNo = D.DeptNo

select * from EmployeeDeptView

/* 13.請寫一個STORE PROCEDURE(包含變數宣告使用，包含 CURSOR 迴圈 、IF ELSE、
有SELECT(需有一筆子查詢)、INSERT & UPDATE 至少兩句、並使用Transaction,TRY CATCH …. ，交易程序*/

--重置第一個員工薪資(方便執行三種sp的情況)
update Employee set Salary = '10000' where EmpNo = '0007'

--情況一：無參數就加薪 < 25000的員工。
EXEC sp_EmployeeSalary
select * from Employee

--情況二：代入一個員工編號參數，就是加薪該同仁10%薪資
EXEC sp_EmployeeSalary @EmpNo = 0007
select * from Employee

--情況三：代入兩個參數(員工編號、薪資)就是該同仁薪資為參數輸入的薪資
EXEC sp_EmployeeSalary @EmpNo = 0007, @NewSalary = 20000
select * from Employee


-- 14.寫二個Function，一個回傳值 ，另一個回傳 TABLE，並使用SELECT 使用這兩函式。

--回傳職(參數代部門代號) => 取得部門薪水總和
select dbo.func_GetValue('M01') AS Result
select dbo.func_GetValue('D01') AS Result

--回傳TABLE(參數代員工編號) => 取得員工請假詳細資訊
select * from dbo.func_GetTable(0251) 
select * from dbo.func_GetTable(0587) 

-- 15.思考題:時間序列(15分鐘為一單位)、檢核同一個時間僅限兩人使用，請練習設計一個TABLE並下SELECT檢核。

--sp參數說明: '員工編號', '連線日期', '連線開始時間', '連線結束時間'
exec sp_CheckReservation '0587', '2023-10-15', '2023-10-15 09:15:00.000', '2023-10-15 09:30:00.000'

--快速測試方式(sp連續執行兩次後 select執行 再重複前面步驟)
select * from Reservation
