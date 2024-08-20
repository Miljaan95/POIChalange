USE [POI]
GO

DROP PROCEDURE IF EXISTS [dbo].[FindPOIs_P]
GO

--Creating Stored Proc for Find PIOs
CREATE PROCEDURE [dbo].[FindPOIs_P]  
	@SearchCriteria NVARCHAR(MAX)
AS
BEGIN

	DECLARE @CurrentLocation GEOGRAPHY;

	-- Default radius in meters
	DECLARE @DefaultRadius INT = 200;

	-- Assume these are the current location coordinates (latitude, longitude)
    SET @CurrentLocation = GEOGRAPHY::Point(33.4484, -112.0740, 4326);

	IF (ISNULL(@SearchCriteria, '') = '')
	BEGIN

		SELECT p.[POI_ID]
			, ISNULL(p.[ParentID], '')			AS [Parent ID]
			, [locations].[CountryCode]			AS [Country Code]
			, [locations].[RegionName]			AS [Region Code]
			, [locations].[CityName]			AS [City Name]
			, p.[Latitude]
			, p.[Longitude]
			, categories.[TopCategoryName]			 AS [Category]
			, ISNULL(categories.[SubCategoryName], '') AS [Sub Category]
			, ISNULL(lp.[WKTPolygonString], '')      AS [WKT Polygon] 
			, p.[LocationName]					     AS [Location Name]
			, p.[PostalCode]					     AS [Postal Code]
			, p.[Operation_Hours]				     AS [Operation Hours]
		FROM [dbo].[POI] p
		INNER JOIN [dbo].[Location] AS [locations]
			ON p.[LocationID] = [locations].[LocationID]
		INNER JOIN [dbo].[LocationPolygon] lp
			ON	p.[POI_ID] = lp.[POI_ID]
				AND [locations].[LocationID] = lp.[LocationID]
		INNER JOIN [dbo].[POICategory] pic
			ON pic.[POI_ID] = p.[POI_ID]
		INNER JOIN [dbo].[Category] categories
			ON pic.[CategoryID] = categories.[CategoryID]
		WHERE p.[LocationGeog].STDistance(@CurrentLocation) <= @DefaultRadius
		FOR JSON AUTO, INCLUDE_NULL_VALUES;

	END

	-- Center point
	DECLARE @CenterPoint GEOGRAPHY = GEOGRAPHY::STGeomFromText('POINT(-111.983962 33.442121)', 4326);
	
	-- Custom Radius
	DECLARE @Radius FLOAT = JSON_VALUE(@SearchCriteria, '$.radius'); 

	-- Check point validity
	BEGIN TRY
		-- Geography parameter
		DECLARE @SearchPoint GEOGRAPHY = GEOGRAPHY::STGeomFromText(JSON_VALUE(@SearchCriteria, '$.point'), 4326);
	
	    -- Check validity
	    IF @SearchPoint.STIsValid() = 1
	    BEGIN
	        PRINT 'The point is valid.';
	    END
	    ELSE
	    BEGIN
	        PRINT 'The point is invalid.';
	    END
	END TRY
	BEGIN CATCH
	    PRINT 'Error: ' + ERROR_MESSAGE();
	END CATCH;

    -- Declare the geography variable using the WKT polygon
    DECLARE @Polygon GEOGRAPHY;

    -- Try to create the geography object from the WKT string
    BEGIN TRY

        SET @Polygon = GEOGRAPHY::STGeomFromText(JSON_VALUE(@SearchCriteria, '$.polygon'), 4326);

        -- Validate the polygon
        IF @Polygon.STIsValid() = 1
        BEGIN
            PRINT 'The polygon is valid.';
        END
        ELSE	
        BEGIN
            PRINT 'The polygon is invalid.';
        END
    END TRY
    BEGIN CATCH
        PRINT N'Error: ' + ERROR_MESSAGE();
    END CATCH;


	SELECT p.[POI_ID]
		, ISNULL(p.[ParentID], '')			       AS [Parent ID]
		, [locations].[CountryCode]			       AS [Country Code]
		, [locations].[RegionName]			       AS [Region Code]
		, [locations].[CityName]			       AS [City Name]
		, p.[Latitude]							   
		, p.[Longitude]							   
		, categories.[TopCategoryName]			   AS [Category]
		, ISNULL(categories.[SubCategoryName], '') AS [Sub Category]
		, ISNULL(lp.[WKTPolygonString], '')        AS [WKT Polygon] 
		, p.[LocationName]					       AS [Location Name]
		, p.[PostalCode]					       AS [Postal Code]
		, p.[Operation_Hours]				       AS [Operation Hours]
	FROM [dbo].[POI] p
	INNER JOIN [dbo].[Location] AS [locations]
		ON p.[LocationID] = [locations].[LocationID]
	INNER JOIN [dbo].[LocationPolygon] lp
		ON	p.[POI_ID] = lp.[POI_ID]
			AND [locations].[LocationID] = lp.[LocationID]
	INNER JOIN [dbo].[POICategory] pic
		ON pic.[POI_ID] = p.[POI_ID]
	INNER JOIN [dbo].[Category] categories
		ON pic.[CategoryID] = categories.[CategoryID]
	WHERE (
			JSON_VALUE(@SearchCriteria, '$.country') IS NULL
		  	OR [locations].[CountryCode] = JSON_VALUE(@SearchCriteria, '$.country')
		  )
		  AND (
			JSON_VALUE(@SearchCriteria, '$.region') IS NULL
		  	OR [locations].[RegionName] = JSON_VALUE(@SearchCriteria, '$.region')
		  )
		  AND (
			JSON_VALUE(@SearchCriteria, '$.city') IS NULL
		  	OR [locations].[CityName] = JSON_VALUE(@SearchCriteria, '$.city')
		  )
		  AND (
			JSON_VALUE(@SearchCriteria, '$.name') IS NULL
		  	OR p.[LocationName] = JSON_VALUE(@SearchCriteria, '$.name')
		  )
		  AND (
			JSON_VALUE(@SearchCriteria, '$.category') IS NULL
		  	OR [categories].[TopCategoryName] = JSON_VALUE(@SearchCriteria, '$.category')
		  	OR [categories].[SubCategoryName] = JSON_VALUE(@SearchCriteria, '$.category')
		  )
		  AND (
			@SearchPoint.STIsValid() = 0
		  	OR p.[LocationGeog].STDistance(@CenterPoint) <= @Radius
		  )
		  AND (
			@Polygon.STIsValid() = 0
		  	OR lp.[WKTPolygonGeog].STIntersects(@Polygon) = 1
		  )
	 FOR JSON AUTO, INCLUDE_NULL_VALUES;

END;
