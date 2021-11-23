/*
	TronoTools 3dsMax Project Functions v1.1
	
	created:			2016/3/12
	last modified:		2016/3/19
	
	changelog
		v1.1	- Added set max default paths to run automatically in SetMaxPaths() to make sure default local dirs are set

	dependencies:
	th_xml.ms




*/

fn MaxArray =
(
	maxPathArray = #(
		#animations,
		#archives,
		#autoback,
		#proxies,
		#downloads,
		#export,
		#expression,
		#image,
		#import,
		#matlib,
		#maxstart,
		#photometric,
		#preview,
		#renderassets,
		#renderoutput,
		#renderpresets,
		#scene,
		#sound,
		#vpost
	)
	
	maxPathArray -- return array
)

fn SetupMaxDefaults = 
(
	-- Get User environment
	-- Creare Environment class (cannot create an object of this class)
	-- This class does not have a constructor (it's a static class)
	Env = dotNetClass "System.Environment"
	-- Get "%USERNAME%" Environment Variable
	UserName = Env.GetEnvironmentVariable "UserName"
	defaultUserFolder = @"C:\Users\" + UserName + @"\Documents\3dsMax\"

	-- Setup default project
	pathConfig.setCurrentProjectFolder defaultUserFolder
	
	prjPathArray = MaxArray()
	
	resultString = ""
	for item in prjPathArray do
	(
		doesExist = ttReturnCustom (toLower (item as string))
		if doesExist == undefined then
		(
			SetDir item (pathConfig.convertPathToAbsolute item)
			resultString += "Not in Config "+ (toLower (item as string)) + ". Path set to absolute.\n"
		)
	)
	
	print resultString
)


fn SetMaxPaths ProjectDir = 
(
	SetupMaxDefaults()
	
	pathConfig.setCurrentProjectFolder ProjectDir

	pathsToReadFromConfig = MaxArray()

	for item in pathsToReadFromConfig do
	(
		ttPath = ttReturnCustom (toLower (item as string))
		if ttPath == undefined then (print ( (toLower (item as string)) + " not found in xml custom settings"))
		else	
		(
			SetDir item (ProjectDir + @"\" + ttPath)
			print (toLower (item as string)) + ": " + (getdir item)
		)
	)
)

