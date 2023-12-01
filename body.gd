extends Sprite2D
var currentdirection=Vector2.ZERO
var directionArray=[]
var positionArray=[]
func _process(delta):
	position+=currentdirection*2
	if directionArray.size()>0:
		if position*currentdirection==positionArray[0]*currentdirection:
			currentdirection = directionArray[0]
			directionArray.pop_front()
			positionArray.pop_front()
func addtoTail(pos,dir):
	positionArray.append(pos)
	directionArray.append(dir)
	
