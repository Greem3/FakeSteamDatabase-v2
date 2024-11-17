--Se crea un nuevo login
EXEC SP_ADD_NEW_LOGIN 'GLOBAL', 'VerySecurePassword';

--Un nuevo usuario para el login GLOBAL
CREATE USER NOT_REGISTERED FOR LOGIN GLOBAL;

--Permite a todos los usuarios en el login GLOBAL poder leer la información
EXEC sp_addrolemember 'db_datareader', 'NOT_REGISTERED';

--DENY hace que sin importar los permisos heredados, si o si se cumplira
EXEC SP_ADD_PERMISSIONS
     'NOT_REGISTERED',
     -1,
     'SELECT',
     'TRANSACTIONS,TRANS_GAMES,WISHLISTS,BOOKSTORES';
GRANT INSERT ON ACCOUNTS TO NOT_REGISTERED

-- REVOKE SELECT, INSERT, UPDATE, DELETE ON TRANSACTIONS TO NOT_REGISTERED
-- REVOKE SELECT, INSERT, UPDATE, DELETE ON TRANS_GAMES TO NOT_REGISTERED
-- REVOKE SELECT, INSERT, UPDATE, DELETE ON WISHLISTS TO NOT_REGISTERED


--Roles para los usuarios ya registrados
EXEC SP_ADD_NEW_LOGIN 'REGISTERED', 'SuperSecurePassword1';
CREATE USER ALL_ACCOUNTS FOR LOGIN REGISTERED;

--Crea un role para los usuarios
CREATE ROLE IS_USER
ALTER ROLE IS_USER ADD MEMBER ALL_ACCOUNTS

--Hace que puedan leer la db
EXEC sp_addrolemember 'db_datareader', 'IS_USER';

--Le añade permisos a INSERT, UPDATE y DELETE
EXEC SP_ADD_PERMISSIONS
    'IS_USER',
    1,
    'INSERT, UPDATE, DELETE',
    'VOTES,FOLLOWS'

EXEC SP_ADD_PERMISSIONS
    'ALL_ACCOUNTS',
    1,
    'UPDATE, DELETE',
    'USERS,ACCOUNTS'

GRANT INSERT ON DEVELOPERS TO IS_USER

--Login para los developers
EXEC SP_ADD_NEW_LOGIN 'DEV_REGISTERED', 'SuperDuperSecurePassword12'
CREATE USER ALL_DEVELOPERS FOR LOGIN DEV_REGISTERED

--Rol para los developers
CREATE ROLE DEV_OPTIONS;
--hereda del role IS_USER
ALTER ROLE DEV_OPTIONS ADD MEMBER IS_USER;

--Añade los permisos que hay a los developers
EXEC SP_ADD_PERMISSIONS
    'DEV_OPTIONS',
    1,
    'INSERT, UPDATE, DELETE',
    'DEVELOPERS,GAMES,GEN_GAMES,ACHIEVEMENTS'

EXEC SP_ADD_PERMISSIONS
    'DEV_OPTIONS',
    1,
    'UPDATE, DELETE',
    'DEVELOPERS,ACCOUNTS'

ALTER ROLE DEV_OPTIONS ADD MEMBER ALL_DEVELOPERS;

--Login paralos administradores
EXEC SP_ADD_NEW_LOGIN 'ADMINS', 'SuperDuperUltraSecurePassword123';
CREATE USER ADMINISTRATOR FOR LOGIN ADMINS;

--Rol para los admins
CREATE ROLE ADMIN_OPTIONS;
--Hereda de DEV_OPTIONS que hereda de IS_USER
ALTER ROLE ADMIN_OPTIONS ADD MEMBER DEV_OPTIONS;
ALTER ROLE ADMIN_OPTIONS ADD MEMBER ADMINISTRATOR

EXEC sp_addrolemember 'db_datareader', 'ADMIN_OPTIONS';
EXEC sp_addrolemember 'db_datawriter', 'ADMIN_OPTIONS';
EXEC sp_addrolemember 'db_ddladmin', 'ADMIN_OPTIONS';
EXEC sp_addrolemember 'db_backupoperator', 'ADMIN_OPTIONS';
EXEC sp_addrolemember 'db_accessadmin', 'ADMIN_OPTIONS';

EXEC SP_ADD_NEW_LOGIN 'SUPER_ADMINS', 'SuperDuperUltraMegaSecurePassword1234'
CREATE USER SUPER_ADMIN FOR LOGIN SUPER_ADMINS;

EXEC sp_addrolemember 'db_owner', 'SUPER_ADMIN';