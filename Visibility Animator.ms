/*
	Tronotools Visibility Animator v2.0
	created: no idea
	last changed: 2016/04/14
	
	

*/

debug = false

if ((Visibility_Animator != undefined) and (Visibility_Animator.isdisplayed)) do 
(
	destroyDialog Visibility_Animator
	try (unregisterTimeCallback VisibilityUpdater()) catch()
)

myUI = 
rollout Visibility_Animator "Visibility Animator" width:227 height:124
(
	label 'lab1' "Currently selected object:" pos:[8,8] width:119 height:13 align:#left
	label 'lab2' "Not yet implemented :)" pos:[8,25] width:216 height:16 style_sunkenedge:true align:#left
	
	slider 'sld1' "Visibility" pos:[9,48] width:131 height:44 range:[0,1,1] type:#float ticks:1 step:0.1 align:#left
	button 'btn1' "Set Key" pos:[160,72] width:52 height:21 align:#left
	
	
	
	label 'lbl6' "1" pos:[140,75] width:12 height:22 align:#left
	checkbox 'chk1' "Update" pos:[160,56] width:56 height:16 checked:true align:#left
	
	
	fn VisibilityUpdater = 
	(
		vis = -1
		if selection.count > 1 then
		(
			lab2.text = "Selection"
			myCheck = true
			for i = 1 to selection.count-1 do
			(
				if selection[i].visibility.controller.value != selection[i].visibility.controller.value then
				(
					myCheck = false
				)
			)
			if myCheck then
			(
				vis = selection[i].visibility.controller.value
			)
		)		
		else if selection.count == 1 then
		(
			lab2.text =  selection[1].name
			vis = selection[1].visibility.controller.value
		)
		else 
		(
			 lab2.text = "None"
		)
		
		if vis != -1 AND chk1.checked then
		(
			sld1.value = vis
		)
	)
	
	on sld1 changed val do
	(
		lbl6.text = sld1.value as string 
		
		if $ == selection then
		(
			for obj in selection do
			(
				if obj.visibility == true then
					obj.visibility = bezier_float() 
				if obj.visibility == false then
					obj.visibility = bezier_float() 
				obj.visibility.controller.value = sld1.value
			)
		)
		else
		(
			if $.visibility == true then
				$.visibility = bezier_float() 
			if $.visibility == false then
				$.visibility = bezier_float() 
			$.visibility.controller.value = sld1.value
		)
		
		
	)
	on btn1 pressed do
	(
		if $ == selection then
		(
			for obj in selection do 
			(
				obj.visibility.controller.value = sld1.value
			)
		)
		else
		(
			$.visibility.controller.value = sld1.value
			print sld1.value as string
		)
		
	)
	
	
	on Visibility_Animator close do 
	(
		callbacks.removeScripts id:#myVisID
	)
	
)




createDialog MyUI
/*
unRegisterTimeCallback (MyUI.VisibilityUpdater())
registerTimeCallback (MyUI.VisibilityUpdater())
callbacks.addScript #selectionSetChanged "(MyUI.VisibilityUpdater())" id:#myVisID
MyUI.VisibilityUpdater()*/