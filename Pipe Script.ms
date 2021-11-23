/*
Things To add:
- Denis collision methods
- Option for collision rotation exit
- Error check for delete scene node/update list
*/

try(destroyDialog rlPipeGen)catch()
rollout rlPipeGen "Pipes Generator"
(
	local grpRig = 25
	local grpPipes = 270
	local grpTools = 175
	local pipeList = #()	
	local iconsFile = #("$scripts/JokerMartini/PipeIconStrip.bmp","$scripts/JokerMartini/PipeIconStripAlpha.bmp")
	local rots = #(-90,-45,0,45,90,180)
	local trgObj = undefined

	groupbox gpPipeRigCtrls "Pipe Rig Templates:" width:200 height:165 pos:[10,grpRig-20]
 		label lbCtrlSize "Size:" pos:[20,grpRig]
		spinner spCtrlSize "" width:90 pos:[110,grpRig] range:[.1,9999999,(units.decodevalue "0.5m")] type:#worldUnits
 		label lbAddToLayer "Add to layer:" pos:[20,grpRig+20]
 		edittext etLayerName "" width:95 pos:[106,grpRig+20] text:"Pipe_ctrls"
		label lbAutoLinkRig "Auto link selection at rig creation:" pos:[20,grpRig+42] tooltip:"CHECKED: Will link all selected objects to the 'Start' control point helper."
		checkbox ckAutoLinkRig "" pos:[185,grpRig+42] checked:true tooltip:"CHECKED: Will link all selected objects to the 'Start' control point helper."
		button btnPipeA "St8" height:30 width:30 pos:[20,grpRig+65] images:#(iconsFile[1], iconsFile[2], 9,1,1,1,1 ) tooltip:"STRAIGHT: pipe includes 1 open end"
		button btnPipeB "T 90°" height:30 width:30 pos:[57,grpRig+65] images:#(iconsFile[1], iconsFile[2], 9,3,3,1,1 ) tooltip:"T: shaped pipe rotated 90° includes 2 open ends"
		button btnPipeC "T" height:30 width:30 pos:[94,grpRig+65] images:#(iconsFile[1], iconsFile[2], 9,2,2,1,1 ) tooltip:"T: shaped pipe includes 2 open ends"
		button btnPipeD "X" height:30 width:30 pos:[131,grpRig+65] images:#(iconsFile[1], iconsFile[2], 9,4,4,1,1 ) tooltip:"CROSS: shaped pipe includes 3 open ends"
		button btnPipeE "90°" height:30 width:30 pos:[168,grpRig+65] images:#(iconsFile[1], iconsFile[2], 9,5,5,1,1 ) tooltip:"CURVE 90°: angle inlcudes 1 open end"
		button btnPipeF "45°" height:30 width:30 pos:[20,grpRig+102] images:#(iconsFile[1], iconsFile[2], 9,6,6,1,1 ) tooltip:"CURVE 45°: angle includes 1 open end"
		button btnPipeG "Fork" height:30 width:30 pos:[57,grpRig+102] images:#(iconsFile[1], iconsFile[2], 9,7,7,1,1 ) tooltip:"FORK: pipe includes 2 open ends"
		button btnPipeH "Y" height:30 width:30 pos:[94,grpRig+102] images:#(iconsFile[1], iconsFile[2], 9,8,8,1,1 ) tooltip:"Y: shaped pipe includes 2 open ends"
		button btnPipeI "End" height:30 width:30 pos:[131,grpRig+102] images:#(iconsFile[1], iconsFile[2], 9,9,9,1,1 ) tooltip:"END CAP: gets used as the object to close any pipe"
	groupbox gpPipes "Pipes:" width:200 height:266 pos:[10,grpPipes]
		multilistbox lstPipes "" items:#() width:130 height:10 pos:[20,grpPipes+20]
		button btnAdd "+" height:68 width:50 pos:[150,grpPipes+20]
		button btnRemove "-" height:67 width:50 pos:[150,grpPipes+88]
		label lbRandRot "Rotate range:" pos:[20,grpPipes+165]
		spinner spRotMin "" fieldwidth:40 range:[0,360,0] type:#float pos:[90,grpPipes+165]
		spinner spRotMax "-" fieldwidth:40 range:[0,360,360] type:#float pos:[143,grpPipes+165]
		label lbRotStep "Rotate Step:" pos:[20,grpPipes+190]
		spinner spnRotStep "" fieldwidth:40 range:[1,360,15] type:#float pos:[147,grpPipes+190]
		label lbBuild "Build:" pos:[20,grpPipes+215]
		radiobuttons rbBuildType "" labels:#("Free flow","To target") pos:[55,grpPipes+215]
		label lbTarget "Target:" pos:[20,grpPipes+240]
		pickbutton pbTarget "PICK TARGET OBJECT" width:140 pos:[60,grpPipes+236] enabled:false
	groupbox gpTools "Tools:" width:200 height:90 pos:[10,grpTools]
		button btnSelectEnds "Select Open Ends" width:180 height:25 pos:[20,grpTools+20]
		label lbQuickRotate "Quick Rotate:" pos:[20,grpTools+60]
		button btnRotA "15°" width:30 height:30 pos:[94,grpTools+52] tooltip:"Left-click rotates 15°, Right-click rotates -15°."
		button btnRotB "45°" width:30 height:30 pos:[132,grpTools+52] tooltip:"Left-click rotates 45°, Right-click rotates -45°."
		button btnRotC "90°" width:30 height:30 pos:[170,grpTools+52] tooltip:"Left-click rotates 90°, Right-click rotates -90°."
	button btnInstructions "?" width:30 height:30 pos:[10,545] 
	button btnGenPipes "Generate Pipes" width:170 height:30 pos:[40,545]
	
	
	/*///////////////// Moves Nodes to Layer //////////////////////////*/
	fn fnObjectsToLayer str nodes: = (--Places supplied nodes to given layer
		if nodes == unsupplied do nodes = #()
		layers = for i = 1 to LayerManager.count - 1 collect (LayerManager.getLayer i).name
		theLayer = if findItem layers str != 0 then (LayerManager.getLayerFromName str)else(layermanager.newLayerFromName str)
		for obj in nodes do (theLayer.addNode obj)
	)
	
	/*///////////////// Hierarchy Functions //////////////////////////*/
	fn fnGetParents nodes: = ( --return the top most parent nodes within selected objects
		if nodes == unsupplied do nodes = #()
		local parentNodes = #()
		
		for i = 1 to nodes.count do (
			o = nodes[i]
			if isvalidnode o do (--Check if the node passed to the function is a valid node.
				while o.parent != undefined do o = o.parent --Loop through the hierarchy until the current node's parent is undefined (i.e. rootnode)
				append parentNodes o --Return the rootnode
			)
		)
		makeUniqueArray parentNodes
		parentNodes
	)

	/*///////////////// Rotation Functions //////////////////////////*/
	fn setNodeWorldRotation theNode theRot = (in coordsys (transmatrix theNode.transform.pos) theNode.rotation = theRot) --sets rotation in world space
	fn setNodeLocalRotation theNode theRot = (in coordsys local rotate theNode theRot) --sets rotation in local object space
		
	/*///////////////// End Point Helper Creation //////////////////////////*/
	fn fnCreateEndCtrl parent: pos:[0,0,0] rot:(eulerangles 0 0 0) = (
		ctrl = point cross:true box:false centerMarker:false axisTripod:true wirecolor:yellow name:(uniqueName "pipeEnd_") size:(spCtrlSize.value/2) parent:parent pos:pos
		setNodeWorldRotation ctrl rot
		ctrl
	)
	
	/*///////////////// Rig Template Creation //////////////////////////*/	
	fn fnCreatePipeRig type:1 layerName: = (		
		local rigCtrls = #()
		ctrlSize = spCtrlSize.value
		
		if (s = selection).count >= 1 then
		(
			pStart = [s.center.x,s.center.y,s.min.z]
			pEnd = [s.center.x,s.center.y,s.max.z]
			tmMax = s.max
			tmMin = s.min
		)
		else
		(
			pStart = [0,0,0]
			pEnd = [0,0,ctrlSize*3]
			tmMax = [ctrlSize*3,ctrlSize*3,ctrlSize*3]
			tmMin = -[ctrlSize*3,ctrlSize*3,ctrlSize*3]
		)
		
		pName = #("Straight","TShaped","TShaped","Cross","90Curve","45Curve","Fork","YShaped","EndCap")
 		append rigCtrls (ctrlStart = point name:(uniqueName ("pipe" + pName[type] +"_Start_")) cross:true box:true centerMarker:false axisTripod:false wirecolor:green size:ctrlSize pos:pStart) --required minimum helper
		
		case type of
		(
			1: ( --Straight
				append rigCtrls (ctrlEndA = fnCreateEndCtrl parent:ctrlStart pos:pEnd)
			)
			2: ( --T Shaped 90°
				append rigCtrls (ctrlEndA = fnCreateEndCtrl parent:ctrlStart pos:pEnd)
				append rigCtrls (ctrlEndB = fnCreateEndCtrl parent:ctrlStart pos:[tmMax.x,pStart.y,pEnd.z/2] rot:(eulerangles 0 -90 0))
			)			
			3: ( --T Shaped
				append rigCtrls (ctrlEndA = fnCreateEndCtrl parent:ctrlStart pos:[tmMax.x,pStart.y,pEnd.z] rot:(eulerangles 0 -90 0))
				append rigCtrls (ctrlEndB = fnCreateEndCtrl parent:ctrlStart pos:[tmMin.x,pStart.y,pEnd.z] rot:(eulerangles 0 90 0))
			)
			4:( --Cross
				append rigCtrls (ctrlEndA = fnCreateEndCtrl parent:ctrlStart pos:pEnd)
				append rigCtrls (ctrlEndB = fnCreateEndCtrl parent:ctrlStart pos:[tmMax.x,pStart.y,pEnd.z/2] rot:(eulerangles 0 -90 0))
				append rigCtrls (ctrlEndC = fnCreateEndCtrl parent:ctrlStart pos:[tmMin.x,pStart.y,pEnd.z/2] rot:(eulerangles 0 90 0))
			)
			5:( --90° Curve Corner
				append rigCtrls (ctrlEndA = fnCreateEndCtrl parent:ctrlStart pos:[tmMax.x,pStart.y,pEnd.z] rot:(eulerangles 0 -90 0))
			)
			6:( --45° Curve Corner
				append rigCtrls (ctrlEndA = fnCreateEndCtrl parent:ctrlStart pos:[tmMax.x,pStart.y,pEnd.z] rot:(eulerangles 0 -45 0))
			)
			7:(--Fork
				append rigCtrls (ctrlEndA = fnCreateEndCtrl parent:ctrlStart pos:pEnd)
				append rigCtrls (ctrlEndB = fnCreateEndCtrl parent:ctrlStart pos:[tmMax.x,pStart.y,pEnd.z] rot:(eulerangles 0 -45 0))
			)
			8:( --Y Shaped
				append rigCtrls (ctrlEndA = fnCreateEndCtrl parent:ctrlStart pos:[tmMax.x,pStart.y,pEnd.z] rot:(eulerangles 0 -45 0))
				append rigCtrls (ctrlEndB = fnCreateEndCtrl parent:ctrlStart pos:[tmMin.x,pStart.y,pEnd.z] rot:(eulerangles 0 45 0))
			)
			9:()-- End Cap
		)
		
		if ckAutoLinkRig.state do (for o in (fnGetParents nodes:(selection as array)) do o.parent = ctrlStart) --rig selection to pipe start control 
 		fnObjectsToLayer layerName nodes:rigCtrls --Add all pipe rig controls to desired layer
	)
	
	/*///////////////// Checks to make sure the node meets the required specifications //////////////////////////*/
	fn checkStart node = (if classof node == Point AND findString node.name "Start" != undefined then true else false)
	
	/*///////////////// Add selected pipe objects to list //////////////////////////*/
	fn fnAddItmsLst lst arr = ( -- add Objects to list if they meet requirements
		curSel = getCurrentSelection() as array
		tmpArr = for p in curSel where (checkStart p) collect p
		
		if tmpArr.count >= 1 do
		(
			for o in tmpArr do (appendIfUnique arr o)
			lst.items = for i in arr collect i.name
		)
	)
	
	/*///////////////// Removes selected list items from list //////////////////////////*/
	fn fnRemoveItmsLst lst arr = ( -- remove objects from list
		local currSel = lst.selection
		for i = lst.items.count to 1 by -1 where currSel[i] do (deleteItem arr i)
		lst.items = for i in arr collect i.name
		lst.selection = #{}
	)
	
	/*///////////////// Gets the end nodes from selected hierarchy //////////////////////////*/
	mapped fn getEndChildren node selectNodes:off ends:#() root:on = if not isvalidnode node then ends else 
	(
		if root or node.children.count > 0 then for child in node.children do getEndChildren child ends:ends root:off
		else if iskindof node Point AND findString node.name "End" != undefined do appendifunique ends node
		if selectNodes do select ends
		ends
	)
	
	/*///////////////// Rotate object towrads target object //////////////////////////*/
	fn getBestRotation block target step:15 =
	(
		fn getAngle dir vector = 
		(
			local up = [0,0,1]
			ang = acos (dot dir vector)
			if dot (cross dir up) (cross vector up) < 0 do ang += 180
			ang
		)
		
		local end = (getEndChildren block)[1] --the node that gets it's vector and position used for calculations
		local origin = block.transform
		local vector = normalize (target.pos - end.pos) 
		local dist = getAngle end.dir vector, best = 0
		for angle= spRotMin.value to spRotMax.value by step do 
		(
			block.transform = prerotatez block.transform step
			if (d = getAngle end.dir vector) < dist do
			(
				dist = d
				best = angle
			)
		)
		block.transform = prerotatez origin best
	)

	/*///////////////// MAIN Pipe generation function //////////////////////////*/
	fn fnGeneratePipes = (
		if (rlPipeGen.lstPipes.selection as array).count  >= 1 then (		
			
			openEnds = #()
			pts = if selection.count >= 1 then (for o in selection collect o) else #(circle name:(uniqueName "PipeSystem_") size:(spCtrlSize.value*2) wirecolor:yellow render_renderable:false render_displayRenderMesh:false) --use selected objects transforms else use the origin
				
			for o in pts do (
				--Randomly choose a pipe based on the list selection
				items = rlPipeGen.lstPipes.selection as array
				idx = items[random 1 items.count]
				_pipe = pipeList[idx]
				
				--Randomly choose a rotation value based on range/steps
				v = random spRotMin.value spRotMax.value
				v = ceil(v/spnRotStep.value)*spnRotStep.value
				
				maxOps.cloneNodes _pipe expandHierarchy:true cloneType:#copy actualNodeList:&refPipes newNodes:&newPipes
				pipeCtrl = newPipes[1]
				
				if rbBuildType.state == 2 AND isValidNode trgObj then 
				(
					pipeCtrl.transform = copy o.transform
					getBestRotation pipeCtrl trgObj step:spnRotStep.value
				)
				else
				(
					pipeCtrl.transform = copy (prerotatez o.transform v)
				)
  				for p in newPipes where (checkStart p) do p.parent = o --link children
				
				join openEnds newPipes 
			)
			clearSelection()
			getEndChildren openEnds selectNodes:on
			if selection.count < 1 do messagebox "You pipe system has ended. Click 'Generate Pipes' to create another pipe system."
		)
		else messagebox "Select at least one or more items in the list in order to generate objects."
	)
	
	on spCtrlSize changed val do (for o in selection where classof o == Point do o.size = val)
	on btnPipeA pressed do (fnCreatePipeRig type:1 layerName:etLayerName.text)
	on btnPipeB pressed do (fnCreatePipeRig type:2 layerName:etLayerName.text)
	on btnPipeC pressed do (fnCreatePipeRig type:3 layerName:etLayerName.text)
	on btnPipeD pressed do (fnCreatePipeRig type:4 layerName:etLayerName.text)
	on btnPipeE pressed do (fnCreatePipeRig type:5 layerName:etLayerName.text)
	on btnPipeF pressed do (fnCreatePipeRig type:6 layerName:etLayerName.text)
	on btnPipeG pressed do (fnCreatePipeRig type:7 layerName:etLayerName.text)
	on btnPipeH pressed do (fnCreatePipeRig type:8 layerName:etLayerName.text)
	on btnPipeI pressed do (fnCreatePipeRig type:9 layerName:etLayerName.text)
	on btnAdd pressed do (fnAddItmsLst lstPipes pipeList)
	on btnRemove pressed do (fnRemoveItmsLst lstPipes pipeList)
	on btnSelectEnds pressed do (getEndChildren selection selectNodes:on)
	on btnRotA pressed do (setNodeLocalRotation selection (eulerangles 0 0 15))
	on btnRotA rightclick do (setNodeLocalRotation selection (eulerangles 0 0 -15))
	on btnRotB pressed do (setNodeLocalRotation selection (eulerangles 0 0 45))
	on btnRotB rightclick do (setNodeLocalRotation selection (eulerangles 0 0 -45))
	on btnRotC pressed do (setNodeLocalRotation selection (eulerangles 0 0 90))
	on btnRotC rightclick do (setNodeLocalRotation selection (eulerangles 0 0 -90))
	on lstPipes doubleclicked itm do (fnGeneratePipes())
	on btnGenPipes pressed do (fnGeneratePipes())
	on pbTarget picked obj do (
		trgObj = obj
		pbTarget.text = if obj != undefined then obj.name else "PICK TARGET OBJECT"
	)
	on rbBuildType changed state do (pbTarget.enabled = if state == 2 then true else false)
)
createDialog rlPipeGen 220 585 style:#(#style_SysMenu, #style_ToolWindow)