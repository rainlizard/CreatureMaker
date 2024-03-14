extends Node
var list = {}

func start(callingScene): # Called by Main root scene
	Nodelist.list["oMain"] = callingScene # Add callingScene manually since the node_added signal doesn't include adding it
	get_tree().node_added.connect(node_added)

func done(): #Called by SubViewportContainer
	get_tree().node_added.disconnect(node_added)
	print('Nodes added to Nodelist: '+str(Nodelist.list.size()))

func node_added(nodeID):
	if nodeID.owner != null:
		Nodelist.list['o'+str(nodeID.name)] = nodeID

func get_player_node(nodeName, ownership):
	match ownership:
		1: return Nodelist.list[nodeName + "P1"]
		2: return Nodelist.list[nodeName + "P2"]
	assert(ownership != 0) #,"get_player_node() was used while ownership was 0")
