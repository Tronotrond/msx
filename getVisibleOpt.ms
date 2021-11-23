fn getVisibleObjectsOpt GeoOnly rendersize =
(
	local fnGetChannel = getchannel
	
	if GeoOnly then theArray = geometry else theArray = objects		
	for i = 1 to theArray.count do theArray[i].gbufferChannel = i
	
	-- set all visibleObjects values to undefined
	visibleObjects = #()
	visibleObjects[theArray.count] = undefined
	
	-- render setup
	preferences.maximumGBufferLayers = 1
	bm = bitmap rendersize rendersize channels:#(#objectID)
	render rendersize rendersize vfb:false to:bm channels:#(#objectID)
	
	-- Loop through bitmap pixels
	iCount = rendersize - 1	
	for x = 0 to iCount do
	(			
		for y = 0 to iCount do
		(
			objId = (fnGetChannel bm [x,y] #objectID)[1]			
			if objId > 0 do 
			(
				-- set visibleObjects value only if it's undefined... way faster than appendIfUnique
				if visibleObjects[objId] == undefined do visibleObjects[objId] = theArray[objId]
			)
		)
	)
	
	-- don't forget to close the bitmap
	close bm ; free bm
	
	-- keep only values that are not undefined
	visibleObjects = for o in visibleObjects where o != undefined collect o	
)

start = timeStamp()
getVisibleObjectsOpt false 1024
end = timeStamp()
format "Processing took % seconds\n" ((end - start) / 1000.0)
