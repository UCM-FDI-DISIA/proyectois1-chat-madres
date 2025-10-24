extends Button

@export var icon_scale := 0.1

func _ready():
	if icon:
		var img = icon.get_image()
		var new_size = img.get_size() * icon_scale
		img.resize(new_size.x, new_size.y)
		var tex = ImageTexture.create_from_image(img)
		self.icon = tex
		
