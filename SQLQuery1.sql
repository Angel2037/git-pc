use Dev_SQLFunctionsStoredTriggers

--function
CREATE FUNCTION dbo.GetClientbyId
(@ClientId int )
RETURNS	table

AS
RETURN(
SELECT*FROM Client WHERE ClientID =@ClientId
)

select*from GetClientbyId(1) 

CREATE FUNCTION dbo.Reservaciones
(@ClientId INT)
RETURNS @ClientReservation TABLE
(
	ClientId			 INT		NOT NULL,
	ClientName			 TEXT		NOT NULL,
	ReservationDateIn	 DATETIME   NOT NULL,
	ReservationDateOut	 DATETIME   NOT NULL
)
AS
BEGIN
	INSERT @ClientReservation
		SELECT a.ClientId, a.ClientName, b.ReservationDateIn, b.ReservationDateOut
	FROM Client a
		INNER JOIN Reservation b
	ON a.ClientId =b.ReservationClientId
WHERE ClientId=@ClientId

RETURN
END

SELECT*FROM dbo.Reservaciones(1)


--trigger 

CREATE TRIGGER dbo.Reservacion_Insert
ON dbo.Reservation
AFTER INSERT 
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @clientId int ;
	SELECT @clientId =INSERTED.ReservationClientID
	FROM INSERTED

	INSERT INTO dbo.log
	VALUES ('Automatic Insert log','client'+ CAST(@clientId as varchar)+'was updated')

END 



CREATE TRIGGER dbo.Room_Update
	ON dbo.Room
	AFTER UPDATE
	AS 
BEGIN 

SET NOCOUNT ON;
	DECLARE @RoomId INT;
	DECLARE @Action VARCHAR (50) ;
SELECT @RoomId =INSERTED.RoomID
FROM INSERTED
	
	IF UPDATE (RoomName)
	BEGIN
		SET @Action ='Updated Name'
	END

	IF UPDATE (RoomDescription)
	BEGIN
		SET @Action='Update Descripcion'

	END

	INSERT INTO dbo.Log
	VALUES('Automatic Update log',@Action+'en room'+ CAST(@RoomId as varchar))



END

DROP TRIGGER Room_Update





CREATE TRIGGER dbo.Reservation_Delete 
	ON dbo.Reservation
	AFTER DELETE 
AS
BEGIN

SET NOCOUNT ON;
DECLARE @RoomId INT ;

SELECT @RoomId = DELETED.ReservationRoomID
FROM DELETED

INSERT INTO dbo.Log
Values ('Automatic deleted log','Room'+CAST(@RoomId as varchar)+'is NOW available ')

END

--procedimiento almacenado--

CREATE PROCEDURE dbo.Getclientes
AS
	SELECT*FROM Client;
GO

EXECUTE dbo.Getclientes


CREATE PROCEDURE dbo.GetClientesName
@LastName nvarchar(50),
@Name nvarchar(50)
AS
SELECT ClientName,ClientLastName,ClientEmail,ClientCountryAddress
FROM Client
WHERE ClientName=@Name AND ClientLastName =@LastName

GO

EXEC dbo.GetClientesName @LastName= N'Lynch',@Name=N'Steven'





--Alter para altererar procedure 
CREATE PROCEDURE dbo.getfullnameEmail 
@Email nvarchar(50)

AS
SELECT CONCAT(CONCAT(ClientName,''),ClientLastName)as ClientFullName,ClientEmail
FROM Client
WHERE ClientEmail LIKE '%'+@Email+'%'
GO

EXEC dbo.getfullnameEmail @Email= N'.com'


create PROC dbo.gettotalreservationuser 
	@ClientID int,
	@ReservationCount int OUTPUT
AS
	SELECT @ReservationCount = Count(*)
	FROM dbo.Reservation
	WHERE ReservationClientID =@ClientID
GO

drop proc dbo.gettotalreservationuser 

DECLARE @ReservationCount int 
EXEC dbo.gettotalreservationuser  @ClientID  =3 ,@ReservationCount = @ReservationCount OUTPUT
SELECT @ReservationCount





--manejo de errores 
CREATE PROC dbo.uspError
AS
BEGIN TRY
SELECT 1/0--ESTE ES EL ERROR
END TRY 
BEGIN CATCH
	SELECT ERROR_NUMBER() As ErrorNumber
	,ERROR_STATE() As ErrorState
	,ERROR_MESSAGE() As ErrorMessage
	,ERROR_SEVERITY() As ErrorSeveryty
	,ERROR_LINE() As ErrorLine
	,ERROR_PROCEDURE() As ErrorProcedure 
END CATCH

EXEC uspError


--CURSORES

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE PrintClients_Cursor
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ClientID INT
		,@ClientName VARCHAR(100)
		,@ClientLastName VARCHAR(100)
	
	Declare @Counter INT
	SET @Counter =1

	DECLARE PrintClients CURSOR READ_ONLY
	FOR
	SELECT ClientID,ClientName,ClientLastName
	FROM Client

	OPEN PrintClients

	FETCH NEXT FROM PrintClients INTO
	@ClientID,@ClientName,@ClientLastName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @Counter = 1
		BEGIN
		PRINT 'ClientID'+CHAR(9)+'NAME'+CHAR(9)+'LAST NAME'
		PRINT'-----------------------------------------------'

	END
		PRINT CAST(@ClientID as VARCHAR(10) )+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+@ClientName +CHAR(9)+@ClientLastName
		SET @Counter = @Counter + 1

		FETCH NEXT FROM PrintClients INTO
		@ClientID,@ClientName,@ClientLastName 
	END
	CLOSE PrintClients
	DEALLOCATE PrintClients
END
GO



DROP PROCEDURE  PrintClients_Cursor

EXEC PrintClients_Cursor





















