/*
macroScript proOptimize
category:"VisualWorks"
tooltip:"Quick Pro Optimizer Tool"
buttontext:"Pro Optimizer"
*/
(

global perVar=bezier_float()
perVar.Value = 50.0

fn CollapseAndHide changeLayer = 
(	
	if changeLayer then
		(
		layer = LayerManager.getLayerFromName "Reduced"
		if layer == undefined then
		(
			layer = LayerManager.newLayer()
			layer.setName "Reduced"
		)
	)

	undo off (
	for obj in selection do 
	(

		if classof obj.modifiers[1] == ProOptimizer then
		(
			obj.modifiers[1].Calculate = true
			ConvertTo obj Editable_Poly
			if changeLayer then
				(layer.addNode obj)			
		)
	)
	hide selection
	)
	gc()
)
	
	

rollout tronoTools "TronoTools v0.1" width:240 height:105
(
	button 'optButton' "Optimize" pos:[8,8] width:96 height:31 toolTip:"ProOptimize" align:#left
	
	spinner 'vertPercentVar' "Vertex% " pos:[112,16] width:79 height:16 range:[0,100,50] type:#float scale:0.1 Controller:perVar align:#left
	button 'btn2' "Collapse and Hide" pos:[8,48] width:96 height:32 align:#left
	checkbox 'chk1' "Place in Reduced Layer" pos:[112,48] width:120 height:32 checked:true align:#left

	on btn2 pressed do
	(
		CollapseAndHide(chk1.checked)
	)
	
	on optButton pressed do
	undo on
	(
	(
			
			if selection.count == 0 then (MessageBox "No object selected!")
	--			else if selection.count > 1 then (MessageBox "More than one object selected!")
		varCounter = 1
		if selection.count > 1 do
		for obj in $ do
		(
				if (classof $[varCounter].modifiers[1]) != ProOptimizer then
				(
					addModifier $[varCounter] (ProOptimizer())
					$[varCounter].modifiers[#ProOptimizer].Calculate = on
				)
	
								
				$[varCounter].modifiers[#ProOptimizer].OptimizationMode = 2
				$[varCounter].modifiers[#ProOptimizer].VertexPercent = perVar.Value
				$[varCounter].modifiers[#ProOptimizer].Calculate = on
				varCounter += 1
							
			
		)
		if selection.count == 1 then
		(
		if (classof $.modifiers[1]) != ProOptimizer then
				(
					addModifier $ (ProOptimizer())
					$.modifiers[#ProOptimizer].Calculate = on
				)
	
								
				$.modifiers[#ProOptimizer].OptimizationMode = 2
				$.modifiers[#ProOptimizer].VertexPercent = perVar.Value
				$.modifiers[#ProOptimizer].Calculate = on
				varCounter += 1	
		)
	)
	)
)

rf = newRolloutFloater "TronoTool" 230 115
addRollout tronoTools rf
)