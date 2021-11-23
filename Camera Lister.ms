/*
	Tronotools Camera Lister v0.2b
	created:		2017/03/09
	last modified: 2017/03/09
	
	Todo:
		DONE - Get all cameras in scene
		DONE - Sort out targets
		DONE - List in viewer
		DONE - Select camera
		DONE - Change view to camera
		- Set up frame ranges
		- Store in scene


*/

_cameraObjs = #()
_cameraNames = #()

fn GetCameraArray = 
(
	_camArray = for cam in cameras where classof cam != Targetobject collect cam
		
	return _camArray
)


rollout CamRollout "Scene Camera Selector" width:304 height:411
(
	listbox 'lbxCams' "Cameras" pos:[0,8] width:304 height:25 align:#left
	
	radioButtons 'rdo1' "" pos:[8,360] width:238 height:16 labels:#("Select from List", "View from List") columns:2 align:#left
	
	button 'btnSelect' "Select Camera" pos:[8,384] width:80 height:16 align:#left
	button 'btnView' "View Camera" pos:[128,384] width:80 height:16 align:#left
	button 'btnRefresh' "Refresh" pos:[232,384] width:64 height:16 align:#left
	
	fn ObjNameToArray theArray =
	(
		nameArray = #()
		for i = 1 to theArray.count do
		(
			nameArray[i] = theArray[i].name
		)
		return nameArray
	)
	
	fn UpdateRollout = 
	(
		_cameraObjs = GetCameraArray()
		_cameraNames = ObjNameToArray(_cameraObjs)
		
		
		lbxCams.items = #()
		lbxCams.items = _cameraNames
	)
		
	on CamRollout open do
	(
		UpdateRollout()
	)
	on btnSelect pressed do
	(
		select _cameraObjs[lbxCams.selection]
	)
	on btnView pressed do
	(
		viewport.setCamera _cameraObjs[lbxCams.selection]
	)
	on btnRefresh pressed do
	(
		UpdateRollout()
	)
	on lbxCams selected val do 
	(
		if rdo1.state == 1 then
		(
			select _cameraObjs[lbxCams.selection]
		)
		else 		
		(
			viewport.setCamera _cameraObjs[lbxCams.selection]
		)
	)
)

createDialog CamRollout