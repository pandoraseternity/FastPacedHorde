-- Useage example:
-- To get the damageMultiplier of the current difficulty: HORDE.Difficulty[HORDE.CurrentDifficulty].damageMultiplier

HORDE.LogbookEnemies = {
    [1] = {
        name = "Sprinter/Walker",
		type = "Common Zombie"
		description = "" ,
    },
    [2] = {
        name = "Exploder",
		type = "Common Zombie"
		description = "" ,
    },
    [3] = {
        name = "Crawler",
		type = "Common Zombie"
		description = "" ,
    },
    [4] = {
        name = "Scragg",
		type = "Common Zombie"
		description = "" ,
    },
    [5] = {
        name = "Healer",
		type = "Common Zombie"
		description = "" ,
    },
	[6] = {
        name = "Wraith",
		type = "Uncommon Zombie"
		description = "" ,
    },
    [7] = {
        name = "Cyst",
		type = "Uncommon Zombie"
		description = "" ,
    },
    [8] = {
        name = "Vomitter",
		type = "Uncommon Zombie"
		description = "" ,
    },
    [9] = {
        name = "Vommitter",
		type = "Uncommon Zombie"
		description = "" ,
    }
}

-- Making sure that all all keys are present
local requiredKeys = {
    "name",

}
