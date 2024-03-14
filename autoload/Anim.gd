extends Node

enum {
	NAME,
	TD_FRAMEGROUP,
	FP_FRAMEGROUP,
	FRAMECOUNT,
	ROTATABLE,
	TD_OFFSET,
	FP_OFFSET,
	INITIAL_FACEDIR,
}

const degreesArray = [0, -45, -90, -135, -180]
const default_td_offset = Vector2(0.5, 0.80)
const default_fp_offset = Vector2(0.5, 1.00)

var data = {
	# cfg animation name, fp frame group array, td frame group array, framecount, rotatable, fp_offset_uv, td_offset_uv, initial_facedir
	0: ["Stand", [null, null, null, null, null], [null, null, null, null, null], 1, true, default_td_offset, default_fp_offset, 0],
	1: ["Walk", [null, null, null, null, null], [null, null, null, null, null], 6, true, default_td_offset, default_fp_offset, 0],
	2: ["Drag", [null, null, null, null, null], [null, null, null, null, null], 0, true, default_td_offset, default_fp_offset, 0],  # Duplicate of ambulate
	3: ["Attack", [null, null, null, null, null], [null, null, null, null, null], 8, true, default_td_offset, default_fp_offset, 0],
	4: ["Dig", [null, null, null, null, null], [null, null, null, null, null], 0, true, default_td_offset, default_fp_offset, 0],
	5: ["Smoke", [null, null, null, null, null], [null, null, null, null, null], 0, true, default_td_offset, default_fp_offset, 0],
	6: ["Relax", [null, null, null, null, null], [null, null, null, null, null], 0, true, default_td_offset, default_fp_offset, 0],
	7: ["PrettyDance", [null, null, null, null, null], [null, null, null, null, null], 0, true, default_td_offset, default_fp_offset, 0],
	8: ["Hit", [null, null, null, null, null], [null, null, null, null, null], 1, true, default_td_offset, default_fp_offset, 0],
	9: ["PickedUp", [null], [null], 6, false, default_td_offset, default_fp_offset, 0],
	10: ["Slapped", [null, null, null, null, null], [null, null, null, null, null], 1, true, default_td_offset, default_fp_offset, 0],
	11: ["Celebrate", [null], [null], 4, false, default_td_offset, default_fp_offset, 0],
	12: ["LairSleep", [null], [null], 8, false, default_td_offset, default_fp_offset, 1],
	13: ["EatChicken", [null], [null], 8, false, default_td_offset, default_fp_offset, 1],
	14: ["Torture", [null], [null], 8, false, default_td_offset, default_fp_offset, 1],
	15: ["Complain", [null], [null], 4, false, default_td_offset, default_fp_offset, 1],
	16: ["Dying", [null], [null], 2, false, default_td_offset, default_fp_offset, 1],
	17: ["DeadSplat", [null], [null], 0, false, default_td_offset, default_fp_offset, 1],
	18: ["GFX18", [null], [null], 0, false, default_td_offset, default_fp_offset, 0],
	19: ["QuerySymbol", [null], [null], 0, false, default_td_offset, default_fp_offset, 0],  # Portrait
	20: ["HandSymbol", [null], [null], 0, false, default_td_offset, default_fp_offset, 0],  # Icon
	21: ["GFX21", [null], [null], 0, false, default_td_offset, default_fp_offset, 0],
}

var old_names = { # Just for backwards compatibility for opening old .creature files. I can remove this one day.
	"Walk" : "Ambulate",
	"Complain" : "Scream",
	"Hit" : "GotHit",
	"LairSleep" : "Sleep",
	"PickedUp" : "PowerGrab",
	"Slapped" : "GotSlapped",
	"Dying" : "DropDead",
}

#var old_names = {
	#"Ambulate" : "Walk",
	#"Scream" : "Complain",
	#"GotHit" : "Hit",
	#"Sleep" : "LairSleep",
	#"PowerGrab" : "PickedUp",
	#"GotSlapped" : "Slapped",
	#"DropDead" : "Dying",
#}
