extends Panel
@onready var file: Label = $File
@onready var date: Label = $Date
@onready var playtime: Label = $Playtime
@onready var room: Label = $Room

@onready var weapon_display: HBoxContainer = $WeaponDisplay

var save_file_id:int = 0

func _ready() -> void:
	read_file()

func read_file() -> void:
	var file_path:String = "user://save"+str(save_file_id)+".save"
	# see if file exists
	if FileAccess.file_exists(file_path):
		# see progress.gd for data references
		var file_open = FileAccess.open(file_path, FileAccess.READ)
		var data_read:Dictionary = file_open.get_var()
		# clear weapon display nodes (prevents duplicates)
		for i in weapon_display.get_children():
			i.queue_free()
		for i:Weapon in GlobalWeapons.weapon_objects:
			if data_read.has("weapon_"+str(i.name)):
				if data_read["weapon_"+str(i.name)]["collected"]:
					var texture:TextureRect = TextureRect.new()
					texture.texture = i.icon
					weapon_display.add_child(texture)
		
		var load_playtime:float = data_read["play_time"]
		var hours = floor((load_playtime/60.0)/60.0)
		var minutes = floor(load_playtime/60.0)
		var seconds = fmod(load_playtime, 60.0)
		playtime.text = "%02d:%02d:%02d" % [hours, minutes, seconds]
		# I'm Australian and my date format is Day, Month, Year
		var date_dic = data_read["date_time"]
		date.text = "%02d/%02d/%04d" % [date_dic["day"], date_dic["month"], date_dic["year"]]
		room.text = data_read["room_name"]
	
	else: # blank file
		date.hide()
		playtime.hide()
		room.text = "Empty File"
	file.text = "Save "+str(save_file_id+1)
