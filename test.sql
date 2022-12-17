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
WHERE ItemCode IN
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
WHERE ItemCode IN
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

