local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

-------------------------------------------------------------------------------
--	Configuration and settings
-------------------------------------------------------------------------------

-- Main addon class.
local MastersVoice = {
  name = "MastersVoice",
  codeVersion = 0.5,

  -- configuration version, changing this will reset all addon settings
  configVersion = 0.5,

  -- enable for debug log output
  debug = false
}

-- Time of last alarm sound.
local lastCall = 0

-- Saved configuration variables.
local config = {}

-- Default configuration values.
local Default = {
  -- turn off this addon
  muteAll = false,
  -- number of seconds to wait before sounding again
  silentTime = 0,
  -- whether to ignore [silentTime] for crown
  crownAlways = true,
  -- whether to sound only when player is in combat
  combatOnly = false,
  -- whether to sound if player himself speaks
  playerAlso = false,
  -- whether to sound only if anyone speaks through /g
  groupOnly = true,
  -- whether to sound only if anyone speaks through /y
  yellOnly = true,
  -- whether to sound only if anyone speaks through /g#
  guildOnly = true,
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
  -- crown message alarm sound in [AlarmSoundsList] table
  crownAlarmSound = "NEW_NOTIFICATION",
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

-------------------------------------------------------------------------------
-- Settings Control
-------------------------------------------------------------------------------

function MastersVoice.UpdateAllChannels()
  config.allChannels =
    not config.muteAll and
    not config.groupOnly and
    not config.guildOnly and
    not config.yellOnly
end

function MastersVoice.SetMuteAll(newBool)
  config.muteAll = newBool
  MastersVoice.UpdateAllChannels()
end

function MastersVoice.SetSilentTime(newTime)
  config.silentTime = newTime
end

function MastersVoice.SetCombatOnly(newBool)
  config.combatOnly = newBool
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

function MastersVoice.PlayGroupAlarm()
  PlaySound(config.groupAlarmSound)
end

function MastersVoice.PlayGuildAlarm()
  PlaySound(config.guildAlarmSound)
end

function MastersVoice.PlayYellAlarm()
  PlaySound(config.yellAlarmSound)
end

function MastersVoice.PlayOtherAlarm()
  PlaySound(config.otherAlarmSound)
end

function MastersVoice.PlayCrownAlarm()
  PlaySound(config.crownAlarmSound)
end

-------------------------------------------------------------------------------
-- Settings Menu
-------------------------------------------------------------------------------

local panelData = {
  type = "panel",
  name = "Master's Voice",
  author = "Uladz, HomoPuerRobustus",
  version = MastersVoice.codeVersion,
  registerForRefresh = true,
  registerForDefaults = true,
  resetFunc = function() print("defaults reset") end
}

local optionsData = {
  [1] = {
    type = "checkbox",
    name = "Mute All Notifications",
    tooltip = "Turn off all notifications.",
    getFunc = function() return config.muteAll end,
    setFunc = function(newBool) MastersVoice.SetMuteAll(newBool) end,
    width = "full",
    default = Default.muteAll,
    reference = "MastersVoice_SETMUTEALL_CHECKBOX"
  },
  [2] = {
    type = "description",
    text = "Set criteria for notifications.",
    width = "full",
    reference = "MastersVoice_DESCRIPTION1"
  },
  [3] = {
    type = "checkbox",
    name = "Combat Only",
    tooltip = "Notify only when player is in combat.",
    getFunc = function() return config.combatOnly end,
    setFunc = function(newBool) MastersVoice.SetCombatOnly(newBool) end,
    width = "full",
    default = Default.combatOnly,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SETCOMBATONLY_CHECKBOX"
  },
  [4] = {
    type = "checkbox",
    name = "Player Also",
    tooltip = "Notify also when player speaks through group chat.",
    getFunc = function() return config.playerAlso end,
    setFunc = function(newBool) MastersVoice.SetPlayerAlso(newBool) end,
    width = "full",
    default = Default.playerOnly,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SETPLAYERALSO_CHECKBOX"
  },
  [5] = {
    type = "checkbox",
    name = "Group Channel",
    tooltip = "Notify only when anyone speaks through group chat.",
    getFunc = function() return config.groupOnly end,
    setFunc = function(newBool) MastersVoice.SetGroupOnly(newBool) end,
    width = "full",
    default = Default.groupOnly,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SETGROUPONLY_CHECKBOX"
  },
  [6] = {
    type = "checkbox",
    name = "Yell Channel",
    tooltip = "Notify only when anyone speaks through yells.",
    getFunc = function() return config.yellOnly end,
    setFunc = function(newBool) MastersVoice.SetYellOnly(newBool) end,
    width = "full",
    default = Default.yellOnly,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SETYELLONLY_CHECKBOX"
  },
  [7] = {
    type = "checkbox",
    name = "Guild Channel",
    tooltip = "Notify only when anyone speaks through guild chat.",
    getFunc = function() return config.guildOnly end,
    setFunc = function(newBool) MastersVoice.SetGuildOnly(newBool) end,
    width = "full",
    default = Default.guildOnly,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SETGUILDONLY_CHECKBOX"
  },
  [8] = {
    type = "checkbox",
    name = "Crown (leader) Only",
    tooltip = "Notify only when crown speaks through group chat or yells.",
    getFunc = function() return config.crownOnly end,
    setFunc = function(newBool) MastersVoice.SetCrownOnly(newBool) end,
    width = "full",
    default = Default.crownOnly,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SETCROWNONLY_CHECKBOX"
  },
  [9] = {
    type = "checkbox",
    name = "Alliance War Only",
    tooltip = "Notify only when player is in an Alliance War zone (e.g., Cyrodiil)",
    getFunc = function() return config.allianceWarOnly end,
    setFunc = function(newBool) MastersVoice.SetAllianceWarOnly(newBool) end,
    width = "full",
    default = Default.allianceWarOnly,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SETALLIANCEWARONLY_CHECKBOX"
  },
  [10] = {
    type = "checkbox",
    name = "Enforce Crown Always",
    tooltip = "Always play notification for crown messages regardless of frequency or channel settings.",
    getFunc = function() return config.crownAlways end,
    setFunc = function(newBool) MastersVoice.SetCrownAlways(newBool) end,
    width = "full",
    default = Default.crownAlways,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SETCROWNALWAYS_CHECKBOX"
  },
  [11] = {
    type = "slider",
    name = "Frequency",
    tooltip = "Number of seconds to wait between notifications.",
    min = 0,
    max = 60,
    step = 1,
    getFunc = function() return config.silentTime end,
    setFunc = function(newTime) MastersVoice.SetSilentTime(newTime) end,
    width = "full",
    default = Default.silentTime,
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_SILENTTIME_SLIDER"
  },
  [12] = {
    type = "description",
    text = "Choose notifications sound.",
    width = "full",
    reference = "MastersVoice_DESCRIPTION2"
  },
  [13] = {
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
    reference = "MastersVoice_GROUPALARMSOUND_DROPDOWN"
  },
  [14] = {
    type = "button",
    name = "Preview Group",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayGroupAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_GROUPPREVIEW_BUTTON"
  },
  [15] = {
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
    reference = "MastersVoice_CROWNALARMSOUND_DROPDOWN"
  },
  [16] = {
    type = "button",
    name = "Preview Crown",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayCrownAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_CROWNPREVIEW_BUTTON"
  },
  [17] = {
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
    reference = "MastersVoice_GUILDNALARMSOUND_DROPDOWN"
  },
  [18] = {
    type = "button",
    name = "Preview Guild",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayGuildAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_GUILDPREVIEW_BUTTON"
  },
  [19] = {
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
    reference = "MastersVoice_YELLNALARMSOUND_DROPDOWN"
  },
  [20] = {
    type = "button",
    name = "Preview Yell",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayYellAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_YELLPREVIEW_BUTTON"
  },
  [21] = {
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
    reference = "MastersVoice_OTHERNALARMSOUND_DROPDOWN"
  },
  [22] = {
    type = "button",
    name = "Preview Other",
    tooltip = "Preview notification sound.",
    func = function() MastersVoice.PlayOtherAlarm() end,
    width = "half",
    disabled = function() return config.muteAll end,
    reference = "MastersVoice_OTHERPREVIEW_BUTTON"
  },
}

-------------------------------------------------------------------------------
-- Initialization section
-------------------------------------------------------------------------------

function MastersVoice:Initialize()
  -- Register event handlers.
  config = ZO_SavedVars:New("MastersVoiceVars",
      MastersVoice.configVersion, 
      nil, 
      Default)
  EVENT_MANAGER:RegisterForEvent(MastersVoice.name,
      EVENT_CHAT_MESSAGE_CHANNEL, 
      MastersVoice.OnChatMessageChannel)
  EVENT_MANAGER:UnregisterForEvent(MastersVoice.name, 
      EVENT_ADD_ON_LOADED)
  
  -- Register addon settings.
  LAM2:RegisterOptionControls("MastersVoiceOptions", 
      optionsData)
  LAM2:RegisterAddonPanel("MastersVoiceOptions", 
      panelData)
end

function MastersVoice.OnAddOnLoaded(event, addonName)
  if addonName == MastersVoice.name then
    MastersVoice:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(MastersVoice.name, EVENT_ADD_ON_LOADED,
  MastersVoice.OnAddOnLoaded)

-------------------------------------------------------------------------------
-- Chat events handling
-------------------------------------------------------------------------------

local function d(msg)
  if MastersVoice.debug then
    CHAT_SYSTEM:AddMessage("[MV_debug] "..msg)
  end
end

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
    if fromName == GetRawUnitName("player") then
      -- don't play notification for yourself
      d("?:player, skip")
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
  local alertChannel = ""
  if config.groupOnly or config.allChannels then
    if messageType == CHAT_CHANNEL_PARTY then
      -- notify if group channel used
      d("?:party")
      alertChannel = "GROUP"
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
      alertChannel = "GUILD"
    end
  end
  if config.yellOnly or config.allChannels then
    if messageType == CHAT_CHANNEL_YELL then
      -- notify if yell channel used
      d("?:yell")
      alertChannel = "YELL"
    end
  end
  if alertChannel == "" and config.allChannels then
    -- all other channels end up here
    alertChannel = "OTHER"
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
  if config.combatOnly then
    if not IsUnitInCombat("player") then
      -- skip if player is not in combat
      d("?:!combat, skip")
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
    MastersVoice.PlayCrownAlarm()
  else
    if alertChannel == "GROUP" then
      MastersVoice.PlayGroupAlarm()
    elseif alertChannel == "GUILD" then
      MastersVoice.PlayGuildAlarm()
    elseif alertChannel == "YELL" then
      MastersVoice.PlayYellAlarm()
    elseif alertChannel == "OTHER" then
      MastersVoice.PlayOtherAlarm()
    end
  end
end