USE [POI]
GO

--Drop table [dbo].[Stg_POI]
DROP TABLE IF EXISTS [dbo].[Stg_POI]
GO

--Creating table [dbo].[Stg_POI]
CREATE TABLE [dbo].[Stg_POI] (
	[id]					NVARCHAR(255)  NULL
	, [parent_id]			NVARCHAR(255)  NULL
	, [brand]				NVARCHAR(255)  NULL
	, [brand_id]			NVARCHAR(255)  NULL
	, [top_category]		NVARCHAR(255)  NULL
	, [sub_category]		NVARCHAR(255)  NULL
	, [category_tags]		NVARCHAR(255)  NULL
	, [postal_code]			NVARCHAR(255)  NULL
	, [location_name]		NVARCHAR(255)  NULL
	, [latitude]			FLOAT          NULL
	, [longitude]			FLOAT          NULL
	, [country_code]		NVARCHAR(255)  NULL
	, [city]				NVARCHAR(255)  NULL
	, [region]				NVARCHAR(255)  NULL
	, [operation_hours]		NVARCHAR(1000) NULL
	, [geometry_type]		NVARCHAR(255)  NULL
	, [polygon_wkt]			NVARCHAR(MAX)  NULL
	);

-- Insert data into [dbo].[Stg_POI]
BULK INSERT [dbo].[Stg_POI]
FROM 'C:\Users\Lenovo T480\Desktop\phoenix.csv'
WITH
(
   FORMAT	= 'CSV',
   FIRSTROW	= 2
)
