-- TH Addon: Search function -- Seach input string for for a certain letter. Case sensetive true or false
	fn positionsInString stringToCheck findThisString caseBool =
	(
		listOfStringPositions = #()
		if stringToCheck.count >= findThisString.count and stringToCheck.count > 0 do
		(
			for strCnt = 1 to (stringToCheck.count - findThisString.count +1) do
			(
				if caseBool then
				(
					if (substring stringToCheck strCnt findThisString.count)  == findThisString do append listOfStringPositions strCnt
				)
				else
				(
					if (substring stringToCheck strCnt findThisString.count as name) == (findThisString as name) do append listOfStringPositions strCnt
				)
				
			)	
		)
		if (listOfStringPositions.count > 0) then 
		(
			return 1
		)
		return 0
	)
		
	fn checkInvalidChars inputName = 
	(
		invalidChars = #(":", "\\", "/", "@", ";", "(", ")", "<", ">", "?", "'", "\"")
		
		replacePositions = #()
		for i in 1 to invalidChars.count do
		(
			SearchString = invalidChars[i] -- set the string to search for		
			replacePositions = positionsInString inputName SearchString false
			if (replacePositions != 0) then
			(
				return 1
			)
		)
		return 0
	)
	
	fn ReplaceChar inputString invalidChar replacementChar =
	(
		replacePositions = #()
		newString = inputString
		_mybool = true
		while _mybool do
		(
			_index = findString newString invalidChar
			if _index == undefined then 
				(_mybool = false)
			else
				(newString[_index] = replacementChar)
		)
		
		return newString
	)