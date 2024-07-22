/*

	This script creates the necessary objects that are used by the UPSERT_DataModelObjects and 
	DELETE_DataModelObjects jobs.  These sample views point to the AdventureWorksDW2017 database
	as an example; when implementing this for production environments, it is recommended to create additional
	replication jobs that copy source data from the ERP system into a staging database first.

	For purposes of this example script, the AdventureWorksDW2017 is considered a staging database that contains
	the source tables that need to be replicated.
	
	CRITICAL: The underlying views must return the names of fields as expected by the Form.com data models - case-sensitive - 
	and modify the data to avoid XML or JSON special characters (ex: @$%&<>{}/\).

	vModelDimCurrency		the currency table to replicate into a Form Data Model
	vModelDimGeography		the geography table to replicate into a Form Data Model
	
	vModelDimCurrencyJSON	the wrapper view for the underlying vModelDimCurrency data
	vModelDimGeographyJSON	the wrapper view for the underlying vModelDimGeography data

	vAllModelJSON			the main view providing the list of all source data sets to replicate in Form.com

*/

--
--
--		THIS SECTION CREATES THE UNDERLYING VIEWS FOR ALL INDIVIDUAL SOURCE TABLES THAT WE WANT TO REPLICATE 
--		This layer is responsible for mapping all source fields to the target Data Model property names
--		This layer is also responsible for formatting the data appropriately so the values can be passed as JSON and XML documents
--
--

/* Undelying view that returns the source data with the expected Form.com data model field names to map to */
CREATE VIEW vModelDimCurrency AS
SELECT 
		-- properties that are specific to this data model
		CurrencyAlternateKey	as [Currency],       -- the Form.com Data Model property should be named Currency
		CurrencyName			    as [Currency Name],  -- the Form.com Data Model property should be named Currency Name
					
		-- properties that are always provided for all data models -- MUST BE EXACTLY LIKE THIS
		'Currency'		        as [_model_keyname_],   -- the key field name of the data model (the field in Form.com used as the Key field)
		81611753		          as [_modelid_],         -- the data model id (the Data Model ID for this list)
		CurrencyAlternateKey	as [_keyid_]            -- the generic unique identifier to use (the ID from the source that maps to the Key field)
					
FROM AdventureWorksDW2017..DimCurrency (NOLOCK)   -- filtering can be used here to exclude records
GO


/* Undelying view that returns the source data with the expected Form.com data model field names to map to */
ALTER VIEW vModelDimGeography AS
SELECT 
     -- properties that are unique to this data model
     geographyKey		    as [id], 
     City			          as [City], 
     StateProvinceCode	as [State],
     StateProvinceName	as [State Name],
     PostalCode		      as [Postal Code],

     -- properties that are always provided for all data models
     'id'		      as [_model_keyname_],   -- the key field name of the data model
     81611629		  as [_modelid_],         -- the data model id
     geographyKey	as [_keyid_]            -- the generic unique identifier to use

FROM AdventureWorksDW2017..DimGeography 
WHERE	CountryRegionCode = 'US' 
		AND StateProvinceCode IN ('AL', 'AZ')	-- filter added during testing to avoid sending all records 	

GO

--
--
--		THIS SECTION CREATES THE WRAPPER VIEWS FOR ALL UNDERLYING VIEWS THAT WE WANT TO REPLICATE 
--		This layer is responsible for returning all source records with in a predictable format as JSON documents
--
--

/* Wrapper view that returns the source data as a JSON document */
CREATE VIEW vModelDimCurrencyJSON AS
SELECT	
	CAST([_keyid_] as NVARCHAR(255)) [_keyid_], 
	[_modelid_], 
	[_model_keyname_],
	(SELECT * FROM vModelDimCurrency B WHERE B.[_keyid_] = A.[_keyid_] FOR JSON Path,Without_Array_Wrapper) jsonData
FROM	vModelDimCurrency A

GO

/* Wrapper view that returns the source data as a JSON document */
ALTER VIEW vModelDimGeographyJSON AS
SELECT	CAST([_keyid_] as NVARCHAR(255)) [_keyid_], 
		[_modelid_], 
		[_model_keyname_],
		(SELECT * FROM vModelDimGeography B WHERE B.[_keyid_] = A.[_keyid_] FOR JSON Path,Without_Array_Wrapper) jsonData
FROM	vModelDimGeography A

--
--
--		THIS SECTION CREATES THE MAIN VIEW THAT RETURNS ALL SOURCE RECORDS TO BE REPLICATED 
--
--

/* The wrapper view that returns all source records in their JSON representation */
ALTER VIEW vAllModelJSON AS
SELECT * FROM [demo]..vModelDimGeographyJSON 
UNION SELECT * FROM [demo]..vModelDimCurrencyJSON
