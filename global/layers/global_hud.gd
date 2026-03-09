extends CanvasLayer

@onready var item_icon: Panel = $CoverIcon/ItemIcon
@onready var item_texture: TextureRect = $CoverIcon/ItemIcon/Texture
@onready var player_hud: Control = $PlayerHud

var player:Player = null:
	set(value):
		player = value
		player_hud.visible = player != null

# set boss health meter values
var meter:float = 0.0:
	set(value):
		meter = value
		$BossMeter/HealthBar.value = meter
		$BossMeter.visible = meter > 0.0


func _ready() -> void:
	GlobalWeapons.weapon_changed.connect(update_weapon_info)
	player_hud.visibility_changed.connect(update_weapon_info)
	item_icon.hide()
	player_hud.hide()


func _process(_delta: float) -> void:
	if player:
		$PlayerHud/HealthBar.value = (float(player.health.health)/float(player.health.max_health)) * 100.0
		$PlayerHud/Health.text = str(player.health.health)+"/"+str(player.health.max_health)

func set_item_vis(set_texture_visible:bool = true) -> void:
	item_icon.visible = set_texture_visible
	if Dialogic.VAR.ITEMS.is_weapon && Weapon.weapon_keys.has(Dialogic.VAR.ITEMS.item_id):
		var weapon:Weapon = Weapon.weapon_keys[Dialogic.VAR.ITEMS.item_id]
		$CoverIcon/ItemIcon/Texture.texture = weapon.item_icon
	elif !Dialogic.VAR.ITEMS.is_weapon && Item.item_keys.has(Dialogic.VAR.ITEMS.item_id):
		var item:Item = Item.item_keys[Dialogic.VAR.ITEMS.item_id]
		$CoverIcon/ItemIcon/Texture.texture = item.icon

func update_weapon_info() -> void:
	if GlobalWeapons.weapon:
		$PlayerHud/WeaponIcon.show()
		$PlayerHud/WeaponIcon.texture = GlobalWeapons.weapon.icon
		$PlayerHud/Ammo.visible = GlobalWeapons.weapon.max_ammo > 0
		$PlayerHud/Ammo.text = str(GlobalWeapons.weapon.ammo)+"/"+str(GlobalWeapons.weapon.max_ammo)
	else:
		$PlayerHud/Ammo.hide()
		$PlayerHud/WeaponIcon.hide()
