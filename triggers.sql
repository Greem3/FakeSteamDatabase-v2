--======================================================
--ACCOUNTS
--======================================================

--Genera un ID Random para los usuarios que tengan el ID vacio
CREATE TRIGGER trg_NotEmptyUserID ON ACCOUNTS
AFTER INSERT, UPDATE AS
BEGIN
    UPDATE ACCOUNTS
    SET ACCOUNT_NAME = CAST(ID AS VARCHAR(100))
    WHERE ACCOUNT_NAME = ''
end


--Evita que los DEVELOPERS puedan tener numeros como ID
CREATE TRIGGER trg_NoNumbersForDevelopers ON ACCOUNTS
AFTER INSERT, UPDATE AS
BEGIN
    --Cuando se inserte una cuenta de tipo developer y tiene un nombre numerico, ejecutara el error
    IF EXISTS(SELECT * FROM inserted WHERE ACCOUNT_TYPE = 'D' AND TRY_CAST(ACCOUNT_NAME AS INT) IS NOT NULL)
    BEGIN
        ROLLBACK;
        RAISERROR ('Developers cannot have numerical names', 16, 1)
    end
end


--Añade a los nuevos usuarios a la base de datos
CREATE TRIGGER trg_CreateUser ON ACCOUNTS
AFTER INSERT AS
BEGIN
    --Variables a usar
    DECLARE @id INT
    DECLARE @name NVARCHAR(100)
    DECLARE @password T_PASSWORD
    DECLARE @type CHAR

    --Añade un nuevo cursor a la base de datos y le dice a que va a apuntar
    --Que son las columnas seleccionadas de la tabla que se va a insertar
    DECLARE temp_cursor CURSOR FOR
    SELECT a.ID, a.ACCOUNT_NAME, a.PASSWORD, a.ACCOUNT_TYPE
    FROM ACCOUNTS a JOIN inserted i ON a.ACCOUNT_NAME = i.ACCOUNT_NAME;

    --Abre el cursor
    OPEN temp_cursor

    --Agarra la siguiente fila de la tabla inserted (en este caso 1)
    FETCH NEXT FROM temp_cursor INTO @id, @name, @password, @type

    --Si existe la fila, ejecuta el bucle, si da como resultado -1 o -2, se detiene el bucle
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @role VARCHAR(9) = 'N_USER'
        DECLARE @table VARCHAR(10) = 'USERS'

        --Si la cuenta es un usuario, lo añadira a la tabla usuarios, sino lo añadira a la tabla developers
        IF (@type = 'D')
        BEGIN
            SET @role = 'DEVELOPER'
            SET @table = 'DEVELOPERS'
        end

        DECLARE @command NVARCHAR(1000) = N'INSERT INTO ' + @table + ' (ACCOUNT_ID) VALUES (' + CAST(@id AS VARCHAR(50)) + ')'
        --Ejecuta el comando SQL
        EXEC sp_executesql @command

        FETCH NEXT FROM temp_cursor INTO @id, @name, @password, @type
    end

    CLOSE temp_cursor
    DEALLOCATE temp_cursor
end

--======================================================
--DIRECTIONS
--======================================================

--Crea la direccion automaticamente al crear la localidad
CREATE TRIGGER trg_CreateDirection ON LOCALITIES
AFTER INSERT AS
BEGIN
    INSERT INTO DIRECTIONS (LOC_ID, PRO_ID, COU_ID)
    SELECT I.ID, P.ID, C.ID
    FROM inserted I JOIN PROVINCES P ON I.PRO_ID = P.ID
        JOIN COUNTRIES C ON P.COU_ID = C.ID
end

--======================================================
--ACHIEVEMENTS
--======================================================

--Evita que se haga un insert como quiera el usuario
CREATE TRIGGER trg_RealInsertAchievement
ON ACHIEVEMENTS
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO ACHIEVEMENTS(ACH_NAME, ID_GAME, INFO, IS_SECRET, NUMBER)
    --Inserta en ACHIEVEMENTS los datos que puso el usuario, pero el number es intercambiado por el valor que devolvera GenNewNumerAch
    SELECT ACH_NAME, ID_GAME, INFO, IS_SECRET, dbo.GenNewNumberAch(ID_GAME)
    FROM inserted
end

--======================================================
--TRANSACTIONS
--======================================================

CREATE TRIGGER trg_AddBookAfterTrans ON TRANS_GAMES
AFTER INSERT AS
BEGIN
    INSERT INTO BOOKSTORES (ACCOUNT_ID, ID_GAME)
    SELECT t.ACCOUNT_ID, i.ID_GAME
    FROM inserted i JOIN TRANSACTIONS t ON i.TRANSACTION_ID = t.ID
end