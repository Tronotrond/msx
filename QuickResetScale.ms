/******************************************************************
**
**	Quick Reset Scale	-	TH2014
**
**	A quicker modified version of Paul Neales ResetXform script
**	for larger scenes. 
**
** Reset scale on all objects, but preserves pivot point. 
** No extra magic...
**
*****************************************************************/

	parent=undefined 	--Temporarily store the parent object.
	children=#()		--Temporarily store the Children.
	
	/************************************************
	Set the bias scale for mirrored matrix values when using Preserve Orientation. 
	************************************************/
	fn getBiasOrientation=
	(
		case biasOrientation of
		(
			1: [-1,-1,1]
			2: [-1,1,-1]
			3: [1,-1,-1]	
		)	
	)
	
	/************************************************
	Returns if a matrix is #right or #left handed
	Returns a name value.
	************************************************/
	fn getHandedMatrix tm =
	(
		x=normalize tm[1] 
		y=normalize tm[2] 
		z=normalize tm[3] 
		an=(dot (cross x y ) z)
		hand=if an>=0 then #right else #left
	)
	
	/*
	These two functions unlink and then relink objects from the hierarchy
		so that the orientation doesn't blow up when they are reset. 
	*/

	
	fn breakHierarchy obj =
	(
	--	format "Parent: % Children: %\n" obj.parent obj.children
		parent=obj.parent
		for c in obj.children do 
		(
			append children c
			c.parent=undefined
		--	format "Child Parent: %\n" c.parent
		)
		obj.parent=undefined
	--	format "Children: %\n" children
	)
	
	fn linkHierarchy obj =
	(
	--	format "Linking to %\n" parent
		obj.parent=parent
		for c in children do c.parent=obj
		parent=undefined
		children=#()
	)

	mapped fn resetXform2 obj =
	(
		--Test if objects are valid incase they have been deleted. 
		--if not (isValidNode obj) then return false
	
		--Unlink hierarchy.
		breakHierarchy obj
	
		--Set the locals. 
		local xFrm=xForm()
		local objTm=obj.objectTransform
		local tm=obj.transform
		local rot=obj.rotation
		
		--Reset all the transforms. 
		obj.Transform=(matrix3 [1,0,0] [0,1,0] [0,0,1] tm.row4)
		obj.objectOffsetPos=[0,0,0]
		obj.objectOffsetRot=(quat 0 0 0 1)
		
		-- orientation should be preserved. 
		--Test if the object has a #right or #left handed matrix. 
		if (getHandedMatrix objTm)==#right then
		(
			obj.rotation=(inverse objTm).rotation
		)
		else
		(
			try (obj.rotation=(inverse objTm*(scaleMatrix (QuickXreset.getBiasOrientation()))).rotation)
				catch()
		)
		
		obj.pivot=tm.row4
		--Add xform modifier and correct orientation and position.
		addModifier obj xFrm
		obj.xform.gizmo.transform=(objTm*inverse obj.objectTransform)
			
		--Relink hierarchy
		linkHierarchy obj
		
	)
	
		rollout QRXF "Quick Reset XForm" width:184 height:144
		(
			label lbl1 "This script quickly resets scale on all selected objects but preserves pivot and orientation. SAVE BEFORE USING!" pos:[8,8] width:168 height:56
			checkbox chk1 "Collapse Stack" pos:[8,104] width:96 height:16
			button btn1 "GO!" pos:[120,120] width:56 height:16
			label lbl5 "If objects move then snapshot them before running this script" pos:[8,64] width:168 height:32
			checkbox chkUndo "Undo" pos:[8,120] width:56 height:16
		
			on btn1 pressed do
			(
				selectedObjs = selection
				disableSceneRedraw()
				
				for obj in selectedObjs where superclassof obj == geometryClass do
				(	
					if chkUndo.checked == true then
					(
						undo on 
						(		
							resetXform2 obj
					
							if chk1.checked == true do
							(
								collapseStack obj
							)
						)
					)
					else 
					(
						undo off 
						(
							resetXform2 obj
					
							if chk1.checked == true do
							(
								collapseStack obj
							)
						)
					)
				)
				
			enableSceneRedraw()
				
			)
		)
	try (destroyDialog "QRXF") catch()
		createDialog QRXF
