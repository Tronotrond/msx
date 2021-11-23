/*
	TronoTools Deadline Library v1.21
	created 		2016/3/1
	last modified 	2016/09/25
	
	changelog:
		v1.01	- Added a submit function that disables task update timouts. For FumeFX simulations etc.
		v1.1	- Added initialization
				- Added DLGetPools() and pool variable to the Submit functions
		v1.2
				- Fixed Deadline Failed to Open Render error with Submitting FumeFX sims through NoTimeout submitt. Now changed to SubmittFumeFX with attached render maxscript.
				- Still needs some work... 
		v1.21 	
				- FumeFX submission script had hardcoded user path. Changed to look in repository instead. File still needs to be manually placed there..

	functions for submitting and handling jobs with Thinkbox Deadline


	requires:
	th_xml.ms

*/

fn DLInit =
(
	DLR = ttReturnDeadlineRepository()
	
	SMTD_FuncList = DLR + @"\submission\3dsmax\Main\SubmitMaxToDeadline_Functions.ms"
	::filein SMTD_FuncList
	
)

fn GetPools =
(
	SMTDFunctions.CollectPools()
	dlPools = SMTDSettings.Pools
	
	
	dlPools
)

fn DLSimpleSubmit _JobName _Priority _Comment _Pool =
(
	
	-- Deadline settings
	SMTDSettings.JobName = _JobName
	SMTDSettings.Priority = _Priority
	SMTDSettings.Comment = _Comment
	SMTDSettings.PoolName = _Pool
	
	-- submit settings
	MaxFileToSubmit = SMTDPaths.tempdir + maxfilename
	SMTDFunctions.SaveMaxFileCopy MaxFileToSubmit
	
	--Create Render Job Files
	SubmitInfoFile = SMTDPaths.tempDir + @"Max_Submit_Info.job"
	JobInfoFile = SMTDPaths.tempDir + @"Max_Job_Info.job"
	-- Create job files
	SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile
	SMTDFunctions.CreateJobInfoFile JobInfoFile
	-- Submit job
	SubmitString = "\""+SubmitInfoFile+"\" \""+JobInfoFile+"\" \""+MaxfileToSubmit+"\" "
	result = SMTDFunctions.WaitForCommandToComplete SubmitString 200
	
	result
)

fn DLSubmitFumeFX _JobName _FumeGrid _Priority _Comment _Pool =
(
	DLR = ttReturnDeadlineRepository()
	FumeFXObjectsToSim = #()
	FumeFXObjectsToSim[1] = _FumeGrid.name 
	SMTD_FuncList = DLR + @"\submission\3dsmax\Main\SubmitMaxToDeadline_Functions.ms"
	::filein SMTD_FuncList
	
	-- Deadline settings
	SMTDFunctions.loadSettings()
	SMTDSettings.JobName = _JobName
	SMTDSettings.Priority = _Priority
	SMTDSettings.Comment = _Comment
	SMTDSettings.PoolName = _Pool
	SMTDsettings.DisableProgressUpdateTimeout = true
	SMTDSettings.ChunkSize = 1
	SMTDSettings.SubmitAsMXSJob = true

	-- FumeFX file needs to be placed in submission dir --
	local MAXScriptFile = DLR + @"\submission\3dsmax\Main\MAXScriptJob_SimulateFumeFX.ms"
	if (doesFileExist MAXScriptFile) == false then (print ("FumeFX Submission Script not found! Please place in " + MAXScriptFile))

	-- Render settings
	renderSceneDialog.close()
	rendTimeType = 3
	rendStart = 1
	rendEnd = 1
	
	-- submit settings
	MaxFileToSubmit = SMTDPaths.tempdir + maxfilename
	SMTDFunctions.SaveMaxFileCopy MaxFileToSubmit
	
	--Create Render Job Files
	SubmitInfoFile = SMTDPaths.tempDir + @"Max_Submit_Info.job"
	JobInfoFile = SMTDPaths.tempDir + @"Max_Job_Info.job"
	-- Create job files
	SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile
	SMTDFunctions.CreateJobInfoFile JobInfoFile
	
	theHandle = openFile JobInfoFile mode:"at"
	with printAllElements on format "FumeFXToSimulate=%" FumeFXObjectsToSim to:theHandle
	close theHandle
	
	-- Submit job
	SubmitString = "\""+SubmitInfoFile+"\" \""+JobInfoFile+"\" \""+maxFileToSubmit+ "\" \""+ MAXScriptFile +"\" " 
	result = SMTDFunctions.WaitForCommandToComplete SubmitString SMTDSettings.TimeoutSubmission
	
	local renderMsg = SMTDFunctions.getRenderMessage() 
	SMTDFunctions.getJobIDFromMessage renderMsg
	
	print renderMsg

	result
)
