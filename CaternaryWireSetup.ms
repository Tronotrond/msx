( 
   struct catenaryHelper 
   ( 
       		   
      fn createScriptController spline p0 p1 = 
      ( 
          
          
         catenaryDataCA= attributes catenaryData 
         ( 
            local maxError = 1e-6 
            local maxIt = 100 
             
            fn TV upper lower = 
            ( 
               (upper + lower) * 0.5 
            ) 
                   
            fn atanh_ x = 
            ( 
               0.5 * log ((1.0 + x) / (1.0 - x)) 
            ) 
             
            fn asinh x = 
            ( 
               log (x + sqrt(1 + x * x)) 
            ) 
             
            fn cosh_ x = 
            ( 
               0.5 * (e^x + e^-x) 
            ) 
             
            fn calc_D a L h sgn = 
            ( 
               q = 2.0 * sgn * sqrt(h * (a + h) * (L * L - a * a)) 
               ((L * L - a * a) * (a + 2.0 * h) - L * q) / (a * a) * (atanh_ (a * a / (L * (a + 2.0 * h) - q))) 
            ) 
             
            fn solve_h a L d = 
            ( 
               s = (L * L - a * a) / (2.0 * a) * log ((L + a) / (L - a)) 
               s = if s < d then -1.0 else 1.0 
               lower = 0 
               upper = (L - a) * 0.5 
               n = 0 
               while (upper - lower) > maxError and (n += 1) < maxIt do 
               ( 
                  if ((calc_d a L (TV upper lower) s) * s) < (d * s) then 
                     upper = TV upper lower 
                  else 
                     lower = TV upper lower 
               ) 
                
               s * TV upper lower 
            ) 
             
            fn calc_L1 h L a sgn = 
            ( 
               ((h * l) + (sgn * sqrt (h * (a + h) * (L * L - a * a)))) / (-a) 
            ) 
             
            fn calc_my h L1 = 
            ( 
               (2.0 * h) / (L1 * L1 - h * h) 
            ) 
             
            fn calc_x1 my L1 = 
            ( 
               (asinh (my * L1)) / my 
            ) 
             
            fn createCatenaryCurve pA pB spline splineLength = 
            (       
               local point0, point1, pos0, pos1 
                
               if pA.pos.z == pB.pos.z do 
                  pA.pos.z += 1 
               if pA.pos.z > pB.pos.z then 
               ( 
                  point0 = pB 
                  point1 = pA 
               ) 
               else 
               ( 
                  point0 = pA 
                  point1 = pB 
               ) 
               pos0 = point0.pos 
               pos1 = point1.pos 
                
               vec = pos1 - pos0 
                         
               if (length vec) > splineLength then 
               ( 
                  count = (numKnots spline 1) - 1 
                  setKnotPoint spline 1 1 pos0 
                   
                  for i = 2 to count do 
                  ( 
                     p = (i - 1) / (count + 1.0) 
                     setKnotPoint spline 1 i (pos0 + p * vec) 
                  ) 
                  setKnotPoint spline 1 (count + 1) pos1 
                  updateShape spline 
                  spline.wirecolor = red 
                  return OK 
               ) 
               spline.wirecolor = green 
               L = amax splineLength ((length vec) * 1.005) 
               vecxy = [vec.x, vec.y, 0] 
               dir = normalize vec 
               d = distance [pos0.x, pos0.y] [pos1.x, pos1.y] 
                
               a = abs (pos0.z - pos1.z) 
               h = solve_h a L d 
               sign = if pos0.z < pos1.z then -1.0 else 1.0 
               L1 = calc_L1 h L a sign 
               my = calc_my h L1 
               x1 = calc_x1 my L1 
               k = pos0.z - h - (1.0 / my) 
               --steps = 20.0 
                
               offset = amin pos0.z pos1.z 
                
               count = numKnots spline 1 
               stepLength = d / (count as float) 
               setKnotPoint spline 1 1 pos0 
                
               for i = 2 to (count - 1) do 
               ( 
                  x = (i - 0.5)  * stepLength 
                  p = (i - 0.5) / (count as float) 
                  z = (cosh_ (my * x - my * x1) * (1.0 /my)) + k - offset 

                  setKnotPoint spline 1 i (pos0 + p * vecxy + [0, 0, z]) 
               ) 
               setKnotPoint spline 1 count pos1 
               updateShape spline 
            ) 
             
            parameters main rollout:params 
            ( 
               splineLength type:#float ui:splineLengthSpinner default:150 
               point0 type:#node 
               point1 type:#node 
               spline type:#node 
            ) 
             
            rollout params "Catenary Parameters" 
            ( 
               spinner splineLengthSpinner "Length" type:#float range:[0,1e4, 200] 
                
               on splineLengthSpinner changed val do 
               ( 
                  deps = (refs.dependents ((refs.dependents this)[1])) 
                  for d in deps where classof d == SplineShape do 
                     if point0 != undefined and point1 != undefined  do 
                        this.createCatenaryCurve point0 point1 d val 
               ) 
            ) 
         ) 
                   
         em = emptyModifier name:"Catenary parameters" 
         CustAttributes.add em catenaryDataCA 
         addModifier spline em 
          
         em.point0 = p0 
         em.point1 = p1 
         --em.spline = spline 
          
         scriptController = position_script() 
         scriptController.addNode "spline" spline 
         scriptController.addNode "p0" p0 
         scriptController.addNode "p1" p1 
         scriptController.script = "" + \ 
         "cmod = spline.modifiers[\"Catenary parameters\"]\n" + \ 
         "cmod.createCatenaryCurve p0 p1 spline cmod.splineLength\n" + \ 
         "p0.pos + 0.5 * (p1.pos - p0.pos)" 
          
         d = dummy() 
         d.pos.controller = scriptController 
      ), 
       
      fn createSpline knotsCount pos0 pos1 = 
      ( 
         ss = splineshape  wirecolor:red 
         addNewSpline ss 
         addKnot ss 1 #smooth #curve pos0 
         vec = pos1 - pos0 
         for i = 1.0 to knotsCount do 
         (       
             
            p = i / (knotsCount + 1) 
            addKnot ss 1 #smooth #curve (pos0 + p * vec) 
         ) 
         addKnot ss 1 #smooth #curve pos1 
         updateshape ss 
         ss 
      ) 
   ) 
    
   -- Example usage: 
   --delete $* 
	rollout catWireHelper "Get your caternaries!" width:184 height:152
	(
		label lbl1 "Caternary Wire Setup" pos:[16,8] width:256 height:16
		label lbl2 "Select two objects. I.e. dummies for each end of the wire. Set lenght and you're good to go!" pos:[16,32] width:168 height:48
		button btn1 "Create" pos:[120,88] width:48 height:16
		spinner spn1 "Lenght" pos:[16,88] width:88 height:16 range:[0,10000,150]
		checkButton ckb1 "Change Lenght on Selected" pos:[8,112] width:168 height:16
		
		on spn1 changed val do
		(
			if ckb1.checked do
			(
				theSelection = selection
				for obj in theSelection do
				(
					if classof obj == SplineShape do
					(
						try (obj.modifiers[#Catenary_parameters].catenaryData.splineLength = val)
						catch()
					)
				)
			)
		)
		
		on btn1 pressed do
		(
			selectedObjs = selection
			if selectedObjs.count == 2 then
			(
				undo on
				(
					posA = selectedObjs[1].pos
					posB = selectedObjs[2].pos
					
					pointA = point pos:posA
					pointB = point pos:posB
					
					pointA.parent = selectedObjs[1]
					pointB.parent = selectedObjs[2]
					
					local catenaryStruct = catenaryHelper() 
					s = catenaryStruct.createSpline 1 posA posB
					catenaryStruct.createScriptController s pointA pointB
					s.modifiers[#Catenary_parameters].catenaryData.splineLength = spn1.value
		
				)
			)
			else
				Messagebox "Select two objects!"
		)
	)
	
	CreateDialog catWireHelper

)