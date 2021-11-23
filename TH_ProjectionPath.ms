(
	collection = #()
	
	rollout AnimationTools "Trono Animation Tools" width:312 height:128
	(
		spinner 'frames' "Frames Ahead" pos:[24,16] width:204 height:16 range:[1,1000,64] type:#integer scale:1 align:#left
		spinner 'nth' "Nth Frame" pos:[136,48] width:111 height:16 range:[1,1000,1] type:#integer scale:1 align:#left
		checkbox 'chk1' "Bake Animation" pos:[16,48] width:104 height:16 align:#left
		button 'btn1' "Calculate" pos:[192,80] width:104 height:24 align:#left

		
		fn CalculateProjection =
		(
			if ($ == undefined) then
			(
				print "Select an object!"
				return false
			)

			fps = framerate
			currentPos = $.position
			previousPos = at time (slidertime-1f) $.position 
			movement = currentPos - previousPos
			grav = (units.decodeValue "-9.80665m")/fps/fps/1.95
			vel = movement
			starttime = sliderTime
			
			undo on
			(
				for i = 0 to frames.value by nth.value do
				(
					if(i != 0) do
					(
						if(chk1.checked) then -- bake simulation
						(
							with animate on
							(
								sliderTime = startTime + i
								
								for a = 1 to nth.value do
									vel.z += grav
								
								newVel = vel*i
								$.position = CurrentPos + newVel
							)
						)
						else
						(
							sp = Sphere()
							sp.radius = 1
							
							for a = 1 to nth.value do
									vel.z += grav
							
							sp.position = currentPos
							sp.position +=  vel*i
							
							append collection sp
						)
					)
				)
			)
			sliderTime = starttime
		)

		button 'btn6' "Delete Paths" pos:[16,80] width:80 height:24 align:#left
		
		-- delete contents of collection array

		on btn1 pressed do
			CalculateProjection()
		on btn6 pressed do
		(
			select collection
			delete $
			collection = #()
		)
	)

	createdialog AnimationTools
)