/***************************************
**	Targeted Vray Light
**	Trond Hille 2012
**
**	Creates a look at target
**	for the selected V-Ray light
**
***************************************/

--open a local scope
(
	-- Light variable
	selectedVlight = undefined
	
	if ((vw_target_light != undefined) and (vw_target_light.isdisplayed)) do (destroyDialog vw_target_light)	

	global redrawviews_tlc_function --ensure variable visibility
	unregisterRedrawViewsCallback redrawviews_tlc_function

	rollout vw_target_light "Target Light Creator" width:136 height:120
	(
		label lbl1 "Light Selected:" pos:[8,8] width:90 height:16
		label lbl2 "<name>" pos:[8,24] width:104 height:16
		checkbox chk1 "" pos:[112,19] width:24 height:24 enabled:false
		button btn1 "Add Target" pos:[16,88] width:104 height:24 enabled:false
		checkbox chk2 "Invisible" pos:[8,40] width:112 height:16 checked:true
		spinner spn1 "Samples" pos:[16,59] width:112 height:16 type:#integer range:[0,64,16]
		
		on btn1 pressed do
		(
			if selectedVlight.rotation.controller == LookAt_Constraint() then 
				messagebox "Light already have a LookAt Constraint"  -- Not working :)
			else
			(
				undo on (
				selectedVlight.invisible = chk2.checked
				selectedVlight.subdivs = spn1.value
				dumming = dummy() -- Create a dummy
				-- Get position of light and align dummy to it
				position = selectedVlight.position	
				dumming.position = position
				
				selectedVlight.rotation.controller=LookAt_Constraint()
				selectedVlight.rotation.controller.appendtarget dumming 100
				selectedVlight.rotation.controller.viewline_length_abs = off
				selectedVlight.rotation.controller.relative = off
				selectedVlight.rotation.controller.target_axis = 2
				selectedVlight.rotation.controller.target_axisFlip = true
				
				select dumming
				)
			)
		)
	)
	
	
	-- Checks that a vray light is selected and enable the button
	fn redrawviews_tlc_function = 
	(
		if (classOf $) == VRayLight then
		(
			vw_target_light.lbl2.text = $.name
			vw_target_light.chk1.checked = true
			vw_target_light.btn1.enabled = true
			selectedVlight = $
		)	
		else
		(
			vw_target_light.chk1.checked = false
			vw_target_light.btn1.enabled = false
			vw_target_light.lbl2.text = "Not a Vray Light"
		)
	)


	createDialog vw_target_light

	registerRedrawViewsCallback redrawviews_tlc_function
--end local scope 
)