/*
	TronoTools V-Ray QuickMaskRender Tool v1.0
	www.hille3d.no / tronotrond@gmail.com

	created:		2016/04/26
	last modified:	2016/04/27

	check for unsaved changes
	save as new filename
	hold and restore scene
	black/white mask selected objects
	render only selected objects (no mask)
	ambient occlusion pass / extra tex
	other extra tex
	override material settings / copy to extraTex
	
	submit to deadline

*/
(
	GLOBAL _ttSelection = #()
	_ttSelectionString = #()
	_giMult = 10
	_matSelected = undefined
	_matUnselected = undefined 
	_matMatte = undefined
	_r = renderers.current
	
	fn SetupDefaultMats = 
	(
		_selMat = VRayMtl()
		_selMat.name = "SelectedMask"
		_selMat.diffuse = color 0 0 0
		_selMat.selfIllumination =  color 255 255 255
		_selMat.selfIllumination_multiplier = _giMult
		
		_unSelMat = VRayMtl()
		_unSelMat.name = "UnselectedMask"
		_unSelMat.diffuse = color 255 255 255
		
		_matteMaterial = VRayMtlWrapper()
		_matteMaterial.baseMtl = _unSelMat
		_matteMaterial.matteSurface = true
		_matteMaterial.alphaContribution = -1.0
		
		_matMatte = _matteMaterial
		_matSelected = _selMat
		_matUnselected = _unSelMat
	)

	fn AddToGlobalArray ObjArray = 
	(
		for i = 1 to ObjArray.count do
		(
			appendIfUnique _ttSelection ObjArray[i]
		)
		print _ttSelection
	)
	fn GetSelectionArray = 
	(
		_selArray = $selection as array
		_return = #()
		_return = (for obj in _selArray where superClassOf obj == GeometryClass collect obj)

		AddToGlobalArray(_return)
	)

	fn RemoveFromGlobalArray Obj =
	(
		deleteitem _ttSelection (findItem _ttSelection Obj)
	)
	fn combineArray arr1 arr2 =
	(
		array = deepcopy arr1
		for i = 1 to arr1.count do insertItem arr2[i] array (i*2)
		array
	)
	
	fn RemoveFromExclude obj =
	(
		_effects = numAtmospherics 
		if _effects > 0 then
		(
			for i = 1 to _effects do
			(
				_type = getAtmospheric i
				if (_type as string) == "VRayToon:VRayToon" then
				(
					_index = (findItem _type.excludeLis obj)
					if _index > 0 then
						deleteItem _type.excludeList _index
				)
			)
		)
		_index = (findItem _r.excludeListOverrideMtl obj)
		if _index > 0 then
			deleteItem _r.excludeListOverrideMtl _index
	)



	rollout ttMaskTools "Tronotools Quick Mask Tools" width:512 height:376
	(
		multiListBox 'lbxObj' "Selected Objects" pos:[9,8] width:248 height:23 align:#left
		button 'btnAddSel' "Add Selection" pos:[8,336] width:80 height:16 align:#left
		button 'btnAdd' "Add" pos:[168,336] width:40 height:16 align:#left
		button 'btnRem' "Rem" pos:[216,336] width:48 height:16 align:#left
		button 'btnHold' "Hold Scene" pos:[272,8] width:104 height:24 align:#left
		button 'btnRestore' "Restore Scene" pos:[392,8] width:104 height:24 enabled:false align:#left
		button 'btnMask' "B/W Mask Selected" pos:[272,48] width:104 height:24 align:#left
		button 'btnSelVisible' "Visible To Cam" pos:[392,48] width:104 height:24 align:#left
		pickbutton 'btnMtl' "Override Material" pos:[272,128] width:104 height:24 align:#left
		button 'btnAddOverrideMtl' "Add as ExtraTex" pos:[392,128] width:104 height:24 enabled:false align:#left
		button 'btnDeadline' "Submitt to Deadline" pos:[280,328] width:104 height:24 enabled:false align:#left
		button 'btn13' "Render Locally" pos:[392,328] width:104 height:24 enabled:false align:#left
		
		fn MirrorArrayToString = 
		(
			-- clear old array
			_ttSelectionString = #()
			for i = 1 to _ttSelection.count do 
			(
				_ttSelectionString[i] = _ttSelection[i].name
			)
		)
		fn UpdateListbox = 
		(
			lbxObj.items = #()
			MirrorArrayToString()
			lbxObj.items = _ttSelectionString
		)

		button 'btnSelArray' "Select Objs" pos:[96,336] width:64 height:16 align:#left
		button 'btnMatte' "Matte Unselected" pos:[392,80] width:104 height:24 align:#left
		checkbox 'chkClear' "Also remove from Exclude lists" pos:[8,355] width:248 height:16 checked:true align:#left
		
		on ttMaskTools open do
		(
			if getsaverequired() then
			(
				messageBox "Warning! You have unsaved changes!\n You should save your scene before using this tool\n to avoid loosing information"
			)
			
			
			GetSelectionArray()
			UpdateListbox()
		)
		on btnAddSel pressed do
		(
			GetSelectionArray()
			UpdateListbox()
		)
		on btnAdd pressed do
			(
		
		)
		on btnRem pressed do
		(
			for item in ttMaskTools.lbxObj.selection do
			(
				
				RemoveFromExclude(_ttSelection[item])
				_ttSelection[item] = undefined
			)
			for i = _ttSelection.count to 1 by -1 do
			(
				if _ttSelection[i] == undefined then
					deleteItem _ttSelection i
			)
			UpdateListbox()
		)
		on btnHold pressed do
		(
			if (queryBox "You are about to save and hold the current scene.\n Are you sure?") then
			(
				max hold
				btnRestore.enabled = true
			)
		)
		on btnRestore pressed do
		(
			if (queryBox "You are about discard this scene and import you held scene.\n Are you sure?") then
				max fetch
		)
		on btnMask pressed do
		(
			DisableSceneRedraw()
			_orgSelection = ($selection as array)
			deselect $
			select _ttSelection
			$.material = _matSelected
			max select invert
			$.material = _matUnselected
			deselect $
			select _orgSelection
			EnableSceneRedraw()
		)
		on btnSelVisible pressed do
		(
			DisableSceneRedraw()
			_orgSelection = ($selection as array)
			deselect $
			select _ttSelection
			$.primaryVisibility = on
			max select invert
			$.primaryVisibility = off
			deselect $
			select _orgSelection
			EnableSceneRedraw()
		)
		on btnSelArray pressed do
		(
			GetSelectionArray()
			UpdateListbox()
		)
		on btnMatte pressed do
		(
			DisableSceneRedraw()
			_orgSelection = ($selection as array)
			deselect $
			_r.options_overrideMtl_on = true
			_r.options_overrideMtl_mtl = _matMatte
			_r.excludeListOverrideMtl = #()
			_r.excludeListOverrideMtl = _ttSelection
			
			_effects = numAtmospherics 
			if _effects > 0 then
			(
				for i = 1 to _effects do
				(
					_type = getAtmospheric i
					if (_type as string) == "VRayToon:VRayToon" then
					(
						if (queryBox "Atmospheric Effect VRayToon found.\n Want to add unselected to the exlude list?\nRemoves cartoon lines etc. on unselected") then
						(
							for obj in _ttSelection do
							(
								select _ttSelection
								max select invert
								_tempArray = ($selection as array)
								for obj in _tempArray do 
									append _type.excludeList obj
							)
						)
							
					)
				)
			)
			select _orgSelection
			EnableSceneRedraw()
		)
	)

	SetupDefaultMats()
	CreateDialog ttMaskTools
)