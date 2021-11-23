global completeFilePath
global datafile
global systemUnits
--global DataArray = #()
--global tempnode = object

--Bugs:
--In big scenes, texture vertices might not import (memory error).
--Please use preset settings that I've provided.

-- TH Addon: Search function
fn positionsInString stringToCheck findThisString caseBool =
(
	listOfStringPositions = #()
	if stringToCheck.count >= findThisString.count and stringToCheck.count > 0 do
	(
		for strCnt = 1 to (stringToCheck.count - findThisString.count +1) do
		(
			if caseBool then
			(
				if (substring stringToCheck strCnt findThisString.count)  == findThisString do append listOfStringPositions strCnt
			)
			else
			(
				if (substring stringToCheck strCnt findThisString.count as name) == (findThisString as name) do append listOfStringPositions strCnt
			)
			
		)	
	)
	listOfStringPositions
)

-- TH Addon: OBJ export does not support special characters. We need to clear them out first
fn fixObjNames = (
	print "Checking object names..."
	disableSceneRedraw()
	-- Create an array with invalid characters
	invalidChars = #(":", "\\", "/", "@", ";", " ", "-", "(", ")")
	-- What to replace them with 
	ReplaceString = "_"
	
	-- Find objects with identical names and fix
	actionMan.executeAction 0 "40021"  -- Selection: Select All
	for nodelist in selection do
	(
		global tempArray = #()
		append tempArray nodelist
		nameVar = nodelist.name
		
		for o in objects where o.name == nameVar do
		(
			append tempArray o			
		)
		-- Rename objects
		if tempArray.count > 1 then
		(
			for i in 1 to tempArray.count do 
			(
				
				-- This code give random numbers
				tempArray[i].name = uniquename tempArray[i].name
			)
		)	
		
	)
	
	
	-- Rename objects with invalid characters
--	actionMan.executeAction 0 "40021"  -- Selection: Select All
	for i in 1 to invalidChars.count do
	(
		for nodeList in selection do 	
		(
			SearchString = invalidChars[i] -- set the string to search for
			
			tempName = nodeList.name
			replacePositions = positionsInString nodeList.name SearchString false
			for stringCnt = 0 to (replacePositions.count-1) do
			(
				currentIndex = ((ReplaceString.count-SearchString.count) * stringCnt) + replacePositions[stringCnt+1]
				tempName = replace tempName currentIndex SearchString.count ReplaceString
			)
			nodeList.name = tempName
		)
	)
	print "Done!"
	enableSceneRedraw()
)

fn exportobjdata=
(
	--just to make sure we close the datafile before we try to open it again.
	--if exporter crashes it does not close the data file. so we need to make sure.
	try
	(close datafile)
	catch(print "closed file.")
	
	-- Get the current used system unit
	systemUnits = units.SystemType
	
	--creates and opens the datafile for writing.
	datafile = createfile ((pathConfig.GetDir #export) + "\\" +  "scenedatafile.txt")
	
	newFilePath = pathConfig.GetDir #export
	
	--just creates a filename to export to.
	completeFilePath = (newFilePath + "/" + "temp_export_reimport" + ".obj")
	
	--goes through all geometry in scene.
	for current in geometry do
	(
		--get's the object
		select current
		--writes out the name to the data file.
		format (current.name + "\n") to:datafile

		--writes out RGB of wirecolor on object.
		format (current.wirecolor.r as string + "\n") to:datafile
		format (current.wirecolor.g as string + "\n") to:datafile
		format (current.wirecolor.b as string + "\n") to:datafile
		
		--write out pivot (obj reset's pivot to 0,0,0 in scene when imported.
		format (current.pivot.x as string + "\n")to:datafile
		format (current.pivot.y as string + "\n")to:datafile
		format (current.pivot.z as string + "\n")to:datafile
	)
	--export the whole scene as 1 file
	exportFile completeFilePath #noPrompt selectedOnly:false using:OBJEXP
	
	--closes the data file for writing.
	close datafile
	
	--clears the selection,
	clearSelection()
	
	--garbage collect.
	gc()
)

fn importdata=
(
	actionMan.executeAction 0 "40005"  -- File: Reset File
	
	-- Set the used system unit
	units.SystemType = systemUnits
	
	--You cannot (for now) get rid of the import dialog box, sorry.
	--but you only need to press it once per scene.
	importFile completeFilePath using:OBJIMP  #noPrompt
	
	--finds the scene data file text file
	evac = ((pathConfig.GetDir #export) + "\\" +  "scenedatafile.txt")
	--opens the file for reading.
	posFile = openFile evac
	
	
	--read through the whole file.
	while not eof posFile do
	(
		--create a empty array for holding the object data.
		DataArray = #()
		
		--collect 7 lines in a row( we use 7 items for each object),
		for i = 1 to 7 do
		(
			--read the line
			new_line = readLine posFile
			--insert to array
			append DataArray new_line
			--skip to next item x of 7
			i +=1
		)
		--when we've read the 7 lines we have the data we need for current object.
		
		--get the object.
		tempnode = getnodebyname (DataArray[1] as string)
		
		--set the wirecolor
		tempnode.wirecolor = [(DataArray[2] as integer), (DataArray[3] as integer), (DataArray[4] as integer)]
		--set the pivot.
		tempnode.pivot = [(DataArray[5] as integer), (DataArray[6] as integer), (DataArray[7] as integer)]
		
	)
	--garbage collect.
	gc()
)

fixObjNames()
exportobjdata()
importdata()
