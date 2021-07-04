-- This Function Written By : http://mamehdi.parsiblog.com/Posts/1
CREATE FUNCTION [dbo].[SDAT] (@intDate DATETIME , @format as nvarchar(50))
 
RETURNS NVARCHAR(50)

BEGIN
/* Format Rules: (پنجشنبه 7 اردیبهشت 1394)
ChandShanbe -> پنجشنبه (روز هفته به حروف)
ChandShanbeAdadi -> 6 (روز هفته به عدد)
Rooz -> 7 (چندمین روز از ماه)
Rooz2 -> 07 (چندمین روز از ماه دو کاراکتری)
Maah -> 2 (چندمین ماه از سال)
Maah2 -> 02 (چندمین ماه از سال دو کاراکتری)
MaahHarfi -> اردیبهشت (نام ماه به حروف)
Saal -> 1394 (سال چهار کاراکتری)
Saal2 -> 94 (سال دو کاراکتری)
Saal4 -> 1394 (سال چهار کاراکتری)
SaalRooz -> 38 (چندمین روز سال)
Default Format -> 'ChandShanbe Rooz MaahHarfi Saal'
*/
DECLARE @YY Smallint=year(@intdate),@MM Tinyint=10,@DD Smallint=11,@DDCNT Tinyint,@YYDD Smallint=0,
        @SHMM NVARCHAR(8),@SHDD NVARCHAR(8)
DECLARE @SHDATE NVARCHAR(max)



IF @YY < 1000 SET @YY += 2000

IF (@Format IS NULL) OR NOT LEN(@Format)>0 SET @Format = 'ChandShanbe Rooz MaahHarfi Saal'

SET @YY -= 622

IF @YY % 4 = 3 and @yy > 1371 SET @dd = 12

SET @DD += DATEPART(DY,@intDate) - 1

WHILE 1 = 1
BEGIN

 SET @DDCNT =
    CASE
        WHEN @MM < 7 THEN 31
        WHEN @YY % 4 < 3 and @MM=12 and @YY > 1370 THEN 29
        WHEN @YY % 4 <> 2 and @MM=12 and @YY < 1375 THEN 29
        ELSE 30
    END
    IF @DD > @DDCNT
    BEGIN
        SET @DD -= @DDCNT
        SET @MM += 1
        SET @YYDD += @DDCNT
    END
    IF @MM > 12
    BEGIN
        SET @MM = 1
        SET @YY += 1
        SET @YYDD = 0
    END
    IF @MM < 7 AND @DD < 32 BREAK
    IF @MM BETWEEN 7 AND 11 AND @DD < 31 BREAK
    IF @MM = 12 AND @YY % 4 < 3 AND @YY > 1370 AND @DD < 30 BREAK
    IF @MM = 12 AND @YY % 4 <> 2 AND @YY < 1375 AND @DD < 30 BREAK
    IF @MM = 12 AND @YY % 4 = 2 AND @YY < 1371 AND @DD < 31 BREAK
    IF @MM = 12 AND @YY % 4 = 3 AND @YY > 1371 AND @DD < 31 BREAK

END

 SET @YYDD += @DD

SET @SHMM =
    CASE
        WHEN @MM=1 THEN N'فروردین'
        WHEN @MM=2 THEN N'اردیبهشت'
        WHEN @MM=3 THEN N'خرداد'
        WHEN @MM=4 THEN N'تیر'
        WHEN @MM=5 THEN N'مرداد'
        WHEN @MM=6 THEN N'شهریور'
        WHEN @MM=7 THEN N'مهر'
        WHEN @MM=8 THEN N'آبان'
        WHEN @MM=9 THEN N'آذر'
        WHEN @MM=10 THEN N'دی'
        WHEN @MM=11 THEN N'بهمن'
        WHEN @MM=12 THEN N'اسفند'
    END
   

set @SHDD=
    CASE
        WHEN DATEPART(dw,@intdate)=7 THEN N'شنبه'
        WHEN DATEPART(dw,@intdate)=1 THEN N'یکشنبه'
        WHEN DATEPART(dw,@intdate)=2 THEN N'دوشنبه'
        WHEN DATEPART(dw,@intdate)=3 THEN N'سه شنبه'
        WHEN DATEPART(dw,@intdate)=4 THEN N'چهارشنبه'
        WHEN DATEPART(dw,@intdate)=5 THEN N'پنجشنبه'
        WHEN DATEPART(dw,@intdate)=6 THEN N'جمعه'
    END
SET @DDCNT=
    CASE
        WHEN @SHDD=N'شنبه' THEN 1
        WHEN @SHDD=N'یکشنبه' THEN 2
        WHEN @SHDD=N'دوشنبه' THEN 3
        WHEN @SHDD=N'سه شنبه' THEN 4
        WHEN @SHDD=N'چهارشنبه' THEN 5
        WHEN @SHDD=N'پنجشنبه' THEN 6
        WHEN @SHDD=N'جمعه' THEN 7
    END

IF @MM=10 AND @DD>10 SET @YYDD += 276
IF @MM>10 SET @YYDD += 276

SET @SHDATE =
 REPLACE(
 REPLACE(
 REPLACE(
 REPLACE(
 REPLACE(
 REPLACE(
 REPLACE(
 REPLACE(
 REPLACE(
 REPLACE(
 REPLACE(@Format,'MaahHarfi',@SHMM),'SaalRooz',LTRIM(STR(@YYDD,3))),'ChandShanbeAdadi',@DDCNT),'ChandShanbe',
         @SHDD),'Rooz2',REPLACE(STR(@DD,2), ' ', '0')),'Maah2',REPLACE(STR(@MM, 2), ' ', '0')),'Saal2',
         SUBSTRING(STR(@YY,4),3,2)),'Saal4',STR(@YY,4)),'Saal',LTRIM(STR(@YY,4))),'Maah',
         LTRIM(STR(@MM,2))),'Rooz',LTRIM(STR(@DD,2)))
/* Format Samples:
Format='ChandShanbe Rooz MaahHarfi Saal' -> پنجشنبه 17 اردیبهشت 1394
Format='Rooz MaahHarfi Saal' -> ـ 17 اردیبهشت 1394
Format='Rooz/Maah/Saal' -> 1394/2/17
Format='Rooz2/Maah2/Saal2' -> 94/02/17
Format='Rooz روز گذشته از MaahHarfi در سال Saal2' -> ـ 17 روز گذشته از اردیبهشت در سال 94
*/

RETURN @SHDATE
END

GO

CREATE TABLE PersianDates (

	GregorianDate						date					PRIMARY KEY,
	YearMonthDay						varchar(10)				NOT NULL,
	YearMonth							varchar(7)				NOT NULL,
	WeekDayName							nvarchar(10)			NOT NULL,
	WeekDayNumber						tinyint					NOT NULL,
	DayInMonth							tinyint					NOT NULL,
	DayInMonthAtLeastTwo				varchar(2)				NOT NULL,
	MonthNumber							tinyint					NOT NULL,
	MonthNumberAtLeastTwo				varchar(2)				NOT NULL,
	PersianMonthName					nvarchar(15)			NOT NULL,
	YearNumber							smallint				NOT NULL,
	DayInYearNumber						smallint				NOT NULL,
	DayNameInMonth						nvarchar(40)			NOT NULL,
	DayNameInYear						nvarchar(50)			NOT NULL
);

GO

CREATE PROCEDURE PopulatePersianDate @startDate date, @endDate date
AS
BEGIN
	
IF(@endDate < @startDate)
	RETURN

DECLARE @date date;
SET @date = @startDate

WHILE @date <= @endDate
BEGIN


INSERT INTO PersianDates 
(
	GregorianDate
	,WeekDayName
	,WeekDayNumber
	,DayInMonth
	,DayInMonthAtLeastTwo
	,MonthNumber
	,MonthNumberAtLeastTwo
	,PersianMonthName
	,YearNumber
	,DayInYearNumber
	,YearMonthDay
	,YearMonth
	,DayNameInMonth
	,DayNameInYear

)
SELECT 	 @date
		,dbo.SDAT(@date, 'ChandShanbe')
		,Convert(tinyint, dbo.SDAT(@date, 'ChandShanbeAdadi'))
		,Convert(tinyint, dbo.SDAT(@date, 'Rooz'))
		,Convert(varchar(2), dbo.SDAT(@date, 'Rooz2'))
		,Convert(tinyint, dbo.SDAT(@date, 'Maah'))
		,Convert(varchar(2), dbo.SDAT(@date, 'Maah2'))
		,Convert(nvarchar(15), dbo.SDAT(@date, 'MaahHarfi'))
		,Convert(smallint, dbo.SDAT(@date, 'Saal4'))
		,Convert(smallint, dbo.SDAT(@date, 'SaalRooz'))
		,dbo.SDAT(@date,'Saal4/Maah2/Rooz2')
		,Convert(varchar(7), dbo.SDAT(@date, 'Saal4/Maah2'))
		, dbo.SDAT(@date, 'ChandShanbe Rooz MaahHarfi')
		, dbo.SDAT(@date, 'ChandShanbe Rooz MaahHarfi Saal4')


	SET @date = DATEADD(DAY, 1, @date)
	END
END

GO

exec PopulatePersianDate '1921-03-21', '2042-03-20'

GO

CREATE NONCLUSTERED INDEX PersianDateYearMonthDay ON PersianDates (YearMonthDay ASC)
