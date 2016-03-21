-- Simple Chat Bubbles - By Dio Revived by RibbedStoic  (v1.0.4) -
-- http://www.esoui.com/downloads/author-1518.html

-------------------------------------------------------------------------------
--	Configuration and settings
-------------------------------------------------------------------------------

-- Main addon class.
local MastersVoice = {
  name = "MastersVoice",
  title = "Master's Voice",
  codeVersion = 0.5,

  -- configuration version, changing this will reset all addon settings
  configVersion = 0.5,

  -- Time of last alarm sound.
  lastCall = 0,

  -- enable for debug log output
  debug = false,
}

-- Saved configuration variables.
local config = {}

-- Default configuration values.
local Default = {
  -- turn off this addon
  muteAll = false,
  -- show notification info on startup
  startupMessage = true,
  -- number of seconds to wait before sounding again
  silentTime = 0,
  -- whether to force notifications for crown, ignores all cond's
  crownAlways = true,
  -- whether to sound if anyone speaks through /w
  whisperAlways = true,
  -- whether to sound only when player is in combat
  combatOnly = false,
  -- whether to sound only when player is NOT in combat
  outOfCombatOnly = true,
  -- whether to sound if player himself speaks
  playerAlso = false,
  -- whether to sound only if anyone speaks through /g
  groupOnly = true,
  -- whether to sound only if anyone speaks through /y
  yellOnly = true,
  -- whether to sound only if anyone speaks through /g#
  guildOnly = true,
  -- whether to sound only if anyone speaks through /s
  sayOnly = false,
  -- whether to sound only if crown speaks through /g or /y
  crownOnly = false,
  -- whether to sound only if in an alliance war zone
  allianceWarOnly = true,
  -- group message alarm sound in [AlarmSoundsList] table
  groupAlarmSound = "NEW_NOTIFICATION",
  -- guild message alarm sound in [AlarmSoundsList] table
  guildAlarmSound = "NEW_NOTIFICATION",
  -- yell message alarm sound in [AlarmSoundsList] table
  yellAlarmSound = "NEW_NOTIFICATION",
  -- say message alarm sound in [AlarmSoundsList] table
  sayAlarmSound = "NEW_NOTIFICATION",
  -- crown message alarm sound in [AlarmSoundsList] table
  crownAlarmSound = "NEW_NOTIFICATION",
  -- whisper message alarm sound in [AlarmSoundsList] table
  whisperAlarmSound = "NEW_NOTIFICATION",
  -- all other messages alarm sound in [AlarmSoundsList] table
  otherAlarmSound = "NEW_NOTIFICATION",
}

-- List of sound notifications to choose from.
local AlarmSoundsList = {
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
}

-- Prints debug log message.
local function d(msg)
  if MastersVoice.debug then
    CHAT_SYSTEM:AddMessage("[MV_DEBUG] "..msg)
  end
end

-------------------------------------------------------------------------------
-- Conditional Checks
-------------------------------------------------------------------------------

-- Returns true if player is in "combat" mode.
function MastersVoice.CheckCombat()
  if (IsUnitInCombat("player") 
      or IsPlayerControllingSiegeWeapon() 
      or IsPlayerEscortingRam()) then 
    return true
  else
    return false
  end
end

-------------------------------------------------------------------------------
-- Settings Control
-------------------------------------------------------------------------------

function MastersVoice.UpdateAllChannels()
  config.allChannels =
    not config.muteAll and
    not config.groupOnly and
    not config.guildOnly and
    not config.yellOnly and
    not config.sayOnly
end

function MastersVoice.SetDebug(newBool)
  MastersVoice.debug = newBool
end

function MastersVoice.SetMuteAll(newBool)
  config.muteAll = newBool
  MastersVoice.UpdateAllChannels()
  if newBool then
    CHAT_SYSTEM:AddMessage("Message notification are |cFF0000disabled|r")
  else
    CHAT_SYSTEM:AddMessage("Message notification are |c00FF00enabled|r")
  end
end

function MastersVoice.SetStartupMessage(newBool)
  config.startupMessage = newBool
end

function MastersVoice.SetSilentTime(newTime)
  config.silentTime = newTime
end

function MastersVoice.SetCrownAlways(newBool)
  config.crownAlways = newBool
end

function MastersVoice.SetWhisperAlways(newBool)
  config.whisperAlways = newBool
end

function MastersVoice.SetCombatOnly(newBool)
  config.combatOnly = newBool
  if newBool then
    config.outOfCombatOnly = false
  end
end

function MastersVoice.SetIdleOnly(newBool)
  config.outOfCombatOnly = newBool
  if newBool then
    config.combatOnly = false
  end
end

function MastersVoice.SetPlayerAlso(newBool)
  config.playerAlso = newBool
end

function MastersVoice.SetGroupOnly(newBool)
  config.groupOnly = newBool
  MastersVoice.UpdateAllChannels()
end

function MastersVoice.SetGuildOnly(newBool)
  config.guildOnly = newBool
  MastersVoice.UpdateAllChannels()
end

function MastersVoice.SetYellOnly(newBool)
  config.yellOnly = newBool
  MastersVoice.UpdateAllChannels()
end

function MastersVoice.SetSayOnly(newBool)
  config.aayOnly = newBool
  MastersVoice.UpdateAllChannels()
end

function MastersVoice.SetCrownOnly(newBool)
  config.crownOnly = newBool
end

function MastersVoice.SetAllianceWarOnly(newBool)
  config.allianceWarOnly = newBool
end

function MastersVoice.SetGroupAlarmSound(newSoundName, play)
  config.groupAlarmSound = newSoundName
  if play == true then
    MastersVoice.PlayGroupAlarm()
  end
end

function MastersVoice.SetGuildAlarmSound(newSoundName, play)
  config.guildAlarmSound = newSoundName
  if play == true then
    MastersVoice.PlayGuildAlarm()
  end
end

function MastersVoice.SetYellAlarmSound(newSoundName, play)
  config.yellAlarmSound = newSoundName
  if play == true then
    MastersVoice.PlayYellAlarm()
  end
end

function MastersVoice.SetSayAlarmSound(newSoundName, play)
  config.sayAlarmSound = newSoundName
  if play == true then
    MastersVoice.PlaySayAlarm()
  end
end

function MastersVoice.SetWhisperAlarmSound(newSoundName, play)
  config.whisperAlarmSound = newSoundName
  if play == true then
    MastersVoice.PlayWhisperAlarm()
  end
end

function MastersVoice.SetOtherAlarmSound(newSoundName, play)
  config.otherAlarmSound = newSoundName
  if play == true then
    MastersVoice.PlayOtherAlarm()
  end
end

function MastersVoice.SetCrownAlarmSound(newSoundName, play)
  config.crownAlarmSound = newSoundName
  if play == true then
    MastersVoice.PlayCrownAlarm()
  end
end

-------------------------------------------------------------------------------
-- Actions
-------------------------------------------------------------------------------

function MastersVoice.PlayGroupAlarm()
  d("^group^")
  PlaySound(config.groupAlarmSound)
end

function MastersVoice.PlayGuildAlarm()
  d("^guild^")
  PlaySound(config.guildAlarmSound)
end

function MastersVoice.PlayYellAlarm()
  d("^yell^")
  PlaySound(config.yellAlarmSound)
end

function MastersVoice.PlaySayAlarm()
  d("^say^")
  PlaySound(config.sayAlarmSound)
end

function MastersVoice.PlayWhisperAlarm()
  d("^whisper^")
  PlaySound(config.whisperAlarmSound)
end

function MastersVoice.PlayOtherAlarm()
  d("^other^")
  PlaySound(config.otherAlarmSound)
end

function MastersVoice.PlayCrownAlarm()
  d("^crown^")
  PlaySound(config.crownAlarmSound)
end

-------------------------------------------------------------------------------
-- Settings Menu
-------------------------------------------------------------------------------

local panelData = {
  type = "panel",
  name = MastersVoice.title,
  author = "Uladz, HomoPuerRobustus",
  version = MastersVoice.codeVersion,
  registerForRefresh = true,
  registerForDefaults = true,
  resetFunc = function() print("defaults reset") end
}

local optionsData = {
  {
    type = "checkbox",
    name = "Mute All Notifications",
    tooltip = "Turn off all notifications.",
    getFunc = function() return config.muteAll end,
    setFunc = function(newBool) MastersVoice.SetMuteAll(newBool) end,
    width = "full",
    default = Default.muteAll,
  },
  {
    type = "header",
    name = "Notification Channels",
    width = "full",
  },
  {
    type = "checkbox",
    name = "Group Channel",
    tooltip = "Notify only when anyone speaks through group chat.",
    getFunc = function() return config.groupOnly end,
    setFunc = function(newBool) MastersVoice.SetGroupOnly(newBool) end,
    width = "full",
    default = Default.groupOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "Guild Channel",
    tooltip = "Notify only when anyone speaks through guild chat.",
    getFunc = function() return config.guildOnly end,
    setFunc = function(newBool) MastersVoice.SetGuildOnly(newBool) end,
    width = "full",
    default = Default.guildOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "Yell Channel",
    tooltip = "Notify only when anyone speaks through yells.",
    getFunc = function() return config.yellOnly end,
    setFunc = function(newBool) MastersVoice.SetYellOnly(newBool) end,
    width = "full",
    default = Default.yellOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "Say Channel",
    tooltip = "Notify only when anyone speaks through \"say\" chat.",
    getFunc = function() return config.sayOnly end,
    setFunc = function(newBool) MastersVoice.SetSayOnly(newBool) end,
    width = "full",
    default = Default.sayOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "header",
    name = "Notification Conditions",
    width = "full",
  },
  {
    type = "checkbox",
    name = "Crown (leader) Only",
    tooltip = "Notify only when crown speaks through group chat or yells.",
    getFunc = function() return config.crownOnly end,
    setFunc = function(newBool) MastersVoice.SetCrownOnly(newBool) end,
    width = "full",
    default = Default.crownOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "In-Combat Only",
    tooltip = "Notify only when player is in combat.",
    getFunc = function() return config.combatOnly end,
    setFunc = function(newBool) MastersVoice.SetCombatOnly(newBool) end,
    width = "full",
    default = Default.combatOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "Out-of-Combat Only",
    tooltip = "Notify only when player is |cFF0000NOT|r in combat.",
    getFunc = function() return config.outOfCombatOnly end,
    setFunc = function(newBool) MastersVoice.SetIdleOnly(newBool) end,
    width = "full",
    default = Default.outOfCombatOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "Alliance War Only",
    tooltip = "Notify only when player is in an Alliance War zone (e.g., Cyrodiil)",
    getFunc = function() return config.allianceWarOnly end,
    setFunc = function(newBool) MastersVoice.SetAllianceWarOnly(newBool) end,
    width = "full",
    default = Default.allianceWarOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "Force Crown (leader) Always",
    tooltip = "Always play notification for crown messages regardless of frequency or channel settings.",
    getFunc = function() return config.crownAlways end,
    setFunc = function(newBool) MastersVoice.SetCrownAlways(newBool) end,
    width = "full",
    default = Default.crownAlways,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "Whisper Alarm",
    tooltip = "Play notification whenever someone sends me a whisper.",
    getFunc = function() return config.whisperAlways end,
    setFunc = function(newBool) MastersVoice.SetWhisperAlways(newBool) end,
    width = "full",
    default = Default.whisperAlways,
    disabled = function() return config.muteAll end,
  },
  {
    type = "checkbox",
    name = "Player Also",
    tooltip = "Notify also when player speaks through enabled channels.",
    getFunc = function() return config.playerAlso end,
    setFunc = function(newBool) MastersVoice.SetPlayerAlso(newBool) end,
    width = "full",
    default = Default.playerOnly,
    disabled = function() return config.muteAll end,
  },
  {
    type = "slider",
    name = "Notification Frequency",
    tooltip = "Number of seconds to wait between notifications.",
    min = 0,
    max = 60,
    step = 1,
    getFunc = function() return config.silentTime end,
    setFunc = function(newTime) MastersVoice.SetSilentTime(newTime) end,
    width = "full",
    default = Default.silentTime,
    disabled = function() return config.muteAll end,
  },
  {
    type = "header",
    name = "Notification Sounds",
    width = "full",
  },
  {
    type = "dropdown",
    name = "Group Notification Sound",
    tooltip = "Choose which sound to play for group notifications.",
    choices = AlarmSoundsList,
    sort = "name-up",
    getFunc = function() return config.groupAlarmSound end,
    setFunc = function(newSoundName) MastersVoice.SetGroupAlarmSound(newSoundName, true) end,
    width = "half",
    default = Default.groupAlarmSound,
    disabled = function() return config.muteAll end,
  },
  {
    type = "button",
    name = "Preview Group",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayGroupAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
  },
  {
    type = "dropdown",
    name = "Crown Notification Sound",
    tooltip = "Choose which sound to play for crown notifications.",
    choices = AlarmSoundsList,
    sort = "name-up",
    getFunc = function() return config.crownAlarmSound end,
    setFunc = function(newSoundName) MastersVoice.SetCrownAlarmSound(newSoundName, true) end,
    width = "half",
    default = Default.crownAlarmSound,
    disabled = function() return config.muteAll end,
  },
  {
    type = "button",
    name = "Preview Crown",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayCrownAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
  },
  {
    type = "dropdown",
    name = "Guild Notification Sound",
    tooltip = "Choose which sound to play for guild notifications.",
    choices = AlarmSoundsList,
    sort = "name-up",
    getFunc = function() return config.guildAlarmSound end,
    setFunc = function(newSoundName) MastersVoice.SetGuildAlarmSound(newSoundName, true) end,
    width = "half",
    default = Default.guildAlarmSound,
    disabled = function() return config.muteAll end,
  },
  {
    type = "button",
    name = "Preview Guild",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayGuildAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
  },
  {
    type = "dropdown",
    name = "Yell Notification Sound",
    tooltip = "Choose which sound to play for yell notifications.",
    choices = AlarmSoundsList,
    sort = "name-up",
    getFunc = function() return config.yellAlarmSound end,
    setFunc = function(newSoundName) MastersVoice.SetYellAlarmSound(newSoundName, true) end,
    width = "half",
    default = Default.yellAlarmSound,
    disabled = function() return config.muteAll end,
  },
  {
    type = "button",
    name = "Preview Yell",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayYellAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
  },
  {
    type = "dropdown",
    name = "Say Notification Sound",
    tooltip = "Choose which sound to play for say notifications.",
    choices = AlarmSoundsList,
    sort = "name-up",
    getFunc = function() return config.sayAlarmSound end,
    setFunc = function(newSoundName) MastersVoice.SetSayAlarmSound(newSoundName, true) end,
    width = "half",
    default = Default.sayAlarmSound,
    disabled = function() return config.muteAll end,
  },
  {
    type = "button",
    name = "Preview Yell",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayYellAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
  },
  {
    type = "dropdown",
    name = "Whisper Notifications Sound",
    tooltip = "Choose which sound to play for whisper notifications.",
    choices = AlarmSoundsList,
    sort = "name-up",
    getFunc = function() return config.whisperAlarmSound end,
    setFunc = function(newSoundName) MastersVoice.SetWhisperAlarmSound(newSoundName, true) end,
    width = "half",
    default = Default.whisperAlarmSound,
    disabled = function() return config.muteAll end,
  },
  {
    type = "button",
    name = "Preview Whisper",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayWhisperAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
  },
  {
    type = "dropdown",
    name = "Other Notifications Sound",
    tooltip = "Choose which sound to play for all other notifications.",
    choices = AlarmSoundsList,
    sort = "name-up",
    getFunc = function() return config.otherAlarmSound end,
    setFunc = function(newSoundName) MastersVoice.SetOtherAlarmSound(newSoundName, true) end,
    width = "half",
    default = Default.otherAlarmSound,
    disabled = function() return config.muteAll end,
  },
  {
    type = "button",
    name = "Preview Other",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayOtherAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
  },
  {
    type = "header",
    name = "More Options",
    width = "full",
  },
  {
    type = "checkbox",
    name = "Show info on load",
    tooltip = "Print a short information about enabled notifications on game startup.",
    getFunc = function() return config.startupMessage end,
    setFunc = function(newBool) MastersVoice.SetStartupMessage(newBool) end,
    width = "full",
    default = Default.startupMessage,
    disabled = function() return config.muteAll end,
  },
}

-------------------------------------------------------------------------------
-- Initialization section
-------------------------------------------------------------------------------

function MastersVoice:Initialize()
  -- Register event handlers.
  config = ZO_SavedVars:New(self.name.."Vars",
      self.configVersion, 
      nil, 
      Default)
  EVENT_MANAGER:RegisterForEvent(self.name,
      EVENT_CHAT_MESSAGE_CHANNEL, 
      self.OnChatMessageChannel)
  EVENT_MANAGER:UnregisterForEvent(self.name, 
      EVENT_ADD_ON_LOADED)

  -- Register addon settings.
  local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
  LAM2:RegisterOptionControls(self.name, optionsData)
  LAM2:RegisterAddonPanel(self.name, panelData)

  -- Register chat "/" commands.
  SLASH_COMMANDS["/mvdebug"] = function() self.SetDebug(not MastersVoice.debug) end
  SLASH_COMMANDS["/mute"] = function() self.SetMuteAll(true) end
  SLASH_COMMANDS["/unmute"] = function() self.SetMuteAll(false) end
end

function MastersVoice.OnAddOnLoaded(event, addonName)
  if addonName == MastersVoice.name then
    MastersVoice:Initialize()
  end
end

function MastersVoice.OnPlayerActivated(...)
  -- Do it once!
  EVENT_MANAGER:UnregisterForEvent(MastersVoice.name,
    EVENT_PLAYER_ACTIVATED)
    
  -- Let user know that notification are enabled
  if not config.startupMessage then
    return
  end
  if not config.muteAll then
    local channels = ""
    if config.groupOnly then
      channels = channels.."group, "
    end
    if config.guildOnly then
      channels = channels.."guild, "
    end
    if config.yellOnly then
      channels = channels.."yell, "
    end
    if config.sayOnly then
      channels = channels.."say, "
    end
    if config.crownAlways then
      channels = channels.."crown, "
    end
    if config.whisperAlways then
      channels = channels.."whisper, "
    end
    if config.playerAlso then
      channels = channels.."player, "
    end
    if config.allChannels then
      channels = channels.."all, "
    end
    local conditions = ""
    if config.crownOnly then
      conditions = conditions.."crown, "
    end
    if config.combatOnly then
      conditions = conditions.."combat, "
    end
    if config.outOfCombatOnly then
      conditions = conditions.."out-of-combat, "
    end
    if config.allianceWarOnly then
      conditions = conditions.."war, "
    end
    zo_callLater(function()
      CHAT_SYSTEM:AddMessage("Message notification are |c00FF00enabled|r")
      CHAT_SYSTEM:AddMessage("- channels: "..channels:sub(1, -3))
      CHAT_SYSTEM:AddMessage("- conditions: "..conditions:sub(1, -3))
    end)
  end
end

EVENT_MANAGER:RegisterForEvent(MastersVoice.name, EVENT_ADD_ON_LOADED,
  MastersVoice.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(MastersVoice.name, EVENT_PLAYER_ACTIVATED,
  MastersVoice.OnPlayerActivated)

-------------------------------------------------------------------------------
-- Chat events handling
-------------------------------------------------------------------------------

function MastersVoice.OnChatMessageChannel(
    eventCode,
    messageType,
    fromName,
    messageText,
    isCustomerService
)
  if config.muteAll then
      -- don't play notification if muted
      d("?:mute, skip")
    return
  end
  if not config.playerAlso then
    if fromName == GetRawUnitName("player") 
        or messageType == CHAT_CHANNEL_WHISPER_SENT then
      -- don't play notification for yourself
      d("?:player, skip")
      return
    end
  end
  if config.whisperAlways and
      messageType == CHAT_CHANNEL_WHISPER then
    -- force notify if whisper channel used
    d("?:whisper")
    MastersVoice.PlayWhisperAlarm()
    return
  end
  local crownSpeaks = false
  if fromName == GetRawUnitName(GetGroupLeaderUnitTag()) then
    crownSpeaks = true
    if config.crownAlways then
      -- if crown sound enforced then play right away
      MastersVoice.PlayCrownAlarm()
      return
    end
  end
  if config.crownOnly then
    if not crownSpeaks then
      -- skip if not crown speaking
      d("?:!crown, skip")
      return
    end
  end
  if config.allianceWarOnly then
    if not IsPlayerInAvAWorld() then
      -- skip if not in alliance war zone
      d("cond:!war, skip")
      return
    end
  end
  if config.combatOnly then
    if not MastersVoice.CheckCombat() then
      -- skip if player is not in combat
      d("?:!combat, skip")
      return
    end
  end
  if config.outOfCombatOnly then
    if MastersVoice.CheckCombat() then
      -- skip if player is not in combat
      d("?:combat, skip")
      return
    end
  end
  local alertType = ""
  if config.groupOnly or config.allChannels then
    if messageType == CHAT_CHANNEL_PARTY then
      -- notify if group channel used
      d("?:party")
      alertType = "GROUP"
    end
  end
  if config.guildOnly or config.allChannels then
    if messageType == CHAT_CHANNEL_GUILD1
        or messageType == CHAT_CHANNEL_GUILD2
        or messageType == CHAT_CHANNEL_GUILD3
        or messageType == CHAT_CHANNEL_GUILD4
        or messageType == CHAT_CHANNEL_GUILD5 then
      -- notify if group channel used
      d("?:guild")
      alertType = "GUILD"
    end
  end
  if config.yellOnly or config.allChannels then
    if messageType == CHAT_CHANNEL_YELL then
      -- notify if yell channel used
      d("?:yell")
      alertType = "YELL"
    end
  end
  if config.sayOnly or config.allChannels then
    if messageType == CHAT_CHANNEL_SAY then
      -- notify if group channel used
      d("?:say")
      alertType = "SAY"
    end
  end
  if alertType == "" then
    -- all other channels end up here
    if config.allChannels then
      d("?:other")
      alertType = "OTHER"
    else
      -- sorry, wrong channel
      d("?:other, skip")
      return
    end
  end
  local timeDiff = GetDiffBetweenTimeStamps(GetTimeStamp(), MastersVoice.lastCall)
  if timeDiff < config.silentTime then
    -- mute if notified too often
    d("?:mute, skip")
    return
  end
  MastersVoice.lastCall = GetTimeStamp()
  if crownSpeaks then
    -- if Crown speaks in any channel then use special sound
    MastersVoice.PlayCrownAlarm()
  else
    if alertType == "GROUP" then
      MastersVoice.PlayGroupAlarm()
    elseif alertType == "GUILD" then
      MastersVoice.PlayGuildAlarm()
    elseif alertType == "YELL" then
      MastersVoice.PlayYellAlarm()
    elseif alertType == "SAY" then
      MastersVoice.PlaySayAlarm()
    elseif alertType == "OTHER" then
      MastersVoice.PlayOtherAlarm()
    end
  end
end