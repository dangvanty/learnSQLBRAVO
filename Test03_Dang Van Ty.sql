-------------- CAU 1:-------------
--create database
USE master;  
GO  
IF DB_ID (N'Test_SQL_03_DVTy') IS NOT NULL  
DROP DATABASE Test_SQL_03_DVTy
GO  
CREATE DATABASE Test_SQL_03_DVTy  
go
use Test_SQL_03_DVTy
go
--
----------- create table -----------
-- DmHangHoa
create table DmHangHoa(
	MaHang char(3),
	TenHang nvarchar(255),
	Dvt nvarchar(30),
	primary key (MaHang)
) 

-- NhapHang
create table NhapHang (
	NgayNhap date,
	MaHang char(3),
	SoLuong int, 
	DonGia int,
	ThanhTien bigint 
	foreign key (MaHang) references DmHangHoa
)

-- XuatHang 
create table XuatHang (
	NgayXuat date,
	MaHang char(3),
	SoLuong int, 
	DonGia int,
	ThanhTien bigint 
	foreign key (MaHang) references DmHangHoa
)

----------- insert -----------
-- DmHangHoa
insert into DmHangHoa values 
		('B01','Bulon', N'cái'),
		('B02',N'Trục cam', N'bộ'),
		('B03',N'Cản trước', N'bộ')

-- NhapHang
insert into NhapHang values 
		('2022/02/01','B02', 5,1200000,6000000),
		('2022/02/02', 'B02',10,1200000,12000000),
		('2022/02/03','B03',8,450000,3600000),
		('2022/02/03','B02', 25,1200000,30000000),
		('2022/02/05', 'B03',47,450000,21150000),
		('2022/02/05','B01',201,10000,2010000),
		('2022/02/10','B01',91,10000,910000)

-- XuatHang

insert into XuatHang values 
		('2022/02/12','B02', 11,1200000,13200000),
		('2022/02/13', 'B03',29,1200000,13050000),
		('2022/02/13','B02',20,450000,24000000),
		('2022/02/15','B03', 7,1200000,3150000),
		('2022/02/15', 'B01',125,450000,1250000),
		('2022/02/16','B01',25,10000,250000)
----------------------------------
-------------- CAU 2:-------------
----------------------------------
go
Create view tong_sl_tien_nhap as(
select NhapHang.MaHang as MaHang,sum(Soluong) as Soluong, sum(Thanhtien)as Tien from
NhapHang join DmHangHoa on DmHangHoa.MaHang = NhapHang.MaHang group by NhapHang.MaHang )
-- select * from tong_sl_tien_nhap

create view tong_hop_nhap as(
	select tong_sl_tien_nhap.MaHang,TenHang,Dvt,Soluong,Tien from
	tong_sl_tien_nhap join DmHangHoa on tong_sl_tien_nhap.MaHang = DmHangHoa.MaHang
)
-- select * from tong_hop_nhap

create view tong_cong_nhap as (
select MaHang='',TenHang=N'Tổng cộng',Dvt='',sum(Soluong) as Soluong, sum(Tien) as "Tien" from tong_hop_nhap
)
-- select * from tong_cong_nhap

------- kết quả ------
create view kqcau2 as(
select * from tong_hop_nhap union all
select * from tong_cong_nhap
)
select * from kqcau2
----------------------------------
-------------- CAU 3:-------------
----------------------------------
go
Create view tong_sl_tien_xuat as(
select XuatHang.MaHang as MaHang,sum(Soluong) as Soluong, sum(Thanhtien)as Tien from
XuatHang join DmHangHoa on DmHangHoa.MaHang = XuatHang.MaHang group by XuatHang.MaHang )
-- select * from tong_sl_tien_xuat

create view tong_hop_xuat as(
	select tong_sl_tien_xuat.MaHang,TenHang,Dvt,Soluong,Tien from
	tong_sl_tien_xuat join DmHangHoa on tong_sl_tien_xuat.MaHang = DmHangHoa.MaHang
)
-- select * from tong_hop_xuat

create view tong_cong_xuat as (
select MaHang='',TenHang=N'Tổng cộng',Dvt='',sum(Soluong) as Soluong, sum(Tien) as "Tien" from tong_hop_xuat
)
-- select * from tong_cong_xuat

------- kết quả ------
create view kqcau3 as(
select * from tong_hop_xuat union all
select * from tong_cong_xuat
)
select * from kqcau3
----------------------------------
-------------- CAU 4:-------------
----------------------------------
select kqcau2.MaHang, kqcau2.TenHang, kqcau2.Dvt, kqcau2.Soluong as SINhap,
	   kqcau2.Tien as TienNhap, kqcau3.Soluong as SIXuat, kqcau3.Tien as TienXuat
	   ,(kqcau2.Soluong - kqcau3.Soluong)as TonCuoi
from kqcau2 join kqcau3 on kqcau2.MaHang = kqcau3.MaHang
----------------------------------
-------------- CAU 5:-------------
----------------------------------
---------
---B01---
---------
create view XuatHang_B01 as(
select XuatHang.MaHang as MaHang, NgayXuat as Ngay,NoiDung=N'Xuất hàng',SlNhap=0,TienNhap=0, Soluong as SlXuat, Thanhtien as TienXuat from
XuatHang join DmHangHoa on DmHangHoa.MaHang = XuatHang.MaHang where XuatHang.MaHang = 'B01'
)
--- select * from XuatHang_B01 

create view NhapHang_B01 as(
select NhapHang.MaHang as MaHang, NgayNhap as Ngay,NoiDung=N'Nhập hàng',Soluong as SlNhap, Thanhtien as TienNhap,SlXuat=0,TienXuat=0  from
NhapHang join DmHangHoa on DmHangHoa.MaHang = NhapHang.MaHang where NhapHang.MaHang = 'B01'
)
--- select * from NhapHang_B01 
create view Nhap_Xuat_B01 as(
select * from NhapHang_B01
union all  select * from XuatHang_B01)
-- select * from Nhap_Xuat_B01

create view tinh_ton_kho_vs_du_B01 as (
select *, sum(Nhap_Xuat_B01.SlNhap - Nhap_Xuat_B01.SlXuat) OVER ( order by Nhap_Xuat_B01.Ngay)as TonCuoi,
		  sum(Nhap_Xuat_B01.TienNhap - Nhap_Xuat_B01.TienXuat) OVER ( order by Nhap_Xuat_B01.Ngay)as SoDu
from Nhap_Xuat_B01
)
--select * from tinh_ton_kho_vs_du_B01

create view tong_nhap_xuat_B01 as(
select MaHang,Ngay='',NoiDung=N'Tổng nhập/ xuất',
	   sum(Nhap_Xuat_B01.SlNhap) as SlNhap,
	   sum(Nhap_Xuat_B01.TienNhap) as TienNhap,
	   sum(Nhap_Xuat_B01.SlXuat) as SlXuat,
	   sum(Nhap_Xuat_B01.TienXuat) as TienXuat,
	   TonCuoi=0,
	   SoDu=0
from Nhap_Xuat_B01 group by MaHang
)

-- select * from tong_nhap_xuat_B01
create view ton_cuoi_ky_B01 as(
select MaHang,Ngay='',NoiDung=N'Tồn cuối kỳ',
       SlNhap=0, TienNhap=0,SlXuat=0, TienXuat=0,
	   tinh_ton_kho_vs_du_B01.TonCuoi,
	   tinh_ton_kho_vs_du_B01.SoDu
from tinh_ton_kho_vs_du_B01 where tinh_ton_kho_vs_du_B01.Ngay=(select Max(Ngay) from tinh_ton_kho_vs_du_B01)
)

----select * from ton_cuoi_ky_B01
create view chi_tiet_B01 as(
select * from tinh_ton_kho_vs_du_B01
union all select * from tong_nhap_xuat_B01
union all select * from ton_cuoi_ky_B01
)
--select * from chi_tiet_B01

---------
---B02---
---------
create view XuatHang_B02 as(
select XuatHang.MaHang as MaHang, NgayXuat as Ngay,NoiDung=N'Xuất hàng',SlNhap=0,TienNhap=0, Soluong as SlXuat, Thanhtien as TienXuat from
XuatHang join DmHangHoa on DmHangHoa.MaHang = XuatHang.MaHang where XuatHang.MaHang = 'B02'
)
--- select * from XuatHang_B02

create view NhapHang_B02 as(
select NhapHang.MaHang as MaHang, NgayNhap as Ngay,NoiDung=N'Nhập hàng',Soluong as SlNhap, Thanhtien as TienNhap,SlXuat=0,TienXuat=0  from
NhapHang join DmHangHoa on DmHangHoa.MaHang = NhapHang.MaHang where NhapHang.MaHang = 'B02'
)
--- select * from NhapHang_B02 

create view Nhap_Xuat_B02 as(
select * from NhapHang_B02
union all  select * from XuatHang_B02)
-- select * from Nhap_Xuat_B02

create view tinh_ton_kho_vs_du_B02 as (
select *, sum(Nhap_Xuat_B02.SlNhap - Nhap_Xuat_B02.SlXuat) OVER ( order by Nhap_Xuat_B02.Ngay)as TonCuoi,
		  sum(Nhap_Xuat_B02.TienNhap - Nhap_Xuat_B02.TienXuat) OVER ( order by Nhap_Xuat_B02.Ngay)as SoDu
from Nhap_Xuat_B02
)
--select * from tinh_ton_kho_vs_du_B02

create view tong_nhap_xuat_B02 as(
select MaHang,Ngay='',NoiDung=N'Tổng nhập/ xuất',
	   sum(Nhap_Xuat_B02.SlNhap) as SlNhap,
	   sum(Nhap_Xuat_B02.TienNhap) as TienNhap,
	   sum(Nhap_Xuat_B02.SlXuat) as SlXuat,
	   sum(Nhap_Xuat_B02.TienXuat) as TienXuat,
	   TonCuoi=0,
	   SoDu=0
from Nhap_Xuat_B02 group by MaHang
)

-- select * from tong_nhap_xuat_B02
create view ton_cuoi_ky_B02 as(
select MaHang,Ngay='',NoiDung=N'Tồn cuối kỳ',
       SlNhap=0, TienNhap=0,SlXuat=0, TienXuat=0,
	   tinh_ton_kho_vs_du_B02.TonCuoi,
	   tinh_ton_kho_vs_du_B02.SoDu
from tinh_ton_kho_vs_du_B02 where tinh_ton_kho_vs_du_B02.Ngay=(select Max(Ngay) from tinh_ton_kho_vs_du_B02)
)

----select * from ton_cuoi_ky_B02
create view chi_tiet_B02 as(
select * from tinh_ton_kho_vs_du_B02
union all select * from tong_nhap_xuat_B02
union all select * from ton_cuoi_ky_B02
)
--select * from chi_tiet_B02

---------
---B03---
---------
create view XuatHang_B03 as(
select XuatHang.MaHang as MaHang, NgayXuat as Ngay,NoiDung=N'Xuất hàng',SlNhap=0,TienNhap=0, Soluong as SlXuat, Thanhtien as TienXuat from
XuatHang join DmHangHoa on DmHangHoa.MaHang = XuatHang.MaHang where XuatHang.MaHang = 'B03'
)
--- select * from XuatHang_B03

create view NhapHang_B03 as(
select NhapHang.MaHang as MaHang, NgayNhap as Ngay,NoiDung=N'Nhập hàng',Soluong as SlNhap, Thanhtien as TienNhap,SlXuat=0,TienXuat=0  from
NhapHang join DmHangHoa on DmHangHoa.MaHang = NhapHang.MaHang where NhapHang.MaHang = 'B03'
)
--- select * from NhapHang_B03

create view Nhap_Xuat_B03 as(
select * from NhapHang_B03
union all  select * from XuatHang_B03)
-- select * from Nhap_Xuat_B03

create view tinh_ton_kho_vs_du_B03 as (
select *, sum(Nhap_Xuat_B03.SlNhap - Nhap_Xuat_B03.SlXuat) OVER ( order by Nhap_Xuat_B03.Ngay)as TonCuoi,
		  sum(Nhap_Xuat_B03.TienNhap - Nhap_Xuat_B03.TienXuat) OVER ( order by Nhap_Xuat_B03.Ngay)as SoDu
from Nhap_Xuat_B03
)
--select * from tinh_ton_kho_vs_du_B03

create view tong_nhap_xuat_B03 as(
select MaHang,Ngay='',NoiDung=N'Tổng nhập/ xuất',
	   sum(Nhap_Xuat_B03.SlNhap) as SlNhap,
	   sum(Nhap_Xuat_B03.TienNhap) as TienNhap,
	   sum(Nhap_Xuat_B03.SlXuat) as SlXuat,
	   sum(Nhap_Xuat_B03.TienXuat) as TienXuat,
	   TonCuoi=0,
	   SoDu=0
from Nhap_Xuat_B03 group by MaHang
)

-- select * from tong_nhap_xuat_B03
create view ton_cuoi_ky_B03 as(
select MaHang,Ngay='',NoiDung=N'Tồn cuối kỳ',
       SlNhap=0, TienNhap=0,SlXuat=0, TienXuat=0,
	   tinh_ton_kho_vs_du_B03.TonCuoi,
	   tinh_ton_kho_vs_du_B03.SoDu
from tinh_ton_kho_vs_du_B03 where tinh_ton_kho_vs_du_B03.Ngay=(select Max(Ngay) from tinh_ton_kho_vs_du_B03)
)

----select * from ton_cuoi_ky_B03
create view chi_tiet_B03 as(
select * from tinh_ton_kho_vs_du_B03
union all select * from tong_nhap_xuat_B03
union all select * from ton_cuoi_ky_B03
)
--select * from chi_tiet_B03

----Kết quả----
select * from chi_tiet_B01
union all 
select * from chi_tiet_B02
union all 
select * from chi_tiet_B03

