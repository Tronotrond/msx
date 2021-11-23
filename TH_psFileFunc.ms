/***************************************************************
**
**	TronoTools File Read/Write Functions for Project Starter v1.0
**
**
**
*
***************************************************************/

fn CheckForValidUserFile userFile =
(
	myPath = getFilenamePath userFile

	--if myPath == undefined then
	if doesFileExist userFile == false then
	(
		print "User config not found! Probably first time you run the script?"
			
		if doesFileExist myPath == false then 
			makeDir myPath all:true
		
		file = getOpenFileName historyCategory:"TTPS" caption:"Open Project Starter Config File" Types:"CFG Data (*.cfg)|*.cfg|All files|*.*|"	
		if file != undefined then
		(
				fflush
				f=fopen userFile "wb"
				WriteString f file
				-- Because max writes a null byte after a string we need to remove it by moving the cursor back one sted and inserting a space
				fseek f -1 #seek_cur
				writebyte f 32
				fclose f
						
			return 0
		)
		else 
			return -1
	)

	return 0
),

fn WriteFile fileName stringArray =
(
	fflush
	f=fopen fileName "wb"
    for theText in stringArray do	
	(
		WriteString f theText
		writebyte f 13
	)
	-- Because max writes a null byte after a string we need to remove it by moving the cursor back one sted and inserting a space
	fseek f -1 #seek_cur
	writebyte f 32
	fclose f
),

fn SetNewConfigFile userFile =
(
	file = getOpenFileName historyCategory:"TTPS" caption:"Open Project Starter Config File" Types:"CFG Data (*.cfg)|*.cfg|All files|*.*|"	
	if file != undefined then
	(
			fflush
			f=fopen userFile "wb"
			WriteString f file
			-- Because max writes a null byte after a string we need to remove it by moving the cursor back one sted and inserting a space
			fseek f -1 #seek_cur
			writebyte f 32
			fclose f
					
		return 0
	)
	else 
		return -1
),

fn GetConfigFile userFile =
(
	configF = openFile userFile
	if configF == undefined then
	(
		print "GetConfigFile read error..."
		return -1
	)
	else
	(
		dataFilePath = readLine configF
		close configF
		if (doesFileExist dataFilePath) == false then
			return -1
		
	)
	return dataFilePath
),

fn readFile myFile arg =
(
	folderArray = #()
	
	if (config = openFile myFile mode:"rb") == undefined then
	(
		messageBox "Data File not found!"
		return false
	)
	startArg = "[" + arg + "]"
	endArg = "[/" + arg + "]"
	if (skipToString config startArg) == undefined then
	(
		errorString = "Config file read error. Argument not found. \n"  + startArg
		messageBox errorString
		close config
		return false
	)
	skipToNextLine config 
	skipToNextLine config 
	i = 0
	while not eof config do
	(
		nextValue = readLine config
		
		if nextValue == endArg then
			exit
		
		if nextValue != "" then
			append folderArray nextValue
		
		i+=1
		if i > 1000 then 
		(
			print "ARGH! Something went wrong. Killing the while loop..."
			exit
		)
	)
	
	close config
	
	return folderArray
),

fn readFileSingle myFile arg =
(
	
	if (config = openFile myFile mode:"rb") == undefined then
	(
		messageBox "Data File not found!"
		return false
	)
	startArg = "[" + arg + "]"

	if (skipToString config startArg) == undefined then
	(
		errorString = "Config file read error. Argument not found. \n"  + startArg
		messageBox errorString
		close config
		return false
	)
	skipToNextLine config 
	skipToNextLine config 
	i = 0
	while not eof config do
	(
		nextValue = readLine config
		
		if nextValue != "" then
		(
			myValue = nextValue
			exit
		)
	)
	
	close config
	
	return myValue
),