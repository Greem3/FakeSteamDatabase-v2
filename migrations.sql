--Haciendo un backup
BACKUP DATABASE GameShop
TO DISK = 'C:\Backup\BackUpDeGameShop.bak'

--Con Inserts
INSERT INTO TestShop.dbo.USERS (ACCOUNT_ID)
SELECT ACCOUNT_ID
FROM GameShop.dbo.USERS

--A XML

SELECT *
FROM ACCOUNTS
--Root es la etiqueta raiz de accounts
--Elements los genera como datos en vez de atributos
FOR XML AUTO, ROOT('Accounts'), ELEMENTS;

--A JSON

SELECT *
FROM ACCOUNTS
FOR JSON AUTO, ROOT('Accounts');



--Cargar un archivo XML a la DB

--Variable para guardar los datos cargados
DECLARE @xmlData XML;

--Guarda los datos del XML en la variable
SELECT @xmlData = BulkColumn
--Single blob carga el contenido completo en binario
FROM OPENROWSET(BULK 'C:\Users\Ian\Documents\Colegio\test.xml', SINGLE_BLOB);


--Insertar los datos en otra base de datos
INSERT INTO TestShop.dbo.ACCOUNTS (USERNAME, EMAIL, PASSWORD, ROL_ID)
SELECT
    T.C.value('(USERNAME)[1]', 'NVARCHAR(100)'),
    T.C.value('(EMAIL)[1]', 'NVARCHAR(255)'),
    T.C.value('(PASSWORD)[1]', 'NVARCHAR(100)'),
    T.C.value('(ROL_ID)[1]', 'NVARCHAR(100)')
FROM @xmlData.nodes('/Accounts/ACCOUNTS') AS T(C);



--Cargar un archivo JSON en la DB

--Aqui se guardara el JSON
DECLARE @json NVARCHAR(MAX);


SELECT @json = BulkColumn
--Single clob es para leer archivos de texto
FROM OPENROWSET(BULK 'C:\Users\Ian\Documents\Colegio\test.json', SINGLE_CLOB);

--Carga el JSON y lo inserta en la tabla
INSERT INTO ACCOUNTS (USERNAME, EMAIL, PASSWORD, ROL_ID)
SELECT
    j.USERNAME,
    j.EMAIL,
    j.PASSWORD,
    j.ROL_ID
FROM OPENJSON(@json)
WITH (
    USERNAME NVARCHAR(100),
    EMAIL NVARCHAR(255),
    PASSWORD T_PASSWORD,
    ROL_ID INT
) AS j;


--Para SSMS
CREATE DATABASE MIGRATE_DB;