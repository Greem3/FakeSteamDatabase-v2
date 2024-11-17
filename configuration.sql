--Vuelve la base de datos una base de datos contenida
EXEC sp_configure 'contained database authentication', 1;

--La reconfigura
RECONFIGURE;

--Hace que la base de datos sea de un solo usuario y desconecta a los otros inmediatamente
ALTER DATABASE TestShop SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--Vuelve el contenimiento parcial
ALTER DATABASE TestShop SET CONTAINMENT = PARTIAL;
--La vuelve multiusuarios
ALTER DATABASE TestShop SET MULTI_USER;

--Muestra las opciones avanzadas
EXEC sp_configure 'show advanced options', 1
RECONFIGURE

--Revisa cual es el modo del Login
EXEC xp_instance_regread
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode';
