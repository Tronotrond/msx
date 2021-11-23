/*

	Tronotools Simple Randomizer v1.0
	created			2016/3/2
	last modified		2016/3/2
	
	A small tool for quickly randomize rotation while modelling
		- for example randomize rotation on nuts and bolts
		
	Todo:
		- Randomize position
		- Randomize scale


*/

roff = 15 -- rollout height offset

rollout ttRandomizer "Simple Randomizer v1.0" width:280 height:312
(
	subRollout pos
	subRollout rot
	subRollout exec
)
rollout pos "Offset Position" width:224 height:88
(
	label 'lbl1' "X" pos:[8,8] width:16 height:16 align:#left
	label 'lbl2' "Y" pos:[8,32] width:16 height:16 align:#left
	label 'lbl3' "Z" pos:[8,56] width:16 height:16 align:#left
	label 'lbl4' "Min" pos:[24,8] width:16 height:16 align:#left
	label 'lbl5' "Min" pos:[24,32] width:16 height:16 align:#left
	label 'lbl6' "Min" pos:[24,56] width:16 height:16 align:#left
	label 'lbl7' "Max" pos:[120,8] width:24 height:16 align:#left
	label 'lbl8' "Max" pos:[120,32] width:24 height:16 align:#left
	label 'lbl9' "Max" pos:[120,56] width:22 height:14 align:#left
	
	spinner 'sXmin' "" pos:[48,8] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sXmax' "" pos:[152,8] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sYmin' "" pos:[48,32] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sYmax' "" pos:[152,32] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sZmin' "" pos:[48,56] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sZmax' "" pos:[152,56] width:64 height:16 range:[-10000,10000,0] align:#left
)
rollout rot "Offset Rotation" width:224 height:88
(
	label 'lbl1' "X" pos:[8,8] width:16 height:16 align:#left
	label 'lbl2' "Y" pos:[8,32] width:16 height:16 align:#left
	label 'lbl3' "Z" pos:[8,56] width:16 height:16 align:#left
	label 'lbl4' "Min" pos:[24,8] width:16 height:16 align:#left
	label 'lbl5' "Min" pos:[24,32] width:16 height:16 align:#left
	label 'lbl6' "Min" pos:[24,56] width:16 height:16 align:#left
	label 'lbl7' "Max" pos:[120,8] width:24 height:16 align:#left
	label 'lbl8' "Max" pos:[120,32] width:24 height:16 align:#left
	label 'lbl9' "Max" pos:[120,56] width:22 height:14 align:#left
	
	spinner 'sXmin' "" pos:[48,8] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sXmax' "" pos:[152,8] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sYmin' "" pos:[48,32] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sYmax' "" pos:[152,32] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sZmin' "" pos:[48,56] width:64 height:16 range:[-10000,10000,0] align:#left
	spinner 'sZmax' "" pos:[152,56] width:64 height:16 range:[-10000,10000,0] align:#left
)
rollout functions "Execution" height:88
(
	button 'btnGo' "Execute"
	
	fn Randomize =
	(
		for obj in (selection as array) do
		(
			rndPosX = random ttRandomizer.pos.pos.sXmin.value ttRandomizer.pos.pos.sXmax.value
			rndPosY = random ttRandomizer.pos.pos.sYmin.value ttRandomizer.pos.pos.sYmax.value
			rndPosZ = random ttRandomizer.pos.pos.sZmin.value ttRandomizer.pos.pos.sZmax.value
			
			rndRotX = random ttRandomizer.rot.rot.sXmin.value ttRandomizer.rot.rot.sXmax.value
			rndRotY = random ttRandomizer.rot.rot.sYmin.value ttRandomizer.rot.rot.sYmax.value
			rndRotZ = random ttRandomizer.rot.rot.sZmin.value ttRandomizer.rot.rot.sZmax.value
			
			obj.pos += [rndPosX, rndPosY, rndPosZ]
			currentMatrix = obj.transform
			preRotate currentMatrix (eulertoquat (eulerAngles rndRotX rndRotY rndRotZ))
			obj.transform = currentMatrix
		)
	)
	on btnGo pressed do
	(
		undo on
		(
			Randomize()
		)
	)
)
fn Init = 
(
	CreateDialog ttRandomizer
	AddSubRollout ttRandomizer.pos pos
	AddSubRollout ttRandomizer.rot rot
	AddSubRollout ttRandomizer.exec functions
	ttRandomizer.pos.height += pos.height+roff
	ttRandomizer.rot.pos += [0,pos.height+roff]
	ttRandomizer.rot.height += rot.height+roff
	ttRandomizer.exec.pos += [0, (rot.height*2) + roff]
	ttRandomizer.exec.height += functions.height + roff
)

Init()