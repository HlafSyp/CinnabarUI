local _, _, Cfg, _ = unpack(select(2,...))

local Auras = {
  -- This config is for configuring what auras will show in both the aura bars
  -- and the typical auras on unit frames

  -- To add a buff/Debuff to this config, pick out the correct list
  -- And add it in the following way
  -- [SPELL_ID] = "SPELL_NAME",
  -- [BUFF_ID] = "BUFF_NAME",
  -- [SPELL_ID] =  true,
  -- [BUFF_ID] = true,
  -- The ID of the spell or buff will always be first, followed by either the
  -- name or true. Then a comma must come afterwords otherwise the addon will
  -- break.
  -- What follows after the equals sign can really be anything since I only
  -- check if it is not nil and not false
  -- Which, if its in the list and not false, it will display

  -------------------------------------------------------------------------------
  -- Class Buffs
  -- Shows on player frame and enemy player's target frame
  -- Holds any and all Class buffs, I don't play every class to a high level so
  -- not every "Important" buff from every class is in this list but I play
  -- every class to some degree and so most buffs will be here
  -------------------------------------------------------------------------------
  CB = {
  -- Death Knight
  [48707] = 'Anti-Magic Shell',
  [101568] = 'Dark Succor',
    -- Blood
    [195181] = 'Bone Shield',
    [194679] = 'Rune Tap',
    [273947] = 'Hemostasis',
    -- Frost
    -- Unholy
  -- Demon Hunter
  [187827] = 'Metamorphosis',
  [203981] = 'Soul Fragments',
    -- Havoc
    -- Vengeance
    [203819] = 'Demon Spikes',
    [258920] = 'Immolation Aura',
  -- Druid
  [22812] = 'Barkskin',
  [319454] = 'Heart of the Wild', -- I really dislike this ability as a druid, Offers literally nothing fun
    -- Balance
    -- Feral
    [61336] = 'Survival Instincts',
    [50334] = 'Berserk',
    [102543] = 'Incarnation: King of the Jungle',
    [5217] = 'Tiger\'s Fury',
    -- Resto
    -- Guardian
    [192081] = 'Iron Fur',
    [22842] =  'Frenzied Regeneration',
    [102558] = 'Incarnation: Guardian of Ursoc',
  -- Hunter
    -- Beast Mastery
    -- Marksmanship
    -- Survival
  -- Mage
    -- Arcane
    -- Fire
    -- Frost
  -- Monk
    -- Brewmaster
    -- Mistweaver
    -- Windwalker
  -- Paladin
    -- Holy
    -- Protection
    -- Retribution
  -- Priest
    [19236] = 'Desperate Prayer',
    [17] = 'Power Word: Shield',
    -- Discipline
      [194384] = 'Atonement',
      [33206] = 'Pain Suppression',
      [47536] = 'Rapture',

    -- Holy
    -- Shadow
  -- Rogue
    [1784] = 'Stealth',
    -- Assassin
    -- Outlaw
    [315496] = 'Slice and DIce',
    -- Subtlety
  -- Shaman
    [974] = 'Earth Shield',
    [192106] = 'Lightning Shield',
    [77762] = 'Lava Surge',
    -- Elemental
    -- Enhancement
    -- Restoration
      [53390] = 'Tidal Waves',
      [61295] = 'Riptide',
      [73685] = 'Unleash Life',
  -- Warlock
    -- Affliction
    -- Demonology
    -- Destruction
  -- Warrior
    -- Arms
    -- Fury
    -- Protection
  },

  -------------------------------------------------------------------------------
  -- Class Debuffs
  -- Shows on target frames
  -- Holds any class specific debuffs, I don't play every class to a high level so
  -- not every "Important" debuff from every class is in this list but I play
  -- every class to some degree and so most debuffs will be here
  -- This list keeps track of things like
  -- Rip, sunfire, Moonfire, Rake, Fiery Brand, Paralysis, Cheap Shot, etc
  -------------------------------------------------------------------------------
  CD = {},

  -------------------------------------------------------------------------------
  -- Buffs
  -- This will show on the Player Frame and Target Frame
  -- These are any miscellaneous Buffs that may be important to the player
  -- By default this list hold nothing, but is formatted the same way as with
  -- The other lists
  -------------------------------------------------------------------------------
  B = {},

  -------------------------------------------------------------------------------
  -- Debuffs
  -- This will show on the Player Frame and Target Frame
  -- These are any miscellaneous Debuffs that may be important to the player
  --  By default this list holds nothing, but is formatted the same way as with
  -- the other lists
  -------------------------------------------------------------------------------
  D = {},
  -------------------------------------------------------------------------------
  -- Raid/Dungeon Buffs/Debuffs
  -- Shows on Enemy Mob's Target frame
  -- These are any important Buffs/Debuffs that need to be kept track of while
  -- in instanced content. Things like raid and dungeons
  -- An example would be like from Shrine of the Storm, with the Renewing Tides
  -- buff
  -- Or keeping track of the Feeding Frenzy on Blackwater Behemoth in Eternal
  -- Palace
  -- By Default, this list will have nothing, unless I come across something
  -- THat I want in here
  -------------------------------------------------------------------------------
  RD = {},
  -------------------------------------------------------------------------------
  -- Bypass Filters
  -- This will bypass any of the filters above when set to true
  -------------------------------------------------------------------------------
  Bypass = false,
}

Cfg.defaults = {
  -- Controls what module is enabled and which are disabled
  -- Takes a boolean value, true/false,
  -- True is enabled
  -- False is disabled
  Modules = {
    ["UnitFrames"]  = true,
    ["Tooltip"]     = true,
    ["Databar"]    = true,
  },
  -- UnitFrames Module Config
  UnitFrames = {
    Units = {
      group           = true,  -- Turns off ALL party and raid frames off
      party           = true,  -- Turns off 5  -man parties
      raid10          = true,  -- Turns off 10 -man raids
      raid20          = true,  -- Turns off 20 -man raids
      raid40          = true,  -- Turns off 40 -man raids
      single          = true,  -- Turn this to false to turn all unit frames off (Player, Target, etc)
      player          = true,  -- Turns off the player unitframe
      target          = true,  -- Turns off the target unitframe
      targettarget    = true,  -- Turns off the Target's Target unitframe
      focus           = true,  -- Turns off the focus unitframe
      focustarget     = true,  -- TUrns off the focus's target unitframe
      pet             = true,  -- TUrns off the pet unitframe
    },
    PercentagePower = {
      ['DEATHKNIGHT'] = {
        false, -- Blood
        true, -- Frost
        true, -- Unholy
      },
      ['DEMONHUNTER'] = {
        true, -- Havoc
        true, -- Vengeance
      },
      ['DRUID'] = {
        true, -- Balance
        false, -- Feral
        true, -- Guardian
        true, -- Resto
      },
      ['HUNTER'] = {
        true, -- BM
        true, -- Marksman
        true, -- Survival
      },
      ['MAGE'] = {
        true, -- ARcane
        true, -- Fire
        true, -- Frost
      },
      ['MONK'] = {
        true, -- Brewmaster
        true, -- Mistweaver
        true, -- Windwalker
      },
      ['PALADIN'] = {
        true, -- Holy
        true, -- Prot
        true, -- "Good" 'Ol Ret
      },
      ['PRIEST'] = {
        true, -- DISC
        true, -- Holy
        true, -- Shadow
      },
      ['ROGUE'] = {
        true, -- Assass
        true, -- Outlaw
        true, -- Sub
      },
      ['SHAMAN'] = {
        true, -- Ele
        true, -- Enhance
        true, -- Resto
      },
      ['WARLOCK'] = {
        true, -- Affliction
        true, -- Demo
        true, -- Destro
      },
      ['WARRIOR'] = {
        true, -- Arms
        true, -- Fury
        true, -- Protection
      },
      -- Can't wait for the next terribly balanced class to be added here
    },
    player = {

      -------------------------------------------------------
      ------ General Frame Options
      -------------------------------------------------------
      Width = 200,                    -- DEFAULT: 200
      Height = 25,                    -- DEFAULT: 30
      Anchor = "RIGHT",               -- DEFAULT: "RIGHT"
      ParentFrame = "UIParent",         -- DEFAULT: UIParent
      ParentAnchor = "CENTER",        -- DEFAULT: "CENTER"
      OffsetX = -200,                 -- DEFAULT: -200
      OffsetY = -200,                 -- DEFAULT: -200
      Mirror = false,                 -- DEFAULT: false
      EnableBackdrop = true,          -- DEFAULT: true
      BackdropInset = 2,              -- DEFAULT: 2
      BackdropOpacity = 1,            -- DEFAULT: 1
      HighlightOpacity = 0.2,         -- DEFAULT: 0.2
      -------------------------------------------------------
      ------ Health bar Options
      -------------------------------------------------------
      HealthBar = {
        Enabled = true,             -- DEFAULT: true
        Height = 20,                -- DEFAULT: 20
        colorTapping = true,        -- DEFAULT: true
        colorDisconnected = true,   -- DEFAULT: true
        colorClass = true,          -- DEFAULT: true
        colorReaction = true,       -- DEFAULT: true
        colorHealth = true,         -- DEFAULT: true
        BgBrightness = 0.3,         -- DEFAULT: 0.5
        ShortenHealthText = true,   -- DEFAULT: true
        HealthTextPrecision = 1,    -- DEFAULT: true
        ColorLevelText = true,      -- DEFAULT: true
      },

      -------------------------------------------------------
      ------- Power Bar Options
      -------------------------------------------------------
      PowerBar = {
        Enabled = true,             -- DEFAULT: true
        Height = 3,                 -- DEFAULT: 8
        Padding = 2,                -- DEFAULT: 2
        frequentUpdates = true,     -- DEFAULT: true
        colorTapping = true,        -- DEFAULT: true
        colorDisconnected = true,   -- DEFAULT: true
        colorPower = true,          -- DEFAULT: true
        colorClass = true,          -- DEFAULT: true
        colorReaction = true,       -- DEFAULT: true
        BgBrightness = 0.3,         -- DEFAULT: 0.5
      },

      -------------------------------------------------------
      ------ Aura Bars Options
      -------------------------------------------------------
      AuraBar =  {
        Enabled = true,             -- DEFAULT: true
        Height = 22,                -- DEFAULT: 25
        Spacing = 6,                -- DEFAULT: 6
        SmallBar = true,            -- DEFAULT: true
        ClassColoredBars = true,    -- DEFAULT: true
      },

      -------------------------------------------------------
      ------ Cast Bar Options
      -------------------------------------------------------
      CastBar = {
        Enabled = true,             -- DEFAULT: true
        Height = 20,
        Width = 500,
        BgBrightness = 0.5,
        Point = 'CENTER',
        relativeTo = "UIParent",
        relativePoint = 'CENTER',
        xOffset = 0,
        yOffset = -376,
        UninteruptibleColors = {0.5,0.5,0.5}
      },
    },
    target = {
      -------------------------------------------------------
      ------ General Frame Options
      -------------------------------------------------------
      Width = 200,                    -- DEFAULT: 200
      Height = 25,                    -- DEFAULT: 30
      Anchor = "LEFT",                -- DEFAULT: "RIGHT"
      ParentFrame = "UIParent",       -- DEFAULT: "UIParent"
      ParentAnchor = "CENTER",        -- DEFAULT: "CENTER"
      OffsetX = 200,                  -- DEFAULT: -200
      OffsetY = -200,                 -- DEFAULT: -200
      Mirror = true,                  -- DEFAULT: false
      EnableBackdrop = true,          -- DEFAULT: true
      BackdropInset = 2,              -- DEFAULT: 2
      BackdropOpacity = 1,            -- DEFAULT: 1
      HighlightOpacity = 0.2,         -- DEFAULT: 0.2
      -------------------------------------------------------
      ------ Health bar Options
      -------------------------------------------------------
      HealthBar = {
        Enabled = true,             -- DEFAULT: true
        Height = 20,                -- DEFAULT: 20
        colorTapping = true,        -- DEFAULT: true
        colorDisconnected = true,   -- DEFAULT: true
        colorClass = true,          -- DEFAULT: true
        colorReaction = true,       -- DEFAULT: true
        colorHealth = true,         -- DEFAULT: true
        BgBrightness = 0.5,         -- DEFAULT: 0.5
        ShortenHealthText = true,   -- DEFAULT: true
        HealthTextPrecision = 1,    -- DEFAULT: true
        ColorLevelText = true,      -- DEFAULT: true
      },

      -------------------------------------------------------
      ------- Power Bar Options
      -------------------------------------------------------
      PowerBar = {
        Enabled = true,             -- DEFAULT: true
        Height = 3,                 -- DEFAULT: 8
        Padding = 2,                -- DEFAULT: 2
        frequentUpdates = true,     -- DEFAULT: true
        colorTapping = true,        -- DEFAULT: true
        colorDisconnected = true,   -- DEFAULT: true
        colorPower = true,          -- DEFAULT: true
        colorClass = true,          -- DEFAULT: true
        colorReaction = true,       -- DEFAULT: true
        BgBrightness = 0.5,         -- DEFAULT: 0.5
      },

      -------------------------------------------------------
      ------ Aura Bars Options
      -------------------------------------------------------
      AuraBar =  {
        Enabled = true,             -- DEFAULT: true
        Height = 22,                -- DEFAULT: 25
        Spacing = 6,                -- DEFAULT: 6
        SmallBar = true,            -- DEFAULT: true
        ClassColoredBars = true,    -- DEFAULT: true
      },

      -------------------------------------------------------
      ------ Cast Bar Options
      -------------------------------------------------------
      CastBar = {
        Enabled = true,             -- DEFAULT: true
        Height = 20,
        Width = 400,
        BgBrightness = 0.5,
        Point = 'CENTER',
        relativeTo = "UIParent",
        relativePoint = 'CENTER',
        xOffset = 0,
        yOffset = - 350,
      }
    },
    targettarget = {},
    focus = {},
    focustarget = {},
    pet = {},
    Auras = Auras
  },
  Tooltip = {
    Anchor = {
      relativePoint = "BOTTOMRIGHT",
      point = "BOTTOMRIGHT",
      OffsetX = -10,
      OffsetY = 10,
    }
  },
  Databar = {
    EnableXP = true,
    EnableHonor = true,
    EnableReputation = true,
    HideXPAtMaxLevel = true,    -- Hides the xp bar if the player is max level
    TopAnchor = false,          -- Anchors the data bars to the top of the minimap instead of the bottom
  },
}

