try (destroyDialog IDRoll) catch()


function setIDs obj faceselect mat =
(
	selected = faceselect as bitarray
	if selected == undefined then
		messagebox "No faces selected"
	else
	(
	-- set Material ID
		case classOf obj of
		(
			Editable_mesh: 
			(
				convertToPoly(obj)
				polyop.setFaceMatID obj selected mat
			)
			Editable_Poly: 
			(
				polyop.setFaceMatID obj selected mat
			)
			default: 
			(
				format "Non poly or mesh object!\n"
				format obj.name
				format "\n\n"
			)
		)
	)
)


rollout IDRoll "NOV MatID Changer" width:208 height:120
(
	label lbl1 "TH NOV ID CHANGER v1.0" pos:[40,0] width:136 height:16
	spinner spn1 "" pos:[15,24] width:47 height:16 range:[1,99,1] type:#integer scale:1
	button btnSelect "SelectID" pos:[72,24] width:56 height:14
	button btnSetID "Set ID" pos:[136,24] width:56 height:14
	checkbox chk1 "Warn if ID exsist" pos:[16,48] width:176 height:16
	checkbox chk2 "Swap ID (Old ID <-> New ID)" pos:[16,64] width:176 height:16 checked:true
	button btnList "List IDs" pos:[136,88] width:56 height:16
	

	on btnSelect pressed do
	(
		undo on 
		(
			obj = selection[1] 
			if ClassOf obj != Editable_Poly do
				convertToPoly(obj)
			
			max modify mode
			subObjectLevel = 4
			newFaceSel = #() 
			for f = 1 to obj.numfaces do
			if polyop.getFaceMatID obj f == spn1.value do 
			(
				append newFaceSel f
			)
			setFaceSelection obj newFaceSel --set the selection
		)
	)
	on btnSetID pressed do
	(
		objs = selection[1] 
		if ClassOf objs != Editable_Poly do
			convertToPoly(objs)
		selFaces = #()
		selFaces = polyop.getFaceSelection objs
				
		undo on
		(
			if chk1.checked == true AND chk2.checked == false then -- Warn if ID user is about to set already exsist
			(
				--print "Chk1.true && Chk2.false"
				check = false
				--tmpValue = selfaces as array
				--if polyop.getFaceMatID objs tmpValue[1]  == spn1.value do  -- If true
				for f = 1 to objs.numfaces do 
					if polyop.getFaceMatID objs f  == spn1.value then
					(
						Messagebox "ID you are about to set already exsist on object! Not changing.."
						check = true
						-- Have to add ok/cancel option
						break
					)
				if check == false do
				(
					setIDs objs selFaces spn1.value
				)
			
			)
			else if chk1.checked == false AND chk2.checked == true then	-- Warn off - Swap on
			(
				--print "Chk1.false && Chk2.true"
				if subObjectLevel == 4 OR subObjectLevel == 5 do -- Make sure user is in subobject mode
				(
					tmpValue = selfaces as array
					oldID = polyop.getFaceMatID objs tmpValue[1]
					newFaceSel = #() 
					for f = 1 to objs.numfaces do -- get old face IDs
					(
						if polyop.getFaceMatID objs f == spn1.value do  
						(
							append newFaceSel f
						)
					)
					--setFaceSelection obj newFaceSel  -- select faces found
					setIDs objs newFaceSel 99
					--setFaceSelection obj selFaces -- Then select user selected faces again
					setIDs objs selFaces spn1.value	-- swap new and old selected IDs
					--setFaceSelection obj newFaceSel 
					setIDs objs newFaceSel oldID
					setFaceSelection objs selFaces  -- and select back to user selected faces again for good meassure
					outString = "Swapped ID " + (oldID as string) + " with " + (spn1.value as string)
					print outString
				)
					
			)
			else if subObjectLevel == 4 OR subObjectLevel == 5 then-- Make sure user is in subobject mode
			(
				print "Hngf!"
				setIDs objs selFaces spn1.value
			)
		) -- Undo off
	)
	on btnList pressed do 
	(
		objs = selection[1] 
		newFaceSel = #() 
		for f = 1 to objs.numfaces do -- get old face IDs
		(
			id = polyop.getFaceMatID objs f
			appendifunique newFaceSel id
		)
		outString = "MatIDs on " + objs.name + ": " + newFaceSel as string
		messageBox outString
	)
	
)

createDialog IDRoll
