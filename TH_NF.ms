/*
	Tronotools Library: Name/Directory Functions v1.12
	* Requires TH_Xml.ms v1.0 loaded
	
	last changed		2016/3/19
	
	changelog
		v1.1	- Added GetFumeSimDir()
		v1.12	- Added FumeFX subdir to GetFumeSimDir()
				- Added GetPflowSimDir()
	
	
	Functions:
	GetProjectName()			-- Returns name of current project

	- Get project name
	- Set output dirs
	- Set output names

*/


fn GetProjectName =
(
	fullPath = PathConfig.getCurrentProjectFolder()
	maxPath = ttReturnMaxProjectPath()

	projectPath = substituteString fullPath maxPath ""
	pathArray = filterString projectPath @"\"
	
	print ("Current Project: " + pathArray[pathArray.count])
	
	pathArray[pathArray.count]
)

fn GetProjectDir =
(
	fullPath = PathConfig.getCurrentProjectFolder()
	maxPath = ttReturnMaxProjectPath()

	projectPath = substituteString fullPath maxPath ""
	
	projectPath
)

fn GetFumeSimDir =
(
	simDir = ttReturnSimulationPath()

	projectName = GetProjectName()	
	simRoot = simDir + @"\FumeFX\" + projectName + @"\" 
	
	simRoot
)

fn GetPflowSimDir =
(
	simDir = ttReturnSimulationPath()
	
	projectName = GetProjectName()
	simRoot = simDir + @"\pFlow\" + projectName + @"\" 
	
	simRoot
)