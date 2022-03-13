use crm_2

create table City_District
(

Id int not null,
City varchar(50) not null,
TownCode varchar (50) not null,
Town varchar (50) not null,
PhoneCode varchar(50) not null,

);

Insert into dbo.City_District ( Id, City, TownCode, Town, PhoneCode )
select ID, CITY, TOWNCODE, TOWN, PHONECODE from CRM2.dbo.CITY_DISTRICT

create table Customers
(

	[ID] [int] NOT NULL,
	[NAMESURNAME] [varchar](150) NOT NULL,
	[GENDER] [varchar](1) NOT NULL,
	[BIRTHDATE] [date] NOT NULL,
	[CITY] [varchar](100) NOT NULL,
	[TOWN] [varchar](100) NOT NULL,
	[TELNR] [varchar](50) NOT NULL,
	[NAME_] [varchar](50) NOT NULL,
	[SURNAME] [varchar](50) NOT NULL,
	[TCNO] [varchar](20) NOT NULL,
);

Insert into dbo.Customers ( ID, NAMESURNAME, GENDER, BIRTHDATE, CITY, TOWN, TELNR, NAME_, SURNAME, TCNO )
select ID, NAMESURNAME, GENDER, BIRTHDATE, CITY, TOWN, TELNR, NAME_, SURNAME, TCNO from CRM2.dbo.CUSTOMERS

create table Names
(
	[ID] [int] NOT NULL,
	[NAME_] [varchar](50) NULL,
	[GENDER] [varchar](50) NULL,
	[NAME2] [varchar](50) NULL,
);

Insert into dbo.Names ( ID, NAME_, GENDER, NAME2 )
select ID, NAME_, GENDER, NAME2 from CRM2.dbo.NAMES

create table Surnames
(
	[ID] [int] NOT NULL,
	[SURNAME] [varchar](150) NULL,
);

Insert into dbo.Surnames( Id, Surname  )
select ID, SURNAME from CRM2.dbo.SURNAMES

create table Telephones
(
	[ID] [int]  NOT NULL,
	[TELNR] [varchar](50) Not NULL,
);

Insert into dbo.Telephones(  ID, TELNR  )
select ID, TELNR from CRM2.dbo.TELEPHONES

---------------sp 

USE [CRM_2]
GO

/****** Object:  StoredProcedure [dbo].[SPGENERATE_CUSTOMER]    Script Date: 1.03.2022 14:53:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 CREATE PROC [dbo].[SPGENERATE_CUSTOMER]
 @COUNT AS INT=10 
 AS

 DECLARE @I AS INT=0
 WHILE @I<@COUNT
 BEGIN

 DECLARE @ID AS INT
 DECLARE @NAME AS VARCHAR(100)
 DECLARE @SURNAME AS VARCHAR(100)
 DECLARE @GENDER AS VARCHAR(1)
 DECLARE @BIRTHDATE AS DATE
 DECLARE @CITY AS VARCHAR(100)
 DECLARE @TOWN AS VARCHAR(100)
 DECLARE @NAMESURNAME AS VARCHAR(100)
 DECLARE @PHONECODE AS VARCHAR(10)
 DECLARE @TELNR AS VARCHAR(20)
 DECLARE @TCNO AS VARCHAR(11)

 

SET @TCNO=CONVERT(VARCHAR,ROUND(RAND()*999999999999,0))
IF  LEN(@TCNO)=7
	SET @TCNO=  SUBSTRING(REPLACE(CONVERT(VARCHAR,GETDATE(),108) ,':',''),2,4)+@TCNO
IF  LEN(@TCNO)=8
	SET @TCNO=  SUBSTRING(REPLACE(CONVERT(VARCHAR,GETDATE(),108) ,':',''),2,3)+@TCNO
IF  LEN(@TCNO)=9
	SET @TCNO=  SUBSTRING(REPLACE(CONVERT(VARCHAR,GETDATE(),108) ,':',''),4,2)+@TCNO
IF  LEN(@TCNO)=10
	SET @TCNO=  SUBSTRING(REPLACE(CONVERT(VARCHAR,GETDATE(),108) ,':',''),4,1)+@TCNO
IF LEN(@TCNO)=12
	SET @TCNO=SUBSTRING(@TCNO,2,11)
IF LEN(@TCNO)=13
	SET @TCNO=SUBSTRING(@TCNO,3,11)
IF LEN(@TCNO)=14
	SET @TCNO=SUBSTRING(@TCNO,4,11)

IF EXISTS(SELECT TcIdentity FROM CUSTOMERS WHERE TcIdentity=@TCNO)
BEGIN
	SET @TCNO=SUBSTRING(@TCNO,2,9)+SUBSTRING(@TCNO,9,2)
END
 
 SET @ID=RAND()*609
 SELECT @NAME=NAME_,@GENDER=GENDER FROM NAMES WHERE ID=@ID 
 SET @ID=RAND()*16000
 SELECT @SURNAME=SURNAME FROM SURNAMES WHERE ID=@ID 

 SET @ID=RAND()*995
 SELECT @PHONECODE=PHONECODE, @CITY=City,@TOWN=TOWN FROM City_District WHERE ID=@ID 
 
 SET @ID=RAND()*(50*365)
 SET @BIRTHDATE=DATEADD(DAY,@ID,'19500101')


 SET @ID=RAND()*200000
 SELECT @TELNR=@PHONECODE+Gsm FROM TELEPHONES WHERE ID=@ID

 SET @NAMESURNAME=@NAME+' '+ @SURNAME 
 
 
 --SELECT @NAME,@SURNAME,@GENDER,@BIRTHDATE,@CITY,@TOWN
 
 INSERT INTO CUSTOMERS( NameSurname, Gender, Birthdate, City, Town, Gsm, Name_, Surname, TcIdentity)
 VALUES (@NAMESURNAME, @GENDER, @BIRTHDATE, @CITY, @TOWN, @NAME, @SURNAME,@TELNR,@TCNO)
SET @I=@I+1 	
 END
 
  
GO

--------------- index fragmantasyonlarýný gözlemlemek adýna oluþturduðumuz store procedure her çaðýrýlýþýnda customers tablosuna 1000 kayýt atar

--exec SPGENERATE_CUSTOMER

select count ( * )  from Customers 

--default hali : 2540376 veri, PK_Customers fill factor % 0, fragmantasyon % 0.01
--IX2 fragmantasyon % 0.00
--IX3 fragmantasyon % 0.00
--IX4 fragmantasyon % 0.00

exec SPGENERATE_CUSTOMER --100.000 kayýt eklendikten sonra

--PK_Customers fragmantasyon % 0.04
--IX2 fragmantasyon % 97.03
--IX3 fragmantasyon % 99.25
--IX4 fragmantasyon % 9.05   bozulma mevcut



--tüm indexleri rebuilt edip fill factor oranlarýný %70 e çekiyorum
--sonra 100.000 kayýt daha ekleyip bozulma oranýný kontrol ediyorum

exec SPGENERATE_CUSTOMER --100.000 kayýt daha eklendi.

--PK_Customers fragmantasyon % 0.01
--IX2 fragmantasyon % 0.01
--IX3 fragmantasyon % 0.00
--IX4 fragmantasyon % 9.64  

--fill factor %70 e çekildikten sonraki bozulma oranlarý düþmüþtür.