extends Node2D

# NodePaths are just things that are already in the scene. You can safely assume that they all have the global_position property.
# You can add nodes by placing the MovingPlatform Scene in the world and add Nodes to the array via the inspector.
# Also I suggest you have a look at the "Tween" Node for moving the platform!
#
# Don't worry, this will probably take less than an hour. Thanks for doing it!

export(bool) var start_active = false
export(Array, NodePath) var positions = []

var next_node = 0

func start():
    pass
    
func stop():
    pass
