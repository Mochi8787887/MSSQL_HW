USE [TrainDB122484]
GO

/****** Object:  StoredProcedure [dbo].[sp_CheckReservation]    Script Date: 2023/12/11 上午 10:28:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**********************************************************
功能說明: <時間序列(15分鐘為一單位)、檢核同一個時間僅限兩人使用>
建立人員: <>
建立日期: <2023.11.8>
修改紀錄: <2023.11.8>
範	  例: <exec sp_CheckReservation '0587', '2023-10-15', '2023-10-15 09:15:00.000', '2023-10-15 09:30:00.000'>
參	  考: 
***********************************************************/
CREATE PROCEDURE [dbo].[sp_CheckReservation] 
	
   @EmpNo varchar(10),
   @AbsDate date,
   @StartTime datetime,
   @EndTime datetime
AS
BEGIN
   -- 計算在指定時間範圍內的連線數量
   DECLARE @CountReservations int
   SELECT @CountReservations = COUNT(*)
   FROM Reservation
   WHERE EmpNo = @EmpNo
     AND AbsDate = @AbsDate
     AND ((StartTime >= @StartTime AND StartTime < @EndTime)
       OR (EndTime > @StartTime AND EndTime <= @EndTime))

   -- 檢查連線數量，如果超過兩個，則不允許連線
   IF @CountReservations >= 2
   BEGIN
       PRINT '無法連線，已經有兩個連線在同一個時段使用。'
   END
   ELSE
   BEGIN
       -- 可以連線，插入新的連線記錄
       INSERT INTO Reservation (EmpNo, AbsDate, StartTime, EndTime)
       VALUES (@EmpNo, @AbsDate, @StartTime, @EndTime)
       PRINT '連線成功。'
   END
END
GO


