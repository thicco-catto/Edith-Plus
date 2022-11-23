local Constants = {}

--Enums
Constants.NORMAL_EDITH_PLAYER = Isaac.GetPlayerTypeByName("EdithPlus")

Constants.SALT_SHAKER_ITEM = Isaac.GetItemIdByName("Salt Shaker")
Constants.GOMORRAHS_DEMISE_ITEM = Isaac.GetItemIdByName("Gomorrah's Demise")
Constants.SODOMS_RAIN_ITEM = Isaac.GetItemIdByName("Sodom's Rain")
Constants.SALT_BABY_ITEM = Isaac.GetItemIdByName("Salt Baby")
Constants.LOTS_CUP_ITEM = Isaac.GetItemIdByName("Lot's Cup")
Constants.EDITHS_SCARF_ITEM = Isaac.GetItemIdByName("Edith's Scarf")
Constants.EDITHS_CURSE_ITEM = Isaac.GetItemIdByName("Edith's Curse")

Constants.SMALL_METEORITE_FAMILIAR = Isaac.GetEntityVariantByName("small rain meteorite")
Constants.BIG_METEORITE_FAMILIAR = Isaac.GetEntityVariantByName("big rain meteorite")
Constants.SALT_BABY_FAMILIAR = Isaac.GetEntityVariantByName("salt baby")

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

Constants.CompletionMark = {
    HEART = "HEART",
    ISAAC = "ISAAC",
    BLUE_BABY = "BLUE_BABY",
    SATAN = "SATAN",
    LAMB = "LAMB",
    MEGA_SATAN = "MEGA_SATAN",
    BOSS_RUSH = "BOSS_RUSH",
    HUSH = "HUSH",
    GREED = "GREED",
    DELIRIUM = "DELIRIUM",
    MOTHER = "MOTHER",
    BEAST = "BEAST"
}

--For normal Edith
Constants.MINIMUM_TRAVEL_DISTANCE = 10
Constants.TARGET_SPRITE_PLAYBACK_SPEED = 0.8
Constants.TARGET_BASE_SPEED = 30
Constants.MAX_DISTANCE_TO_DOOR_TO_INTERACT = 40
Constants.MAX_SAFETY_ROOM_TRANSITION_TIMER = 20
Constants.MAX_FRAMES_TO_TP = 2
Constants.MINI_MAGNETO_RADIUS = 35
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
	{Variant = PickupVariant.PICKUP_PILL, SubType = -1},
	{Variant = PickupVariant.PICKUP_LIL_BATTERY, SubType = -1},
	{Variant = PickupVariant.PICKUP_TAROTCARD, SubType = -1},
	{Variant = PickupVariant.PICKUP_TRINKET, SubType = -1},
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

--Sodom's rain stuff
Constants.SODOMS_RAIN_METEORITE_MIN_INTERVAL = 60
Constants.SODOMS_RAIN_METEORITE_BASE_SPAWN_CHANCE = 100

--Gomorrah's demise stuff
Constants.GOMORRAHS_DEMISE_DURATION = 20 * 30 --20 seconds
Constants.GOMORRAHS_DEMISE_METEORITE_INTERVAL = 12
Constants.GOMORRAHS_DEMISE_BIG_METEORITE_CHANCE = 10

--Small meteorite stuff
Constants.SMALL_METEORITE_FALLING_DIRECTION = Vector(1, 4):Normalized()
Constants.SMALL_METEORITE_FALLING_SPEED = 13
Constants.SMALL_METEORITE_STARTING_HEIGHT_BASE = 600
Constants.SMALL_METEORITE_STARTING_HEIGHT_RANDOM = 200
Constants.SMALL_METEORITE_RADIUS = 75
Constants.SMALL_METEORITE_DAMAGE = 3 --Multiplies player damage
Constants.SMALL_METEORITE_BURN_DURATION = 42
Constants.SMALL_METEORITE_BURN_DAMAGE = 3 --Multiplies player damage

--Big meteorite stuff
Constants.BIG_METEORITE_EXPLOSION_DAMAGE = 125
Constants.BIG_METEORITE_BURN_DURATION = 62
Constants.BIG_METEORITE_BURN_DAMAGE = 5 --Multiplies player damage

--Salt baby stuff
Constants.SALT_BABY_TEAR_RATE = 20
Constants.SALT_BABY_CREEP_TIMEOUT = 200
Constants.SALT_BABY_CREEP_SCALE = 1

--Lot's Cup stuff
Constants.LOTS_CUP_NAME = "Lot's Cup"
Constants.LOTS_CUP_DESCRIPTION = "Fill it"
Constants.LOTS_CUP_MAX_CHARGE = 20
Constants.LOTS_CUP_HELPER_ITEMS = {}
for i = 1, Constants.LOTS_CUP_MAX_CHARGE, 1 do
	table.insert(Constants.LOTS_CUP_HELPER_ITEMS, Isaac.GetItemIdByName("Lot's Cup " .. i))
end
Constants.LOTS_CUP_POSSIBLE_STATS = {
	CacheFlag.CACHE_FIREDELAY,
	CacheFlag.CACHE_LUCK,
	CacheFlag.CACHE_RANGE,
	CacheFlag.CACHE_SHOTSPEED,
	CacheFlag.CACHE_SPEED
}
Constants.LOTS_CUP_STAT_MULTIPLIER = {
	[CacheFlag.CACHE_DAMAGE] = 0.07,
	[CacheFlag.CACHE_FIREDELAY] = 0.1,
	[CacheFlag.CACHE_LUCK] = 0.05,
	[CacheFlag.CACHE_RANGE] = 10,
	[CacheFlag.CACHE_SHOTSPEED] = 0.01,
	[CacheFlag.CACHE_SPEED] = 0.01
}
Constants.LOTS_CUP_CREEP_SIZE_MULTIPLIER = 0.1
Constants.LOTS_CUP_CREEP_SIZE_SPEED = 0.2
Constants.LOTS_CUP_CREEP_TIMEOUT = 100

--Edith's Scarf stuff
Constants.EDITHS_SCARF_TEARDELAY = 1.5
Constants.EDITHS_SCARF_SHOTSPEED = 0.2
Constants.EDITHS_SCARF_LUCK = -1
Constants.EDITHS_SCARF_STAT_MULTIPLIER = 0.5

--Edith's Curse stuff
Constants.SALT_CURSE_CHANCE = 10
Constants.SALT_CURSE_INCREASED_CHANCE = 50
Constants.SALT_CURSE_SOUL_HEART_CHANCE = 50

return Constants