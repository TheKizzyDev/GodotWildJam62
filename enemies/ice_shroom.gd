extends "res://enemies/enemy_base.gd"


func attack():
	$Skin.play("attack")
	super.attack()


func enter_idle():
	super.enter_idle()
	$Skin.play("idle")


func enter_walk():
	super.enter_walk()
	$Skin.play("walk")
