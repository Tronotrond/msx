try (destroyDialog vraySubdivs) catch()

rollout vraySubdivs "maxSubdivs" width:168 height:160
(
	spinner spn1 "Min subdivs" pos:[16,16] width:112 height:16 range:[0,512,96] type:#integer scale:1
	spinner spn2 "Max subdivs" pos:[16,40] width:112 height:16 range:[0,512,512] type:#integer scale:1
	
	checkbox chk1 "Change Reflective Gloss" pos:[8,64] width:160 height:24 checked:true
	checkbox chk2 "Change Refractive Gloss" pos:[8,88] width:160 height:24 checked:true
	
	button btn1 "Change all" pos:[88,128] width:64 height:24
	
	on btn1 pressed do
	(
		undo on (
			
			for obj in geometry do
			(
				if classof obj.material == vraymtl do
				(
					if (obj.material.reflection_subdivs < spn1.value) then -- minimum subdivs
					(
						if(chk1.checked == true) then
							obj.material.reflection_subdivs = spn1.value
					)
					else if(obj.material.reflection_subdivs > spn2.value) then  -- maximum subdivs
					(
						if(chk1.checked == true) then
							obj.material.reflection_subdivs = spn2.value
					)
					if (obj.material.refraction_subdivs < spn1.value) then -- minimum subdivs
					(
						if(chk2.checked == true) then
							obj.material.refraction_subdivs = spn1.value
					)
					else if(obj.material.refraction_subdivs > spn2.value) then  -- maximum subdivs
					(
						if(chk2.checked == true) then
							obj.material.refraction_subdivs = spn2.value
					)
					
					
				)
				if classof obj.material == multimaterial or classof obj.material == multisubmaterial do
				(
					for m in obj.material do --loop through sub materials
					(
						if classof m == vraymtl do 
						(
							if (m.reflection_subdivs < spn1.value) then
							(
								if(chk1.checked == true) then
									m.reflection_subdivs = spn1.value
								
							)
							else if(m.reflection_subdivs > spn2.value) then
							(
								if(chk1.checked == true) then
									m.reflection_subdivs = spn2.value
								
							)
							
							if (m.refraction_subdivs < spn1.value) then
							(
								if(chk2.checked == true) then
									m.refraction_subdivs = spn1.value
								
							)
							else if(m.refraction_subdivs > spn2.value) then
							(
								if(chk2.checked == true) then
									m.refraction_subdivs = spn2.value
								
							)
							
							
						)
					)
				)	
			)
		)
		
	)
)

createDialog vraySubdivs 