extends Button

@onready var oAutofillConfirmationDialog = Nodelist.list["oAutofillConfirmationDialog"]
@onready var oAutofillSpinBox = Nodelist.list["oAutofillSpinBox"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oBuiltInAnimationOptions = Nodelist.list["oBuiltInAnimationOptions"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

func _on_pressed():
	oAutofillConfirmationDialog.popup_centered()

func _on_autofill_confirmation_dialog_confirmed():
	var idx = oBuiltInAnimationOptions.selected
	if idx <= 0:
		oMessage.quick("You need to select an animation first.")
		return

	oFrameManager.delete_frames_of_animation(oSelectCurrentAnimation.selected)

	var numOfNewFrames = oAutofillSpinBox.value
	var current_anim_data = Anim.data[oSelectCurrentAnimation.selected]
	var rotatable = current_anim_data[Anim.ROTATABLE]

	if rotatable:
		for rot in range(Anim.degreesArray.size()):
			var tdFg = current_anim_data[Anim.TD_FRAMEGROUP][rot]
			var fpFg = current_anim_data[Anim.FP_FRAMEGROUP][rot]
			
			for i in numOfNewFrames:
				var tdFrame = tdFg.add_frame()
				tdFrame.initialize(["Frame", "AnimationFrame", "TopDownFrame"])
				
				var fpFrame = fpFg.add_frame()  
				fpFrame.initialize(["Frame", "AnimationFrame", "FirstPersonFrame"])

				var tdFpArray = [[tdFrame], [fpFrame]]
				
				for perspective in tdFpArray:
					for frame in perspective:
						var aniPlayer = frame.model_get_part("AnimationPlayer")
						if aniPlayer == null:
							break

						var menuOptionString = oBuiltInAnimationOptions.get_item_text(idx)
						aniPlayer.play(menuOptionString)
						aniPlayer.pause()

						var seekPos = lerp(0.0, aniPlayer.current_animation_length, float(i + 1) / float(numOfNewFrames))
						aniPlayer.seek(seekPos, true)

						var degrees = Anim.degreesArray[rot]
						frame.set_camera_rotation(Vector3(0, degrees, 0))
	else:
		var tdFg = current_anim_data[Anim.TD_FRAMEGROUP][0] 
		var fpFg = current_anim_data[Anim.FP_FRAMEGROUP][0]
		
		for i in numOfNewFrames:
			var tdFrame = tdFg.add_frame()
			tdFrame.initialize(["Frame", "AnimationFrame", "TopDownFrame"])

			var fpFrame = fpFg.add_frame()
			fpFrame.initialize(["Frame", "AnimationFrame", "FirstPersonFrame"])

			var tdFpArray = [[tdFrame], [fpFrame]]
			
			for perspective in tdFpArray:
				for frame in perspective:
					var aniPlayer = frame.model_get_part("AnimationPlayer")
					if aniPlayer == null:
						break

					var menuOptionString = oBuiltInAnimationOptions.get_item_text(idx)
					aniPlayer.play(menuOptionString)
					aniPlayer.pause()

					var seekPos = lerp(0.0, aniPlayer.current_animation_length, float(i + 1) / float(numOfNewFrames))
					aniPlayer.seek(seekPos, true)
	
	oFrameUpdater.apply_settings_to_current_animation_frames()
	oFrameUpdater.redraw_frames()
