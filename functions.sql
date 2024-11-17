--Una funcion que se puede usar en toda la DB
CREATE FUNCTION GenNewNumberAch(@ID_GAME INT)
RETURNS INT
AS
BEGIN
    --Si el valor es null devuelve 0 y se le suma 1 (osea 1), sino, suma el maximo valor que encontro en la columna NUMBER y le suma 1
    RETURN (SELECT ISNULL(MAX(NUMBER), 0)+1 FROM ACHIEVEMENTS WHERE ID_GAME = @ID_GAME)
end

--Elimina todos los espacios en blanco a la izquierda y derecha de un texto
CREATE FUNCTION TRIM(@text VARCHAR(MAX))
RETURNS VARCHAR
AS
BEGIN
    RETURN LTRIM(RTRIM(@text))
end