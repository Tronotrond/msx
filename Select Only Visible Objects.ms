/*
	Tronotools 	Select Only Visible Objects 	v1.3
		Trond Hille 2016 - tronotrond@gmail.com
		hille3d.no
	
	last modified:
		2016/10/03
		
	changelog:
		v1.0: 
			initial release
		v1.1
			nudging camera inside the sphere to for the lattice not to block the view
			added option to add a small rotation to the camera sphere by default. might increase accuracy. 
		v1.2
			public release
			fixed minor nuianses
			Added option to select hidden objects
			Fixed default camera rig radius to more fit the scene
			Locks cameras in place 
			Added on close query box to remove any camera rigs in scene
			Better functionality to check from a custom camera
			Optimized render
		v1.3
			Highly optimized the bitmap scanning. Thanks to Jerome Moab!
			Objects are now stored in Named Selection Set "ScannedObjects"
		
		
	description:
		The script creates a given amount of cameras places in a sphere. Make sure all your objects are inside the sphere
		and as visible to all cameras as possible. The script renders each view and checks for what objects the cameras can see.
		The array of visible objects is stored and selected when rendering is done. 
		
		Isolate selection and save selected, or invert selection to delete all objects not visible to camera. 
		
		Limitations: 
			-	There's a max limit of 65536 objects to be scanned at once!
			- 	Script will fail if you have ActiveShade active. 
		
		Tip: Invert selection and give interal objects a bright color and look for any objects not caught by the cameras your self.
*/


try(destroyDialog ttSelectVisible)catch()

(
	camSphere
	myModifier
	myCam
	defaultRadius = ((length (objects.max - objects.min))*1.5)
	if (int defaultRadius < 10) then (defaultRadius = 100)
	centerpos = objects.center
	cameraArray = #()
	visibleObjects = #()
	rendersize = 320
	
	fn CreateCameraSphere numSegs =
	(		
		camSphere = GeoSphere pos: centerpos radius:defaultRadius segments:numSegs name:"CameraSphere" baseType:1
		camSphere.renderable = off
		converttomesh camSphere
		allVerts = meshOp.GetNumVerts camSphere
		
		vertPos = meshOp.GetVert camSphere 1
		myCam = Targetcamera position:vertPos target:camSphere
		myCam.nearclip = 10
		myCam.farClip = 25400000
		myCam.fov = 62
		myCam.parent = camSphere
		
		append cameraArray myCam
		
		for i = 2 to allVerts do
		(
			vertPos = meshOp.GetVert camSphere i
			
			d = vertPos - camsphere.pos
			vertPos = vertPos - (d/100)
			
			newCam = instance myCam
			newCam.position = vertPos
			newCam.parent = camSphere
			
			append CameraArray newCam
		)
		
		-- move the cameras out of the lattice
		for cam in CameraArray do
		(
			dir = normalize (centerpos - cam.pos)
			cam.pos = cam.pos + dir*1.2
			setTransformLockFlags cam #all -- Lock camera in place
		)
		
		myModifier = Lattice()
		addmodifier camSphere myModifier
		myModifier.Strut_Radius = 1
		myModifier.Joint_Radius = 0
		
		print cameraArray
	)
	fn AdjustSphere newRad =
	(

	) 

	fn getVisibleObjects GeoOnly =
	(
		theArray = #()
		
		if GeoOnly == true then
			theArray = geometry
		else
			theArray = objects
		
		
		for i = 1 to theArray.count do
			theArray[i].gbufferChannel = i
		
		-- render setup
		preferences.maximumGBufferLayers = 1
		bm = bitmap rendersize rendersize channels:#(#objectID)
		render rendersize rendersize to:bm channels:#(#objectID)

		-- Loop through bitmap pixels
		iCount = rendersize - 1	
		for x = 0 to iCount do
		(			
			for y = 0 to iCount do
			(
				objId = (GetChannel bm [x,y] #objectID)[1]			
				if objId > 0 do 
				(
					-- set visibleObjects value only if it's undefined... way faster than appendIfUnique
					if visibleObjects[objId] == undefined do visibleObjects[objId] = theArray[objId]
				)
			)
		)
		
		-- don't forget to close the bitmap
		close bm ; free bm
		
		-- keep only values that are not undefined
		visibleObjects = for o in visibleObjects where o != undefined collect o	
	)
	
	rollout ttSelectVisible "Select Visible Objects v1.3" width:312 height:272
	(
		radiobuttons 'rdoCams' "Number of Cameras" pos:[16,8] width:109 height:30 labels:#("6", "18", "38") default:2 columns:3 align:#left
		button 'btnCreate' "Create" pos:[136,16] width:72 height:24 align:#left
		button 'btnDelete' "DeleteCamRig" pos:[216,16] width:80 height:24 enabled:false align:#left
		
		label 'lbl1' "Script will only detect objects visible to one or more of the cameras. Adjust Number of Cameras and Render Size accordingly. Higher values means more accurate results! Please make sure to scale the rig and adjust the camera FOV to cover all your objects. Render settings etc. will be reset!\nGeo only: Select only geometry\nRot: Slightly rotate camera sphere on creation." pos:[16,48] width:280 height:112 align:#left
		
		radiobuttons 'rdoRndSize' "RenderSize" pos:[16,168] width:94 height:46 labels:#("320", "512", "1024", "2048") default:1 columns:2 align:#left
		button 'btnRender' "RenderAllCameras" pos:[160,176] width:136 height:24 enabled:false align:#left
		button 'btnRenderSelected' "Render Selected View" pos:[160,208] width:136 height:24 enabled:true align:#left
		checkbox 'chkGeo' "Geo Only?" pos:[16,216] width:72 height:16 checked:true align:#left
		checkbox 'chkRot' "Rot" pos:[96,216] width:48 height:16 checked:true align:#left
		
		checkbox 'chkInvert' "Check to select visible. Uncheck to select hidden objects." pos:[16,240] width:272 height:16 checked:false align:#left
		
		
		-- Renders only from active view
		
		
		on btnCreate pressed do
		(
			CreateCameraSphere rdoCams.state
			if chkRot.checked then
			(	-- slightly rotate sphere
				rot = eulerAngles 20 5 5
				camSphere.rotation = eulerToQuat rot
			)
			btnCreate.enabled = false
			btnDelete.enabled = true
			btnRender.enabled = true
			--btnRenderSelected.enabled = true
			
			renderers.current = default_scanline_renderer()
			select camSphere
			displaySafeFrames = true
		)
		fn deleteRig = 
		(
			btnCreate.enabled = true
			btnDelete.enabled = false
			btnRender.enabled = false
			--btnRenderSelected.enabled = false
			
			cameraArray = #()
			
			if not isDeleted camSphere then
			(
				for cameraChild in camSphere.children do
				(
					delete cameraChild
				)
			)
		)
		on btnDelete pressed do
		(
			deleteRig()
		)
		
		on ttSelectVisible close do
		(
			if btnDelete.enabled then
			(
				if (queryBox "Do you want to delete camera rig in scene before exiting tool?" beep:true) then
					(deleteRig())
			)
		)
		
		on rdoRndSize changed state do
		(
			rendersize = case state of
			(
				1: 320
				2: 512
				3: 1024
				4: 2048
			)
			tmp = "Render size changed to " + (rendersize as string)
			print tmp
		)
		on btnRender pressed do
		(
			visibleObjects = #()
			for theCamera in cameraArray do
			(
				viewport.setCamera theCamera
				getVisibleObjects chkGeo.checked
			)
			select visibleObjects
			if not chkInvert.checked then 
			(
				max select invert
				print "Selecting hidden objects"
			)
			selectionSets["ScannedObjects"] = #()
			selectionSets["ScannedObjects"] = selection
			print "Scan completed! Objects saved in Named Selection Set: ScannedObjects"
		)
		on btnRenderSelected pressed do
		(			
			visibleObjects = #()
			getVisibleObjects chkGeo.checked
		
			select visibleObjects
			if not chkInvert.checked then 
			(
				print "Selecting hidden objects"
				max select invert
			)
			selectionSets["ScannedObjects"] = #()
			selectionSets["ScannedObjects"] = selection
			print "Scan completed! Objects saved in Named Selection Set: ScannedObjects"
		)
	)
	
	
	if (querybox "This tool will change your current render settings. Continue?" beep:false) then
	(
		renderers.current = Default_Scanline_Renderer()
		vr = renderers.current 
		vr.mapping = false
		vr.shadows = false
		vr.antiAliasing = false
		vr.autoReflect = false
		vr.imageMotionBlur = false
		vr.objectMotionBlur = false
		re = maxOps.GetCurRenderElementMgr() 
		re.SetElementsActive(false)
		
		_l = lights
		if _l.count > 0 then
			if (queryBox "Lights found in scene. It's recommended to delete these. Delete all lights?" Beep:false) then
			(
				delete _l
			)
		
		
		createDialog ttSelectVisible
	)
	
)

