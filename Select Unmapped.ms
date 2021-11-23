-----------------------------------------------------------------
--	Select unmapped objects v0.1
--	Trond Hille 2011
--
--	Selects all objects in scene without a material
-----------------------------------------------------------------

objArray = #()

-- Remove old window if already open
if ((tt_selUnmap != undefined) and (tt_selUnmap.isdisplayed)) do (destroyDialog tt_selUnmap)


rollout tt_selUnmap "Select unmapped" width:120 height:80
(
	button btn1 "Select Unmapped" pos:[8,40] width:103 height:28
	on btn1 pressed  do
	(
		disableSceneRedraw()
		-- Get all geometry without any material applied
		objArray = for obj in geometry where obj.material == undefined collect obj
		select objArray
		enableSceneRedraw()	
	)
)

createDialog tt_selUnmap --pos:[50,150]
