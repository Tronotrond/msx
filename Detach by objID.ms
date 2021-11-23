-- Detach elements by objectID
/*
macroScript DetachMatID
category:"VisualWorks"
tooltip:"Detaches object to elements by Material ID"
buttontext:"Detach by MatID"
*/
(
	fn detacher = (
	
		global aObjects = geometry as array

		for i in 1 to aObjects.count do 
		(

			objorig = aObjects[i]
			obj = convertToPoly(objorig)

			faceIDCount = 30

		--obj_array =#()


			for i = 1 to faceIDCount do
			(
			obj.selectByMaterial i
			currentID =polyop.getFaceSelection obj
			print i
			polyop.detachFaces obj currentID delete:true asNode:true name:"NOVDETACHED"

			)

			delete obj
			obj_array =  $NOVDETACHED* as array
			print obj_array
			--obj_array = $ as array
			for i = 1 to (obj_array.count) do try
			(
			MotherMat = obj_array[i].material
			obj_array[i].name = MotherMat.materialList[i].name
			print i

			)
			catch()
		
		)
	)
		-- Remove old window if already open
	if ((tt_detacher != undefined) and (tt_detacher.isdisplayed)) do (destroyDialog tt_detacher)

	rollout tt_detacher "Detatch by MatId" width:120 height:80
	(
		button btn1 "Detach!" pos:[8,40] width:103 height:28
		on btn1 pressed  do
		(
			detacher()
		)
	)

	createDialog tt_detacher	
)