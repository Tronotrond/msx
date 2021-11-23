/*
	Tronotools Quick Link Locks v1.1
	last changed: 2016/04/27

	changelog:
		v1.1	fixed a bug crashing script when no objects selected

*/


rollout ttLinkInfo "Compact Link Info" width:184 height:80
(
	label 'lbl1' "Move" pos:[8,8] width:32 height:16 align:#left 
	label 'lbl2' "Rot" pos:[8,24] width:32 height:16 align:#left
	label 'lbl3' "Scale" pos:[8,40] width:32 height:16 align:#left
	-- Move 
	checkbox 'chkMX' "X" pos:[40,8] width:24 height:16 align:#left 
	checkbox 'chkMY' "Y" pos:[72,8] width:24 height:16 align:#left
	checkbox 'chkMZ' "Z" pos:[104,8] width:24 height:16 align:#left
	button 'btnML' "L" pos:[136,8] width:16 height:16 align:#left
	button 'btnMU' "U" pos:[160,8] width:16 height:16 align:#left
	-- Rot
	checkbox 'chkRX' "X" pos:[40,24] width:24 height:16 align:#left
	checkbox 'chkRY' "Y" pos:[72,24] width:24 height:16 align:#left
	checkbox 'chkRZ' "Z" pos:[104,24] width:24 height:16 align:#left
	button 'btnRL' "L" pos:[136,24] width:16 height:16 align:#left
	button 'btnRU' "U" pos:[160,24] width:16 height:16 align:#left
	-- Scale
	checkbox 'chkSX' "X" pos:[40,40] width:24 height:16 align:#left
	checkbox 'chkSY' "Y" pos:[72,40] width:24 height:16 align:#left
	checkbox 'chkSZ' "Z" pos:[104,40] width:24 height:16 align:#left
	button 'btnSL' "L" pos:[136,40] width:16 height:16 align:#left
	button 'btnSU' "U" pos:[160,40] width:16 height:16 align:#left
	-- Global
	button 'btnGL' "GL" pos:[40,56] width:24 height:16 align:#left
	button 'btnGU' "GU" pos:[72,56] width:24 height:16 align:#left
	
	-- triState: 2 - indeterminate (checked:true)
	
	fn GetLinkInfo = 
	(
		transformArray = #()
		-- compare: (transformarray[1] as string ) == (transformarray[2] as string)
		
		for obj in selection do
		(
			append transformArray (getTransformLockFlags obj)
		)
		theyAreAllEqual = true
		if transformArray.count == 0 then
		(
			_tmp = #{}
			return _tmp
		)
		else if transformArray.count == 1 then
		(
			return transformArray[1]
		)
		else
		(
			for i in 1 to transformArray.count-1 do
			(
				if (transformArray[i] as string) != (transformArray[i+1] as string) do
				(
					theyAreAllEqual = false
					break
				)
			)
			
			if theyAreAllEqual then
			(return transformArray[1])
			else
			(
				_ca = #()
				_ca.count = 9
				for i in 1 to _ca.count do
				(
					_a = transformArray[1]
					for j in 2 to transformArray.count do
					(
						_b = transformArray[j]
						
						if (_a[i] == _b[i]) then
						(
							_ca[i] = _a[i]
						)
						else
						(
							_ca[i] = 2
							break
						)
					)
				)
				return _ca
			)
		)
	)
	
	fn UpdateLinkInfo =
	(
		_ba = GetLinkInfo()
		_bb = #()
		_bb.count = 9 
		
		if _ba.count == 0 then
		(
			chkMX.tristate = 0
			chkMY.tristate = 0
			chkMZ.tristate = 0
			
			chkRX.tristate = 0
			chkRY.tristate = 0 
			chkRZ.tristate = 0 
			
			chkSX.tristate = 0
			chkSY.tristate = 0 
			chkSZ.tristate = 0
			
			chkMX.enabled = false
			chkMY.enabled = false
			chkMZ.enabled = false
			
			chkRX.enabled = false
			chkRY.enabled = false
			chkRZ.enabled = false
			
			chkSX.enabled = false
			chkSY.enabled = false
			chkSZ.enabled = false
			
		)
		else 
			(
			for i in 1 to _ba.count do
			(
				chkMX.enabled = true
				chkMY.enabled = true
				chkMZ.enabled = true
				
				chkRX.enabled = true
				chkRY.enabled = true
				chkRZ.enabled = true
				
				chkSX.enabled = true
				chkSY.enabled = true
				chkSZ.enabled = true
				
				
				case _ba[i] of
				(
					0: _bb[i] = 0
					1: _bb[i] = 1
					true: _bb[i] = 1
					false: _bb[i] = 0
					2: _bb[i] = 2
					undefined: _bb[i] = 0
				)
				
			)
			chkMX.tristate = _bb[1]
			chkMY.tristate = _bb[2]
			chkMZ.tristate = _bb[3]
			
			chkRX.tristate = _bb[4] 
			chkRY.tristate = _bb[5] 
			chkRZ.tristate = _bb[6] 
			
			chkSX.tristate = _bb[7] 
			chkSY.tristate = _bb[8] 
			chkSZ.tristate = _bb[9] 
		)
	)
	
	fn SetLocks = 
	(
		_mba = #{}
		_mba[1] = chkMX.checked
		_mba[2] = chkMY.checked
		_mba[3] = chkMZ.checked
		
		_mba[4] = chkRX.checked
		_mba[5] = chkRY.checked
		_mba[6] = chkRZ.checked
		
		_mba[7] = chkSX.checked
		_mba[8] = chkSY.checked
		_mba[9] = chkSZ.checked
		
		setTransformLockFlags selection _mba
	)
	
	on btnML pressed do
	(
		chkMX.checked = true
		chkMY.checked = true
		chkMZ.checked = true
		SetLocks()
	)
	on btnMU pressed do
	(
		chkMX.checked = false
		chkMY.checked = false
		chkMZ.checked = false
		SetLocks()
	)
	on btnRL pressed do
	(
		chkRX.checked = true
		chkRY.checked = true
		chkRZ.checked = true
		SetLocks()
	)
	on btnRU pressed do
	(
		chkRX.checked = false
		chkRY.checked = false
		chkRZ.checked = false
		SetLocks()
		
	)
	on btnSL pressed do
	(
		chkSX.checked = true
		chkSY.checked = true
		chkSZ.checked = true
		SetLocks()
	)
	on btnSU pressed do
	(
		chkSX.checked = false
		chkSY.checked = false
		chkSZ.checked = false
		SetLocks()
	)
	on btnGL pressed do
	(
		chkMX.checked = true
		chkMY.checked = true
		chkMZ.checked = true
		chkRX.checked = true
		chkRY.checked = true
		chkRZ.checked = true
		chkSX.checked = true
		chkSY.checked = true
		chkSZ.checked = true
		SetLocks()
	)
	on btnGU pressed do
	(
		chkMX.checked = false
		chkMY.checked = false
		chkMZ.checked = false
		chkRX.checked = false
		chkRY.checked = false
		chkRZ.checked = false
		chkSX.checked = false
		chkSY.checked = false
		chkSZ.checked = false
		SetLocks()
	)
	on chkMX changed val do
	(
		SetLocks()
	)
	on chkMY changed val do
	(
		SetLocks()
	)
	on chkMZ changed val do
	(
		SetLocks()
	)
	on chkRX changed val do
	(
		SetLocks()
	)
	on chkRY changed val do
	(
		SetLocks()
	)
	on chkRZ changed val do
	(
		SetLocks()
	)
	on chkSX changed val do
	(
		SetLocks()
	)
	on chkSY changed val do
	(
		SetLocks()
	)
	on chkSZ changed val do
	(
		SetLocks()
	)
	
	on ttLinkInfo open do
	(
		UpdateLinkInfo()
		callbacks.addScript #selectionSetChanged "ttlinkinfo.UpdateLinkInfo()" id:#myLinkId
	)
	on ttLinkInfo close do
	(
		callbacks.removeScripts id:#myLinkId
	)
	
)

CreateDialog ttLinkInfo