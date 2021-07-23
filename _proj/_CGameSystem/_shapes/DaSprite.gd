tool
extends Sprite


export (bool) var Override

export (Dictionary) var Line = {
	"visible": true,
	"From": Vector2.ZERO,
	"To": Vector2.ZERO,
	"Color": Color(),
	"Linewidth": 1.0,
	"AA": true,
}

export (Dictionary) var Rectangle = {
	"visible": true,
	"Rect": Rect2(),
	"Color": Color(),
	"Filled": true,
	"Linewidth": 1.0,
	"AA": true,
}

export (Dictionary) var Circle = {
	"visible": true,
	"Position": Vector2.ZERO,
	"Radius": 0.0,
	"Color": Color(),
	"Filled": true,
	"Line_width": 1.0,
	"Line_segments": 50,
	"AA": true,
}

export (Dictionary) var Text = {
	"visible": true,
	"Text": "",
	"Position": Vector2.ZERO,
	"Color": Color(),
	"Font": null,
	"Clip_width": -1.0,
}



func _ready(): 
	pass
	
func _draw():
	if texture != null and not Override: return
	#
	#print(".")
	if Line.visible:
		draw_line (Line.From, Line.To, Line.Color, Line.Linewidth, Line.AA)
		#
	if Rectangle.visible:
		draw_rect (Rectangle.Rect, Rectangle.Color, Rectangle.Filled, Rectangle.Linewidth, Rectangle.AA)
	if Circle.visible:
		if Circle.Filled:
			draw_arc(Circle.Position, Circle.Radius, 0.0, PI*2.0, Circle.Line_segments, Circle.Color, 4.0, Circle.AA)
			draw_circle (Circle.Position, Circle.Radius, Circle.Color)
		else:
			draw_arc (Circle.Position, Circle.Radius, 0.0, PI*2.0, Circle.Line_segments, Circle.Color, Circle.Line_width, Circle.AA)
	if Text.visible:
		draw_string (Text.Font, Text.Position, Text.Text, Text.Color, Text.Clip_width)			
