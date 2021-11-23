/*
	Instance Identical Geometry
	v.2.0 [2010-06-03] by Anubis [project3d.narod.ru]
	
	What's new in version 2.0 :
		[*] proccess multiple (selected) objects at once
		[*] rollout (with pick button) removed
		[*] the script rewritten as macros
	
	To be instanced nodes need to match this criterions:
		identical class, face/verts count, scale
	You could expand it with more... (see the notes in the code)
	
	Tronotools Edit:
		- Macroscript part commented out
		- Simple rollout created
	
*/
/*
macroScript Instance_Identical_Geometry
	buttonText:"Instance Identical Geometry" 
	category:"Tools" 
	internalCategory:"Tools" 
	tooltip:"Instance Identical Geometry" 
*/ 



fn InstanceSelected = 
(
	-- filter selection & get all geometry objects
	local objSet = for i in selection where (getPolygonCount i) as string != "#(0,0)" collect i
	
	--on isEnabled return (objSet.count != 0)
	--on execute do
	--(
		setWaitCursor()
		with redraw off
		(
			while objSet.count > 0 do
			(
				obj = objSet[1]
				deleteItem objSet 1
				-- array of properties to be compared // you could expand it with more...
				srcData = #(
					classOf obj, 
					(getPolygonCount obj) as string, 
					obj.scale
				)
				-- collect identical
				local identical = for i in geometry where \
					not areNodesInstances obj i and \
					classOf i == srcData[1] and \
					(getPolygonCount i) as string == srcData[2] and \
					i.scale == srcData[3] collect i
				-- clean up objSet
				for i in identical do (
					dub = findItem objSet i
					if dub != 0 do deleteItem objSet dub
				)
				instanceReplace identical obj -- mapped
			)
		)
		redrawViews()
		setArrowCursor()
	--)
) 

rollout instancer "Find Instances (Selected)"
(
	button btn1 "Find Instances"
	
	on btn1 pressed do
	(
		undo on (
		InstanceSelected()
		)
	)
)
try (DestroyDialog instancer) catch()
CreateDialog instancer
