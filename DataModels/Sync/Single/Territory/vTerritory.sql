/*

	This sample script builds the necessary database objects for the form_surveyGetObjects_Territory job to function. 

	Assumption: 

		- a database connection (called sql in DataZen) points to the database where this script will be executed. 
		- the DimTerritory table below is the source for the territory data and represents the System or Record (SoR) 
			This can be a view to another database, or a replicated table from another source system that was created by DataZen (ex: an HTTP API endpoint)
	
*/


CREATE VIEW vTerritory AS
SELECT 
		-- properties that are specific to this data model
		Territory  as [Territory],
					
		-- properties that are always provided for all data models -- MUST BE EXACTLY LIKE THIS
		'Territory'		        as [_model_keyname_],   -- the key field name of the data model (the field in Form.com used as the Key field)
		12345678		        as [_modelid_],         -- the data model id (the Data Model ID for this list)
		[Territory]				as [_keyid_]            -- the generic unique identifier to use (the ID from the source that maps to the Key field)
		-- SELECT * 			
FROM DimTerritory (NOLOCK)   -- filtering can be used here to exclude records
GO

/* Wrapper view that returns the source data as a JSON document */
CREATE VIEW vTerritoryJSON AS
SELECT	
	CAST([_keyid_] as NVARCHAR(255)) [_keyid_], 
	[_modelid_], 
	[_model_keyname_],
	(SELECT * FROM vTerritory B WHERE B.[_keyid_] = A.[_keyid_] FOR JSON Path,Without_Array_Wrapper) jsonData
FROM	vTerritory A
