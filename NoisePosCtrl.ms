/***********************************************************
**
**		NOISE CONTROLLER WITH RANDOM SEED COPIER
**
**		NOV / Trond Hille 2014
**
**		- Works as intended :)
**
*************************************************************/




try (destroyDialog "Noisy Controllers") catch()

tempVar1 = undefined
scaleVar = 10
controller = Noise_position ()

fn setupTestBox =
(
	tempVar1 = box()
	tempVar1.length = scaleVar
	tempVar1.width = scaleVar
	tempVar1.height = scaleVar
	
	select tempVar1
	
	tempVar1.pos.controller = controller
	--tempVar1.pos.controller.Available.controller  
	displayControlDialog tempVar1.pos.controller "Shake yer pants and get jiggy!"
)

fn changeScale =
(
	tempVar1.length = scaleVar
	tempVar1.width = scaleVar
	tempVar1.height = scaleVar
)

fn deletePosControllers =
(
	undo on
	(
		disableSceneRedraw()
		for obj in selection do
		(
			try obj.pos.controller = Position_XYZ ()
			catch()
		)
		enableSceneRedraw()
	)
)

/*
----------------------------------------------------------
System.Windows.Forms.MessageBoxButtons (Enumeration)
----------------------------------------------------------
.AbortRetryIgnore
.OK
.OKCancel
.RetryCancel
.YesNo
.YesNoCancel

----------------------------------------------------------
System.Windows.Forms.MessageBoxDefaultButton (Enumeration)
----------------------------------------------------------
.Button1
.Button2
.Button3

----------------------------------------------------------
System.Windows.Forms.MessageBoxIcon (Enumeration)
----------------------------------------------------------
.Asterisk
.Error
.Exclamation
.Hand
.Information
.None
.Question
.Stop
.Warning

----------------------------------------------------------
MessageBox.show (Method)
----------------------------------------------------------
MessageBox.show ( text, caption, buttons, icon, defaultButton )

*/ 

fn confirmDialogBox title str =
(
	-- setup dotnet classes / objects
	mb = dotNetClass "System.Windows.Forms.MessageBox"
	buttons = dotNetClass "System.Windows.Forms.MessageBoxButtons"
	icons = dotNetClass "System.Windows.Forms.MessageBoxIcon"
	defaultButton = dotNetClass "System.Windows.Forms.MessageBoxDefaultButton"
	dialogResult = dotNetClass "System.Windows.Forms.DialogResult"
	
	result = mb.show str title buttons.OKCancel icons.Information defaultButton.Button1
	
	-- evaluate result of messageBox (which button has been pressed by the user)
	if ( result == dialogResult.Ok ) then
	(
		return 0
	)
	else if ( result == dialogResult.Cancel ) then
	(
		return 1
	)
	
)

rollout noiseCopy "NoisePosCtrl" width:184 
(
	label lbl1 "Noise Shake dat Ass" pos:[40,0] width:104 height:16

	spinner spnScale "Setup Object Scale" pos:[16,24] width:160 height:16 range:[0,1000,10]
	checkbox chkRndSeed "Randomize Seed" pos:[8,48] width:168 height:24 checked:true
	
	button btn1 "Setup" pos:[16,72] width:64 height:24 enabled:true
	button btn2 "Copy" pos:[104,72] width:64 height:24 enabled:false
		
	on btn1 pressed do
	(
		btn1.enabled = false
		btn2.enabled = true
		
		setupTestBox()
	)
	on btn2 pressed do
	(
		checkConfirm = confirmDialogBox("Confirm") ("Select objects to copy Noise Controller to before continuing") 
		print checkConfirm
		if checkConfirm == 0 do -- User pressed OK
		(
			undo on 
			(
				disableSceneRedraw()
				selectionArray = selection
				delete tempVar1
				for obj in selectionArray do
				(
					obj.pos.controller = position_list ()
					tmpcontroller = copy controller
					
					-- randomize seed
					if chkRndSeed.checked == true do
					(
						tmpcontroller.seed = random 1 4500
					)
					
					obj.pos.controller.Available.controller = tmpcontroller
					
					enableSceneRedraw()
					-- reenable buttons
					btn1.enabled = true
					btn2.enabled = false
				)
			)
		)			
		
	)
	on spnScale changed val do
	(
		scaleVar = val
		if tempVar1 != undefined do
		(
			changeScale()
		)
	)
	on btn5 pressed do
	(
		checkConfirm = confirmDialogBox()
		print checkConfirm
		if checkConfirm == 0 do -- User pressed OK
		(
			undo on 
				(
				selectionArray = selection
				delete tempVar1
				for obj in selectionArray do
				(
					obj.pos.controller = position_list ()
					tmpcontroller = copy controller
					
					-- randomize seed
					if chkRndSeed.checked == true do
					(
						tmpcontroller.seed = random 1 4500
					)
					
					obj.pos.controller.Available.controller = tmpcontroller
					
					
					-- reenable buttons
					btn1.enabled = true
					btn2.enabled = false
				)
			)
		)			
		
	)
)

rollout noiseCopyExtras "Extras" width:184
(
	button btnClear "ClearControllers" pos:[16,8] width:128 height:16 enabled:true toolTip:"Removes all position controllers" 
	
	on btnClear pressed do
	(
		check = checkConfirm = confirmDialogBox("Confirm") ("Continuing replace all position controllers on selected objects with a standard position controller.") 
		
		if check == 0 do --user pressed OK
		(
			deletePosControllers()
			
		)
		
	)
	
)

rf = newRolloutFloater "Noisy Controllers" 184 180
addRollout noiseCopy rf
addRollout noiseCopyExtras rf rolledUp:true
--CreateDialog noiseC