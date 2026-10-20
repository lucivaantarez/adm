getgenv().VO_CONFIG = {
    -- === HUB / AUTH ===
    HubKey = "ztOZVe47zX7dsa7JJKpxWYLg7NThkueue96KcFuPn1s",
    DeviceName = "1",

    -- === MAIN FARM (choose one mode) ===
    PotFarm = true,
    EggFarm = false,
    PetFarm = true, -- Third mode: farm pets from PetFarmList in order (natural task-aging)
    EggBuy = true, -- If true (default): buy an egg when none in inventory. If false: no target eggs -> switch to PotFarm
    KeepEggFarm = false, -- If true, will keep trying to hatch eggs even when no bucks
    KeepPetFarm = true, -- If true, will switch back when PetFarmList targets appear
    EggName = {"Egg Name"},  -- Priority order: first egg tried, then second, etc.
    PetFarmList = {}, -- Ordered pet names: age all non-FG of first name, then second, etc.; fallback if none available
    PrioritizePet = "2D Kitty",

    -- === HALLOWEEN 2026 EVENT ===
    AutoCandyCornPile = false,        -- Claim the Candy Corn Pile (requires the 1.25x Candy Multiplier gamepass)
    GhostClustersMinigame = false,     -- Ghost Gallery minigame (on unless set to false; farm tasks pause while it runs; drops Crypt Keys)
    HauntletMinigame = true,          -- Hauntlet 2 door-picking minigame (on unless set to false; farm tasks pause while it runs)
    SpotlightMinigame = false,         -- Spotlight circus candy corn minigame (on unless set to false; farm tasks pause while it runs)

    -- === PET PEN ===
    PetPen = true,
    CustomPenEggs = {"Cracked Egg"},
    CustomPenPets = {"Ant", "Mouse"},
    PrioritizePetPenTypes = {"Egg", "Neon", "Normal"},  -- "Egg", "Normal", "Neon" (empty = all)

    -- === PET RELEASER ===
    PetReleaser = true,
    ReleasePets = {
        "Mega Ant",
        "Mega Mouse",
        "Camel",
        "Donkey",
        "Poodle",
        "Orangutan",
        "Parakeet",
        "Zebra",
        "Corgi",
        "Robot",
        "Swordfish",     
    },       -- Whitelist: names to release (empty = all)
    ExcludeReleasePets = {
        "Frostbite Bear",
        "Dragonfruit Fox",
        "Dango Penguins",
        "Silverback Gorilla",
        "Sushi Penguin",
        "Velocirooster",
        "2D Doggy",
        "2D Kitty",
        "Rainbow Trout",
        "Tealwood Monster",
        "Oakee Wizard",
        "General Sheepdog",
        "Chihuahua",
        "Sunflower Friend",
        "Violet Friend",
        "Alicorn",
        "Ancient Dragon",
        "Blue Whale",
        "Sea Turtle",
        "Dragonfly",
        "Kiwi Kiwi",
        "Huntsman Robin",
        "Three Blind Mice",
        "Skelicorn",
        "Stitches"
    }, -- Blacklist: base names or prefixed like ReleasePets ("Neon Dog", "Normal Cat", "Mega FG X")
    ReleaseTypes = {},      -- "Mega", "Neon", "Normal" (empty = all)
    ReleaseRarities = {},   -- If ReleasePets non-empty: only used for pets NOT named in ReleasePets. If ReleasePets empty: filters all candidates.
    ExcludeRarities = {"Legendary"},   -- Blacklist rarities (pets on ReleasePets by name bypass this)

    -- === AGE PETS ===
    AgePets = false,
    AgePetsNames = {},
    AgePetsTypes = {"Normal"},  -- "Normal", "Neon", "ALL"

    -- === AUTO FUSE ===
    AutoFuse = true,
    AutoFuseBlacklist = {}, -- Pet names to never include in neon/mega fusion

    -- === BUY PETS ===
    BuyPets = true,
    BuyPetName = {"Skelicorn", "Crystal Egg", "Cracked Egg"},  -- Loops in order, buys all of first pet then moves to next

    -- === STAR REWARDS SHOP ===
    BuyStarRewards = true,
    StarRewardBuyList = {"Gemstone Egg"},

    -- === BOXES ===
    BuyBoxes = false,
    BoxName = {"Box Name"},   -- Boxes to buy when BuyBoxes is true
    OpenBoxes = {"Box Name"}, -- Box names to open from inventory

    -- === LURE ===
    BaitName = "Ice Soup Bait",

    -- === AUTO TRADE ===
    AutoTrade = true,
    ReceiverUsernames = {
            "bcbcbbb7263663",
            "bdxbxxhgdb67366",
            "bsbshs62626262",
            "bshs626w6hs",
            "bsu22ue737ehsh",
            "bsuw72u2nwu",
            "dhhdhddhhh66yy",
            "ebdbdhhshbs64663",
            "hdhdbdh73637",
            "hebss7366",
            "hedhehsbsbbs63736",
            "hehdh7373uhd",
            "hs772h2eu7",
            "hs62626hs7",
            "hshbwbsbs7726",
            "hshhshsbs627",
            "hshshwbsbs6372",
            "hshssvxvjwn876",
            "hzhbs637",
            "jsiwiiwuklo6262",
            "jsjjssyou838373",
            "jsjs772jw",
            "jsjsh63hebbw82",
            "jsn6bs73636he",
            "kk737usjsj72",
            "kk77037une",
            "kkjjjj9876",
            "ksskmsmsks737737",
            "llijnjk98767",
            "mdmsooyou77",
            "mzjajjaahshsh6636363",
            "mzkkss77u",
            "nsnsjsnsjj66",
            "ooeou337",
            "sbhs77236",
            "sjjsjj72727272",
            "sjjsjwjj72727",
            "sujssjjsss63636",
            "wwhshjsj6736",
            "ywhshwhsb87",
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
            "Stitches"
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
