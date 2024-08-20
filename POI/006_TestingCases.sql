USE [POI]
GO

-- Without any search parameter 
EXEC [dbo].[FindPOIs_P] ''

-- With added Country AND/OR RegionName AND/OR CityName 
EXEC [dbo].[FindPOIs_P] N'{
							"Country Code": "US",
							"Region Code": "AZ",
							"City Name": "Phoenix"}'

-- With added PIOCategory AND/OR POIName (category: TopCategory and SubCategory are covered)
EXEC [dbo].[FindPOIs_P] N'{
							"name": "SterlingSolutions",
							"category": "Machinery, Equipment, and Supplies Merchant Wholesalers"}'

-- With added Point AND/OR radius
EXEC [dbo].[FindPOIs_P] N'{
							"point": "POINT(-110.983962 45.442121)",
							"radius": "500"}'

-- With added polygon
--EXEC [dbo].[FindPOIs_P] N'{"polygon": "POLYGON((-111.983962 33.442121, -111.983000 33.443000, -111.984000 33.444000, -111.983962 33.442121))"}'

DECLARE @Polygon GEOGRAPHY;	
SET @Polygon = GEOGRAPHY::STGeomFromText('POLYGON((-111.983962 33.442121, -111.983000 33.443000, -111.984000 33.444000, -111.983962 33.442121))', 4326);

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
WHERE 	lp.[WKTPolygonGeog].STIntersects(@Polygon) = 1

	