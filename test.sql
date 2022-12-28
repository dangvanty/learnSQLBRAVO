SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()), 3) MondayOfCurrentWeek
-- SET STATISTICS TIME ON 
-- SELECT * FROM AccDoc

SELECT COUNT(DISTINCT DocCode ) FROM AccDoc
SELECT * FROM AccDocDetail 
WHERE cast(Quantity as float) <> cast(Quantity as int)
SET STATISTICS TIME ON
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
go
--c2

DECLARE @_List_Ten_VT NVARCHAR(100)=N'Máy,Đồng,Tôn'
SELECT ItemCode, ItemName,Unit,ItemType,IsActive 
FROM  Item JOIN (SELECT value FROM string_split(@_List_Ten_VT,',')) chuoi
ON CHARINDEX(chuoi.value,ItemName) >0

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
--c2
SELECT DocNo, DocDate, DocGroup, Description 
FROM AccDoc
WHERE DATEDIFF(dd,DocDate,GETDATE()) <=580
	AND CHARINDEX('xuất',Description) >0 

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

----check

SELECT DocCode, ItemCode,
    CASE WHEN DocCode = 'NM' THEN SUM(Quantity)
        ELSE CAST(0 AS NUMERIC(15,3)) END AS Nhap_Mua,
    CASE WHEN DocCode = 'PX' THEN SUM(Quantity)
        ELSE CAST(0 AS NUMERIC(15,3)) END AS Xuat_Sx,
    CASE WHEN DocCode = 'TP' THEN SUM(Quantity)
        ELSE CAST(0 AS NUMERIC(15,3)) END AS Nhap_Tp,
    CASE WHEN DocCode = 'HD' THEN SUM(Quantity)
        ELSE CAST(0 AS NUMERIC(15,3)) END AS Xuat_Ban
FROM AccDocDetail
GROUP BY DocCode, ItemCode
ORDER BY DocCode, ItemCode

SELECT CustomerCode, CustomerName 
FROM Customer
WHERE EXISTS (SELECT TOP 1 CustomerCode
FROM AccDoc 
WHERE Customer.CustomerCode = AccDoc.CustomerCode 
AND AccDoc.DocCode = 'HD')

--====================================
-- Chương VI
--====================================
--BÀI TẬP 1: Thay thế ‘NM’ thành ‘TP’ của DocNo trong bảng AccDoc với DocCode = ‘TP’ 
UPDATE AccDoc 
SET DocNo=REPLACE(DocNo,'NM','TP')
WHERE DocCode='TP'
--BÀI TẬP 2: Tạo khóa chính cho bảng Item, Customer, AccDoc
select * from AccDoc
ALTER TABLE Item
ADD CONSTRAINT PK_Item_ItemCode PRIMARY KEY (ItemCode)

ALTER TABLE Customer
ADD CONSTRAINT PK_Customer_CustomerCode PRIMARY KEY (CustomerCode)

ALTER TABLE AccDoc
ADD CONSTRAINT PK_AccDoc_DocNo PRIMARY KEY (DocNo)


--BÀI TẬP 3: Tạo khóa ngoại cho các bảng AccDocDetail trường DocNo, OpenInventory trường ItemCode
ALTER TABLE AccDocDetail
    ADD CONSTRAINT FK_AccDocDetail_DocNo 
        FOREIGN KEY (DocNo) REFERENCES AccDoc(DocNo)

ALTER TABLE OpenInventory 
    ADD CONSTRAINT FK_OpenInventory_ItemCode
        FOREIGN KEY (ItemCode) REFERENCES OpenInventory(ItemCode)

--BÀI TẬP 4: Thêm trường TaxCode vào bảng Customer và tạo UNIQUE cho TaxCode
ALTER TABLE Customer
ADD TaxCode NVARCHAR(16) NOT NUll UNIQUE

--BÀI Tập 5: Tạo thêm INDEX cho bảng AccDoc trường CustomerCode, bảng AccDocDetail trường  ItemCode
CREATE  NONCLUSTERED INDEX IX_AccDoc ON AccDoc (CustomerCode)
CREATE  NONCLUSTERED INDEX IX_AccDocDetail ON AccDocDetail (ItemCode)

--BÀI TẬP 6: Tìm mặt hàng có tổng số lượng bán lớn nhất

;WITH SortQuantity_CTE as(
    SELECT ItemCode, DENSE_RANK() OVER ( ORDER BY SUM(Quantity) DESC) AS rank
    FROM AccDocDetail 
    WHERE DocCode ='HD'
    GROUP BY ItemCode
)

SELECT ItemCode, ItemName, Unit, ItemType, IsActive
FROM Item 
WHERE ItemCode IN
    (SELECT ItemCode FROM SortQuantity_CTE WHERE rank =1)
go

--BÀI TẬP 7: Tìm mặt hàng có tổng số lần bán lớn nhất
;WITH SortCountSale_CTE as(
    SELECT ItemCode, DENSE_RANK() OVER ( ORDER BY COUNT(*) DESC) AS rank
    FROM AccDocDetail
    WHERE DocCode ='HD'
    GROUP BY ItemCode
)

SELECT ItemCode, ItemName, Unit, ItemType, IsActive
FROM Item 
WHERE ItemType = 2 AND ItemCode IN
    (SELECT ItemCode FROM SortCountSale_CTE WHERE rank =1)

--BÀI TẬP 8: Tìm mặt hàng có tổng doanh số bán lớn nhất.

;WITH SortSumSale_CTE as(
    SELECT ItemCode, DENSE_RANK() OVER ( ORDER BY SUM(Amount2) DESC) AS rank
    FROM AccDocDetail
    WHERE DocCode ='HD'
    GROUP BY ItemCode
)
SELECT ItemCode, ItemName, Unit, ItemType, IsActive
FROM Item 
WHERE ItemType = 2 AND ItemCode IN
    (SELECT ItemCode FROM SortSumSale_CTE WHERE rank =1)

--BÀI TẬP 9: Thể hiện tổng số tiền mua hàng và số tiền bán hàng của từng ngày gồm các cột:
--DocCode, DocDate, Tien_Mua, Tien_Ban.
SELECT a.DocCode, DocDate, Tien_Mua=SUM(Amount1), Tien_Ban=SUM(Amount2)
FROM AccDoc a LEFT JOIN AccDocDetail ad On a.DocNo =ad.DocNo
WHERE a.DocCode in ('NM','HD')
GROUP BY a.DocDate,a.DocCode

/*BÀI TẬP 10: Cho bảng kế hoạch sản xuất (ProductionPlan) như sau:
            ItemCode Plan
            TP01     1000
            TP02     800
            TP03     700
- Lấy ra danh sách sản phẩm và sản lượng hoàn thành kế hoạch sản xuất
- Lấy ra danh sách sản phẩm và sản lượng không hoàn thành kế hoạch sản xuất
*/
;WITH SPComplete_CTE AS ( SELECT ItemCode,
    CASE 
        WHEN ItemCode='TP01' AND Quantity>=1000 THEN Quantity
        WHEN ItemCode='TP02' AND Quantity>=800 THEN Quantity
        WHEN ItemCode='TP03' AND Quantity>=700 THEN Quantity
    END as Quantity
FROM OpenInventory )
SELECT * FROM SPComplete_CTE WHERE Quantity IS NOT NULL

;WITH SPNOTComplete_CTE AS ( SELECT ItemCode,
    CASE 
        WHEN ItemCode='TP01' AND Quantity<1000 THEN Quantity
        WHEN ItemCode='TP02' AND Quantity<800 THEN Quantity
        WHEN ItemCode='TP03' AND Quantity<700 THEN Quantity
    END as Quantity
FROM OpenInventory )
SELECT * FROM SPNOTComplete_CTE WHERE Quantity IS NOT NULL


--------------------------
--Chương VII
--------------------------
--VD: Nếu muốn lấy bảng kê đầy đủ của những khách hàng và mặt hàng bán ra trong tháng thể hiện 
--đầy đủ ngày bán hàng, tên khách hàng, tên hàng hóa thì sẽ kết hợp các hình thức JOIN dữ liệu từ 4 
--bảng.
SELECT Tb1.DocCode, Tb1.DocNo, Tb1.DocDate, Tb1.CustomerCode,
Cus.CustomerName, Tb2.ItemCode, Item.ItemName, Item.Unit,
Tb2.Quantity, Tb2.UnitPrice, Tb2.Amount2
 FROM AccDocDetail Tb2 
INNER JOIN AccDoc Tb1 ON Tb1.DocNo = Tb2.DocNo
LEFT OUTER JOIN Customer Cus ON Tb1.CustomerCode = Cus.CustomerCode
LEFT OUTER JOIN Item Item ON Tb2.ItemCode = Item.ItemCode
WHERE Tb1.DocCode = 'HD'
ORDER BY Tb1.DocNo, Tb2.ItemCode

/*BAITAP1: Hiển thị thông tin số chứng từ, ngày chứng từ, mã vật tư, tên vật tư, Số lượng của các chứng 
từ nhập kho.*/
SELECT N'Số chứng từ' = Tb1.DocNo, N'Ngày chứng từ' = Tb2.DocDate, N'Mã vật tư' = Tb1.ItemCode, 
N'Tên vật tư' = Item.ItemName, N'Số lượng' = Quantity FROM AccDocDetail Tb1 
INNER JOIN AccDoc Tb2 ON Tb1.DocNo = Tb2.DocNo 
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode = 'TP' AND Item.ItemType = 1

/*BAITAP2: Hiển thị thông tin số chứng từ, ngày chứng từ, mã vật tư, tên vật tư, Số lượng của các chứng 
từ xuất kho sản xuất.*/
SELECT N'Số chứng từ' = Tb1.DocNo, N'Ngày chứng từ' = Tb2.DocDate, N'Mã vật tư' = Tb1.ItemCode, 
N'Tên vật tư' = Item.ItemName, N'Số lượng' = Tb1.Quantity FROM AccDocDetail Tb1 
INNER JOIN AccDoc Tb2 ON Tb1.DocNo = Tb2.DocNo 
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode = 'PX' AND Item.ItemType = 1

/*BAITAP3: Hiển thị thông tin ngày xuất gần nhất của vật tư nhập mua: Mã vật tư, Tên vật tư, Đơn vị tính, 
Ngày xuất gần nhất.*/
--c1
SELECT N'Mã vật tư' = Tb1.ItemCode, N'Tên vật tư' = Item.ItemName,
N'Đơn vị tính' = Item.Unit, N'Ngày chứng từ' = Tb2.DocDate FROM AccDocDetail Tb1 
INNER JOIN AccDoc Tb2 ON Tb1.DocNo = Tb2.DocNo 
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode = 'PX' AND Item.ItemType = 1 
AND Tb2.DocDate = (SELECT TOP 1 DocDate FROM AccDocDetail Tb1 INNER JOIN AccDoc Tb2 ON Tb1.DocNo = Tb2.DocNo 
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode = 'PX' AND Item.ItemType = 1  ORDER BY DATEDIFF(dd,Tb2.DocDate,GETDATE()) DESC)

--c2
;WITH VTxuatGanNhat_CTE AS (
SELECT Tb1.ItemCode, Item.ItemName, Item.Unit, Tb2.DocDate, 
DENSE_RANK() OVER (ORDER BY DATEDIFF(dd,Tb2.DocDate,GETDATE()) DESC) as rank
FROM AccDocDetail Tb1 
INNER JOIN AccDoc Tb2 ON Tb1.DocNo = Tb2.DocNo 
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode = 'PX' AND Item.ItemType = 1   
)
SELECT N'Mã vật tư' = ItemCode, N'Tên vật tư' = ItemName,
N'Đơn vị tính' = Unit, N'Ngày chứng từ' = DocDate FROM VTxuatGanNhat_CTE 
WHERE rank = 1


/*BAITAP4: Hiển thị số liệu nhập xuất theo ngày của vật tư: Ngày, Mã vật tư, tên vật tư, đơn vị tính, số lượng 
nhập, số lượng xuất.*/
select * from AccDoc
SELECT Tb2.DocDate, Tb1.ItemCode, Item.ItemName, Item.Unit,
CASE WHEN Tb1.DocCode = 'NM' THEN Tb1.Quantity
ELSE 0 END AS N'Số lượng nhập',
CASE WHEN Tb1.DocCode = 'PX' THEN Tb1.Quantity
ELSE 0 END AS N'Số lượng xuất'
FROM AccDocDetail Tb1 INNER JOIN AccDoc Tb2 ON Tb1.DocNo = Tb2.DocNo 
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode IN ('NM','PX') 
--AND Item.ItemType = 1 
ORDER BY Tb2.DocDate 

/*BAITAP5: Hiển thị tổng số lượng vật tư được sản xuất và bán ra từ ngày 01/01/2022 đến ngày 15/01/2022: 
Mã vật tư, tên vật tư, đơn vị tính, số lượng sản xuất, số lượng bán ra.*/
;WITH Tbtam_CTE AS( SELECT Tb1.ItemCode, Item.ItemName, Item.Unit,
CASE WHEN Tb1.DocCode = 'TP' THEN SUM(Tb1.Quantity)
ELSE 0 END AS Sl_sx,
CASE WHEN Tb1.DocCode = 'HD' THEN SUM(Tb1.Quantity)
ELSE 0 END AS Sl_ban 
FROM AccDocDetail Tb1 INNER JOIN AccDoc Tb2 ON Tb1.DocNo = Tb2.DocNo 
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode IN ('TP','HD') AND Tb2.DocDate BETWEEN '2022/01/01' AND '2022/01/15'
GROUP BY Tb1.ItemCode ,Tb1.DocCode, Item.ItemName, Item.Unit)

SELECT N'Mã vật tư' = ItemCode, N'Tên vật tư' = ItemName, N'Đơn vị tính' = Unit,
N'Số lượng sản xuất' = SUM(Sl_sx),
N'Số lượng bán ra' = SUM(Sl_ban)
FROM Tbtam_CTE 
GROUP BY ItemCode, ItemName, Unit

/*BAITAP6: Hiển thị hai khách hàng có doanh số lớn nhất: Mã khách hàng, tên khách hàng, doanh số.*/
;WITH DoanhSoRank_CTE AS (SELECT TOP 2 CustomerCode, Doanh_so FROM(
SELECT Tb2.CustomerCode, Sum(Tb1.Amount2) AS Doanh_so,
DENSE_RANK () OVER (ORDER BY Sum(Tb1.Amount2) DESC) as rank
FROM AccDocDetail Tb1 INNER JOIN AccDoc Tb2 ON Tb1.DocNo = Tb2.DocNo 
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode = 'HD'
GROUP BY Tb2.CustomerCode
) RankYeuCau ORDER BY rank )

SELECT N'Mã khách hàng' = Ds.CustomerCode, N'Tên khách hàng' = Cus.CustomerName, N'Doanh số' = Ds.Doanh_so
FROM Customer Cus
JOIN DoanhSoRank_CTE Ds ON  Cus.CustomerCode = Ds.CustomerCode

/*BAITAP7: Hiển thị tổng sản lượng theo từng vật tư theo cấu trúc: Mã vật tư, tên vật tư, đơn vị tính, Số
lượng mua, số lượng xuất vào sản xuất, số lượng nhập thành phẩm, số lượng bán.*/
;WITH Tbtam_CTE AS ( SELECT Tb1.ItemCode, Item.ItemName, Item.Unit,
CASE WHEN Tb1.DocCode = 'NM' THEN SUM(Tb1.Quantity)
ELSE 0 END AS Sl_mua,
CASE WHEN Tb1.DocCode = 'PX' THEN SUM(Tb1.Quantity)
ELSE 0 END AS Sl_sx,
CASE WHEN Tb1.DocCode = 'TP' THEN SUM(Tb1.Quantity)
ELSE 0 END AS Sl_nhap,
CASE WHEN Tb1.DocCode = 'HD' THEN SUM(Tb1.Quantity)
ELSE 0 END AS Sl_ban
FROM AccDocDetail Tb1
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
GROUP BY Tb1.ItemCode, Tb1.DocCode, Item.ItemName, Item.Unit )

SELECT N'Mã vật tư' = ItemCode, N'Tên vật tư' = ItemName, N'Đơn vị tính' = Unit, 
N'Số lượng mua' = SUM(Sl_mua),
N'Số lượng xuất vào sản xuất' = SUM(Sl_sx),
N'Số lượng nhập thành phẩm' = SUM(Sl_nhap),
N'Số lượng bán ra' = SUM(Sl_ban)
FROM Tbtam_CTE
GROUP BY ItemCode, ItemName, Unit

----
--CHECK
--===========================
-- Chương VIII
--===========================
--Bai1

CREATE TABLE Employee (
	EmployeeCode CHAR (16) NOT NUll DEFAULT (''),
	EmployeeName NVARCHAR (96) NOT NUll DEFAULT (''),
	Gender INT NOT NUll CHECK(Gender in (1,2,3)), --INT -> 1: Nam; 2: Nữ; 3: Khác
	DeptCode NVARCHAR (16) NOT NUll DEFAULT (''),
	Salary NUMERIC (18,2) NOT NUll DEFAULT (0),
    IsActive INT NOT NULL CHECK (IsActive IN(0,1))
)

INSERT INTO Employee (EmployeeCode, EmployeeName, Gender, DeptCode, Salary, IsActive)
VALUES ('NV01', N'Phi Công Anh', 1, 'TK', 12000000, 1),
       ('NV02', N'Đàm Văn Đức', 1, 'TK', 11000000, 1),
       ('NV03', N'Ninh Ngọc Hiếu', 1, 'TK', 15000000, 1),
       ('NV04', N'Nguyễn Thu Huyền', 2, 'BH', 10000000, 1),
       ('NV05', N'Đỗ Xuân Thiết', 1, 'BH', 13000000, 1),
       ('NV06', N'Nguyễn Xuân Dũng', 1, 'CN', 15000000, 1),
       ('NV07', N'Nguyễn Sĩ Quyền', 1, 'CN', 14000000, 1)

-- Lấy ra các đối tượng thuộc đơn vị tổ chức và nhân viên là nam với cấu trúc: Mã đối tượng, tên đối tượng.
SELECT N'Mã đối tượng' = EmployeeCode, N'Tên đối tượng' = EmployeeName
FROM Employee
WHERE DeptCode = 'TK' AND Gender = 1

/*Hiển thị thông tin bảng kê những chứng từ bán hàng, sắp xếp theo thứ tự ngày tăng dần, số
tăng dần. Phần bôi đậm sẽ được sắp xếp theo thứ tự giảm dần. Ra được kết quả như sau là đúng */

SELECT N'Số chứng từ' = DocNo, N'Ngày chứng từ' = ngay_chung_tu,  N'Mã vật tư' = ItemCode,
N'Diễn giải' = dien_giai, N'ĐVT' = Unit, N'Số lượng' = Quantity, N'Đơn giá' = UnitPrice,
N'Tiền bán hàng' = Amount2
FROM
(SELECT Tb1.DocNo, ngay_chung_tu = FORMAT (Tb1.DocDate, 'dd/MM/yyyy '), Tb2.ItemCode, 
dien_giai = Item.ItemName, Item.Unit, Tb2.Quantity, 
Tb2.UnitPrice, Tb2.Amount2, Tb1.CustomerCode
FROM AccDoc Tb1 LEFT JOIN AccDocDetail Tb2 ON Tb1.DocNo = Tb2.DocNo 
    LEFT JOIN Item ON Tb2.ItemCode = Item.ItemCode 
WHERE Tb1.DocCode = 'HD'
UNION ALL
SELECT DocNo = '', ngay_chung_tu = '', ItemCode = '', 
dien_giai = CONCAT(Cus.CustomerCode,' - ', Cus.CustomerName), Unit = '', Quantity = 0, 
UnitPrice = 0, Amount2 = SUM(Tb2.Amount2), Cus.CustomerCode
FROM AccDoc Tb1 LEFT JOIN AccDocDetail Tb2 ON Tb1.DocNo = Tb2.DocNo 
    LEFT JOIN Customer Cus ON Tb1.CustomerCode = Cus.CustomerCode
WHERE Tb1.DocCode = 'HD' 
GROUP BY Cus.CustomerCode, Cus.CustomerName 
)
Kq
ORDER BY  CustomerCode DESC, ngay_chung_tu

---==============================
---==============================
IF OBJECT_ID('tempdb..#tbdetail ') IS NOT NULL DROP TABLE #tbdetail 
SELECT * INTO #tbdetail 
FROM(
SELECT tb.ItemCode, ItemName, Unit, 
ton_dau = OI.Quantity, Sl_nhap, Sl_sx,
ton_cuoi = OI.Quantity + Sl_nhap - Sl_sx
FROM ( SELECT ItemCode, ItemName, Unit, Sl_nhap = SUM(Sl_nhap), Sl_sx= SUM(Sl_sx)
FROM (SELECT Tb1.ItemCode, Item.ItemName, Item.Unit,
CASE WHEN Tb1.DocCode = 'NM' THEN SUM(Tb1.Quantity)
ELSE 0 END AS Sl_nhap,
CASE WHEN Tb1.DocCode = 'PX' THEN SUM(Tb1.Quantity)
ELSE 0 END AS Sl_sx
FROM AccDocDetail Tb1
LEFT OUTER JOIN Item Item ON Tb1.ItemCode = Item.ItemCode
WHERE Tb1.DocCode IN ('NM','PX')
GROUP BY Tb1.ItemCode, Tb1.DocCode, Item.ItemName, Item.Unit) tb_tam
GROUP BY ItemCode, ItemName, Unit) tb
LEFT JOIN OpenInventory OI ON OI.ItemCode = tb.ItemCode) a

SELECT N'Mã vật tư' = ItemCode, N'Tên vật tư' = ItemName, N'Đvt' = Unit, 
N'Tồn đầu' = ton_dau, N'SL nhập' = Sl_nhap, N'SL xuất' = Sl_sx, N'Tồn cuối' = ton_cuoi
 FROM (
SELECT * FROM #tbdetail
UNION ALL
(SELECT ItemCode = '', ItemName = N'Tổng cộng', Unit = '',
    ton_dau = SUM(ton_dau), Sl_Nhap = SUM(Sl_nhap),
    Sl_sx = SUM(Sl_sx), ton_cuoi = SUM(ton_cuoi)
    FROM #tbdetail
)
) Kq

--================================
-- chương 9 
--================================

SELECT EmployeeCode, EmployeeName,
CASE WHEN CAST(BH as NVARCHAR(MAX)) is NULL then ''
ELSE CAST(BH as NVARCHAR(MAX)) END  as BH,
CASE WHEN CAST(CN as NVARCHAR(MAX)) is NULL then ''
ELSE CAST(CN as NVARCHAR(MAX)) END  as CN,
CASE WHEN CAST(TK as NVARCHAR(MAX)) is NULL then ''
ELSE CAST(TK as NVARCHAR(MAX)) END  as TK
FROM Employee AS Tb1
PIVOT
(
SUM (Salary) FOR DeptCode IN (BH, CN, TK)
) AS Tb2
UNION ALL
SELECT CAST ('' AS NVARCHAR(16)) AS EmployeeCode,
N'Tổng lương' AS EmployeeName, CAST(BH as NVARCHAR(MAX)) as BH, 
CAST(CN as NVARCHAR(MAX)) as CN, CAST(TK as NVARCHAR(MAX)) TK 
FROM (SELECT DeptCode, Salary FROM EmPloyee) AS Tb3
PIVOT
(
SUM(Salary)
FOR DeptCode IN (BH, CN, TK)
) AS Tb4

--C2 chuyển null thành 0 

SELECT EmployeeCode, EmployeeName, ISNULL(BH,0)as BH, ISNULL(CN,0) as CN, ISNULL(TK,0) as TK
FROM Employee AS Tb1
PIVOT
(
SUM (Salary) FOR DeptCode IN (BH, CN, TK)
) AS Tb2
UNION ALL
SELECT CAST ('' AS NVARCHAR(16)) AS EmployeeCode,
N'Tổng lương' AS EmployeeName, BH, CN, TK 
FROM (SELECT DeptCode, Salary FROM EmPloyee) AS Tb3
PIVOT
(
SUM(Salary)
FOR DeptCode IN (BH, CN, TK)
) AS Tb4

--+++++++++++++Có thể động được trong trường hợp đổi mã bộ phận (DeptCode) hoặc thêm mới bộ phận thì 
--vẫn chạy được mà không sửa code
--c1
go
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @deptcodes AS NVARCHAR(MAX) = STUFF(
         (SELECT ',' + DeptCode
          FROM (select distinct DeptCode from Employee)  p
          FOR XML PATH (''))
          , 1, 1, '')

DECLARE @deptcodes1 AS NVARCHAR(MAX) = STUFF(
         (SELECT ',' + CONCAT('ISNULL(',DeptCode,',','0)',DeptCode)
          FROM (select distinct DeptCode from Employee)  p
          FOR XML PATH (''))
          , 1, 1, '')

DECLARE @tongluong AS NVARCHAR(MAX) = N'Tổng lương'

SET @sql =N'SELECT EmployeeCode, EmployeeName, '+@deptcodes1+'
FROM Employee AS Tb1
PIVOT
(
SUM (Salary) FOR DeptCode IN ('+@deptcodes+')
) AS Tb2
UNION ALL
SELECT CAST ('''' AS NVARCHAR(16)) AS EmployeeCode,
N''' + @tongluong + N''' AS EmployeeName, '+@deptcodes1+'
FROM (SELECT DeptCode, Salary FROM EmPloyee) AS Tb3
PIVOT
(
SUM(Salary)
FOR DeptCode IN ('+@deptcodes1+')
) AS Tb4'
EXEC sp_executesql @sql
---

--c2
go
DECLARE @sql AS NVARCHAR(MAX)
DECLARE @deptcodes AS NVARCHAR(MAX) = STUFF(
         (SELECT ',' + DeptCode
          FROM (select distinct DeptCode from Employee)  p
          FOR XML PATH (''))
          , 1, 1, '')

DECLARE @columnName1 AS NVARCHAR(MAX) = STUFF(
         (SELECT ',' + CONCAT('CASE WHEN CAST(',DeptCode,' AS NVARCHAR(MAX)) is NULL THEN '''' ELSE CAST(' ,DeptCode,' as NVARCHAR(MAX)) END ',DeptCode)
          FROM (select distinct DeptCode from Employee)  p
          FOR XML PATH (''))
          , 1, 1, '')
DECLARE @columnName2 AS NVARCHAR(MAX) = STUFF(
         (SELECT ',' + CONCAT('CAST(',DeptCode,' AS NVARCHAR(MAX))',DeptCode)
          FROM (select distinct DeptCode from Employee)  p
          FOR XML PATH (''))
          , 1, 1, '')

DECLARE @tongluong AS NVARCHAR(MAX) = N'Tổng lương'

SET @sql =N'SELECT EmployeeCode, EmployeeName, '+@columnName1+'
FROM Employee AS Tb1
PIVOT
(
SUM (Salary) FOR DeptCode IN ('+@deptcodes+')
) AS Tb2
UNION ALL
SELECT CAST ('''' AS NVARCHAR(16)) AS EmployeeCode,
N''' + @tongluong + N''' AS EmployeeName, '+@columnName2+'
FROM (SELECT DeptCode, Salary FROM EmPloyee) AS Tb3
PIVOT
(
SUM(Salary)
FOR DeptCode IN ('+@deptcodes+')
) AS Tb4'
EXEC sp_executesql @sql

--=====================
--=====================
/*BAITAP2: Viết báo cáo tổng hợp số lượng bán hàng theo từng khách hàng và từng mặt hàng với cấu trúc 
như sau:
*/
DECLARE @_CusCode NVARCHAR(MAX) = STUFF(
         (SELECT ',' + CustomerCode
          FROM (SELECT DISTINCT Cus.CustomerCode FROM AccDoc AccD
                LEFT JOIN AccDocDetail AccDl ON AccD.DocNo = AccDl.DocNo
                LEFT JOIN Item ON AccDl.ItemCode = Item.ItemCode
                LEFT JOIN Customer Cus ON AccD.CustomerCode = Cus.CustomerCode
                WHERE AccDl.DocCode = 'HD')  p
          FOR XML PATH (''))
          , 1, 1, '')

SELECT Stt= CAST(ROW_NUMBER() OVER (order by ItemCode)AS nvarchar(16)), ItemCode, ItemName, Unit, KH01, KH02, KH03, N'Tổng số lượng' = KH01+KH02+KH03 FROM (
SELECT Item.ItemCode, Item.ItemName, Item.Unit, Cus.CustomerCode, AccDl.Quantity FROM AccDoc AccD
    LEFT JOIN AccDocDetail AccDl ON AccD.DocNo = AccDl.DocNo
    LEFT JOIN Item ON AccDl.ItemCode = Item.ItemCode
    LEFT JOIN Customer Cus ON AccD.CustomerCode = Cus.CustomerCode
    WHERE AccDl.DocCode = 'HD') tb1
PIVOT
(
SUM(Quantity)
FOR CustomerCode IN (KH01,KH02,KH03)
) AS Tb2
UNION ALL
SELECT Stt = '', ItemCode = N'Tổng cộng', ItemName = '', Unit= '',KH01, KH02, KH03, N'Tổng số lượng' = KH01+KH02+KH03 FROM 
(SELECT Cus.CustomerCode, SUM(AccDl.Quantity) As SumQ FROM AccDoc AccD
    LEFT JOIN AccDocDetail AccDl ON AccD.DocNo = AccDl.DocNo
    LEFT JOIN Item ON AccDl.ItemCode = Item.ItemCode
    LEFT JOIN Customer Cus ON AccD.CustomerCode = Cus.CustomerCode
    WHERE AccDl.DocCode = 'HD'
    GROUP BY Cus.CustomerCode) tb3
PIVOT
(
SUM(SumQ)
FOR CustomerCode IN (KH01,KH02,KH03)
) AS Tb4

--=================
--=================
/*BAITAP3: Viết báo cáo tổng hợp doanh số bán hàng theo từng khách hàng và từng mặt hàng với cấu 
trúc như sau*/

DECLARE @_itemcode NVARCHAR(MAX) = STUFF(
         (SELECT ',' + ItemCode
          FROM (SELECT DISTINCT Item.ItemCode FROM AccDoc AccD
                LEFT JOIN AccDocDetail AccDl ON AccD.DocNo = AccDl.DocNo
                LEFT JOIN Item ON AccDl.ItemCode = Item.ItemCode
                LEFT JOIN Customer Cus ON AccD.CustomerCode = Cus.CustomerCode
                WHERE AccDl.DocCode = 'HD')  p
          FOR XML PATH (''))
          , 1, 1, '')

SELECT Stt= CAST(ROW_NUMBER() OVER (order by CustomerCode)AS nvarchar(16)), CustomerCode, CustomerName, TP01, TP02, TP03, N'Tổng số lượng' = TP01+TP02+TP03 FROM (
SELECT Cus.CustomerCode, Cus.CustomerName, Item.ItemCode, AccDl.Quantity FROM AccDoc AccD
    LEFT JOIN AccDocDetail AccDl ON AccD.DocNo = AccDl.DocNo
    LEFT JOIN Item ON AccDl.ItemCode = Item.ItemCode
    LEFT JOIN Customer Cus ON AccD.CustomerCode = Cus.CustomerCode
    WHERE AccDl.DocCode = 'HD'
    ) tb1
PIVOT
(
SUM(Quantity)
FOR ItemCode IN (TP01, TP02, TP03)
) AS Tb2
UNION ALL
SELECT Stt = '', ustomerCode = N'Tổng cộng', CustomerName= '', TP01, TP02, TP03, N'Tổng số lượng' = TP01+TP02+TP03 FROM 
(SELECT Item.ItemCode, SUM(AccDl.Quantity) As SumQ FROM AccDoc AccD
    LEFT JOIN AccDocDetail AccDl ON AccD.DocNo = AccDl.DocNo
    LEFT JOIN Item ON AccDl.ItemCode = Item.ItemCode
    LEFT JOIN Customer Cus ON AccD.CustomerCode = Cus.CustomerCode
    WHERE AccDl.DocCode = 'HD'
    GROUP BY Item.ItemCode) tb3
PIVOT
(
SUM(SumQ)
FOR ItemCode IN (TP01, TP02, TP03)
) AS Tb4

--==========================
--==========================
/*BAITAP4: Viết báo cáo thể hiện bảng kê có nội dung và cấu trúc tương tự như bảng sau:
*/

SELECT Stt,  N'Số chứng từ' = DocNo, N'Ngày chứng từ' = ngay_chung_tu,  N'Mã vật tư' = ItemCode,
N'Diễn giải' = dien_giai, N'Tiền'= tien
FROM
( SELECT * FROM(
    SELECT Stt= CAST(ROW_NUMBER() OVER (PARTITION BY Item.ItemCode order by Tb1.DocNo)AS nvarchar(16)), Tb1.DocNo, ngay_chung_tu = FORMAT (Tb1.DocDate, 'dd/MM/yyyy '), Tb2.ItemCode, 
CASE Tb1.DocCode WHEN 'NM' THEN N'Mua chứng từ' WHEN 'PX' THEN N'Nhập kho' END AS dien_giai,
CASE Tb1.DocCode WHEN 'NM' THEN Tb2.Amount1 WHEN 'PX' THEN Tb2.Amount2 END AS tien
FROM AccDoc Tb1 LEFT JOIN AccDocDetail Tb2 ON Tb1.DocNo = Tb2.DocNo 
    LEFT JOIN Item ON Tb2.ItemCode = Item.ItemCode 
WHERE Tb1.DocCode IN ('NM','PX')
UNION ALL
SELECT Stt='', DocNo = '', ngay_chung_tu = '', Item.ItemCode, 
Item.ItemName as dien_giai, SUM(Tb2.Amount1 + Tb2.Amount2) as tien
FROM AccDoc Tb1 LEFT JOIN AccDocDetail Tb2 ON Tb1.DocNo = Tb2.DocNo 
    LEFT JOIN Item  ON Tb2.ItemCode = Item.ItemCode
WHERE Tb1.DocCode IN ('NM','PX')
GROUP BY Item.ItemCode, Item.ItemName 
) TbU1
UNION ALL 
SELECT Stt='', DocNo = '', ngay_chung_tu = '', ItemCode = '', 
 dien_giai = N'Tổng cộng',  SUM(Amount1 + Amount2) as tien FROM AccDocDetail 
WHERE DocCode IN ('NM','PX')
) Kq
ORDER BY  ItemCode DESC, Stt, ngay_chung_tu

--=============================
--=============================
/*BAITAP5: Viết báo cáo thể hiện chi tiết các lần nhập xuất vật tư có nội dung và cấu trúc tương 
tự bảng sau:*/

IF OBJECT_ID('tempdb..#Tb_chitiet_nhapxuat ') IS NOT NULL DROP TABLE #Tb_chitiet_nhapxuat

-- SELECT * INTO #Tb_chitiet_nhapxuat FROM(
-- SELECT AccDl.ItemCode, ngay = FORMAT (Acc.DocDate, 'dd/MM/yyyy '),
-- CASE Acc.DocCode WHEN 'NM' THEN N'Nhập hàng'
-- WHEN 'PX' THEN N'Xuất hàng' END AS noi_dung,
-- CASE WHEN Acc.DocCode='NM' THEN CAST(Quantity as nvarchar(16))
-- ELSE '' END AS sl_nhap,
-- CASE WHEN Acc.DocCode='NM' THEN CAST(Amount1 as nvarchar(16))
-- ELSE '' END AS tien_nhap,
-- CASE WHEN Acc.DocCode='PX' THEN CAST(Quantity as nvarchar(16))
-- ELSE '' END AS sl_xuat,
-- CASE WHEN Acc.DocCode='PX' THEN CAST(Amount2 as nvarchar(16))
-- ELSE '' END AS tien_xuat,
-- sl_ton = 0, sldu = 0
-- FROM AccDoc Acc LEFT JOIN AccDocDetail AccDl ON Acc.DocNo = AccDl.DocNo
-- WHERE Acc.DocCode IN ('NM', 'PX')
-- ) Tb1
SELECT * INTO #Tb_chitiet_nhapxuat FROM(
SELECT AccDl.ItemCode, ngay = Acc.DocDate,
CASE Acc.DocCode WHEN 'NM' THEN N'Nhập hàng'
WHEN 'PX' THEN N'Xuất hàng' END AS noi_dung,
CASE WHEN Acc.DocCode='NM' THEN Quantity
ELSE 0 END AS sl_nhap,
CASE WHEN Acc.DocCode='NM' THEN Amount1 
ELSE 0 END AS tien_nhap,
CASE WHEN Acc.DocCode='PX' THEN Quantity 
ELSE 0 END AS sl_xuat,
CASE WHEN Acc.DocCode='PX' THEN Amount2 
ELSE 0 END AS tien_xuat,
sl_ton = 0, sldu = 0
FROM AccDoc Acc LEFT JOIN AccDocDetail AccDl ON Acc.DocNo = AccDl.DocNo
WHERE Acc.DocCode IN ('NM', 'PX')
) Tb1
--======
IF OBJECT_ID('tempdb..#Tb_chitiet_nhapxuatton ') IS NOT NULL DROP TABLE #Tb_chitiet_tksd

SELECT * INTO #Tb_chitiet_nhapxuatton FROM (
SELECT ItemCode , ngay = '1900-01-01', noi_dung = N'Tồn đầu kỳ', sl_nhap = 0, tien_nhap = 0, 
sl_xuat = 0, tien_xuat = 0, sl_ton = Quantity, sldu = Amount  FROM OpenInventory 
Where ItemCode In (SELECT DISTINCT ItemCode FROM #Tb_chitiet_nhapxuat)
UNION ALL 
SELECT * FROM #Tb_chitiet_nhapxuat) Tb

SELECT ItemCode, ngay, noi_dung, sl_nhap, tien_nhap, sl_xuat, tien_xuat,
tonkho = sum(sl_ton + sl_nhap - sl_xuat) OVER (PARTITION BY ItemCode ORDER by  ngay), 
sodu = sum(sldu + tien_nhap - tien_xuat) OVER (PARTITION BY ItemCode ORDER by ItemCode, ngay)
FROM #Tb_chitiet_nhapxuatton 
UNION ALL
SELECT Itemcode, ngay = '9999-12-30', noi_dung = N'Tổng nhập/xuất', sl_nhap = SUM(sl_nhap), tien_nhap = SUM(tien_nhap),
sl_xuat = SUM(sl_xuat), tien_xuat = SUM(tien_xuat), tonkho = 0, sodu = 0 FROM #Tb_chitiet_nhapxuat
GROUP BY ItemCode
UNION ALL
SELECT ItemCode, ngay = '9999-12-31', noi_dung = N'Tồn cuối kỳ', sl_nhap = 0, tien_nhap = 0,
sl_xuat = 0, tien_xuat = 0, tonkho = SUM(sl_ton) + SUM(sl_nhap) - SUM(sl_xuat),
sodu = SUM(sldu)+ SUM(tien_nhap) - SUM(tien_xuat) FROM #Tb_chitiet_nhapxuatton
GROUP BY ItemCode
ORDER BY ItemCode, ngay

 
