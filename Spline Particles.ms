-- int. step: select PF_Source
pf = $'PF_Spline' -- assign to var.
sp = splineShape()
-- Add edit spline modifier for animation purposes.
es = Edit_Spline()
addmodifier sp es 
splineColor = color 0 0 255
posArray = #() -- where to collect Point3 val's
countarray = #()
connectArray = #()
splineArray = #()

numConnectingParticles = 3
maxConnectingDistance = 8
maxParticleAge = 12
splineView = true
splineRender = true
splineThinckness = 0.1f
splineSides = 4
splineType = #corner

count = pf.NumParticles()
countarray.count = count

fn UpdateParticles =
(
	connectArray = #()
	count = pf.NumParticles()
	countarray = #()
	countarray.count = count
	posArray = #()
	ageArray = #()
	
	for i = 1 to count do
	(
		pf.particleIndex = i
		posArray[i] = pf.particlePosition
		ageArray[i] = pf.particleAge
	)
	
	for i = 1 to posArray.count do
	(
		for j = i+1 to posArray.count-1 do
		(
			if countarray[j] == undefined then
					countarray[j] = 0
			
			if (distance posArray[i] posArray[j]) < maxConnectingDistance then
			(
				if countarray[j] < numConnectingParticles AND ageArray[j] < maxParticleAge then
				(
					posses = #()
					posses[1] = posArray[i]
					posses[2] = posArray[j]
					append connectArray posses
					
					countarray[j] = countarray[j] += 1
				)
			)
		)
		
	)
)
fn DrawSplines = 
(
	if sp == undefined then
	(
		sp = splineShape()
		-- Add edit spline modifier for animation purposes.
		es = Edit_Spline()
		addmodifier sp es 
	)
	resetShape sp	
	
	sp.wirecolor = splineColor
	sp.render_renderable = splineRender
	sp.render_displayRenderMesh = splineView
	sp.thickness = splineThinckness
	sp.sides = splineSides
	
	addnewSpline sp
	
	for i = 1 to connectArray.count do
		for pos in connectArray[i] do
		(
			addKnot sp 1 splineType #curve pos
		)
		
	--append splineArray sp
	--print "draw new spline"
)

fn DelSplines = 
(
	delete sp
	/*
	for spl in splineArray do
		try(delete spl) catch()
	splineArray = #()
	*/
)

fn SplineUpdate = 
(
	--print ("SplineUpdate() called. Recalculating " + (posArray.count as string) + " particles")
	-- remove old spline 
	--DelSplines()
	
	UpdateParticles()
	DrawSplines()	
)

fn BakeSplineAnimation =
(
	_pc = Point_Cache()
	_fn = getSaveFileName "Save Cache File" types:"XML(*.xml)|*.xml|PC2(*.pc2)|*.pc2"
	if _fn != undefined then
	(
		_pc.filename = _fn
		addModifier splineArray[1] _pc
		cacheOps.recordcache splineArray[1].modifiers[#point_cache] 
	)
	else
	(
		print "No cache output set"
	)
	
)

rollout ttParticleSpine "ParticleSplines" width:200 height:408
(
	fn PickFilter obj = classOf obj == PF_Source
	
	pickbutton 'btnSelect' "Select Particle System" pos:[40,8] width:112 height:24 filter:pickFilter align:#left
	
	spinner 'spnConnectingParticles' "" pos:[120,48] width:64 height:16 type:#integer align:#left
	label 'lbl1' "Max Connections" pos:[8,48] width:104 height:16 align:#left
	spinner 'spnDist' "" pos:[120,72] width:64 height:16 range:[0,100,0] type:#integer align:#left
	label 'lbl2' "Max Distance" pos:[8,72] width:104 height:16 align:#left
	spinner 'spnAge' "" pos:[120,96] width:64 height:16 range:[0,100,0] type:#integer align:#left
	label 'lbl3' "Max Particle Age" pos:[8,96] width:104 height:16 align:#left
	
	label 'lbl4' "Spline Settings" pos:[64,128] width:80 height:16 align:#left
	
	checkbox 'chkView' "Enable in Viewport" pos:[8,152] width:176 height:16 align:#left
	checkbox 'chkRender' "Enable in Render" pos:[8,176] width:176 height:16 align:#left
	spinner 'spnThickness' "" pos:[120,200] width:64 height:16 range:[0,100,0] type:#float align:#left
	label 'lbl5' "Thickness" pos:[8,200] width:104 height:16 align:#left
	spinner 'spnSides' "" pos:[120,224] width:64 height:16 range:[0,100,0] type:#integer align:#left
	label 'lbl6' "Sides" pos:[8,224] width:104 height:16 align:#left
	
	label 'lbl13' "Spline Color" pos:[8,256] width:80 height:16 align:#left
	colorPicker 'cp1' "" pos:[128,248] width:48 height:24 color:[0,0,255] modal:false align:#left
	
	label 'lbl14' "Spline Style" pos:[8,288] width:80 height:16 align:#left
	radiobuttons 'rdo1' "" pos:[80,288] width:59 height:32 labels:#("Linear", "Smooth") align:#left

	button 'btnUpdate' "Update" pos:[112,336] width:72 height:24 enabled:false align:#left
	button 'btnDelete' "Delete Spline" pos:[16,336] width:72 height:24 align:#left	
	
	button 'btnBake' "Bake Anim" pos:[112,368] width:72 height:24 enabled:false align:#left
	
	on ttParticleSpine open do
	(
		if (classOf $ == PF_Source) then
		(
			btnSelect.object = $
			btnSelect.text  = $.name
			btnUpdate.enabled = true
			
		)
	
		spnConnectingParticles.value = numConnectingParticles
		spnDist.value = maxConnectingDistance
		spnAge.value = maxParticleAge
		
		chkView.checked = splineView
		chkRender.checked = splineRender
		spnThickness.value = splineThinckness
		spnSides.value = splineSides	
		
		cp1.color = splineColor
	)
	on btnSelect picked obj do
	(
		btnSelect.text  = obj.name
		btnUpdate.enabled = true
	)
	on spnConnectingParticles changed val do
	(
		numConnectingParticles = val
	)
	on spnDist changed val do
	(
		maxConnectingDistance = val
	)
	on spnAge changed val do
	(
		maxParticleAge = val
	)
	on chkView changed state do
	(
		splineView = state
	)
	on chkRender changed state do
	(
		splineRender = state
	)
	on spnThickness changed val do
	(
		splineThinckness = val
	)
	on spnSides changed val do
	(
		splineSides = val
	)
	on cp1 changed col do
	(
		splineColor = col
	)
	on rdo1 changed state do
	(
		if state == 1 then 
		(
			splineType = #corner
		)
		else
		(
			splineType = #smooth
		)
	)
	on btnUpdate pressed do
	(
		unRegisterTimeCallback SplineUpdate
		callbacks.removescripts id:#spline_render
		callbacks.removescripts id:#spline_render2
		SplineUpdate()
		registerTimeCallback SplineUpdate
		
		callbacks.addScript #preRenderEval "SplineUpdate()" id:#spline_render2
		callbacks.addScript #postRenderFrame "SplineUpdate()" id:#spline_render
		--callbacks.addscript #preRender "SplineUpdate()" id:#spline_render
		btnBake.enabled = true
	)
	on btnDelete pressed do
	(
		DelSplines()
		btnBake.enabled = false
	)
	on btnBake pressed do
	(
		BakeSplineAnimation()
	)
)

try(DestroyDialog ttParticleSpine) catch()
CreateDialog ttParticleSpine