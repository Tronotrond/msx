/**********************************************
	WireColor2Mtl v1.0
	Trond Hille 2016 - tronotrond@gmail.com

	Copies selected material on to all objects, keeping 
**********************************************/
(
	_shaderToUse
	_allObjects = #()
	_theMaterials = #()
		
	fn CollectObj unshadedOnly = 
	(
		if unshadedOnly then
		(
			for obj in objects where obj.material == undefined do
				append _allObjects obj
		)
		else
		(
			_allObjects = objects
		)
	)

	tt_wire2mtl =
	(
		rollout tt_wire2mtl "WireColor 2 Diffuse" width:128 height:168
		(
				
			pickbutton 'btnMtl' "ObjWithShader" pos:[8,104] width:112 height:24 toolTip:"Select Object with the shader (settings) you want to copy" align:#left
			button 'btnGo' "Go" pos:[8,136] width:112 height:24 enabled:false align:#left
			label 'lbl1' "Drag and drop your base material with the settings you want." pos:[8,8] width:112 height:48 align:#left
			checkbox 'chkAll' "Objects with no materials only" pos:[8,72] width:112 height:32 checked:true align:#left
		
			on btnMtl picked mtl do
			(
				if IsKindOf mtl.material Material then
				(
					btnGo.enabled = true
					_shaderToUse = copy mtl.material
					myString = "Copied " + _shaderToUse as string + " to buffer. Ready to populate..."
					print myString
					btnMtl.text = mtl.name
				)
				else 
				(
					btnGo.enabled = false
					messageBox "No material on object" title:"Try again.."
				)
			)
			
			on btnGo pressed do
			(
				CollectObj chkAll.checked
				instanceCount = 0
				--compareString = ""
				undo on
				(
					_theMaterials = #()
					for obj in _allObjects do
					(
						_theColor = obj.wirecolor
						_theMat = undefined
						
						if _theMaterials.count == 0 then
						(
							print "Adding first material to array..."
							_theMat = copy _shaderToUse
							_theMat.diffuse = _theColor
							append _theMaterials _theMat
							_theMat.name ="ttMat#" + (random 1 135098103957) as string
						)
						else
						(
							
							for mat in _theMaterials do
							(
								--CompareString += mat.diffuse as string + " :: " + _theColor as string + "\n"
								if mat.diffuse as string == _theColor as string then
								(
									_theMat = mat
									instanceCount += 1
								)
							)
							if _theMat == undefined then
							(
								_theMat = copy _shaderToUse
								_theMat.diffuse = _theColor
								append _theMaterials _theMat
								_theMat.name ="ttMat#" + (random 1 135098103957) as string
							)
						)
						obj.material = _theMat
					)
				)
				--print compareString
				myString = "Instance number: " + instanceCount as string
				myString += "\nNumber of materials in Array: " + _theMaterials.count as string
				print myString
				messageBox "All Done!" title:"Completed!"
			)
		)
	)

	fn Initialize =
	(
		createDialog tt_wire2mtl
	)
	
	Initialize()
)