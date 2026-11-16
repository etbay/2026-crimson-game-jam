extends Node



var sfx: Dictionary[String, AudioStream] = {
	"parry": preload("uid://cg1hi3fsngehi"),
	"gain_health": preload("uid://blch70dyjjsr4"),
	"absorb_bullet": preload("uid://df728cm1gg08"),
	"activate_beast_mode": preload("uid://bkplao7c8fj38"),
	"cthulu_hurt1": preload("uid://6x0l2d6ixt55"),
	"cthulu_hurt2": preload("uid://byj2p08asy7hg"),
	"cthulu_death": preload("uid://c86c0jx0kcmgm"),
	"statue_hurt": preload("uid://41wj6q4aq3fr"),
	"statue_death": preload("uid://dsoyopagsm6n5"),
	"player_shoot": preload("uid://dn4totoqav2cy"),
	"player_hurt": preload("uid://8ljfvd4tlbey"),
	"dash": preload("uid://di0rl1wvs3vhb"),
	"laser": preload("uid://bmh5u7v4fu44s"),
	"roar": preload("uid://doc7hwrc4sqlu")
}

var music: Dictionary[String, AudioStream] = {
	"cthulu_fight_theme": preload("uid://8tak7dptne0d"),
	"tutorial_theme": preload("uid://djjv2dfhpgeou"),
	"title_theme": preload("uid://cyyeexrpl0ptb"),
}
