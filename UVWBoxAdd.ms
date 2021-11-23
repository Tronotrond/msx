global uvwboxadd
try(destroyDialog uvwboxadd)catch()

m = uvwmap() 

fn UVWmapSelected sizeValue = (
	m.maptype = 4
	m.length = sizeValue
	m.width = sizeValue
	m.height = sizeValue
	for obj in $selection do addmodifier obj (copy m)
)


rollout uvwboxadd "UV to the W" width:143 height:101
(
	label lbl1 "Add a UVW Box modifier to all selected objects" pos:[16,8] width:120 height:31
	spinner spn1 "Square Size" pos:[16,48] width:120 height:16 range:[0,100000,100] type:#worldunits
	button btn1 "Do it!" pos:[24,72] width:96 height:24


	on btn1 pressed do
	(
		undo on
		UVWmapSelected spn1.value
		undo off
		print "Done!"
	)
)




CreateDialog uvwboxadd