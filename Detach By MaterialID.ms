/*//////////   SCRIPT:   Detach By MID v1.0  //////////*/
/*//////////   WRITTEN BY:   Branko Zivkovic   //////////*/
/*//////////   EMAIL:   barigazy@hotmail.com   //////////*/
try(destroyDialog ::bgaRoll)catch()
rollout bgaRoll "Detach By MID"
(
	checkbox cb_wire "Randomize Wirecolor" pos:[5,5] width:120 checked:on
	checkbox cb_pivot "Place Pivot At Center" pos:[5,25] width:120 checked:on
	button btn_detach "Detach By MID" pos:[5,45] width:120 height:18
	
	fn hold mode str: =
	(
		case mode of
		(
			#start: if not thehold.holding() then thehold.begin() else (thehold.cancel() ; thehold.begin())
			#accept: if thehold.holding() do thehold.accept str
			#cancel: if thehold.holding() do thehold.cancel()
			#suspend: if not theHold.IsSuspended() do theHold.Suspend()
			#resume: if theHold.IsSuspended() do theHold.Resume()
		)
	)
	fn sortByNumberset arr1 arr2 type: maxtomin: =
	(
		local first = arr1[2].numberset, second = arr2[2].numberset
		case of (
			(first < second): if not maxtomin then -1 else 1
			(first > second): if not maxtomin then 1 else -1
			default:0
		)
	)	
	fn collectFaceID node sorted:on = 
	(
		local nodeFaces = #{1..node.numfaces}, collection = #()
		getFaceMatID = polyop.getFaceMatID
		while not nodeFaces.isEmpty do
		(
			BooleanClass = on
			for f in nodeFaces while BooleanClass do 
			(
				e = getFaceMatID node f
				node.selectByMaterial e clearCurrentSelection:on
				bits = node.selectedfaces as bitarray
				nodeFaces -= bits ; append collection #(e,bits) ; BooleanClass = off
			)
		) ; node.selectedfaces = #()
		if sorted do qsort collection sortByNumberset maxtomin:on
		collection
	)
	fn detachElements node = if isValidNode node do
	(
		clearSelection() 
		polyop.collapseDeadStructs node ; polyop.deleteIsoVerts node
		deleteFaces = polyop.deleteFaces ; object = #(node) ; 
		if (array = collectFaceID node).count > 1 do
		(
			for e = 1 to array.count-1 do append object (copy node)
			number = for i = 1 to array.count do
			(
				float = #{}
				for j = 1 to array.count where j != i do float += array[j][2]
				deleteFaces object[i] float delIsoVerts:on
			)
		) ; free array ; gc()
		if cb_wire.checked do for o in object do o.wirecolor = (e = random black white ; e.s *= 1.5 ; e)
		if cb_pivot.checked do for o in object do CenterPivot o
	)
	
	on btn_detach pressed do
	(
		if selection.count != 1 then messageBox "Select en Editable Poly object!" title:"Warning" beep:off else
		(
			if not isKindOf (node = selection[1]) Editable_Poly then messageBox "Select en Editable Poly object!" title:"Warning" beep:off else
			(
				if GetCommandPanelTaskMode() != #create do SetCommandPanelTaskMode #create
				hold #start
				with redraw off (detachElements node ; gc light:on)
				hold #accept str:"Detach By MID"
			)
		)
	)
)
createDialog bgaRoll 130 65 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)