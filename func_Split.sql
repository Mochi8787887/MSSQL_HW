USE [TrainDB122484]
GO

/****** Object:  UserDefinedFunction [dbo].[func_Split]    Script Date: 2023/12/11 上午 10:36:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/**********************************************************
功能說明: <取得字串中,以分隔符號區隔的資料>
建立人員: <高鈺翔>
建立日期: <2023.10.30>
修改紀錄: <2023.10.30>
範	  例: <select dbo.func_Split('今天,溫度是,非常,熱' , ',' ,3)>
餐	  考: https://medium.com/@vevin045/tsql-%E5%9C%A8mssql%E4%B8%AD%E4%BD%BF%E7%94%A8string-split-%E5%87%BD%E5%BC%8F%E5%88%86%E9%9A%94-%E5%A4%9A%E5%AD%97%E5%85%83-%E5%88%86%E9%9A%94%E7%AC%A6-932f8b70f5dc
***********************************************************/
--CREATE FUNCTION func_Split
CREATE FUNCTION [dbo].[func_Split]
(	
	--定義輸入的參數
	@inputString VARCHAR(MAX),		--輸入的字串
	@delimiter CHAR(1),				--符號
	@position INT					--傳回位置的數值
)
RETURNS VARCHAR(MAX)		--傳回結果字串
AS
BEGIN
	--儲存最後結果的值
	DECLARE @outputString VARCHAR(MAX)

	--宣告暫存表，儲存「分割字串的值」還有「行號數值」
	DECLARE @splitValues TABLE (value VARCHAR(MAX), RowNum INT)

	--輸入的字串，按照「分隔符號-逗號」分割，將結果insert到暫存表中
	insert into @splitValues

	--ROW_NUMBER 依序為所有資料列編號
	--OVER(ORDER BY (select null)不幫結果排序 滿足ROW_NUMBER函數用法 
	--string_split(輸入的字串, 符號) 將輸入的字串按照符號分隔成多個值
	select value, ROW_NUMBER() OVER(ORDER BY (select null))
	from string_split(@inputString, @delimiter)

	--查詢上面的暫存表，來獲取指定位置的值
	select @outputString = value
	from @splitValues
	where RowNum = @position

	--回傳最終結果
	RETURN @outputString
END
GO


