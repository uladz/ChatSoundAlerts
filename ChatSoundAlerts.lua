-- Chat Sound Alerts by @uladz
-- http://www.esoui.com/downloads/info1113-TheMastersVoice.html

-------------------------------------------------------------------------------
--	Configuration and settings
-------------------------------------------------------------------------------

local SOUND_OTHER = 1
local SOUND_CROWN = 2
local SOUND_PARTY = 3
local SOUND_GUILD = 4
local SOUND_YELL = 5
local SOUND_WHISPER = 6
local SOUND_SAY = 7
local SOUND_EMOTE = 8
local SOUND_OFFICER = 9
local SOUND_ZONE = 10

-- Main class.
local MastersVoice = {
  name = "ChatSoundAlerts",
  title = "Chat Sound Alerts",
  author = "@uladz",
  version = "1.0.0",
  dbVersion = 1,

  -- List of all supported channels.
  channelNames = {
    "MONSTER_EMOTE",
    "MONSTER_SAY",
    "MONSTER_WHISPER",
    "MONSTER_YELL",
    "EMOTE",
    "SAY",
    "YELL",
    "ZONE",
    "PARTY",
    "GUILD_1",
    "GUILD_2",
    "GUILD_3",
    "GUILD_4",
    "GUILD_5",
    "OFFICER_1",
    "OFFICER_2",
    "OFFICER_3",
    "OFFICER_4",
    "OFFICER_5"
  },
  otherChannels = {{
    name = "WHISPER",
    channelId = CHAT_CHANNEL_WHISPER,
    categoryId = CHAT_CATEGORY_WHISPER_INCOMING
  }, {
    name = "ZONE (ENGLISH)",
    channelId = CHAT_CHANNEL_ZONE_LANGUAGE_1,
    categoryId = CHAT_CATEGORY_ZONE_ENGLISH
  }, {
    name = "ZONE (FRENCH)",
    channelId = CHAT_CHANNEL_ZONE_LANGUAGE_2,
    categoryId = CHAT_CATEGORY_ZONE_FRENCH
  }, {
    name = "ZONE (GERMAN)",
    channelId = CHAT_CHANNEL_ZONE_LANGUAGE_3,
    categoryId = CHAT_CATEGORY_ZONE_GERMAN
  }},

  -- List of all supported sounds.
  soundNames = {
    "OTHER",
    "CROWN",
    "PARTY",
    "GUILD", 
    "YELL",
    "WHISPER",
    "SAY",
    "EMOTE",
    "OFFICER",
    "ZONE",
  },

  -- Mapping of channels to different sounds.
  channelSoundMap = {
    [CHAT_CHANNEL_PARTY] = SOUND_PARTY,
    [CHAT_CHANNEL_ZONE] = SOUND_ZONE,
    [CHAT_CHANNEL_ZONE_LANGUAGE_1] = SOUND_ZONE,
    [CHAT_CHANNEL_ZONE_LANGUAGE_2] = SOUND_ZONE,
    [CHAT_CHANNEL_ZONE_LANGUAGE_3] = SOUND_ZONE,
    [CHAT_CHANNEL_GUILD_1] = SOUND_GUILD,
    [CHAT_CHANNEL_GUILD_2] = SOUND_GUILD,
    [CHAT_CHANNEL_GUILD_3] = SOUND_GUILD,
    [CHAT_CHANNEL_GUILD_4] = SOUND_GUILD,
    [CHAT_CHANNEL_GUILD_5] = SOUND_GUILD,
    [CHAT_CHANNEL_OFFICER_1] = SOUND_OFFICER,
    [CHAT_CHANNEL_OFFICER_2] = SOUND_OFFICER,
    [CHAT_CHANNEL_OFFICER_3] = SOUND_OFFICER,
    [CHAT_CHANNEL_OFFICER_4] = SOUND_OFFICER,
    [CHAT_CHANNEL_OFFICER_5] = SOUND_OFFICER,
    [CHAT_CHANNEL_YELL] = SOUND_YELL,
    [CHAT_CHANNEL_MONSTER_YELL] = SOUND_YELL,
    [CHAT_CHANNEL_SAY] = SOUND_SAY,
    [CHAT_CHANNEL_MONSTER_SAY] = SOUND_SAY,
    [CHAT_CATEGORY_WHISPER_INCOMING] = SOUND_WHISPER,
    [CHAT_CHANNEL_MONSTER_WHISPER] = SOUND_WHISPER,
    [CHAT_CHANNEL_EMOTE] = SOUND_EMOTE,
    [CHAT_CHANNEL_MONSTER_EMOTE] = SOUND_EMOTE,
  },

  -- List of sound notifications to choose from.
  alarmSoundsList = {
    "ABILITY_MORPH_PURCHASED",
    "ACHIEVEMENT_AWARDED",
    "AVA_GATE_CLOSED",
    "AVA_GATE_OPENED",
    "BOOK_ACQUIRED",
    "DEFER_NOTIFICATION",
    "DIALOG_ACCEPT",
    "DIALOG_DECLINE",
    "GENERAL_ALERT_ERROR",
    "GROUP_JOIN",
    "GROUP_LEAVE",
    "MAIL_SENT",
    "NEW_MAIL",
    "NEW_NOTIFICATION",
    "OBJECTIVE_DISCOVERED",
    "STATS_PURCHASE",
  },

  -- Saved configuration options.
  db = {},

  -- Time of last alarm sound.
  lastCall = 0,

  -- enable for debug log output
  debug = false,
}

-- Prints debug log message.
local function _d(msg)
  if MastersVoice.debug then
    CHAT_SYSTEM:AddMessage("[MV_DEBUG] "..msg)
  end
end

-- Builds sorted list of all chat channels.
function MastersVoice:GetChannels()
  self.channels = {}
  self.sortedChannels = {}

  for _, channelName in ipairs(self.channelNames) do
    local channelId = GetChatChannelId(channelName)
    local soundId = self.channelSoundMap[channelId]
    if not soundId then
      soundId = SOUND_OTHER
    end
    local newChannel = {
      id = channelId,
      name = string.gsub(" "..channelName:gsub("_", " "):lower(), 
          "%W%l", string.upper):sub(2),
      soundId = soundId,
    }
    self.channels[channelId] = newChannel
    table.insert(self.sortedChannels, newChannel)
  end

  for _, channel in pairs(self.otherChannels) do
    local soundId = self.channelSoundMap[channel.channelId]
    if not soundId then
      soundId = SOUND_OTHER
    end
    local newChannel = {
      id = channel.channelId,
      name = string.gsub(" "..channel.name:gsub("_", " "):lower(), 
          "%W%l", string.upper):sub(2),
      soundId = soundId,
    }
    self.channels[channel.channelId] = newChannel
    table.insert(self.sortedChannels, newChannel)
  end

  table.sort(self.sortedChannels, 
    function(a, b)
      return a.name < b.name
    end
  )
end

-- Builds sorted list of all chat channels.
function MastersVoice:GetSounds()
  self.sounds = {}
  self.sortedSounds = {}

  for soundId, soundName in ipairs(self.soundNames) do
    local newSound = {
      id = soundId,
      name = string.gsub(" "..soundName:gsub("_", " "):lower(), 
          "%W%l", string.upper):sub(2),
    }
    self.sounds[soundId] = newSound
    table.insert(self.sortedSounds, newSound)
  end

  table.sort(self.sortedSounds, 
    function(a, b)
      return a.name < b.name
    end
  )
end

-- Builds a list of all alarm sound names and IDs.
function MastersVoice:GetAlarms()
  self.alarmNameMap = {}
  self.alarmIdMap = {}
  self.alarmNames = {}
  
  for _, alarmId in ipairs(self.alarmSoundsList) do
    local name = string.gsub(" "..alarmId:gsub("_", " "):lower(), 
        "%W%l", string.upper):sub(2)
    self.alarmNameMap[name] = alarmId
    self.alarmIdMap[alarmId] = name
    table.insert(self.alarmNames, name)
  end
end

-- Synchronizes enabled channels settings with Simple Chat Bubbles.
function MastersVoice:SyncWithSCB(val)
  if val ~= nil then
    self.db.syncWithSCB = val
  end
  if self.db.syncWithSCB and self:CheckSCB() then
    for _, channel in ipairs(self.sortedChannels) do
      self.scb.db.channels[channel.id] = self.db.channels[channel.id]
    end
  end
end

-- Returns true if a compatible version of SCB is loaded.
--[[
function MastersVoice.CheckSCB()
  if not GetSCB or not GetSCB().version then
    return false
  else
    return GetSCB().version >= "2.2.1"
  end
end
]]

function MastersVoice:CheckSCB()
  if self.hasSCB ~= nil then
    return self.hasSCB
  end
  _d("SCB?")
  local libAA = LibStub:GetLibrary("LibAddonAPI")
  local loaded, version = libAA:IsAddonLoaded("SimpleChatBubbles")
  if loaded == nil then
    _d("addons are still loading")
    return nil
  elseif not loaded then
    _d("SCB is not loaded")
    self.scb = nil
    self.hasSCB = false
  else
    if version == 2 then
      self.scb = libAA:GetAddonAPI("SimpleChatBubbles")
      if self.scb then
        if self.scb.version < "2.2.1" then
          _d("incompatible SCB addon version "..self.scb.version)
          self.scb = nil
          self.hasSCB = false
        else
          _d("found compatible SCB API v"..self.scb.version)
          assert(self.scb)
          self.hasSCB = true
        end
      else
        _d("SCB did not register public API")
        self.scb = nil
        self.hasSCB = false
      end
    else
      _d("incompatible SCB API version "..version)
      self.scb = nil
      self.hasSCB = false
    end
  end
  return self.hasSCB
end

-- Play a message notification.
function MastersVoice:PlayAlarm(soundId)
  local sound = self.db.sounds[soundId]
  if sound then
    _d("play "..self.soundNames[soundId].." = "..sound)
    PlaySound(sound)
  end
end

-- Returns true if player is in "combat" mode.
function MastersVoice.CheckCombat()
  return IsUnitInCombat("player") 
      or IsPlayerControllingSiegeWeapon() 
      or IsPlayerEscortingRam()
end

-- Mute/unmute with log message.
function MastersVoice:Mute(val)
  self.db.muteAll = val
  local state;
  if val then
    state = "|cFF0000disabled|r"
  else
    state = "|c00FF00enabled|r"
  end
  CHAT_SYSTEM:AddMessage("Message notification are "..state)
end

-- Enable/disable notifications in combat only.
function MastersVoice:SetCombatOnly(val)
  self.db.combatOnly = val
  if val then
    self.db.outOfCombatOnly = false
  end
end

-- Enable/disable notifications out of combat only.
function MastersVoice:SetOutOfCombatOnly(val)
  self.db.outOfCombatOnly = val
  if val then
    self.db.combatOnly = false
  end
end

-- Enable/disable notifications in AvA only.
function MastersVoice:SetAllianceWarOnly(val)
  self.db.allianceWarOnly = val
  if val then
    self.db.outOfWarOnly = false
  end
end

-- Enable/disable notifications out of AvA only.
function MastersVoice:SetOutOfWarOnly(val)
  self.db.outOfWarOnly = val
  if val then
    self.db.allianceWarOnly = false
  end
end

-------------------------------------------------------------------------------
-- Settings Menu
-------------------------------------------------------------------------------

function MastersVoice:MakeConfig()
  -- Addon LAM2 config panel
  local panel = {
    type = "panel",
    name = self.title,
    author = self.author,
    version = self.version,
    registerForRefresh = true,
    registerForDefaults = true,
    resetFunc = function() print("defaults reset") end
  }

  -- General options.
  local options = {
    {
      type = "checkbox",
      name = "Use Account-wide Settings",
      tooltip = "Save options account-wide for all characters instead of per-character.",
      getFunc = function() return self.db.accountWide end,
      setFunc = function(val) self:SetAccountWide(val) end,
      width = "full",
    },
    {
      type = "checkbox",
      name = "Mute All Notifications",
      tooltip = "Turn off all notifications.",
      getFunc = function() return self.db.muteAll end,
      setFunc = function(val) self.db.muteAll = val end,
      width = "full",
    },
  }
  
  -- Notification conditions.
  local conditionOptions = {
    {
      type = "header",
      name = "Notification Conditions",
      width = "full",
    },
    {
      type = "checkbox",
      name = "Crown (leader) Only",
      tooltip = "Notify only when crown speaks through group chat or yells.",
      getFunc = function() return self.db.crownOnly end,
      setFunc = function(val) self.db.crownOnly = val end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
    {
      type = "checkbox",
      name = "In-Combat Only",
      tooltip = "Notify only when player is in combat.",
      getFunc = function() return self.db.combatOnly end,
      setFunc = function(val) self:SetCombatOnly(val) end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
    {
      type = "checkbox",
      name = "Out-of-Combat Only",
      tooltip = "Notify only when player is |cFF0000NOT|r in combat.",
      getFunc = function() return self.db.outOfCombatOnly end,
      setFunc = function(val) self:SetOutOfCombatOnly(val) end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
    {
      type = "checkbox",
      name = "Alliance War (PvP) Only",
      tooltip = "Notify only when player is in an Alliance War zone (e.g., Cyrodiil)",
      getFunc = function() return self.db.allianceWarOnly end,
      setFunc = function(val) self:SetAllianceWarOnly(val) end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
    {
      type = "checkbox",
      name = "Out-of-War (PvP) Only",
      tooltip = "Notify only when player is |cFF0000NOT|r in an Alliance War zone (e.g., Cyrodiil)",
      getFunc = function() return self.db.outOfWarOnly end,
      setFunc = function(val) self:SetOutOfWarOnly(val) end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
    {
      type = "checkbox",
      name = "Force Crown (leader) Always",
      tooltip = "Always play notification for crown messages regardless of frequency or channel settings.",
      getFunc = function() return self.db.crownAlways end,
      setFunc = function(val) self.db.crownAlways = val end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
    {
      type = "checkbox",
      name = "Whisper Always",
      tooltip = "Play notification whenever someone sends me a whisper.",
      getFunc = function() return self.db.whisperAlways end,
      setFunc = function(val) self.db.whisperAlways = val end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
--[[
    {
      type = "checkbox",
      name = "New Conversations Only",
      tooltip = "Play notification only and the beginning of conversations.",
      getFunc = function() return self.db.dialogOnly end,
      setFunc = function(val) self.db.dialogOnly = val end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
    {
      type = "slider",
      name = "Conversation Pause",
      tooltip = "Number of seconds that mark a stop in a conversation.",
      min = 0,
      max = 60,
      step = 1,
      getFunc = function() return self.db.dialogStopTime end,
      setFunc = function(val) self.db.dialogStopTime = val end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
]]
    {
      type = "slider",
      name = "Notification Frequency",
      tooltip = "Number of seconds to wait between notifications.",
      min = 0,
      max = 60,
      step = 1,
      getFunc = function() return self.db.silentTime end,
      setFunc = function(val) self.db.silentTime = val end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
  }

  -- Notification channels options.
  local channelOptions = {
    {
      type = "header",
      name = "Notification Channels",
      width = "full",
    },
  }
  for _, channel in ipairs(self.sortedChannels) do
    local newChannel = {
      type = "checkbox",
      name = channel.name,
      tooltip = "Sound a notification when a message in "..channel.name.." channel is received.",
      getFunc = function() return self.db.channels[channel.id] end,
      setFunc = function(val) 
          self.db.channels[channel.id] = val; 
          self:SyncWithSCB() 
        end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    }
    table.insert(channelOptions, newChannel)
  end

  -- Notification sound options.
  local soundOptions = {
    {
      type = "header",
      name = "Notification Sounds",
      width = "full",
    },
  }
  for _, sound in ipairs(self.sortedSounds) do
    local newSound = {
      type = "dropdown",
      name = sound.name.." Notification Sound:",
      tooltip = "Choose notification sound for a message from "..sound.name.." channel.",
      choices = self.alarmNames,
      sort = "name-up",
      getFunc = function() 
          local alarmId = self.db.sounds[sound.id]
          return self.alarmIdMap[alarmId]
        end,
      setFunc = function(val) 
          local alarmId = self.alarmNameMap[val]
          self.db.sounds[sound.id] = alarmId
          self:PlayAlarm(sound.id)
        end,
      width = "half",
      disabled = function() return self.db.muteAll end,
    }
    table.insert(soundOptions, newSound)
    local newPreview = {
      type = "button",
      name = "Preview "..sound.name,
      tooltip = "Playback notification sound for a message from "..sound.name.." channel.",
      func = function() self:PlayAlarm(sound.id) end,
      width = "half",
      disabled = function() return self.db.muteAll end,
    }
    table.insert(soundOptions, newPreview)
  end

  -- More options.
  local moreOptions = {
    {
      type = "header",
      name = "More Options",
      width = "full",
    },
    {
      type = "checkbox",
      name = "Show info on load",
      tooltip = "Print a short information about enabled notifications on game startup.",
      getFunc = function() return self.db.startupMessage end,
      setFunc = function(val) self.db.startupMessage = val end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
    {
      type = "checkbox",
      name = "Player Also (debug)",
      tooltip = "Notify also when player speaks through enabled channels.",
      getFunc = function() return self.db.playerAlso end,
      setFunc = function(val) self.db.playerAlso = val end,
      width = "full",
      disabled = function() return self.db.muteAll end,
    },
  }
--  if self:CheckSCB() then
    local newOption = {
      type = "checkbox",
      name = "Sync channels with Simple Chat Bubbles",
      tooltip = "Enable or disable the same chat channels as Simple Chat Bubbles addon.",
      getFunc = function() return self.db.syncWithSCB end,
      setFunc = function(val) self:SyncWithSCB(val) end,
      width = "full",
      disabled = function() return self.db.muteAll or not self:CheckSCB() end,
    }
    table.insert(moreOptions, newOption)
--  end
  
  for _, option in ipairs(conditionOptions) do
    table.insert(options, option)
  end
  for _, option in ipairs(channelOptions) do
    table.insert(options, option)
  end
  for _, option in ipairs(soundOptions) do
    table.insert(options, option)
  end
  for _, option in ipairs(moreOptions) do
    table.insert(options, option)
  end
  
  -- Register addon settings.
  local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
  LAM2:RegisterOptionControls(self.name, options)
  LAM2:RegisterAddonPanel(self.name, panel)
end

-- Switches between pre-character and account-wide settings.
function MastersVoice:SetAccountWide(val)
  self.db_CS.accountWide = val
  self.db_AW.accountWide = val
  if val then
    self.db = self.db_AW
  else
    self.db = self.db_CS
  end
end

-- Initializes addon, loads all settings, registers for events, etc.
function MastersVoice:Init()
  -- Default configuration.
  local defaults = {
    accountWide = false,
    muteAll = false,
    startupMessage = true,
    silentTime = 0,
    crownAlways = true,
    whisperAlways = true,
    combatOnly = false,
    outOfCombatOnly = true,
    playerAlso = false,
    crownOnly = false,
    allianceWarOnly = false,
    outOfWarOnly = false,
    syncWithSCB = false,
    
    channels = {
      [CHAT_CHANNEL_EMOTE] = true,
      [CHAT_CHANNEL_SAY] = true,
      [CHAT_CHANNEL_YELL] = true,
      [CHAT_CHANNEL_WHISPER] = true,
      [CHAT_CHANNEL_GUILD_1] = true,
      [CHAT_CHANNEL_GUILD_2] = true,
      [CHAT_CHANNEL_GUILD_3] = true,
      [CHAT_CHANNEL_GUILD_4] = true,
      [CHAT_CHANNEL_GUILD_5] = true,
      [CHAT_CHANNEL_PARTY] = true,
    },
    sounds = {
      [SOUND_OTHER] = "NEW_NOTIFICATION",
      [SOUND_CROWN] = "NEW_NOTIFICATION",
      [SOUND_PARTY] = "NEW_NOTIFICATION",
      [SOUND_GUILD] = "NEW_NOTIFICATION",
      [SOUND_YELL] = "NEW_NOTIFICATION",
      [SOUND_WHISPER] = "NEW_NOTIFICATION",
      [SOUND_SAY] = "NEW_NOTIFICATION",
      [SOUND_EMOTE] = "NEW_NOTIFICATION",
      [SOUND_ZONE] = "NEW_NOTIFICATION",
      [SOUND_OFFICER] = "NEW_NOTIFICATION",
    }
  }
  
  -- Load options from database, account-wide supported.
  self.db_CS = ZO_SavedVars:New(self.name.."Vars",
      self.dbVersion, nil, defaults)
  self.db_AW = ZO_SavedVars:NewAccountWide(self.name.."Vars",
      self.dbVersion, nil, defaults)
  if self.db_AW.accountWide == true then
    self.db_CS.accountWide = true
    self.db = self.db_AW
  else
    self.db_CS.accountWide = false
    self.db = self.db_CS
  end

  -- Register addon settings.
  self:GetChannels()
  self:GetSounds()
  self:GetAlarms()
  --self:GetLoadedAddons()
  self:MakeConfig()

  -- Register event handlers.
  EVENT_MANAGER:RegisterForEvent(self.name,
      EVENT_CHAT_MESSAGE_CHANNEL, 
      self.OnChatMessageChannel)

  -- Register chat "/" commands.
  SLASH_COMMANDS["/mvdebug"] = function() self.debug = not self.debug end
  SLASH_COMMANDS["/mute"] = function() self:Mute(true) end
  SLASH_COMMANDS["/unmute"] = function() self:Mute(false) end

  -- Publish addon API.
  local libAA = LibStub:GetLibrary("LibAddonAPI")
  libAA:RegisterAddon(self.name, 1, self)
end

-- Print short summary of the addon option is chat.
function MastersVoice:PrintStartupMessage(...)
  if not self.db.startupMessage then
    return
  end
  
  local channels = ""
  if not self.db.muteAll then
    for _, channel in ipairs(self.sortedChannels) do
      if self.db.channels[channel.id] then
        channels = channels..channel.name..", "
      end
    end
    if self.db.playerAlso then
      channels = channels.."Player, "
    end
    local conditions = ""
    if self.db.crownAlways then
      conditions = conditions.."Crown Always, "
    end
    if self.db.whisperAlways then
      conditions = conditions.."Whisper Always, "
    end
    if self.db.combatOnly then
      conditions = conditions.."In Combat, "
    end
    if self.db.outOfCombatOnly then
      conditions = conditions.."Out-of-combat, "
    end
    if self.db.allianceWarOnly then
      conditions = conditions.."Alliance War, "
    end
    if self.db.outOfWarOnly then
      conditions = conditions.."Out-of-war, "
    end
    if self.db.silentTime > 0 then
      conditions = conditions.."silence="..self.db.silentTime..", "
    end
    zo_callLater(function()
      CHAT_SYSTEM:AddMessage("Message notification are |c00FF00enabled|r")
      CHAT_SYSTEM:AddMessage("- Channels: "..channels:sub(1, -3))
      CHAT_SYSTEM:AddMessage("- Conditions: "..conditions:sub(1, -3))
    end)
  else
    zo_callLater(function()
      CHAT_SYSTEM:AddMessage("Message notification are |cFF0000disabled|r")
    end)
  end
end

-- Process a new message and sound a notification if conditions are met.
function MastersVoice:NewMessage(messageType, fromName)
  if self.db.muteAll then
      -- don't play notification if muted
      _d("all muted")
    return
  end
  if not self.db.playerAlso then
    if fromName == GetRawUnitName("player") 
        or messageType == CHAT_CHANNEL_WHISPER_SENT then
      -- don't play notification from yourself
      _d("from yourself -> mute")
      return
    end
  end
  if self.db.whisperAlways and
      messageType == CHAT_CHANNEL_WHISPER then
    -- force notify if whisper channel used
    self:PlayAlarm(SOUND_WHISPER)
    return
  end
  local crownSpeaks = false
  if fromName == GetRawUnitName(GetGroupLeaderUnitTag()) then
    crownSpeaks = true
    if self.db.crownAlways then
      -- if crown sound enforced then play right away
      self:PlayAlarm(SOUND_CROWN)
      return
    end
  end
  if self.db.crownOnly then
    if not crownSpeaks then
      -- skip if not crown speaking
      _d("not crown -> mute")
      return
    end
  end
  if self.db.allianceWarOnly then
    if IsPlayerInAvAWorld() then
      -- skip if not in alliance war zone
      _d("not in war -> mute")
      return
    end
  end
  if self.db.outOfWarOnly then
    if not IsPlayerInAvAWorld() then
      -- skip if not in alliance war zone
      _d("in war -> mute")
      return
    end
  end
  if self.db.combatOnly then
    if not self.CheckCombat() then
      -- skip if player is not in combat
      _d("not in combat -> mute")
      return
    end
  end
  if self.db.outOfCombatOnly then
    if self.CheckCombat() then
      -- skip if player is not in combat
      _d("in combat -> mute")
      return
    end
  end
  if not self.db.channels[messageType] then
    _d(self.channels[messageType].name.." is off -> mute")
    return
  end
  local timeDiff = GetDiffBetweenTimeStamps(GetTimeStamp(), self.lastCall)
  if timeDiff < self.db.silentTime then
    -- mute if notified too often
    _d("silence time = "..timeDiff.." -> mute")
    return
  end
  self.lastCall = GetTimeStamp()
  local sound = self.channels[messageType].soundId
  if crownSpeaks then
    sound = SOUND_CROWN
  end
  self:PlayAlarm(sound)
end

-------------------------------------------------------------------------------
-- Events handling
-------------------------------------------------------------------------------

function MastersVoice.OnAddOnLoaded(event, addonName)
  if addonName == MastersVoice.name then
    EVENT_MANAGER:UnregisterForEvent(MastersVoice.name, 
        EVENT_ADD_ON_LOADED)
    MastersVoice:Init()
  end
end

function MastersVoice.OnPlayerActivated()
  EVENT_MANAGER:UnregisterForEvent(MastersVoice.name, 
      EVENT_PLAYER_ACTIVATED)
  MastersVoice:PrintStartupMessage()
end

function MastersVoice.OnChatMessageChannel(eventCode, messageType,
    fromName, messageText, isCustomerService)
  MastersVoice:NewMessage(messageType, fromName)
end

EVENT_MANAGER:RegisterForEvent(MastersVoice.name, 
    EVENT_ADD_ON_LOADED,
    MastersVoice.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(MastersVoice.name, 
    EVENT_PLAYER_ACTIVATED,
    MastersVoice.OnPlayerActivated)

