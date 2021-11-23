/*********************************
**
**	TronoTools ORT changer v1.1
**				2015
**
**	v1.0 initial release
**	v1.1 added support for modifiers
**
**********************************/

struct TT_OutOfRange
(
	private
		MainUI,
	public
			
	fn ChangeOorType myController oorType prePost =
	(
		enableORTs myController true
		
		case prePost of
		(
			"Both":
			(
				setBeforeORT myController oorType
				setAfterORT myController oorType
			)
			"Before":
			(
				setBeforeORT myController oorType
			)
			"After":
			(
				setAfterORT myController oorType
			)
			default: (print "error" return false)
		)
		
	),
	
	fn DisableOor objController  =
	(
		enableORTs objController false
	),
	
	
	fn InitRollout =
	(
		MainUI = rollout tt_oor "TH: This is so out of range! I don't even.." width:304 height:120
		(
			local owner = if owner != undefined do owner
				
			dropdownList 'ddlOor' "OutOfRange Type" pos:[8,8] width:216 height:40 items:#(#Constant, #Cycle, #Loop, #PingPong, #Linear, #RelativeRepeat) align:#left
			button 'BTNOK' "Change" pos:[232,16] width:64 height:32 align:#left
			radiobuttons 'rdoWhere' "Pre/Post" pos:[8,72] width:171 height:30 labels:#("Both", "After", "Before") default:1 columns:3 align:#left
			button 'btnDisable' "Disable ORT" pos:[176,88] width:64 height:16 align:#left		
		
			checkbox 'chkPos' "Pos" pos:[8,56] width:48 height:16 checked:true align:#left
			checkbox 'chkRot' "Rot" pos:[56,56] width:48 height:16 checked:true align:#left
			checkbox 'chkScale' "Scale" pos:[104,56] width:48 height:16 align:#left
			checkbox 'chkModifiers' "Modifiers" pos:[160,56] width:60 height:16 align:#left
			
			on btnOk pressed do 
			(
				prepost = ""
				case rdoWhere.state of
				(
					1: ( prepost = "Both")
					2: ( prepost = "After")
					3: ( prepost = "Before")
				)
				undo on 
					for obj in selection do
					(
						if chkPos.checked then
						(
							print ddlOor.selected
							owner.changeOorType obj.position.controller ddlOor.selected prepost
						)
						if chkRot.checked then
						(
							owner.changeOorType obj.rotation.controller ddlOor.selected prepost
						)
						if chkScale.checked then
						(
							owner.changeOorType obj.scale.controller ddlOor.selected prepost
						)
						if chkModifiers.checked then
						(
							owner.changeOorType (getsubanim $ 4) ddlOor.selected prepost
						)
					)
			)
			on btnDisable pressed do
			(
				undo on 
					for obj in selection do
						owner.DisableOor obj
			)
		)
		tt_oor.owner = this 
		oorType = tt_oor.ddlOor.selected
		return MainUI
	),
	
	fn ShowUI =
	(
		MainUI = InitRollout()
		CreateDialog MainUI.tt_oor
	)
)

oorChanger = TT_OutOfRange()
oorChanger.ShowUI()