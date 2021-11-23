/*****************************************
** 		TronoTools Folder Functions
**
*****************************************/


fn CreateFolders mainDir folderArray =
(
	-- Can directory be created
	if ((makeDir mainDir all:true) == false) then
	(
		messageBox "Error: Directory could not be created!"
		return false
	)
	else -- yes, setup folders!
	(
		for i in 1 to folderArray.count do
		(
			if((makeDir (mainDir + "\\" +folderArray[i]) all:true) == false) then -- create directories and check for errors
			(
				messageBox "Error while creating directories!"
				return false
			)
		)
	)
	return true
)