USE [POI]
GO

DROP FUNCTION IF EXISTS [dbo].[RemoveSpecialCharacters_F]
GO

CREATE FUNCTION [dbo].[RemoveSpecialCharacters_F] (
	@input NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @pos INT = 1;
    DECLARE @cleanString NVARCHAR(MAX) = '';

    WHILE @pos <= LEN(@input)
    BEGIN
        DECLARE @char NCHAR(1) = SUBSTRING(@input, @pos, 1);

        -- ASCII Range: 32 (space) to 126 (~), extend if needed
        IF UNICODE(@char) BETWEEN 32 AND 126
        BEGIN
            SET @cleanString = @cleanString + @char;
        END

        SET @pos = @pos + 1;
    END

	WHILE PATINDEX('%[^a-zA-Z0-9]%', @cleanString) > 0
    BEGIN
        SET @cleanString = STUFF(@cleanString, PATINDEX('%[^a-zA-Z0-9]%', @input), 1, '');
    END

    RETURN @cleanString;
END;
GO