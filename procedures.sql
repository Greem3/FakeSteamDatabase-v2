--Crea un nuevo user en la DB
CREATE PROCEDURE SP_ADD_NEW_USER @name NVARCHAR(100), @role VARCHAR(30)
AS
BEGIN
    DECLARE @command NVARCHAR(500) = N'CREATE USER ' + QUOTENAME(@name) + '; ALTER ROLE ' + @role + N' ADD MEMBER ' + QUOTENAME(@name) + ';'

    EXEC sp_executesql @command;
end

--Crea un nuevo login en la DB
CREATE PROCEDURE SP_ADD_NEW_LOGIN @name VARCHAR(100), @password T_PASSWORD = NULL
AS
BEGIN
    DECLARE @command NVARCHAR(500) = N'CREATE LOGIN ' + QUOTENAME(@name) + N' WITH PASSWORD = ''' + @password + N''';'

    IF @password IS NULL
    BEGIN
        SET @command = N'CREATE LOGIN ' + QUOTENAME(@name) + N' WITHOUT PASSWORD;'
    end

    EXEC sp_executesql @command;
end

--Añade permisos a un objeto
CREATE PROCEDURE SP_ADD_PERMISSIONS @object VARCHAR(100), @add INT, @permissions VARCHAR(200), @tables VARCHAR(MAX)
AS
BEGIN
    --Agarra la primera coma de tables
    DECLARE @pos INT = CHARINDEX(',', @tables)
    --Si se agregara o eliminaran permisos
    DECLARE @grant VARCHAR(6)
    --El comando que se ejecutara
    DECLARE @command NVARCHAR(500)

    SELECT @grant = this FROM (
    VALUES
         (0, 'REVOKE'),
         (1, 'GRANT'),
         (-1, 'DENY')
    ) AS temp(id, this)
    WHERE id = @add

    WHILE @pos > 0
    BEGIN
        --Elimina los espacios en blanco del substring
        --EL comando que se usara para añadir permisos a un objeto
        SET @command = @grant + ' ' + @permissions + ' ON ' + TRIM(SUBSTRING(@tables, 1, @pos - 1)) + ' TO ' + @object

        EXEC sp_executesql @command;

        --Elimina la tabla que ya se uso junto con la coma
        SET @tables = TRIM(SUBSTRING(@tables, @pos + 1, LEN(@tables)))

        --Revisa si hay una nueva coma
        SET @pos = CHARINDEX(',', @tables)
    end

    IF LEN(@tables) > 0
    BEGIN
        --Se ejecuta el comando directamente
        SET @command = @grant + ' ' + @permissions + ' ON ' + TRIM(@tables) + ' TO ' + @object

        EXEC sp_executesql @command
    end
end

CREATE PROCEDURE SP_ADD_INDEX_IN @table VARCHAR(30), @columns VARCHAR(MAX), @type VARCHAR(12) = ''
AS
BEGIN
    DECLARE @pos INT = CHARINDEX('|', @columns)
    DECLARE @command NVARCHAR(MAX)
    DECLARE @act_columns VARCHAR(2000)

    --Mientras haya un punto, se ejecuta
    WHILE @pos > 0
    BEGIN
        --Agarra las columnas actuales
        SET @act_columns = TRIM(SUBSTRING(@columns, 1, @pos-1))
        --Reemplaza los ( y ) para ponerle un nombre al indice
        SET @command = 'CREATE ' + @type + ' INDEX IDX_' + @table + '_' + REPLACE(REPLACE(@act_columns, '(', ''), ')', '') + ' ON ' + @table + '(' + @act_columns + ')'

        EXEC sp_executesql @command;

        --Elimina la columna ya utilizada
        SET @columns = TRIM(SUBSTRING(@columns, @pos + 1, LEN(@columns) - @pos))
        SET @pos = CHARINDEX('|', @columns)
    end

    IF LEN(@columns) > 0
    BEGIN
        SET @command = 'CREATE ' + @type + ' INDEX IDX_' + @table + '_' + REPLACE(REPLACE(@columns, '(', ''), ')', '') + ' ON ' + @table + '(' + @columns + ')'

        EXEC sp_executesql @command;
    end
end