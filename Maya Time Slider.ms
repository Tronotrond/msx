/*

	Maya-like Time Slider v1.1
	By Trond Hille www.hille3d.no

	Simple functionality like Maya's time slider. 
	Does not scale properly with screen size, but you can easily edit the width in the rollout
	below to fit your needs with minimal maxscript knowledge (or use the visual editor).
	
	Changelog:
	v1.0 initial release
	v1.1 fixed an undefined bug with UpdateSliders()

*/
(
	rollout ttTimeToolbar "TT Time Toolbar" width:1200 height:32
	(
		spinner 'spnST' "ST" pos:[0,0] width:66 height:16 range:[-100000,99999,0] type:#integer align:#left
		spinner 'spnSS' "" pos:[88,0] width:64 height:16 range:[0,100,0] type:#integer align:#left
		spinner 'spnSE' "" pos:[1048,0] width:64 height:16 range:[0,100,50] type:#integer align:#left
		spinner 'spnET' "ET" pos:[1112,0] width:66 height:16 range:[-99999,100000,100] type:#integer align:#left
		
		slider 'sldL' "Slider" pos:[160,-16] width:440 height:44 type:#integer align:#left
		slider 'sldR' "Slider" pos:[600,-16] width:440 height:44 range:[0,100,0] type:#integer align:#left
		
		fn UpdateSliders =
		(
			anmS = ttTimeToolbar.spnST.value
			anmE = ttTimeToolbar.spnET.value
			tt = ttTimeToolbar
			
			if tt.sldL.value < anmS then (tt.sldL.value = anmS)
			if tt.sldL.value > tt.sldR.value-1f then (tt.sldL.value = tt.sldR.value-1f)
			tt.sldL.range = [anmS, tt.sldR.value-1f, tt.sldL.value]
			tt.spnSS.range = [anmS, tt.sldR.value-1f, tt.sldL.value]
			
			if tt.sldR.value < tt.sldL.value+1f then (tt.sldR.value = tt.sldL.value+1f)
			if tt.sldR.value > anmE then (tt.sldR.value = anmE)
			tt.sldR.range = [tt.sldL.value+1f, anmE, tt.sldR.value]
			tt.spnSE.range = [tt.sldL.value+1f, anmE, tt.sldR.value]
		)
			
		on spnST changed val do
		(
			--animationRange = interval val animationrange.end
			UpdateSliders()
		)
		on spnSS changed val do
		(
			animationRange = interval val animationrange.end
			custStart = val
			sldL.value = val
			UpdateSliders()
		)
		on spnSE changed val do
		(
			animationRange = interval animationrange.start val
			custEnd = val
			sldR.value = val
			UpdateSliders()
		)
		on spnET changed val do
		(
			--animationRange = interval animationrange.start val
			UpdateSliders()
		)
		on sldL changed val do
		(
			--animationrange.start = val
			animationRange = interval val animationrange.end
			spnSS.value = val
			UpdateSliders()
		)
		on sldR changed val do
		(
			--animationrange.end = val
			animationRange = interval animationrange.start val
			spnSE.value = val
			UpdateSliders()
		)
		
		
	)
	


	fn CreateUI =
	(
		CreateDialog ttTimeToolbar
		
		anmS = animationrange.start
		anmE = animationrange.end
		
		global custStart = anmS 
		global custEnd = anmE
		
		
		ttTimeToolbar.spnST.value = anmS
		ttTimeToolbar.spnET.value = anmE
		
		ttTimeToolbar.sldL.range = [anmS, anmE-1f, anmS]
		ttTimeToolbar.spnSS.range = [anmS, anmE-1f, anmS]
		ttTimeToolbar.sldR.range = [anmS+1f, anmE, anmE]
		ttTimeToolbar.spnSE.range = [anmS+1f, anmE, anmE]
	)



	try(
		cui.unRegisterDialogBar ttTimeToolbar
		DestroyDialog ttTimeToolbar
		) catch()

	CreateUI()

	cui.registerDialogBar ttTimeToolbar style:#(#cui_dock_bottom, #cui_floatable, #cui_dock_top)
	cui.dockDialogBar ttTimeToolbar #cui_dock_bottom
)