USE [TrainDB122484]
GO

/****** Object:  StoredProcedure [dbo].[sp_ResultDate]    Script Date: 2023/12/11 上午 10:30:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**********************************************************
功能說明: <傳日期和類型的參數，根據結果回傳相應的日期，並以8碼結果呈現>
建立人員: <>
建立日期: <2023.10.27>
修改紀錄: <2023.10.27>
範	  例: <EXEC sp_ResultDate '20231015' , 'm'>
參	  考: https://dotblogs.com.tw/lastsecret/2010/10/04/18097
***********************************************************/
--CREATE PROCEDURE [dbo].[sp_ResultDate] 
CREATE PROCEDURE [dbo].[sp_ResultDate] 
	
	--定義輸入的參數
	@date AS VARCHAR(8),	--輸入日期
	@feq AS VARCHAR(1)		--頻率類型
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--宣告變數@resultDate，用來儲存計算之後的結果日期
	DECLARE @resultDate AS VARCHAR(8)

	--將輸入的日期值，轉換為日期類型
	DECLARE @inputDate AS DATE
	SET @inputDate = CAST(SUBSTRING(@date, 1, 4) + '-' + SUBSTRING(@date, 5, 2) + '-' + SUBSTRING(@date, 7, 2) AS DATE)

	--SET @date = SUBSTRING(@date, 1, 4) + '-' + SUBSTRING(@date, 5, 2) + '-' + SUBSTRING(@date, 7, 2) 

	--================================【上月底】================================
	IF @feq = 'm'
	BEGIN
	
	-- DATEADD(DAY, -DAY(@inputDate), @inputDate)說明
	-- DATEADD(單位是日, 減去日期的部分, 要減去日期的起始時間)
	-- => select DATEADD(DAY, -DAY('2023-10-30'), '2023-10-30') => '2023-09-30'
		SET @resultDate = CONVERT(VARCHAR(8), DATEADD(DAY, -DAY(@inputDate), @inputDate),112)
	END

	--================================【上季底】================================
	ELSE IF @feq = 's'
	BEGIN
	--dateadd(單位, 正數為加/負數為減, 抓出目前時間日期)
	--DATEADD(單位是季, (加多少日期的部分), 要減去日期的起始時間 )
	--DATEADD(單位是季, DATEDIFF(單位是季, 開始的時間為0, 結束的時間為輸入日期 ) , 要減去日期的起始時間 )
	--=>總結變成 DATEDIFF先計算輸入的日期跟1900-01-01差距幾個季 再利用DATEADD執行輸入的日期當季-1季
		SET @resultDate = CONVERT(VARCHAR(8), DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @inputDate), -1), 112)
	END

	--================================【上年底】================================
	ELSE IF @feq ='y'
	BEGIN
	-- DATEADD(DAY, -DAY(@inputDate), DATEADD(YEAR, -1, @inputDate))說明
	-- DATEADD(單位是日, 減去日期的部分, DATEADD(單位是年, 減去1年的部分, 要減去日期的起始時間) )
	-- => 總結上面一行變成 DATEADD(單位是日, 減去日期的部分, 輸入的日期減去1年的結果 )
	--select DATEADD(DAY, -DAY('2023-10-30'), DATEADD(YEAR, -1, '2023-10-30')) => '2022-09-30
		SET @resultDate = CONVERT(VARCHAR(8), DATEADD(DAY, -DAY(@inputDate), DATEADD(YEAR, -1, @inputDate)),112)
	END

	--其他
	ELSE
	BEGIN
		--輸入的不是 'm' 或 's' 或 'y'
		SET @resultDate = '無效結果'
	END
	
    -- 傳回最終結果
	SELECT @resultDate AS ResultDate
END
GO


