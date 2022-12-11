--create db Tech
USE master;  
GO  
IF DB_ID ('Tech') IS NOT NULL  
DROP DATABASE Tech
GO  
CREATE DATABASE Tech
GO
USE Tech
GO

CREATE TABLE Item (
	ItemCode NVARCHAR (16) not null,
	ItemName NVARCHAR (96),
	Unit NVARCHAR (10),
	ItemType INT,--> 0: dịch vụ; 1: vật tư; 2- sản phẩm
	IsActive INT --> 0: Không sử dụng; 1: Sử dụng
)

CREATE TABLE Customer (
	CustomerCode NVARCHAR (16) not null,
	CustomerName NVARCHAR (96),
	CustomerType INT, --> 1: Cá nhân; 2: đơn vị; 3: Nội bộ
	IsActive INT --> 0: Không sử dụng; 1: Sử dụng
)

CREATE TABLE AccDoc (
	DocCode CHAR (2) not null,
	DocNo NVARCHAR (10) not null, --> Duy nhất (khóa)
	DocDate DATETIME,
	CustomerCode NVARCHAR (16),
	DocGroup INT, --> 1: Nhập; 2: Xuất
	Description NVARCHAR (256),
	IsActive INT, --> 0: Không sử dụng; 1: Sử dụng
	CONSTRAINT PK_AccDoc PRIMARY KEY (DocCode,DocNo)
)

CREATE TABLE AccDocDetail (
	DocCode CHAR (2) not null, --> Link DocCode của AccDoc
	DocNo NVARCHAR (10) not null, --> Link DocNo của AccDoc
	ItemCode NVARCHAR (16),
	Quantity NUMERIC (15,3),
	UnitCost NUMERIC (15,5),
	Amount1 NUMERIC (18,2),
	UnitPrice NUMERIC (15,5),
	Amount2 NUMERIC (18,2),
	CONSTRAINT FK_AccDocDetail 
    FOREIGN KEY(DocCode,DocNo)
    REFERENCES dbo.AccDoc(DocCode,DocNo)
)

CREATE TABLE OpenInventory (
	ItemCode NVARCHAR (16) not null,
	Quantity NUMERIC (15,3),
	Amount NUMERIC (18,2)
)

-- add contraint: 

-- insert values: 
INSERT INTO Item (ItemCode, ItemName, Unit, ItemType, IsActive)
VALUES
	('NVLC01', N'Máy nén', N'Cái', 1, 1),
	('NVLC02', N'Tôn dày 0.5 mm', N'Kg', 1, 1),
	('NVLC03', N'Ống đồng', N'M', 1, 1),
	('TP01', N'Tủ đông kích thước 1.5*0.7*0.6', N'Cái', 2, 1),
	('TP02', N'Tủ đông kích thước 1.5*0.8*0.8', N'Cái', 2, 1),
	('TP03', N'Tủ mát kích thước 0.8*0.8*1.9', N'Cái', 2, 1)

INSERT INTO Customer (CustomerCode, CustomerName, CustomerType, IsActive)
VALUES
	('NCC01', N'Công ty TNHH Vạn Xuân', 2, 1),
	('NCC02', N'Công ty Cổ phần Đại Phát', 2, 1),
	('NCC03', N'Công ty Cổ phần tôn Hòa Phát', 2, 1),
	('KH01', N'Đại lý Cô Tám', 1, 1),
	('KH02', N'Công ty cổ phần đầu tư xây dựng Dacinco', 2, 1),
	('KH03', N'Công ty TNHH cà phê Thắng Lợi', 2, 1),
	('NB01', N'Phi Công Anh', 1, 1),
	('NB02', N'Đàm Văn Đức', 1, 1),
	('NB03', N'Phân xưởng sản xuất', 3, 1)

INSERT INTO AccDoc (DocCode, DocNo, DocDate, CustomerCode, DocGroup, Description, IsActive)
VALUES 
	('NM', 'NM001', '2022/01/01', 'NCC01', 1, N'Nhập mua NPL', 1),
	('NM', 'NM002', '2022/01/10', 'NCC02', 1, N'Nhập mua NPL', 1),
	('NM', 'NM003', '2022/01/11', 'NCC01', 1, N'Nhập mua NPL', 1),
	('NM', 'NM004', '2022/01/15', 'NCC03', 1, N'Nhập mua NPL', 1),
	('PX', 'PX001', '2022/01/02', 'NB03', 2, N'Xuất sản xuất', 1),
	('PX', 'PX002', '2022/01/13', 'NB03', 2, N'Xuất sản xuất', 1),
	('PX', 'PX003', '2022/01/22', 'NB03', 2, N'Xuất sản xuất', 1),
	('PX', 'PX004', '2022/01/28', 'NB03', 2, N'Xuất sản xuất', 1),
	('TP', 'TP001', '2022/01/15', 'NB03', 1, N'Xuất sản xuất', 1),
	('TP', 'TP002', '2022/01/31', 'NB03', 1, N'Nhập thành phẩm', 1),
	('HD', 'HD001', '2022/01/05', 'KH01', 2, N'Xuất bán hàng', 1),
	('HD', 'HD002', '2022/01/06', 'KH03', 2, N'Xuất bán hàng', 1),
	('HD', 'HD003', '2022/01/10', 'KH02', 2, N'Xuất bán hàng', 1),
	('HD', 'HD004', '2022/01/12', 'KH01', 2, N'Xuất bán hàng', 1),
	('HD', 'HD005', '2022/01/16', 'KH02', 2, N'Xuất bán hàng', 1),
	('HD', 'HD006', '2022/01/18', 'KH03', 2, N'Xuất bán hàng', 1),
	('HD', 'HD007', '2022/01/23', 'KH01', 2, N'Xuất bán hàng', 1),
	('HD', 'HD008', '2022/01/31', 'KH03', 2, N'Xuất bán hàng', 1)
	
INSERT INTO AccDocDetail (DocCode, DocNo, ItemCode, Quantity, UnitCost, Amount1, UnitPrice, Amount2)
VALUES
	('NM', 'NM001', 'NVLC01', 100.00, 3099000.00, 309900000, 0, 0),
	('NM', 'NM001', 'NVLC02', 999.95, 29956.35, 29954852, 0, 0),
	('NM', 'NM002', 'NVLC01', 50.00, 3050000.00, 152500000, 0, 0),
	('NM', 'NM002', 'NVLC02', 200.33, 29956.55, 6001196, 0, 0),
	('NM', 'NM002', 'NVLC03', 2000.00, 105987.92, 211975840, 0, 0),
	('NM', 'NM003', 'NVLC01', 60.00, 3050000.00, 183000000, 0, 0),
	('NM', 'NM003', 'NVLC02', 100.00, 29956.55, 2995655, 0, 0),
	('NM', 'NM003', 'NVLC03', 150.00, 105987.92, 15898188, 0, 0),
	('NM', 'NM004', 'NVLC01', 90.00, 3050000.00, 274500000, 0, 0),
	('NM', 'NM004', 'NVLC02', 300.00, 29956.55, 8986965, 0, 0),
	('NM', 'NM004', 'NVLC03', 200.00, 105987.92, 21197584, 0, 0),
	('PX', 'PX001', 'NVLC01', 90.00, 0, 0, 0, 0),
	('PX', 'PX001', 'NVLC02', 500.00, 0, 0, 0, 0), 
	('PX', 'PX001', 'NVLC03', 400.00, 0, 0, 0, 0), 
	('PX', 'PX002', 'NVLC01', 50.00, 0, 0, 0, 0),
	('PX', 'PX002', 'NVLC02', 200.33, 0, 0, 0, 0),
	('PX', 'PX002', 'NVLC03', 1000.00, 0, 0, 0, 0),
	('PX', 'PX003', 'NVLC01', 100.00, 0, 0, 0, 0),
	('PX', 'PX003', 'NVLC02', 150.00, 0, 0, 0, 0),
	('PX', 'PX003', 'NVLC03', 200.00, 0, 0, 0, 0),
	('PX', 'PX004', 'NVLC01', 90.00, 0, 0, 0, 0),
	('PX', 'PX004', 'NVLC02', 320.00, 0, 0, 0, 0),
	('PX', 'PX004', 'NVLC03', 170.00, 0, 0, 0, 0),
	('TP', 'TP001', 'TP01', 400.00, 0, 0, 0, 0),
	('TP', 'TP001', 'TP02', 500.00, 0, 0, 0, 0),
	('TP', 'TP001', 'TP03', 700.00, 0, 0, 0, 0),
	('TP', 'TP002', 'TP01', 300.00, 0, 0, 0, 0),
	('TP', 'TP002', 'TP02', 200.00, 0, 0, 0, 0),
	('TP', 'TP002', 'TP03', 200.00, 0, 0, 0, 0),
	('HD', 'HD001', 'TP02', 100.00, 0, 0, 11000000, 1100000000),
	('HD', 'HD001', 'TP03', 300.00, 0, 0, 12000000, 3600000000),
	('HD', 'HD002', 'TP01', 50.00, 0, 0, 10000000, 500000000),
	('HD', 'HD002', 'TP03', 150.00, 0, 0, 12000000, 1800000000),
	('HD', 'HD003', 'TP01', 50.00, 0, 0, 10000000, 500000000),
	('HD', 'HD003', 'TP02', 100.00, 0, 0, 11000000, 1100000000),
	('HD', 'HD004', 'TP01', 90.00, 0, 0, 10000000, 900000000),
	('HD', 'HD004', 'TP02', 270.00, 0, 0, 11000000, 2970000000),
	('HD', 'HD004', 'TP03', 140.00, 0, 0, 12000000, 1680000000),
	('HD', 'HD005', 'TP02', 100.00, 0, 0, 11000000, 1100000000),
	('HD', 'HD005', 'TP03', 300.00, 0, 0, 12000000, 3600000000),
	('HD', 'HD006', 'TP01', 50.00, 0, 0, 10000000, 500000000),
	('HD', 'HD006', 'TP03', 150.00, 0, 0, 12000000, 1800000000),
	('HD', 'HD007', 'TP01', 50.00, 0, 0, 10000000, 500000000),
	('HD', 'HD008', 'TP02', 100.00, 0, 0, 11000000, 1100000000),
	('HD', 'HD008', 'TP01', 90.00, 0, 0, 10000000, 900000000),
	('HD', 'HD008', 'TP02', 270.00, 0, 0, 1100000, 2970000000),
	('HD', 'HD008', 'TP03', 140.00, 0, 0, 12000000, 1680000000)

INSERT INTO OpenInventory (ItemCode, Quantity, Amount)
VALUES 
	('NVLC01', 1000, 3000000000),
	('NVLC02', 1500, 46500000),
	('NVLC03', 2000, 210000000),
	('TP01', 500, 2000000000),
	('TP02', 400, 2000000000),
	('TP03', 600, 2520000000)




	

	
