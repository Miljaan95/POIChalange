USE [POI]
GO

-- Populating Brand Table
PRINT N'Inserting rows in the Brand table...'

INSERT INTO [dbo].[Brand](
	[BrandID]	
	, [BrandName]	
)
SELECT DISTINCT 
		[brand_id]	
		, [brand]
FROM [dbo].[Stg_POI]
WHERE ISNULL([brand_id], '') <> ''
GO

-- Populating Contry table
PRINT N'Inserting rows in the Country table...'

INSERT INTO [dbo].[Country](
	[CountryCode]
)
SELECT DISTINCT [country_code]
FROM [dbo].[Stg_POI]
WHERE ISNULL([country_code], '') <> ''
GO

-- Populating Region table
PRINT N'Inserting rows in the Region table...'

INSERT INTO [dbo].[Region](
	[RegionName]
)
SELECT DISTINCT sp.[region]
FROM [dbo].[Stg_POI] AS sp
WHERE ISNULL(sp.[region], '') <> ''
GO

-- Populating City table
PRINT N'Inserting rows in the City table...'

INSERT INTO [dbo].[City](
	[CityName]
)
SELECT DISTINCT sp.[city]
FROM [dbo].[Stg_POI] AS sp
WHERE ISNULL(sp.[city], '') <> ''
GO

-- Populating Location table
PRINT N'Inserting rows in the Location table...'

INSERT INTO [dbo].[Location](
	[CountryCode]
	, [RegionName]
	, [CityName]
)
SELECT DISTINCT 
	   sp.[country_code]
	   , sp.[region]
	   , sp.[city]
FROM [dbo].[Stg_POI] AS sp 

GO

-- Populating POI table
PRINT N'Inserting rows in the POI table...'

INSERT INTO [dbo].[POI](
	[POI_ID]
	, [ParentID]
	, [LocationID]
	, [LocationName]
	, [Latitude]
	, [Longitude]
	, [PostalCode]
	, [Operation_Hours]
	, [LocationGeog]
)
SELECT [id]
	   , [parent_id]
	   , [LocationID]
	   , [dbo].[RemoveSpecialCharacters_F](sp.[location_name]) AS [LocationName]
	   , [latitude]
	   , [longitude]
	   , [postal_code]
	   , [operation_hours]
	   , GEOGRAPHY::Point([latitude], [longitude], 4326) AS [LocationGeog]
FROM [dbo].[Stg_POI] AS sp
INNER JOIN [dbo].[Location] l 
	ON sp.[country_code] = l.[CountryCode]
	   AND sp.[region] = l.[RegionName]
	   AND sp.[city] = l.[CityName]
GO

-- Populating LocationPolygon table
PRINT N'Inserting rows in the LocationPolygon table...'

INSERT INTO [dbo].[LocationPolygon](
	[LocationID]
	, [WKTPolygonString]
	, [WKTPolygonGeog]
	, [POI_ID]
)
SELECT temp.[LocationID]
	   , temp.[polygon_wkt]				       AS [WKTPolygonString] 
	   , CAST(temp.[polygon_wkt] AS GEOGRAPHY) AS [WKTPolygonGeog]
	   , [POI_ID]
FROM(
	SELECT DISTINCT p.[LocationID]
					, sp.[polygon_wkt] AS [polygon_wkt]
					, p.[POI_ID]
	FROM [dbo].[Stg_POI] AS sp 
	INNER JOIN [dbo].[POI] p
		ON sp.[id] = p.[POI_ID]
) AS temp
GO

-- Populating TopCategory table
PRINT N'Inserting rows in the TopCategory table...'

INSERT INTO [dbo].[TopCategory](
	[TopCategoryName]
)
SELECT DISTINCT sp.[top_category]
FROM [dbo].[Stg_POI] AS sp
WHERE ISNULL(sp.[top_category], '') <> ''
GO

-- Populating SubCategory table
PRINT N'Inserting rows in the SubCategory table...'

INSERT INTO [dbo].[SubCategory](
	[SubCategoryName]
)
SELECT DISTINCT sp.[sub_category]
FROM [dbo].[Stg_POI] AS sp
WHERE ISNULL(sp.[sub_category], '') <> ''
GO

-- Populating CategoryTags table
PRINT N'Inserting rows in the CategoryTags table...'

INSERT INTO [dbo].[CategoryTags](
	[TagName]
)
SELECT DISTINCT sp.[category_tags]
FROM [dbo].[Stg_POI] AS sp
WHERE ISNULL(sp.[category_tags], '') <> ''
GO

-- Populating POI table
PRINT N'Inserting rows in the Category table...'

INSERT INTO [dbo].[Category](
	[TopCategoryName]
	, [SubCategoryName]
	, [CategoryTagName]
)
SELECT DISTINCT 
		sp.[top_category]
		, sp.[sub_category]
		, sp.[category_tags]
FROM [dbo].[Stg_POI] AS sp

GO

-- Populating POICategory table
PRINT N'Inserting rows in the POICategory table...'

INSERT INTO [dbo].[POICategory](
	[POI_ID]
	, [CategoryID]
)
SELECT DISTINCT sp.[id]
	  , cc.[CategoryID]
FROM [dbo].[Stg_POI] AS sp
INNER JOIN [dbo].[Category] cc
	ON ISNULL(sp.[top_category], '') = ISNULL(cc.[TopCategoryName], '')
	   AND ISNULL(sp.[sub_category], '') = ISNULL(cc.[SubCategoryName], '') 
	   AND ISNULL(sp.[category_tags], '')  = ISNULL(cc.[CategoryTagName], '') 
GO

-- Populating Brand_TopCategory table
PRINT N'Inserting rows in the BrandCategory table...'

INSERT INTO [dbo].[BrandCategory](
	[BrandID]
	, [CategoryID]
)	
SELECT DISTINCT sp.[brand_id]
			   , cc.[CategoryID]
FROM [dbo].[Stg_POI] AS sp
INNER JOIN [dbo].[Category] cc
	ON ISNULL(sp.[top_category], '') = ISNULL(cc.[TopCategoryName], '')
	   AND ISNULL(sp.[sub_category], '') = ISNULL(cc.[SubCategoryName], '') 
	   AND ISNULL(sp.[category_tags], '')  = ISNULL(cc.[CategoryTagName], '') 
WHERE ISNULL(sp.[brand_id], '') <> ''
GO