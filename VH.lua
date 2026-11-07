getgenv().VO_CONFIG = {
    -- === HUB / AUTH ===
    HubKey = "ztOZVe47zX7dsa7JJKpxWYLg7NThkueue96KcFuPn1s",
    DeviceName = "lvr",

    -- === MAIN FARM (choose one mode) ===
    PotFarm = true,
    EggFarm = false,
    PetFarm = true, -- Third mode: farm pets from PetFarmList in order (natural task-aging)
    EggBuy = true, -- If true (default): buy an egg when none in inventory. If false: no target eggs -> switch to PotFarm
    KeepEggFarm = false, -- If true, will keep trying to hatch eggs even when no bucks
    KeepPetFarm = false, -- If true, will switch back when PetFarmList targets appear
    EggName = {"Egg Name"},  -- Priority order: first egg tried, then second, etc.
    PetFarmList = {}, -- Ordered pet names: age all non-FG of first name, then second, etc.; fallback if none available
    Farm2DEvent = false,
    PrioritizePet = "",

    -- === PET PEN ===
    PetPen = true,
    CustomPenEggs = {"Cracked Egg"},
    CustomPenPets = {"Ant", "Mouse"},
    PrioritizePetPenTypes = {"Egg", "Normal", "Neon"},  -- "Egg", "Normal", "Neon" (empty = all)

    -- === PET RELEASER ===
    PetReleaser = true,
    ReleasePets = {
        "Neon Ant",
        "Neon Mouse",
        "Camel",
        "Donkey",
        "Poodle",
        "Orangutan",
        "Parakeet",
        "Zebra",
        "Corgi",
        "Robot",
        "Swordfish",     
        "Mummy Spider",
    },       -- Whitelist: names to release (empty = all)
    ExcludeReleasePets = {
        "Chihuahua",
        "Stitches",
    }, -- Blacklist: base names or prefixed like ReleasePets ("Neon Dog", "Normal Cat", "Mega FG X")
    ReleaseTypes = {},      -- "Mega", "Neon", "Normal" (empty = all)
    ReleaseRarities = {},   -- If ReleasePets non-empty: only used for pets NOT named in ReleasePets. If ReleasePets empty: filters all candidates.
    ExcludeRarities = {"Legendary"},   -- Blacklist rarities (pets on ReleasePets by name bypass this)

    -- === AGE PETS ===
    AgePets = true,
    AgePetsNames = {"Ant", "Mouse"},
    AgePetsTypes = {"All"},  -- "Normal", "Neon", "ALL"

    -- === AUTO FUSE ===
    AutoFuse = true,
    AutoFuseBlacklist = {}, -- Pet names to never include in neon/mega fusion

    -- === BUY PETS ===
    BuyPets = true,
    BuyPetName = {"Crystal Egg", "Cracked Egg"},  -- Loops in order, buys all of first pet then moves to next

    -- === STAR REWARDS SHOP ===
    BuyStarRewards = false,
    StarRewardBuyList = {"Gemstone Egg"},

    -- === BOXES ===
    BuyBoxes = false,
    BoxName = {"Box Name"},   -- Boxes to buy when BuyBoxes is true
    OpenBoxes = {"Box Name"}, -- Box names to open from inventory

    -- === LURE ===
    BaitName = "Cyclone Sponge Bait",
    LightningFarm = true,

    -- === AUTO TRADE ===
    AutoTrade = true,
ReceiverUsernames = {
"sbjs13fczo55",
"rzumvhap1580",
"rypv94xngv22",
"ryeb41ubmk34",
"saej84jkqz14",
"saeg54tabv33",
"sady00zkqg43",
"ryhzntkl7000",
"saeh71mzao92",
"rzom91scru59",
"sajh97xryd87",
"rsic57rvgo53",
"rxoj15ynqn11",
"rsib51zzvw52",
"rsibdlqd6382",
"sazstvob4428",
"sadf44vdzd59",
"sbijucib5104",
"saheomce7206",
"rzfaytcc5196",
    },
    TradeItemList = {
         pets = {
            "Skelicorn",
            "Crystal Egg",
            "Mummy Spider",
            "Alicorn",
            "Ancient Dragon",
            "Dragonfly",
            "Frostbite Bear",
            "Stitches",
            "Admin Abuse Egg",
            "Stray Cat Dragon",
            "Pandaguin Glooptodog",
            "Electric Hornet",
            "Thunderfisher",
            "Haetyphoon",
        }
    }, -- Per category: { pets = {"Dog","Neon Cat"}, food = {}, toys = {}, ... } ? use "ALL" in a category to allow that whole category (pets still gated by TradePetType for bare names)
    TradePetType = {"ALL"},       -- Only applies to pets: "ALL", "Mega", "Neon", "Regular", "Neon_FG", "Regular_FG" ? not used for food/toys/etc.; inline prefixes on pet strings (e.g. "Mega Dog") bypass this

    -- === CASH TRANSFER ===
    CashTransfer = false,
    TransferMethods = {"mannequin"},  -- Current Methods: "mannequin"
    TransferAccount = "",

    -- === DISCORD WEBHOOK ===
    WebhookEnabled = false,
    WebhookURL = "",
    WebhookPets = {},  -- Pet names to send (empty = all)

    -- === ACCOUNT FEATURES (stop when Conditions met; FarmSync / FarmersV5 only) ===
    AccountFeatures = {
        Enabled = false,
        RequireAll = true, -- true = AND all conditions; false = OR any one
        Conditions = {
            -- { Type = "PetCount", PetName = "Mega Neon Dog", MinCount = 16 },
            -- { Type = "Currency", Currency = "money", MinAmount = 100000 },
            -- { Type = "SessionMinutes", MinMinutes = 180 },
        },
        ["Selected Tool"] = "FarmSync", -- or "FarmersV5"
        FarmSync = {
            DisableAccount = false,
            AutoChange = false,
            StartFolderId = "",
            EndFolderId = "",
            ConfigId = "",
        },
        FarmersV5 = {
            DisableAccount = false,
            APIKey = "",
            AutoSwap = false,
            AutoSwapOption = 1,
            AutoSwapCooldown = 100,
        },
    },

    ExtraOpti = true
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/voltrex2/VoHub/refs/heads/main/FARM"))()
