USE [POI]
GO

-- Brand Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'Brand')
BEGIN

	CREATE TABLE [dbo].[Brand] (
		[BrandID]		NVARCHAR(255) NOT NULL
		, [BrandName]   NVARCHAR(255) NOT NULL
		, CONSTRAINT [PK_Brand] PRIMARY KEY CLUSTERED 
		  (
			[BrandID] ASC
		  )
	    , CONSTRAINT [UQ_Brand_BrandName] UNIQUE ([BrandName]));
END

-- Top Category Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'TopCategory')
BEGIN

	CREATE TABLE [dbo].[TopCategory] (
		[TopCategoryID]		INT	IDENTITY(1,1) NOT NULL 
		, [TopCategoryName] NVARCHAR(255)     NOT NULL
		, CONSTRAINT [PK_Top_Category] PRIMARY KEY CLUSTERED 
		  (
			[TopCategoryName] ASC
		  ));
END

-- Subcategory Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'SubCategory')
BEGIN

	CREATE TABLE [dbo].[SubCategory] (
		[SubcategoryID]     INT IDENTITY(1,1) NOT NULL 
		, [SubCategoryName] NVARCHAR(255)    NOT NULL
		, CONSTRAINT [PK_Subcategory] PRIMARY KEY CLUSTERED 
		  (
			[SubCategoryName] ASC
		  ));

END

-- Category Tags Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'CategoryTags')
BEGIN

	CREATE TABLE [dbo].[CategoryTags] (
		[CategoryTagID]	INT	IDENTITY(1,1) NOT NULL 
		, [TagName]  	NVARCHAR(255)     NOT NULL
		, CONSTRAINT [PK_Category_Tags] PRIMARY KEY CLUSTERED 
		  (
			[TagName] ASC
		  ));

END

-- Country Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'Country')
BEGIN

	CREATE TABLE [dbo].[Country] (
	    [CountryID]	    INT IDENTITY(1,1) NOT NULL
	    , [CountryCode] NVARCHAR(3)       NOT NULL
		, CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
		  (
			[CountryCode] ASC
		  ));

END 

-- Region Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'Region')
BEGIN

	CREATE TABLE [dbo].[Region] (
	    [RegionID]      INT IDENTITY(1,1) NOT NULL
	    , [RegionName]  NVARCHAR(255)	  NOT NULL
	    , CONSTRAINT [PK_Region] PRIMARY KEY CLUSTERED 
	      (
	   		 [RegionName] ASC
	      ));

END

-- City Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'City')
BEGIN

	CREATE TABLE [dbo].[City] (
	    [CityID]     INT IDENTITY(1,1)  NOT NULL
	    , [CityName] NVARCHAR(255)	    NOT NULL
	    , CONSTRAINT [PK_City] PRIMARY KEY CLUSTERED 
	      (
	   		 [CityName] ASC
	      ));

END 

-- Location Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'Location')
BEGIN

	CREATE TABLE [dbo].[Location] (
	    [LocationID]	 INT IDENTITY(1,1) NOT NULL
		, [CountryCode]	 NVARCHAR(3)   NOT NULL 
		, [RegionName]	 NVARCHAR(255) NOT NULL
	    , [CityName]	 NVARCHAR(255) NOT NULL
	    , CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
	      (
	   		 [LocationID] ASC
	      ));

-- Creating foreign key on Location table to Region
	ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Region_RegionName] FOREIGN KEY([RegionName])
	REFERENCES [dbo].[Region] ([RegionName])
	
	ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Region_RegionName]

-- Creating foreign key on Location table to Country
	ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Country_CountryCode] FOREIGN KEY([CountryCode])
	REFERENCES [dbo].[Country] ([CountryCode])
	
	ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Country_CountryCode]

-- Creating foreign key on Location table to City
	ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_City_CityName] FOREIGN KEY([CityName])
	REFERENCES [dbo].[City] ([CityName])
	
	ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_City_CityName]

-- Creating index on [dbo].[Location]
	DROP INDEX IF EXISTS [IX_Location_Code_Reg_City] ON [dbo].[Location]

	CREATE NONCLUSTERED INDEX [IX_Location_Code_Reg_City] ON [dbo].[Location]
	(
		[CountryCode] ASC
		, [RegionName] ASC
		, [CityName] ASC
	)
	INCLUDE([LocationID])

END

-- POI Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'POI')
BEGIN

	CREATE TABLE [dbo].[POI] (
	    [POI_ID]		    NVARCHAR(255)     NOT NULL
	    , [ParentID]        NVARCHAR(255)	  NULL
		, [LocationID]		INT				  NOT NULL
		, [LocationName]    NVARCHAR(255)     NOT NULL
	    , [Latitude]	    FLOAT			  NOT NULL
	    , [Longitude]	    FLOAT			  NOT NULL
		, [PostalCode]	    NVARCHAR(10)	  NOT NULL
		, [Operation_Hours] NVARCHAR(MAX)	  NULL
		, [LocationGeog]	GEOGRAPHY		  NOT NULL
	    , CONSTRAINT [PK_POI] PRIMARY KEY CLUSTERED 
	      (
	   		 [POI_ID] ASC
	      ));

-- Creating foreign key on POICategory table to TopCategory
	ALTER TABLE [dbo].[POI]  WITH CHECK ADD  CONSTRAINT [FK_POI_Location_LocationID] FOREIGN KEY([LocationID])
	REFERENCES [dbo].[Location] ([LocationID])
	
	ALTER TABLE [dbo].[POI] CHECK CONSTRAINT [FK_POI_Location_LocationID]

-- Creating index on [dbo].[POI]
	DROP INDEX IF EXISTS [IX_POI_LocGeog] ON [dbo].[POI]

	CREATE NONCLUSTERED INDEX [IX_POI_LocGeog] ON [dbo].[POI] 
	(
		[LocationID]
	)
	INCLUDE ([ParentID],[LocationName],[Latitude],[Longitude],[PostalCode],[Operation_Hours],[LocationGeog])

-- Creating spartial index 
	DROP INDEX IF EXISTS [SIDX_POI_Location] ON [dbo].[POI]

	CREATE SPATIAL INDEX [SIDX_POI_Location] ON [dbo].[POI]([LocationGeog]);

END

-- LocationPolygon Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'LocationPolygon')
BEGIN

	CREATE TABLE [dbo].[LocationPolygon] (
	    [LocationPolygonID]	 INT IDENTITY(1,1) NOT NULL
		, [LocationID]		 INT			   NOT NULL 
		, [WKTPolygonString] NVARCHAR(MAX)     NULL
		, [WKTPolygonGeog]   GEOGRAPHY	       NULL
		, [POI_ID]			 NVARCHAR(255)	   NOT NULL
	    , CONSTRAINT [PK_LocationPolygon] PRIMARY KEY CLUSTERED 
	      (
	   		 [LocationPolygonID] ASC
	      ));

-- Creating foreign key on LocationPolygon table to Location
	ALTER TABLE [dbo].[LocationPolygon]  WITH CHECK ADD  CONSTRAINT [FK_LocationPolygon_Location_LocationID] FOREIGN KEY([LocationID])
	REFERENCES [dbo].[Location] ([LocationID])
	
	ALTER TABLE [dbo].[LocationPolygon] CHECK CONSTRAINT [FK_LocationPolygon_Location_LocationID]

-- Creating foreign key on LocationPolygon table to Location
	ALTER TABLE [dbo].[LocationPolygon]  WITH CHECK ADD  CONSTRAINT [FK_LocationPolygon_POI_POI_ID] FOREIGN KEY([POI_ID])
	REFERENCES [dbo].[POI] ([POI_ID])
	
	ALTER TABLE [dbo].[LocationPolygon] CHECK CONSTRAINT [FK_LocationPolygon_POI_POI_ID]

-- Creating index on [dbo].[LocationPolygon]
	DROP INDEX IF EXISTS [IX_LocationPolygon_LocationID] ON [dbo].[LocationPolygon]

	CREATE NONCLUSTERED INDEX [IX_LocationPolygon_LocationID] ON [dbo].[LocationPolygon]
	( 
		[LocationID]
		, [POI_ID]
	)
	INCLUDE ([WKTPolygonString])

-- Creating spartial index 	
	DROP INDEX IF EXISTS [SIDX_Location_Polygon_WKTPolygonGeog] ON [dbo].[LocationPolygon]

	CREATE SPATIAL INDEX [SIDX_Location_Polygon_WKTPolygonGeog] ON [dbo].[LocationPolygon]([WKTPolygonGeog]);

END

-- Category Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'Category')
BEGIN

	CREATE TABLE [dbo].[Category] (
	    [CategoryID] INT IDENTITY(1,1)    NOT NULL
	    , [TopCategoryName] NVARCHAR(255) NULL
		, [SubCategoryName] NVARCHAR(255) NULL
		, [CategoryTagName]	NVARCHAR(255) NULL
	    , CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
	      (
	   		 [CategoryID] ASC
	      ));

-- Creating foreign key on POICategory table to TopCategory
	ALTER TABLE [dbo].[Category]  WITH CHECK ADD  CONSTRAINT [FK_Category_TopCategory_TopCategoryName] FOREIGN KEY([TopCategoryName])
	REFERENCES [dbo].[TopCategory] ([TopCategoryName])
	
	ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [FK_Category_TopCategory_TopCategoryName]

-- Creating foreign key on POICategory table
	ALTER TABLE [dbo].[Category]  WITH CHECK ADD  CONSTRAINT [FK_Category_SubCategory_SubCategoryName] FOREIGN KEY([SubCategoryName])
	REFERENCES [dbo].[SubCategory] ([SubCategoryName])

	ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [FK_Category_SubCategory_SubCategoryName]

-- Creating foreign key on Subcategory_CategoryTag table
	ALTER TABLE [dbo].[Category]  WITH CHECK ADD  CONSTRAINT [FK_Category_CategoryTags_TagName] FOREIGN KEY([CategoryTagName])
	REFERENCES [dbo].[CategoryTags] ([TagName])

	ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [FK_Category_CategoryTags_TagName]

-- Creating index on [dbo].[Category]
	DROP INDEX IF EXISTS [IX_Category_Top_Sub_CategoryTags] ON [dbo].[Category]

	CREATE NONCLUSTERED INDEX [IX_Category_Top_Sub_CategoryTags] ON [dbo].[Category]
	(
		[TopCategoryName]   ASC
		, [SubCategoryName] ASC
		, [CategoryTagName] ASC 
	)
	INCLUDE([CategoryID])

END

-- POICategory Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'POICategory')
BEGIN

	CREATE TABLE [dbo].[POICategory] (
	    [POI_ID]			NVARCHAR(255) NOT NULL
	    , [CategoryID]      INT			  NOT NULL
	    , CONSTRAINT [PK_POICategory] PRIMARY KEY CLUSTERED 
	      (
	   		 [POI_ID]	         ASC
			 , [CategoryID] ASC
	      ));

-- Creating foreign key on POICategory table to POI
	ALTER TABLE [dbo].[POICategory]  WITH CHECK ADD  CONSTRAINT [FK_POICategory_POI_POI_ID] FOREIGN KEY([POI_ID])
	REFERENCES [dbo].[POI] ([POI_ID])
	
	ALTER TABLE [dbo].[POICategory] CHECK CONSTRAINT [FK_POICategory_POI_POI_ID]

-- Creating foreign key on POICategory table to TopCategory
	ALTER TABLE [dbo].[POICategory]  WITH CHECK ADD  CONSTRAINT [FK_POICategory_Category_CategoryID] FOREIGN KEY([CategoryID])
	REFERENCES [dbo].[Category] ([CategoryID])
	
	ALTER TABLE [dbo].[POICategory] CHECK CONSTRAINT [FK_POICategory_Category_CategoryID]

	DROP INDEX IF EXISTS [IX_POICategory_CategoryID] ON [dbo].[POICategory] 

	CREATE NONCLUSTERED INDEX [IX_POICategory_CategoryID] ON [dbo].[POICategory] 
	(
		[CategoryID]
	)

END

-- Brand_TopCategory Table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = 'dbo' 
           AND TABLE_NAME = 'BrandCategory')
BEGIN

	CREATE TABLE [dbo].[BrandCategory] (
	    [BrandID]		NVARCHAR(255)
	    , [CategoryID]  INT
		, CONSTRAINT [PK_Brand_Category] PRIMARY KEY CLUSTERED 
		  (
			[BrandID] ASC
			, [CategoryID] ASC
		  ));

-- Creating foreign key on Brand_TopCategory table to Brand 
	ALTER TABLE [dbo].[BrandCategory]  WITH CHECK ADD  CONSTRAINT [FK_BrandCategory_Brand_BrandID] FOREIGN KEY([BrandID])
	REFERENCES [dbo].[Brand] ([BrandID])
	
	ALTER TABLE [dbo].[BrandCategory] CHECK CONSTRAINT [FK_BrandCategory_Brand_BrandID]

-- Creating foreign key on Brand_TopCategory to TopCategory table
	ALTER TABLE [dbo].[BrandCategory]  WITH CHECK ADD  CONSTRAINT [FK_BrandCategory_Category_CategoryID] FOREIGN KEY([CategoryID])
	REFERENCES [dbo].[Category] ([CategoryID])
	
	ALTER TABLE [dbo].[BrandCategory] CHECK CONSTRAINT [FK_BrandCategory_Category_CategoryID]

END 


