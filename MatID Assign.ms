----------------------------------------
--	Mat ID assigner
--	Trond Hille 2012
--
--
----------------------------------------
/*
macroScript matIDassign
category:"VisualWorks"
tooltip:"Assign Material ID to selected objects"
buttontext:"Material ID assign"
*/
(


global matID
try(destroyDialog matID)catch()

fn assignWireColor wColor = (
	try ($.wirecolor = wColor) catch()
	
)

fn assignShaders IDval = (
	
	objToBeShaded = #()
	

		objs = selection as array

		-- set Material ID
		for a in 1 to objs.count do 
		(
			
			case classOf objs[a] of
			(
				Editable_mesh: (
					convertToPoly(objs[a])
					--fcArr = polyop.getNumFaces objs[a]
					--polyop.SetSelection #Face #{1..fcArr}
					polyop.setFaceMatID objs[a] #all IDval
					append objToBeShaded objs[a]
				)
				Editable_Poly: (
					--fcArr = polyop.getNumFaces objs[a]
					--polyop.SetSelection #Face #{1..fcArr}
					polyop.setFaceMatID objs[a] #all IDval
					append objToBeShaded objs[a]
				)
				default: (
					format "Non poly or mesh object!\n"
					format objs[a].name
					format "\n\n"
					)
				
			)
			
		)
		
				
)



rollout matID "MatIDassigner" width:292 height:404
(
	button btn1 "ID1 - Gul" pos:[16,16] width:112 height:24
	button btn2 "ID2 - Blå" pos:[168,16] width:112 height:24
	button btn3 "ID3 - Hvit" pos:[16,48] width:112 height:24
	button btn4 "ID4 - Rød" pos:[168,48] width:112 height:24
	button btn5 "ID5 - Galvanized" pos:[16,80] width:112 height:24
	button btn6 "ID6 - Brushed Met" pos:[168,80] width:112 height:24
	button btn7 "ID7 - Chrome" pos:[16,112] width:112 height:24
	button btn8 "ID8 - Generic Metal" pos:[168,112] width:112 height:24
	button btn9 "ID9 - Dark Metal" pos:[16,144] width:112 height:24
	button btn10 "ID10 - Diffused Met" pos:[168,144] width:112 height:24
	button btn11 "ID11 - Rubber" pos:[16,176] width:112 height:24
	button btn12 "ID12 - Grating" pos:[168,176] width:112 height:24
	button btn13 "ID13 - Gummislanger" pos:[16,208] width:112 height:24
	button btn14 "ID14 - Grå" pos:[168,208] width:112 height:24
	button btn15 "ID15 - Grating Gutter" pos:[16,240] width:112 height:24
	button btn16 "ID16 - Vindu" pos:[168,240] width:112 height:24
	button btn17 "ID17 - Hvit Gummi" pos:[16,272] width:112 height:24
	button btn18 "ID18" pos:[168,272] width:112 height:24
	button btn19 "ID19" pos:[16,304] width:112 height:24
	button btn20 "ID20" pos:[168,304] width:112 height:24
	button btn21 "ID21" pos:[16,336] width:112 height:24
	button btn22 "ID22" pos:[168,336] width:112 height:24
	button btn23 "ID23" pos:[16,368] width:112 height:24
	button btn24 "ID24" pos:[168,368] width:112 height:24
	
	
	
	on btn1 pressed do
	(
		undo on (
			assignWirecolor([252,103,39] as color)
			assignShaders(1)
		)
	)
	on btn2 pressed do
	(
		undo on (
			assignWirecolor([0,0,255] as color)
			assignShaders(2)		
		)
	)
	on btn3 pressed do
	(
		undo on (
			assignWirecolor([255,255,255] as color)
			assignShaders(3)		
		)
	)
	on btn4 pressed do
	(
		undo on (
			assignWirecolor([255,0,0] as color)
			assignShaders(4)		
		)
	)
	on btn5 pressed do
	(
		undo on (
			assignWirecolor([96,96,96] as color)
			assignShaders(5)		
		)
	)
	on btn6 pressed do
	(
		undo on
		(
			assignWirecolor([64,64,64] as color)
			assignShaders(6)		
		)
	)
	on btn7 pressed do
	(
		undo on (
			assignWirecolor([160,160,160] as color)
			assignShaders(7)		
		)
	)
	on btn8 pressed do
	(
		undo on (
			assignWirecolor([128,128,128] as color)
			assignShaders(8)		
		)
	)
	on btn9 pressed do
	(
		undo on (
			assignWirecolor([32,32,32] as color)
			assignShaders(9)		
		)
	)
	on btn10 pressed do
	(
		undo on (
			assignWirecolor([180,180,180] as color)
			assignShaders(10)		
		)
	)
	on btn11 pressed do
	(
		undo on (
			assignWirecolor([0,0,254] as color)
			assignShaders(11)		
		)
	)
	on btn12 pressed do
	(
		undo on (
			assignWirecolor([113,135,6] as color)
			assignShaders(12)		
		)
	)
	on btn13 pressed do
	(
		undo on (
			assignWirecolor([32,32,32] as color)
			assignShaders(13)		
		)
	)
	on btn14 pressed do
	(
		undo on (
			assignWirecolor([96,96,96] as color)
			assignShaders(14)		
		)
	)
	on btn15 pressed do
	(
		undo on (
			assignWirecolor([46,16,4] as color)
			assignShaders(15)		
		)
	)
	on btn16 pressed do
	(
		undo on (
			assignWirecolor([200,200,200] as color)
			assignShaders(16)		
		)
	)
	on btn17 pressed do
	(
		undo on (
			assignWirecolor([130,120,110] as color)
			assignShaders(17)		
		)
	)
	on btn18 pressed do
	(
			assignShaders(18)		
	)
	on btn19 pressed do
	(
			assignShaders(19)		
	)
	on btn20 pressed do
	(
			assignShaders(20)		
	)
	on btn21 pressed do
	(
			assignShaders(21)		
	)
	on btn22 pressed do
	(
			assignShaders(22)		
	)
	on btn23 pressed do
	(
			assignShaders(23)		
	)
	on btn24 pressed do
	(
			assignShaders(24)		
	)
)

createdialog matId

)