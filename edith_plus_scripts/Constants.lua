local Constants = {}

--Enums
Constants.NORMAL_EDITH_PLAYER = Isaac.GetPlayerTypeByName("EdithPlus")
Constants.TAINTED_EDITH_PLAYER = Isaac.GetPlayerTypeByName("EdithPlus", true)

Constants.SALT_SHAKER_ITEM = Isaac.GetItemIdByName("Salt Shaker")
Constants.EDITHS_CURSE_ITEM = Isaac.GetItemIdByName("Edith's Curse")


--Useful stuff
Constants.FLOAT_ANIM_PER_DIRECTION = {
	[Direction.NO_DIRECTION] = "FloatDown",
	[Direction.LEFT] = "FloatLeft",
	[Direction.UP] = "FloatUp",
	[Direction.RIGHT] = "FloatRight",
	[Direction.DOWN] = "FloatDown"
}
Constants.SHOOT_ANIM_PER_DIRECTION = {
	[Direction.NO_DIRECTION] = "FloatDown",
	[Direction.LEFT] = "FloatShootLeft",
	[Direction.UP] = "FloatShootUp",
	[Direction.RIGHT] = "FloatShootRight",
	[Direction.DOWN] = "FloatShootDown"
}
Constants.DIRECTION_TO_VECTOR = {
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1),
}


--For normal Edith
Constants.MINIMUM_TRAVEL_DISTANCE = 10
Constants.TARGET_SPRITE_PLAYBACK_SPEED = 0.8
Constants.TARGET_BASE_SPEED = 30
Constants.MAX_DISTANCE_TO_DOOR_TO_INTERACT = 30
Constants.MAX_SAFETY_ROOM_TRANSITION_TIMER = 20
Constants.MAX_FRAMES_TO_TP = 2
Constants.MINI_MAGNETO_RADIUS = 45
Constants.MINI_MAGNETO_PICKUP_WHITELIST = {
	{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_BONE},
    {Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_BLENDED},
	{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_SOUL},
	{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_ETERNAL},
	{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_GOLDEN},
	{Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_HALF_SOUL},
	{Variant = PickupVariant.PICKUP_COIN, SubType = -1},
	{Variant = PickupVariant.PICKUP_KEY, SubType = -1},
	{Variant = PickupVariant.PICKUP_BOMB, SubType = -1},
	{Variant = PickupVariant.PICKUP_POOP, SubType = -1},
	{Variant = PickupVariant.PICKUP_GRAB_BAG, SubType = -1},
	{Variant = PickupVariant.PICKUP_LIL_BATTERY, SubType = -1},
}
Constants.MINI_MAGNETO_PICKUP_SPEED = 3
Constants.MINI_MAGENTO_PICKUP_ACCEL = 0.5
Constants.DEVIL_ENEMIES = {
	{EntityType.ENTITY_NULL, 0},			--Nulls
	{EntityType.ENTITY_EXORCIST, 0},		--Exorcist
	{EntityType.ENTITY_EXORCIST, 1},		--Fanatic
	{EntityType.ENTITY_IMP, 0},				--Imp
	{EntityType.ENTITY_BABY_BEGOTTEN, 0},	--Baby begotten
	{EntityType.ENTITY_KNIGHT, 4},			--Black knight
	{EntityType.ENTITY_WHIPPER, 2},			--Flagellant
	{EntityType.ENTITY_DOPLE, 1},			--Evil twin
	{EntityType.ENTITY_VIS_FATTY, 0},		--Vis fatty
	{EntityType.ENTITY_VIS_FATTY, 1},		--Fetal demon
	{EntityType.ENTITY_SHADY, 0},			--Shady
	{EntityType.ENTITY_BLACK_MAW, 0},		--Black maw
	{EntityType.ENTITY_REVENANT, 0},		--Revenant
	{EntityType.ENTITY_REVENANT, 1},		--Quad revenant
	{EntityType.ENTITY_BEGOTTEN, 0},		--Begotten
	{EntityType.ENTITY_GOAT, 0},			--Goat
	{EntityType.ENTITY_GOAT, 1},			--Black goat
	{EntityType.ENTITY_CULTIST, 0},			--Cultist
	{EntityType.ENTITY_CULTIST, 1},			--Blood cultist
	{EntityType.ENTITY_DARK_ONE, 0},		--Dark one
	{EntityType.ENTITY_SIREN, 0},			--The siren
	{EntityType.ENTITY_FALLEN, 0},			--The fallen
	{EntityType.ENTITY_FALLEN, 1},			--Krampus
	{EntityType.ENTITY_ADVERSARY, 0},		--The adversary
	{EntityType.ENTITY_SATAN, 0},			--Satan
	{EntityType.ENTITY_SATAN, 10},			--Satan leg
	{EntityType.ENTITY_THE_LAMB, 0},		--The lamb
	{EntityType.ENTITY_THE_LAMB, 10},		--The lamb
	{EntityType.ENTITY_BIG_HORN, 0},		--Big horn
	{EntityType.ENTITY_LITTLE_HORN, 0}		--Little horn
}
Constants.CHANCE_REPLACE_FIRST_DEAL_1 = 50
Constants.CHANCE_REPLACE_FIRST_DEAL_2 = 25
Constants.EDITH_TEAR_SCALE = 0.2

--Salt shaker stuff
Constants.SALT_CREEP_SCALE = 1
Constants.SALT_CREEP_TIMEOUT = 300
Constants.SALT_CREEP_SEPARATION = 20
Constants.SALT_CREEP_DAMAGE = 2

--Edith's Curse stuff
Constants.SALT_CURSE_CHANCE = 10
Constants.SALT_CURSE_NO_SOUL_HEART_CHANCE = 25
Constants.SALT_CURSE_DOUBLE_SOUL_HEART_CHANCE = 25

return Constants