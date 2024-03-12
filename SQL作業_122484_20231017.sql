USE [TrainDB122484]

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
