/*****************************************
**
**	Object ID manager tool v2.0
**	Trond Hille 2015-2016
**	tronotrond@gmail.com
**
**	last changed 	2016/04/21
**
**	changelog:
**		v1.01	- Changed undefined IDs from 0 to 100 to prevent color "bugs" on the element
**		v2.0	- Redefined GUI
**				- Added Increase ID functions
**		
*****************************************/


(
	local _selectionArray = #()
	local _collectionArray = #()
	local _allSceneIDs = #()

	-- Gets selected shapes and geometry
	fn GetSelection = 
	(
		_selectionArray = #()
		_tmpArray = #()
		
		_selectionArray =  for o in selection where superClassOf o == geometryClass collect o 
		_tmpArray = for o in selection where superClassOf o == Shape collect o
		join _selectionArray _tmpArray 
		--print _selectionArray
		-- filter out non-mesh items
		
	)
	
	fn SelectObjById Id =
	(
		Max select none
		_tmpArray = #()
		_collectionArray = #()
		
		_tmpArray = geometry
		
		for o in _tmpArray do
		(
			if o.gbufferchannel == Id do
				append _collectionArray o
		)
		
		select _collectionArray
		
		if _collectionArray.count > 1 then
			print "Objects selected!"
		else
			print "No objects with ID found"
	)
	
	fn ClearAllObjId =
	(
		for o in geometry do
			o.gbufferchannel = 0
	)
	
	fn SetObjIdOnSelection id = 
	(
		for i in _selectionArray do
			i.gbufferchannel = id
		
		printstring = "Set Object ID " + (id as string) + " to selected objects"
		print printstring
	)
	
	fn ClearMultiMatteElements = 
	(
		_elementsArray = #()
		
		re = maxOps.GetCurRenderElementMgr() -- get the current render element manager

		for n = 1 to re.numrenderelements() do
		(
			element = re.getRenderElement(n-1)
			if classOf element == MultiMatteElement do
			(
				append _elementsArray element
			)
		)
		
		for e in _elementsArray do
			re.RemoveRenderElement(e)
		
		tmpString = "Removed " + _elementsArray.count as string + " MultiMatte Render Elements..."
		print tmpString

	)
	
	fn ListAllIds =
	(
		_tmpArray = geometry
		_allSceneIDs = #()
		
		for obj in _tmpArray do
			if obj.gBufferChannel != 0 do
				appendifunique _allSceneIDs obj.gBufferChannel
			
		sort _allSceneIDs
	)
	
	fn NextAvailableID list = 
	(
		for i = 1 to list.count do
		(
			if list[i] == i then ( continue )
			else
			( return i )
		)
		return (list.count + 1)
	)
	
	fn AddMultiMattes =
	(
		_tmpArray = geometry
		_idArray = #()
		
		for obj in _tmpArray do
			if obj.gBufferChannel != 0 do
				appendifunique _idArray obj.gBufferChannel
		
		tmpString = _idArray.count as string + " unique ObjectIDs found!"
			
		sort _idArray
		print tmpString
		
		re = maxOps.GetCurRenderElementMgr()
		
		_Ids = _idArray.count / 3.0
		_elementsNeeded = ceil _Ids as integer
			
		elementCounter = 0
		
		for count = 1 to _elementsNeeded do
		(
			nameString = "TH_MultiMat_" + count as string
			
			id1 = _idArray[1+elementCounter]
			id2 = _idArray[2+elementCounter]
			id3 = _idArray[3+elementCounter]
			
			if id1 == undefined then
				id1 = 100
			if id2 == undefined then
				id2 = 100
			if id3 == undefined then
				id3 = 100
			
			re.AddRenderElement (MultiMatteElement elementname:nameString  R_gbufID:id1 R_gbufIDOn:(on) G_gbufID:id2 G_gbufIDOn:(on) B_gbufID:id3 B_gbufIDOn:(on))
			
			elementCounter += 3
		)
	)
	rollout ListIDs "Scene IDs" width:104 height:256
	(
		listbox 'lbxIDs' "Scene ObjectIDs" pos:[8,8] width:88 height:16 align:#left
		
		on lbxIDs selected changed do
		(
			idSelected = lbxIDs.items[lbxIDs.selection] as integer
			print ("Selecting all objects with ID: " + idSelected as string)
			SelectObjById(idSelected)
		)
		
	)

	rollout ObjID "V-Ray Multimatte/Object ID Handler v2.0" width:296 height:80
	(
		spinner 'spn1' "" pos:[16,8] width:72 height:16 range:[0,65535,0] type:#integer align:#left
		
		button 'btnSetID' "Set ID" pos:[96,8] width:72 height:16 align:#left
		button 'btnSelectByID' "Select by ID" pos:[96,32] width:72 height:16 align:#left
		spinner 'spn2' "" pos:[16,32] width:72 height:16 range:[0,65535,0] type:#integer align:#left
		button 'btnClearAll' "Reset All IDs" pos:[96,56] width:72 height:16 align:#left
		button 'btnListIDs' "List All IDs" pos:[208,32] width:72 height:16 align:#left
		button 'btnSetupLayers' "Setup Layers" pos:[208,56] width:72 height:16 align:#left
		button 'btnIncrement' "+" pos:[176,8] width:16 height:16 align:#left
		checkbox 'chk1' "Use next available ID" pos:[200,0] width:104 height:32 checked:true align:#left
		button 'btnSelInc' "+" pos:[176,32] width:16 height:16 align:#left
		
		on btnIncrement pressed do
		(
			if chk1.checked then
			(
				_ids = ListAllIds()
				_val = NextAvailableID(_ids)
				spn1.value = _val
				GetSelection()
				SetObjIdOnSelection(spn1.value)				
			)
			else 
			(
				spn1.value = spn1.value + 1
				GetSelection()
				SetObjIdOnSelection(spn1.value)
			)
		)
		
		on btnSetID pressed do
		(
			GetSelection()
			SetObjIdOnSelection(spn1.value)
		)
		on btnSelectByID pressed do
		(
			SelectObjById(spn2.value)
		)
		on btnSelInc pressed do
		(
			spn2.value = spn2.value + 1
			SelectObjById(spn2.value)
		)
		
		
		on btnClearAll pressed do
		(
			if queryBox "This will set all Object IDs back to zero! Confirm?" beep:false then
				ClearAllObjId()
		)
		on btnListIDs pressed do
		(
			ListAllIds()
			CreateDialog ListIDs
			stringList = #()
			
			for i = 1 to _allSceneIDs.count do
				stringList[i] = _allSceneIDs[i] as string
			
			ListIDs.lbxIDs.items = stringList
		)
		on btnSetupLayers pressed do
		(
			if queryBox "Do you also want to delete all existing MultiMatte elements?" beep:true then
			(
				ClearMultiMatteElements()
			)
			AddMultiMattes()
		)
	)
	
	


	CreateDialog ObjId
)-- End of local sc