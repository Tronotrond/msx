/*
	Configuration library for TronoTools Project Management v1.22
	last changed: 2016/03/22
	
	changelog:
		v1.11:
			- Added deadline repository
		v1.12
			- Added Simulation directory
		v1.2
			- Added support for Custom Keys 
			- Added 3dsMax #paths as default custom keys
			- Added IsInitialized() Function/Query
		v1.21
			- Fixed a variable bug in loading the asset path
		v1.22
			- Added mkdir to the xml userpath. Previous version failed if directory did not exist.
			
			
	
	- Default config setup
	- Save and Load xml config file
	
	Functions:
	bool IsInitialized()			-- Returns true is config has been loaded
	FillConfigArray()				-- Puts all data into a standarized 2D array. Used for saving XML, automatically run on tt_LoadConfig()
	tt_SaveConfig(filename)			-- Save config from #myconfig 2D array to filename
	tt_LoadConfig(filename)			-- Save load config from filename. Populates into #myconfig array
	ttReturnProjectDirs() 			-- return array of directories for projects
	ttReturnRenderDirs()			-- return array of directors for render output
	ttReturnDeadlineRepository()	-- return deadline repository
	ttReturnSimulationPath()		--  return full path for simulations
	ttReturnFileClasses()			-- Returns array of valid classes for files
	ttReturnCustom customSetting	-- Returns key from given search string
	string ttGetFPS()				-- Gets defaults Frames Per Second from config
	bool ttGetUNC()					-- Gets true or false statement to use UNC paths or not (network drives)
	string ttGetDefaultUnits()		-- Gets the default units to use 
	bool ttGetUseYear()				-- Return true to divide projects in yearly folders
	bool ttGetUseQuarterly()		-- Return true to divide projects in Quarterly folders
	ttReturnFullProjectPath()		-- Returns path to projects. Projects will be placed here
	ttReturnFullRenderPath()		-- returns full path to renders. Each project output will be placed here
	ttReturnFullAssetPath()			-- returns full path to global assets folder - non project specific
	ttReturnMaxProjectPath()		-- return the default project specific path to where 3dsmax creates its files
	SaveNewLocalConfig()			-- Saves a .ms file in local users 3dsmax folder. Includes location to XML config file 
	GetXmlConfigLocation()			-- If exist; loads custom file with stored location of XML config file. Asks for dir if not found.
	
	myconfig array setup:
	[1][1] = Project Drive
	[1][2] = Render Drive
	[1][3] = Asset Drive
	
	[1][4] = Global Project Folder 
	[1][5] = Global Render Folder
	[1][6] = Global Asset Folder
	
	[1][7] = 3dsMax Project Path
	
	[1][8] = USEUNC 
	[1][9] = USEYEAR 
	[1][10] = USEQUARTERLY 
	[1][11] = DEFAULTFPS
	[1][12] = DEFAULTUNITS 
	[1][13] = Deadline Repository
	[1][14] = Simulation Directory
	
	[2] = Project specific folders (Project drive + project path + project name + this)
	[3] = render specific folders (render drive + render path + project name + this)
	[4] = Valid statuses/classes for 3D files. For automatic file generation
		ProjectName+Scene+ShotNumber+Class+CustomPassName+Version+Take
	
	[5] = Array of custom keys

*/

configVersion = "1.2"
dotNet.loadAssembly "system.xml"


-- Initialize 2D array
global myconfig = #(#())
	
-- DEFAULTS --
PRJDRV =@"S:\"
RNDDRV = @"S:\"
ASSETDRV = @"S:\"
PROJECTROOT = @"!Projects"
RENDERROOT = @"!Projects"
ASSETROOT = @"!Assets\Lib"
MAXPATH = @"3_Production\3dsMax"
USEUNC = "true"
USEYEAR = "true"
USEQUARTERLY = "false"
DEFAULTFPS = "24"
DEFAULTUNITS = "inches"
DEADLINEREPOSITORY = @"\\tronotrond-pc\DeadlineRepository"
SIMULATIONPATH = @"G:\!Simulations"
	
PROJECTFOLDERS = #(
	@"\0_io",  
	@"\0_io\References", 
	@"\0_io\MatLibs", 
	@"\0_io\FilesIn",  
	@"\0_io\FilesOut",  
	@"\1_ProjectDocs", 
	@"\2_Previz",
	@"\3_Production\Textures\Maps",
	@"\3_Production\Textures\HDRI",
	@"\3_Production\Movie",
	@"\3_Production\Proxies",
	@"\3_Production\Assets\Models",
	@"\3_Production\Assets\FX",
	@"\3_Production\Assets\Cameras",
	@"\3_Production\Assets\ENV",
	@"\4_Comp",
	@"\5_Drafts",
	@"\6_Final"
	)

RENDERFOLDERS = #(
	@"\!Frames\0_RenderFrames",
	@"\!Frames\1_CompFrames",
	@"\!Frames\2_VFX",
	@"\!Frames\3_StillFrames",
	@"\!Frames\4_Other"
	)
	
FILESTATUSES = #(
	"GEO",
	"LGT",
	"TEX",
	"ANM",
	"RND",
	"VFX"
)
-- XML tag first. Separate with &. Data field second 
-- # IS NOT A SUPPORTED CHARACTER IN TAG!
-- Case sensitive!
CUSTOMSETTINGS = #(
	@"scene&\3_Production", 								-- #Scene path	 -- 3dsMax defined paths
	@"renderoutput&\!Frames\0_RenderFrames", 	-- #renderoutput 
	@"export&\0_io\FilesOut",								-- #export
	@"import&\0_io\FilesIn",								-- #import
	@"preview&\5_Drafts",									-- #preview
	@"maxstart&\3_Production", 							-- #maxstart
	@"proxies&\3_Production\Proxies",				-- #proxies
	@"matlib&\0_io\MatLibs"	 							-- #matlib	
)


-- DEFAULT LOCAL USER SAVE LOCATION
userPath = if 1998+((maxversion())[1]/1000)>2012 then (getdir #plugcfg_ln) else (getdir #plugcfg)
userFile = "ttpsv3.ms"
userConfig = userPath + @"\TronoTools\" + userFile

-- END OF DEFAULTS -- 

fn IsInitialized =
(
	if myconfig.count == undefined or myconfig.count == 0 then
	(return false)
	else
	(return true)
)
	
fn FillConfigArray =
(
	myconfig[1][1] = PRJDRV
	myconfig[1][2] = RNDDRV
	myconfig[1][3] = ASSETDRV
	
	myconfig[1][4] = PROJECTROOT
	myconfig[1][5] = RENDERROOT
	myconfig[1][6] = ASSETROOT
	myconfig[1][7] = MAXPATH
	
	myconfig[1][8] = USEUNC 
	myconfig[1][9] = USEYEAR 
	myconfig[1][10] = USEQUARTERLY 
	myconfig[1][11] = DEFAULTFPS
	myconfig[1][12] = DEFAULTUNITS 
	myconfig[1][13] = DEADLINEREPOSITORY
	myconfig[1][14] = SIMULATIONPATH
	
	append myconfig PROJECTFOLDERS
	append myconfig RENDERFOLDERS
	append myconfig FILESTATUSES
	
	append myconfig CUSTOMSETTINGS
)

fn tt_SaveConfig xmlsavefile  = 
(
	-- Create the XML elemenet
	xmlDoc=dotNetObject "system.xml.xmlDocument"
	
	xmlRoot = xmlDoc.CreateElement "TRONOTOOLS_CONFIG"
	xmlDoc.appendChild xmlRoot
	
	--Create a new element for the object.
	newBase = xmlDoc.createElement "settings"
	xmlRoot.appendChild newBase
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "version" configVersion
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "projectdrive" myconfig[1][1]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "renderdrive" myconfig[1][2]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "assetdrive" myconfig[1][3]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "projectpath" myconfig[1][4]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "renderpath" myconfig[1][5]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "assetpath" myconfig[1][6]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "maxpath" myconfig[1][7]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "useunc" myconfig[1][8]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "useyear" myconfig[1][9]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "usequarterly" myconfig[1][10]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "defaultfps" myconfig[1][11]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "defaultunits" myconfig[1][12]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "deadlinerepository" myconfig[1][13]
	newBase.appendChild newElement
	
	newElement = xmlDoc.createElement "setting"
	newElement.setAttribute "simulationpath" myconfig[1][14]
	newBase.appendChild newElement
	
	projectXML = xmlDoc.createElement "projectfolders"
	xmlRoot.appendChild projectXML
	
	for myPath in myconfig[2] do
	(
		newElement = xmlDoc.createElement "folder"
		newElement.setAttribute "value" myPath
		projectXML.appendChild newElement
	)
	
	renderXML = xmlDoc.createElement "renderfolders"
	xmlRoot.appendChild renderXML
	
	for myPath in myconfig[3] do
	(
		newElement = xmlDoc.createElement "folder"
		newElement.setAttribute "value" myPath
		renderXML.appendChild newElement
	)
	
	renderXML = xmlDoc.createElement "filestatus"
	xmlRoot.appendChild renderXML
	
	for myPath in myconfig[4] do
	(
		newElement = xmlDoc.createElement "status"
		newElement.setAttribute "value" myPath
		renderXML.appendChild newElement
	)
	
	renderXML = xmlDoc.createElement "customsettings"
	xmlRoot.appendChild renderXML
	
	for cstSet in myconfig[5] do
	(
		splitSettings = filterString cstSet "&"
		newElement = xmlDoc.createElement splitSettings[1]
		newElement.setAttribute "value" splitSettings[2]
		renderXML.appendChild newElement
	)
	
	xmlDoc.save xmlsavefile
)

fn tt_LoadConfig xmlToLoad = 
(
	print "Loading config file..."
	if doesFileExist xmlToLoad then
	(
		-- empty array
		global myconfig = #(#())
		
		xmlDoc=dotNetObject "system.xml.xmlDocument"
		xmlDoc.load xmlToLoad
		
		Elem = xmlDoc.documentElement
		
		-- check if root element exsists
		if Elem != undefined and Elem.name == "TRONOTOOLS_CONFIG" then
		(
			-- Get base information
			part1 = elem.ChildNodes.itemOf[0]
			fileVersion = (part1.childnodes.itemof[0].GetAttributeNode "version").value
			
			if configVersion != fileVersion then -- This should probably be implemented better later
				print "Version mismatch between script and config file! Possible errors could occur"
			
			configVersion = fileVersion
			
			PRJDRV =  (part1.childnodes.itemof[1].GetAttributeNode "projectdrive").value
			RNDDRV =  (part1.childnodes.itemof[2].GetAttributeNode "renderdrive").value
			ASSETDRV =  (part1.childnodes.itemof[3].GetAttributeNode "assetdrive").value
			
			PROJECTROOT =  (part1.childnodes.itemof[4].GetAttributeNode "projectpath").value
			RENDERROOT =  (part1.childnodes.itemof[5].GetAttributeNode "renderpath").value
			ASSETROOT =  (part1.childnodes.itemof[6].GetAttributeNode "assetpath").value
			MAXPATH =  (part1.childnodes.itemof[7].GetAttributeNode "maxpath").value
			
			USEUNC =  (part1.childnodes.itemof[8].GetAttributeNode "useunc").value
			USEYEAR =  (part1.childnodes.itemof[9].GetAttributeNode "useyear").value
			USEQUARTERLY =  (part1.childnodes.itemof[10].GetAttributeNode "usequarterly").value
			DEFAULTFPS =  (part1.childnodes.itemof[11].GetAttributeNode "defaultfps").value
			DEFAULTUNITS =  (part1.childnodes.itemof[12].GetAttributeNode "defaultunits").value
			DEADLINEREPOSITORY =  (part1.childnodes.itemof[13].GetAttributeNode "deadlinerepository").value
			SIMULATIONPATH =  (part1.childnodes.itemof[14].GetAttributeNode "simulationpath").value
			
			-- clean out old arrays 
			global PROJECTFOLDERS = #()
			global RENDERFOLDERS = #()
			global FILESTATUSES = #()
			
			-- get the rest of the config file
			for i = 1 to elem.Childnodes.count-1 do
			(
				
				theChild = elem.ChildNodes.itemOf[i]
				
				if theChild != undefined and theChild.name == "projectfolders" then -- get all project folders
				(
					for i = 1 to theChild.ChildNodes.count do
					(
						folder =  (theChild.childnodes.itemOf[i-1].GetAttributeNode "value").value
						PROJECTFOLDERS[i] = folder
					)
				)
				else if theChild != undefined and theChild.name == "renderfolders" then
				(
					-- Get render folders from xml
					for i = 1 to theChild.ChildNodes.count do
					(
						folder = (theChild.childnodes.itemOf[i-1].GetAttributeNode "value").value
						RENDERFOLDERS[i] = folder
					)
				)
				else if theChild != undefined and theChild.name == "filestatus" then
				(
					-- Get valid file statuses from xml
					for i = 1 to theChild.ChildNodes.count do
					(
						theValue = (theChild.childnodes.itemOf[i-1].GetAttributeNode "value").value
						FILESTATUSES[i] = theValue
					)
				)
				else if theChild != undefined and theChild.name == "customsettings" then
				(
					-- Get valid file statuses from xml
					for i = 1 to theChild.ChildNodes.count do
					(
						firstInput = theChild.childnodes.itemOf[i-1].name
						secondInput = (theChild.childnodes.itemOf[i-1].GetAttributeNode "value").value
						
						theValue = firstInput + "&" + secondInput
						
						CUSTOMSETTINGS[i] = theValue
					)
				)
				else (messageBox "Unknown part of xml file found. Possible version mismatch..")
			) -- end for loop
		)	-- end if
		
		-- Update array with new information
		FillConfigArray()
		
		-- return the loaded settings as 2D array 
		myconfig
	)
	else (messageBox "Failed to load XML file. Does not exist!")	
)

-- specific config returns --
fn ttReturnProjectDirs =
(
	if myconfig[2] != undefined then
	(
		myconfig[2]
	)
)
fn ttReturnRenderDirs =
(
	myReturn = undefined 
	if myconfig[3] != undefined then
	(
		myReturn = myconfig[3]
	)
	else 
	(
		print "ttReturnFullProjectPath: myconfig array undefined"
	)
	
	-- return this
	myReturn
)
fn ttReturnFileClasses =
(
	myReturn = undefined 
	if myconfig[4] != undefined then
	(
		myReturn = myconfig[4]
	)
	else 
	(
		print "ttReturnFullProjectPath: myconfig array undefined"
	)
	
	-- return this
	myReturn
)


fn ttGetFPS = 
(
	if myconfig[1][11] != undefined then
	(
		myconfig[1][11]
	)
)

fn ttGetUNC = 
(
	if myconfig[1][8] != undefined then
	(
		myconfig[1][8]
	)
)
fn ttGetUseYear = 
(
	if myconfig[1][9] != undefined then
	(
		myconfig[1][9]
	)
)
fn ttGetUseQuarterly = 
(
	if myconfig[1][10] != undefined then
	(
		myconfig[1][10]
	)
)
fn ttGetDefaultUnits = 
(
	if myconfig[1][12] != undefined then
	(
		myconfig[1][12]
	)
)



fn ttReturnFullProjectPath = 
(
	myReturn = undefined 
	if myconfig[1][1] != undefined then
	(
		myReturn = (myconfig[1][1] + myconfig[1][4])
	)
	else 
	(
		print "ttReturnFullProjectPath: myconfig array undefined"
	)
	
	-- return this
	myReturn
)

fn ttReturnFullRenderPath = 
(
	myReturn = undefined 
	if myconfig[1][1] != undefined then
	(
		myReturn = (myconfig[1][2] + myconfig[1][5])
	)
	else 
	(
		print "ttReturnFullProjectPath: myconfig array undefined"
	)
	
	-- return this
	myReturn
)

fn ttReturnCustom customSetting =
(
	myReturn = undefined 
	if myConfig[5] != undefined then
	(
		for theItem in myConfig[5] do
		(
			splitString = filterString theItem "&"
			if splitString[1] == customSetting then 
				(myReturn = splitString[2])
		)
	)
	else 
	(
		print "ttReturnCustom: myconfig array undefined"
	)
	
	if myReturn == undefined then
	(print ("ttReturnCustom: " + customSetting + " key not found/not defined"))
	-- return this
	myReturn
)

fn ttReturnMaxProjectPath =
(
	myReturn = undefined 
	if myconfig[1][1] != undefined then
	(
		myReturn = myconfig[1][7]
	)
	else 
	(
		print "ttReturnFullProjectPath: myconfig array undefined"
	)
	
	-- return this
	myReturn
)

fn ttReturnFullAssetPath = 
(
	myReturn = undefined 
	if myconfig[1][1] != undefined then
	(
		myReturn = (myconfig[1][3] + myconfig[1][6])
	)
	else 
	(
		print "ttReturnFullProjectPath: myconfig array undefined"
	)
	
	-- return this
	myReturn
)

fn ttReturnDeadlineRepository = 
(
	myReturn = undefined 
	if myconfig[1][1] != undefined then
	(
		myReturn = (myconfig[1][13])
	)
	else 
	(
		print "ttReturnFullProjectPath: myconfig array undefined"
	)
	
	-- return this
	myReturn
)

fn ttReturnSimulationPath = 
(
	myReturn = undefined 
	if myconfig[1][1] != undefined then
	(
		myReturn = (myconfig[1][14])
	)
	else 
	(
		print "ttReturnFullProjectPath: myconfig array undefined"
	)
	
	-- return this
	myReturn
)

fn SaveNewLocalConfig =
(
	file = getOpenFileName historyCategory:"TTPS" caption:"Open Project Starter XML Config File" Types:"XML Data (*.xml)|*.xml|All files|*.*|"	
	if file != undefined then
	(
		thePath = getFilenamePath userConfig
		makeDir thePath
		Outfile = createfile userConfig
		format "%\n" ("global ttxmlconfig = " + "@\"" + file+ "\"") to:Outfile
		close Outfile
					
		return 0
	)
	else 
		return -1
)

fn GetXmlConfigLocation = 
(
	global ttps_xmlconfig = undefined
	
	if doesFileExist userConfig then
	(
		ttps_xmlconfig = ::filein userConfig
		
	)
	else
	(
		if SaveNewLocalConfig() == -1 then
		(
			return -1
		)
		ttps_xmlconfig = ::filein userConfig
	)
	-- return path if found
	ttps_xmlconfig
)



--tt_LoadConfig @"C:\temp\test2.xml"
--FillConfigArray()
--tt_saveconfig @"C:\temp\test.xml"
