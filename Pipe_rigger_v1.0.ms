------------------------------------------------------
--	Pipe rigging system v1.0
--	Trond Hille 2012
--	tronotrond@gmail.com
--
--	Thanks to HardrockRam@3dhue.com 
--	for math expressions
-------------------------------------------------------


-- Setup variables
p1 = undefined -- Root
p2 = undefined -- Anim Main
p3 = undefined -- Anim Slave
b1 = undefined -- pipe object

-- Default axis and variables, will be changed later
axis = "X"				-- Which axis to use
rotAxis = "Y"			-- Rotation Axis
pipeLength = 100 	-- Pipelength for correct calculations
dummySize = 100	-- Will use width of pipe for now

rotCtrl =""

-- Close script window if already open
global thPipeRig
try(destroyDialog thPipeRig)catch()

-- Check if all necessary objects have been selected
fn checkAllButtons = (
	if (p1 != undefined) and (p2 != undefined) and (p3 != undefined) and (b1 != undefined) then
		thPipeRig.btn5.enabled = true
	
)

-- Check bounding box and return the largest axis dimension
fn getLargestDimAxis obj = (
	--tmpSize = nodeLocalBoundingBox obj	
	tmpSize = obj.max - obj.min

		if (tmpSize[1] > tmpSize[2]) and (tmpSize[1] > tmpSize[3]) then
			return "X"
		else if (tmpSize[2] > tmpSize[1]) and (tmpSize[2] > tmpSize[3]) then
			return "Y"
		else if (tmpSize[3] > tmpSize[1]) and (tmpSize[3] > tmpSize[2]) then
			return "Z"
	
	return false	-- two lagest or all axis are the same size 
)

-- Get the length of the provided axis
fn getAxisSize obj inAxis = (
	-- Get axis sizes
	try(tmpSize = obj.max - obj.min) catch()
		
	if inAxis == "X" then
		return tmpSize[1]
	else if inAxis == "Y" then
		return tmpSize[2]
	else 
		return tmpSize[3]
	
)

fn pivotFix obj = (
-- Pipe object
centerPivot obj
ResetXForm obj -- reset xform on pipe to prevent errors from scaling
WorldAlignPivot obj
convertToPoly obj	-- convert to poly and collapse stack
)


fn thRigDatShiz = (
	dummySize = (dummySize*2)

	p1 = point box:true cross:false  name:"Root" size:(dummySize*2) wirecolor:[0,255,0] pos:b1.transform.position
	p2 = point box:true cross:false  name:"Anim" size:dummySize wirecolor:[0,255,0] pos:b1.transform.position
	p3 = point box:true cross:false  name:"Slave" size:dummySize wirecolor:[0,255,0] pos:b1.transform.position

	-- Move the dummies to each end of the pipe
	tempCode = "p2.pos." + axis + " = b1.transform.position."+ axis +" - (pipelength/2)\n"
	tempCode += "p3.pos." + axis + " = b1.transform.position."+ axis +" + (pipelength/2)\n"
	print tempCode
	execute tempCode
	
	-- Move pipe pivot to one end
	b1.pivot = p3.pivot
	
--Parent
p2.parent = p1
p3.parent = p1
b1.parent = p3

-- Convert pipeLenght to string
pipeLength = pipeLength as string

-- Add controllers
p2.controller.position.controller = position_list()
p2.controller.position.controller.available.controller = position_XYZ()
p2.controller.position.controller.setName 2 "CTRL"
p2.controller.position.controller.setActive  2

p3.controller.position.controller = position_list()
posCtrl = p3.controller.position.controller.available.controller = position_script()
p3.controller.position.controller.setName 2 "SLAVE"

p3.controller.rotation.controller = rotation_list()
p3.controller.rotation.controller.available.controller = euler_XYZ()
p3.controller.rotation.controller.setName 2 "SLAVE"

tmpScript = "rotCtrl = p3.controller.rotation.controller.SLAVE.controller." + rotAxis +"_Rotation.controller = float_script()\n"
execute tmpScript


--Expression
if axis == "Y" then
(
pos = "if master_zPos <" + pipeLength + " then\n"
pos += "(\n"
pos += "A = " + pipeLength + "*" + pipeLength + "\n"
pos += "B = master_zPos * master_zPos\n"
pos += "C = sqrt (A - B)\n"
pos += "\n"
pos += "xPos = 0\n"
pos += "yPos = C - " + pipeLength + "\n"
pos += "zPos = 0\n"
pos += "\n"
pos += "[xPos, yPos, zPos]\n"
pos += ")\n"
pos += "else\n"
pos += "(\n"
pos += "[0,-" + pipeLength + ",master_zPos-" + pipeLength + "]\n"
pos += ")\n"

rot = "if master_zPos < " + pipeLength + " then\n"
rot += "(\n"
rot += "   -degToRad (asin (master_zPos/" + pipeLength + "))\n"
rot += ")\n"
rot += "else\n"
rot += "(\n"
rot += "   -degToRad 90\n"
rot += ")\n"

)
else
(
pos = "if master_zPos <" + pipeLength + " then\n"
pos += "(\n"
pos += "A = " + pipeLength + "*" + pipeLength + "\n"
pos += "B = master_zPos * master_zPos\n"
pos += "C = sqrt (A - B)\n"
pos += "\n"
pos += "xPos = C - " + pipeLength + "\n"
pos += "yPos = 0\n"
pos += "zPos = 0\n"
pos += "\n"
pos += "[xPos, yPos, zPos]\n"
pos += ")\n"
pos += "else\n"
pos += "(\n"
pos += "[0-" + pipeLength + ", 0 ,master_zPos-" + pipeLength + "]\n"
pos += ")\n"

rot = "if master_zPos < " + pipeLength + " then\n"
rot += "(\n"
	rot += "   degToRad (asin (master_zPos/" + pipeLength + "))\n"
	rot += ")\n"
	rot += "else\n"
	rot += "(\n"
	rot += "   degToRad 90\n"
	rot += ")\n"
)

--Add script to controllers
/*
if rotAxis == "X" then 
	axisVal = 1
if rotAxis == "Y" then 
	axisVal = 2
if rotAxis == "Z" then 
	axisVal = 3
	*/
posCtrl.addTarget "master_zPos" p2.controller.position.controller.CTRL[3]
posCtrl.script = pos
rotCtrl.addTarget "master_zPos" p2.controller.position.controller.CTRL[3]
rotCtrl.script = rot 
)



rollout thPipeRig "Pipe Rigger" width:128 height:176
(
	label lbl1 "Pipe Rigging Helper" pos:[18,6] width:117 height:21

	pickbutton btn4 "Select Pipe Mesh" pos:[16,32] width:96 height:24
	button btn5 "Rig Pipe!" pos:[16,64] width:96 height:24 enabled:false	
	label lbl2 "Currently only supports pipes laying straight in the X or Y axis!" pos:[24,104] width:88 height:64
	
	on btn4 picked obj do	-- Object
	(
		-- If user did not cancel picking
		if obj != undefined do
		(
			b1 = obj
			-- display the name of the object on the button:
			btn4.text = obj.name
			--checkAllButtons()
			btn5.enabled = true
		)
	)
	on btn5 pressed do
	(
		undo on (
			pivotFix b1	
			axis = getLargestDimAxis b1
			-- Set rotational axis
			if axis  == "Y" then rotAxis = "X"
			if axis == "Z" then 
			(
				--rotAxis = "Z"
				messageBox "Error! Pipe standing in Z axis?"
				return false
			)
	
			pipeLength = getAxisSize b1 axis
			
			-- Get width from another axis
			if axis == "X" then
				dummySize = getAxisSize b1 "Y"
			else 
				dummySize = getAxisSize b1 "X"
			
			thRigDatShiz()
		)
	)
)

createDialog thPipeRig


