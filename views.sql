
--====================================================================================
--Nombre de las direcciones
--====================================================================================

CREATE VIEW V_NAME_DIRECTIONS AS
SELECT d.ID, c.COU_NAME AS COUNTRY, p.PRO_NAME AS PROVINCE, l.LOC_NAME AS LOCALITY
--Union entre direcciones y paises
FROM DIRECTIONS d JOIN LOCALITIES l ON d.LOC_ID = l.ID
    JOIN PROVINCES p ON l.PRO_ID = p.ID
    JOIN COUNTRIES c ON c.ID = p.COU_ID

--====================================================================================
--Info BOOKSTORES
--====================================================================================

CREATE VIEW V_BOOKSTORES_INFO AS
--Muestra todos los registros (que serian los juegos totales) y el total de horas jugadas por el usuario
SELECT a.ACCOUNT_NAME, COUNT(b.ACCOUNT_ID) AS 'TOTAL GAMES', SUM(b.HOURS_PLAYED) AS 'TOTAL HOURS PLAYED'
FROM BOOKSTORES b RIGHT JOIN ACCOUNTS a ON b.ACCOUNT_ID = a.ID
GROUP BY a.ACCOUNT_NAME

--====================================================================================
--Estadisticas de los usuarios
--====================================================================================

CREATE VIEW V_ACCOUNTS_STATS AS
SELECT a.ACCOUNT_NAME AS NAME, a.INFO AS DESCRIPTION, a.CREATE_DATE, d.COUNTRY, d.PROVINCE, d.LOCALITY, COUNT(ac.ID_ACH) AS TOTAL_ACHIEVEMENTS, COUNT(b.ACCOUNT_ID) AS 'TOTAL GAMES PURCHASED'
--Union entre las cuentas y el nombre de las direcciones, si la cuenta no tiene direccion saldra igualmente, pero las cuentas saldran NULL
FROM ACCOUNTS a LEFT JOIN V_NAME_DIRECTIONS d ON a.DIRECTION_ID = d.ID
    --Union entre las cuentas y los logros para ver sus logros totales
    LEFT JOIN ACCOUNTS_ACHS ac ON a.ID = ac.ACCOUNT_ID
    --Union entre las cuentas y su biblioteca, sino tienen saldran igualmente
    LEFT JOIN BOOKSTORES b ON a.ID = b.ACCOUNT_ID
GROUP BY a.ACCOUNT_NAME, a.INFO, a.CREATE_DATE, a.INFO, a.ACCOUNT_NAME, d.COUNTRY, d.PROVINCE, d.LOCALITY

--====================================================================================
--Info Developers
--====================================================================================

CREATE VIEW V_DEVELOPERS_INFO AS
SELECT a.USERNAME AS 'DEVELOPER NAME', D.WEB_PAGE, VAS.DESCRIPTION, VAS.CREATE_DATE, VAS.COUNTRY, VAS.PROVINCE, VAS.LOCALITY, VAS.TOTAL_ACHIEVEMENTS, VAS.[TOTAL GAMES PURCHASED]
FROM DEVELOPERS D JOIN ACCOUNTS a ON D.ACCOUNT_ID = a.ID
    JOIN V_ACCOUNTS_STATS VAS ON a.ACCOUNT_NAME = VAS.NAME

--====================================================================================
--Logros de los juegos sin importar que esten secretos
--====================================================================================

CREATE VIEW V_GLOBAL_ACHIEVEMENTS AS
SELECT g.ID AS GAME_ID, g.GAME_NAME, a.ID AS ACH_ID, a.ACH_NAME AS 'ACHIEVEMENT NAME', a.INFO AS 'ACHIEVEMENT INFO', a.IS_SECRET
FROM GAMES g JOIN ACHIEVEMENTS a ON g.ID = a.ID_GAME

--====================================================================================
--Logros de los juegos pero los secretos no muestran información
--====================================================================================

CREATE VIEW V_SECRET_ACHIEVEMENTS AS
SELECT GAME_NAME,
    --Si el logro es secreto no se mostrara su información
    --TODO: hacer que detecte si lo desbloqueo
    IIF(IS_SECRET = 1, 'This achievement is secret', [ACHIEVEMENT NAME]) AS 'ACHIEVEMENT NAME',
    IIF(IS_SECRET = 1, 'You can''t see how to unlock this achievement', [ACHIEVEMENT INFO]) AS 'ACHIEVEMENT INFO'
--Union entre los juegos y sus logros
FROM V_GLOBAL_ACHIEVEMENTS

--====================================================================================
--Logros de las cuentas en los juegos
--====================================================================================

CREATE VIEW V_ACCOUNTS_ACHIEVEMENTS AS
SELECT a.ACCOUNT_NAME, g.GAME_NAME, g.[ACHIEVEMENT NAME] AS 'ACHIEVEMENT NAME', g.[ACHIEVEMENT INFO] AS 'ACHIEVEMENT DESCRIPTION'
--Union entre la tabla account_achs y la tabla accounts
FROM ACCOUNTS_ACHS ach JOIN ACCOUNTS a ON ach.ACCOUNT_ID = a.ID
    --Union entre el VIEW global_achievements para ver todos los logros de los usuarios
    JOIN V_GLOBAL_ACHIEVEMENTS g ON g.ACH_ID = ach.ID_ACH

--====================================================================================
--Informacion de los juegos
--====================================================================================

CREATE VIEW V_GAME_INFO AS
SELECT g.GAME_NAME, STRING_AGG(gag.GEN_NAME, ', ') AS GENRES, g.CREATED_DATE, g.ID_DEV AS DEVELOPER,
       g.ID_EDT AS EDITOR, g.INFO AS DESCRIPTION, g.PRICE, COUNT(a.ID) AS TOTAL_ACHIEVEMENTS, g.ORIGINAL_GAME
--Union entre juegos y la tabla de interseccion entre games gender
FROM GAMES g JOIN GEN_GAMES gg ON g.ID = gg.ID_GAME
    --Union entre la tabla de interseccion y los generos de los juegos
    JOIN GAMES_GENRES gag ON gag.ID = gg.GENRE_ID
    --Union con los logros de los juegos
    LEFT JOIN ACHIEVEMENTS a ON g.ID = a.ID_GAME
GROUP BY g.GAME_NAME, g.CREATED_DATE, g.PRICE, g.ORIGINAL_GAME, g.ID_DEV, g.ID_EDT, g.INFO

--====================================================================================
--Ver los objetos de las transacciones y sus precios
--====================================================================================

CREATE VIEW V_ITEMS_TRANSACTIONS AS
--Se muestra toda la informacion del objeto de una transaccion
SELECT t.TRANSACTION_ID, g.ID AS GAME_ID, g.GAME_NAME, g.PRICE
FROM TRANS_GAMES t JOIN GAMES g ON t.ID_GAME = g.ID

--====================================================================================
--Informacion de las transacciones
--====================================================================================

CREATE VIEW V_TRANSACTIONS_INFO AS
--Muestra el nombe del usuario, todos los juegos que compro, y el precio total de la transaccion
SELECT a.ACCOUNT_NAME AS 'USER', STRING_AGG(g.GAME_NAME, ', ') AS ALL_GAMES, SUM(g.PRICE) AS 'TOTAL PRICE',
       t.TRANS_DATE AS 'TRANSACTION DATE', t.USE_CARD AS WALLET
--Union entre las transacciones y los objetos que tendra la transaccion
FROM TRANSACTIONS t JOIN V_ITEMS_TRANSACTIONS g ON t.ID = g.TRANSACTION_ID
    --Union entre la transaccion y la cuenta de usuario
    JOIN ACCOUNTS a ON t.ACCOUNT_ID = a.ID
GROUP BY t.TRANS_DATE, a.ACCOUNT_NAME, t.USE_CARD

--====================================================================================
--Informacion de las votaciones de los juegos
--====================================================================================

CREATE VIEW V_VOTE_INFO AS
SELECT
    a.ACCOUNT_NAME AS ACCOUNT,
    --Si el VOTE_TYPE es 1 mostrara recomendado
    IIF(v.VOTE_TYPE = 1, 'RECOMMENDED', 'NOT RECOMMENDED') AS TYPE_VOTE,
    g.GAME_NAME AS GAME_VOTED,
    v.INFO AS DESCRIPTION
FROM VOTES v JOIN ACCOUNTS a ON v.ACCOUNT_ID = a.ID
    JOIN GAMES g ON v.ID_GAME = g.ID

--====================================================================================
--Ver todos los seguidores de un Developer
--====================================================================================

CREATE VIEW V_ACCOUNT_FOLLOWS AS
SELECT a.USERNAME AS 'ACCOUNT', da.ACCOUNT_NAME AS 'DEVELOPER'
--Relacion entre los seguidores
FROM DEVELOPERS d JOIN FOLLOWS f ON d.ACCOUNT_ID = f.ACCOUNT_ID_DEV
    --Se relaciona con las cuentas que lo siguiente
    JOIN ACCOUNTS a ON a.ID = f.ACCOUNT_ID
    --Se relaciona con la cuenta del developer para poner su nombre
    JOIN ACCOUNTS da ON da.ID = f.ACCOUNT_ID_DEV

CREATE VIEW V_USER_TOTAL_FOLLOWS AS
--Calcula el total de cuentas a la que sigue el usuario
SELECT ACCOUNT, COUNT(DEVELOPER) AS 'TOTAL FOLLOWS'
FROM V_ACCOUNT_FOLLOWS
GROUP BY ACCOUNT

CREATE VIEW V_DEV_FOLLOWERS AS
--Se muestra el nombre del developer y el total de sus seguidores
SELECT DEVELOPER, COUNT(ACCOUNT) AS 'TOTAL FOLLOWERS'
FROM V_ACCOUNT_FOLLOWS
GROUP BY DEVELOPER

--====================================================================================
--Ver los permisos de los roles
--====================================================================================

CREATE VIEW V_ROLES_PERMISSIONS AS
SELECT r.ROL_NAME, STRING_AGG(p.PER_NAME, ', ') AS PERMISSIONS, r.OBLIGATORY
FROM ROLES r LEFT JOIN ROLES_PERMISSIONS rp ON r.ID = rp.ROL_ID
    JOIN PERMISSIONS p ON rp.PER_ID = p.ID
GROUP BY r.ROL_NAME, r.OBLIGATORY

--====================================================================================
--Ver la whistlist de las cuentas
--====================================================================================

CREATE VIEW V_ACCOUNT_WISHLIST_SEPARATED AS
SELECT a.ID, a.ACCOUNT_NAME, g.ID, g.GAME_NAME
FROM WISHLISTS w RIGHT JOIN ACCOUNTS a ON w.ACCOUNT_ID = a.ID
    JOIN GAMES g ON g.ID = w.GAME_ID

CREATE VIEW V_ACCOUNT_WISHLIST AS
SELECT a.ACCOUNT_NAME, STRING_AGG(g.GAME_NAME, ', ') AS 'GAMES NAMES', COUNT(g.ID) AS 'TOTAL GAMES'
FROM WISHLISTS w RIGHT JOIN ACCOUNTS a ON w.ACCOUNT_ID = a.ID
    JOIN GAMES g ON g.ID = w.GAME_ID
GROUP BY a.ACCOUNT_NAME

--====================================================================================
--Ver los roles
--====================================================================================

CREATE VIEW V_ROLES_PERMS AS
SELECT r.ROL_NAME, p.PER_NAME AS 'PERMISSION NAME', p.PER_DESCRIPTION AS 'PERMISSION DESCRIPTION'
FROM ROLES r JOIN ROLES_PERMISSIONS rp ON r.ID = rp.ROL_ID
    JOIN PERMISSIONS p ON p.ID = rp.PER_ID

CREATE VIEW V_ROLES_PERMS_JOINED AS
SELECT r.ROL_NAME, STRING_AGG(p.PER_NAME, ', ') AS 'ROLES PERMISSIONS'
FROM ROLES r JOIN ROLES_PERMISSIONS rp ON r.ID = rp.ROL_ID
    JOIN PERMISSIONS p ON p.ID = rp.PER_ID
GROUP BY r.ROL_NAME

