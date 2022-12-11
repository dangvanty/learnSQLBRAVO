SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()), 3) MondayOfCurrentWeek

SELECT * FROM AccDocDetail
SELECT * FROM AccDocDetail 
WHERE cast(Quantity as float) <> cast(Quantity as int)

DECLARE @_A NVARCHAR (32) = N'Máy,Đồng,Tôn'

SELECT * 
FROM item I
INNER JOIN (SELECT value from string_split(@_A,',')) E
    ON I.ItemName LIKE '%'+E.value+'%'

/* BAITAP1: Hiện thị thông tin: Bảng chi tiết chứng từ với 
những vật tư có Quantity không phải là số nguyên.
*/
--SELECT * FROM AccDocDetail
SELECT DocCode, DocNo, ItemCode, Quantity, UnitCost, Amount1, UnitCost, Amount2
FROM AccDocDetail
WHERE CAST (Quantity AS INT ) != Quantity

--BAITAP2: Cho một chuỗi họ và tên: Lấy ra tên đệm và tên.
DECLARE @_ten NVARCHAR(100) = N'Đặng Văn Tỵ'
SELECT RIGHT (@_ten, LEN(@_ten)-CHARINDEX(' ',@_ten,1)) as N'Tên đệm và tên'

--BAITAP3: Cho chuỗi @_A cắt ký tự chuỗi @_A để hiện thị dữ liệu theo từng dòng


go
DECLARE	@_A NVARCHAR(100) = N'êbcdh'
;WITH Position AS (
SELECT 1 AS POS
	UNION ALL
SELECT POS+1 from Position
WHERE POS <LEN (@_A)
)
SELECT SUBSTRING (@_A, POS, 1) as CH	
FROM Position

/*DECLARE @_A NVARCHAR (32); SELECT @_A = N'Bố, Mẹ, Anh, Chị' 
-- cắt ký tự xuống dòng (Không dùng vòng lặp) */
go
DECLARE @_A NVARCHAR (32)= N'Bố, Mẹ, Anh, Chị'
SELECT LTRIM(value) newRow FROM string_split(@_A,',')

/*BAITAP4: Hiển thị danh mục vật tư mà có tên vật tư trong chuỗi danh sách @_List_Ten_VT 
='Máy,Đồng,Tôn'*/
go
DECLARE @_List_Ten_VT NVARCHAR(100)=N'Máy,Đồng,Tôn'
SELECT ItemCode, ItemName,Unit,ItemType,IsActive 
FROM  Item JOIN (SELECT value FROM string_split(@_List_Ten_VT,',')) chuoi
ON ItemName like '%'+chuoi.value+'%'

/*BAITAP5: Hiển thị ký tự đầu viết hoa và ký tự khác 
viết thường trong chuỗi tên có 3 từ 'ninH ngỌc hiếU' */
go
DECLARE @_ten NVARCHAR(100)=N'ninH ngỌc hiếU'
;WITH tenTable AS (SELECT value FROM string_split(@_ten,' '))
SELECT STUFF((SELECT ' ' + UPPER(LEFT(value,1)) + LOWER(Right(value,LEN(value)-1))
          FROM tenTable
          FOR XML PATH('')), 1, 1, '')

/*BAITAP1: Hiện thị các chứng từ phiếu xuất có phát sinh từ ngày hiện tại đến 180 ngày trở về trước gồm: 
DocNo, DocDate, DocGroup, Description.*/
--select * from  AccDoc
SELECT DocNo, DocDate, DocGroup, Description 
FROM AccDoc
WHERE DATEDIFF(dd,DocDate,GETDATE()) <=180 
	AND Description like N'%xuất%' 
go 

/*BAITAP2: Hiện thị các phiếu được bán vào thứ 4 ngày 5.*/
SELECT DocNo, DocDate, DocGroup, Description, DATENAME(dw,DocDate)as day
FROM AccDoc
WHERE Description LIKE  N'%bán%'
AND DATENAME(dw,DocDate) IN ('Wednesday','Thursday')

/*BAITAP3: Sử dụng các hàm ngày tháng để hiển thị thông tin của bảng chứng gồm: DocCode, DocNo, 
DocDate, Thang, Quy, Nam, DocGroup, Description*/
SELECT DocCode, DocNo, 
DocDate, Thang =MONTH(DocDate), Quy=DATENAME(quarter,DocDate), Nam=YEAR(DocDate), DocGroup, Description
FROM AccDoc

/*BAITAP4: Cho một ngày bất kỳ. 
- Lấy ra ngày đầu tháng và ngày cuối tháng
- Lấy ngày đầu tháng cùng kỳ năm trước và ngày cuối tháng cùng kỳ năm trước
*/
DECLARE @_Ngay date = '2022-01-04'
SELECT DATEADD(DD,-(DAY(@_Ngay) -1), @_Ngay) AS FirstDateOfMonth
SELECT DATEADD(DD,-(DAY(@_Ngay)), DATEADD(MM, 1, @_Ngay)) AS LastDateOfMonth
SELECT DATEADD(DD,-(DAY(@_Ngay) -1), DATEADD(YY, -1, @_Ngay)) AS FirstDateOfPreviousMonthYear
SELECT DATEADD(DD,-(DAY(@_Ngay)), DATEADD(MM, 1, DATEADD(YY, -1, @_Ngay))) AS LastDateOFPreviousMonthYear



