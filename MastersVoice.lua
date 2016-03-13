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
local savedVariables = {}

-- Default configuration values.
local Default = {
  -- number of seconds to wait before sounding again
  silentTime = 30,
  -- whether to sound only when player is in combat
  combatOnly = true,
  -- whether to sound if player himself speaks
  playerAlso = true,
  -- whether to sound only if anyone speaks through /g
  groupOnly = true,
  -- whether to sound only if anyone speaks through /y
  yellOnly = true,
  -- whether to sound only if crown speaks through /g or /y
  crownOnly = true,
  -- whether to sound only if in an alliance war zone
  allianceWarOnly = true,
  -- group alarm sound in MastersVoice.AlarmSoundsList table
  alarmSound1 = "NEW_NOTIFICATION",
  -- crown alarm sound in MastersVoice.AlarmSoundsList table	
  alarmSound2 = "NEW_NOTIFICATION"
}

-- List of sound notifications to choose from.
local alarmSoundsList = {
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

function MastersVoice.SetSilentTime(newTime)
	savedVariables.silentTime = newTime
end

function MastersVoice.SetCombatOnly(newBool)
	savedVariables.combatOnly = newBool
end

function MastersVoice.SetPlayerAlso(newBool)
  savedVariables.playerAlso = newBool
end

function MastersVoice.SetGroupOnly(newBool)
	savedVariables.groupOnly = newBool
end

function MastersVoice.SetYellOnly(newBool)
  savedVariables.yellOnly = newBool
end

function MastersVoice.SetCrownOnly(newBool)
	savedVariables.crownOnly = newBool
end

function MastersVoice.SetAllianceWarOnly(newBool)
	savedVariables.allianceWarOnly = newBool
end

function MastersVoice.SetAlarmSound1(newSoundName, play)
  savedVariables.alarmSound1 = newSoundName
  if play == true then
    MastersVoice.PlayAlarm1()
  end
end

function MastersVoice.SetAlarmSound2(newSoundName, play)
	savedVariables.alarmSound2 = newSoundName
  if play == true then
    MastersVoice.PlayAlarm2()
  end
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
		type = "description",
		text = "Set criteria for notifications and change notification sound.",
		width = "full",
		reference = "MastersVoice_DESCRIPTION"
	},
	[2] = {
		type = "checkbox",
		name = "Combat Only",
		tooltip = "Notify only when player is in combat.",
		getFunc = function() return savedVariables.combatOnly end,
		setFunc = function(newBool) MastersVoice.SetCombatOnly(newBool) end,
		width = "full",
		default = Default.combatOnly,
		reference = "MastersVoice_SETCOMBATONLY_CHECKBOX"
	},
  [3] = {
    type = "checkbox",
    name = "Player Also",
    tooltip = "Notify also when player speaks through group chat.",
    getFunc = function() return savedVariables.playerAlso end,
    setFunc = function(newBool) MastersVoice.SetPlayerAlso(newBool) end,
    width = "full",
    default = Default.playerOnly,
    reference = "MastersVoice_SETPLAYERALSO_CHECKBOX"
  },
	[4] = {
		type = "checkbox",
		name = "Group Chat Only",
		tooltip = "Notify only when anyone speaks through group chat.",
		getFunc = function() return savedVariables.groupOnly end,
		setFunc = function(newBool) MastersVoice.SetGroupOnly(newBool) end,
		width = "full",
		default = Default.groupOnly,
		reference = "MastersVoice_SETGROUPONLY_CHECKBOX"
	},
  [5] = {
    type = "checkbox",
    name = "Yell Channel Only",
    tooltip = "Notify only when anyone speaks through yells.",
    getFunc = function() return savedVariables.yellOnly end,
    setFunc = function(newBool) MastersVoice.SetYellOnly(newBool) end,
    width = "full",
    default = Default.yellOnly,
    reference = "MastersVoice_SETYELLONLY_CHECKBOX"
  },
	[6] = {
		type = "checkbox",
		name = "Crown (leader) Only",
		tooltip = "Notify only when crown speaks through group chat or yells.",
		getFunc = function() return savedVariables.crownOnly end,
		setFunc = function(newBool) MastersVoice.SetCrownOnly(newBool) end,
		width = "full",
		default = Default.groupOnly,
		reference = "MastersVoice_SETCROWNONLY_CHECKBOX"
	},
	[7] = {
		type = "checkbox",
		name = "Alliance War Only",
		tooltip = "Notify only when player is in an Alliance War zone (e.g., Cyrodiil)",
		getFunc = function() return savedVariables.allianceWarOnly end,
		setFunc = function(newBool) MastersVoice.SetAllianceWarOnly(newBool) end,
		width = "full",
		default = Default.allianceWarOnly,
		reference = "MastersVoice_SETALLIANCEWARONLY_CHECKBOX"
	},
	[8] = {
		type = "slider",
		name = "Frequency",
		tooltip = "Number of seconds to wait between crown notifications.",
		min = 0,
		max = 60,
		step = 1,
		getFunc = function() return savedVariables.silentTime end,
		setFunc = function(newTime) MastersVoice.SetSilentTime(newTime) end,
		width = "full",
		default = Default.silentTime,
		reference = "MastersVoice_SILENTTIME_SLIDER"
	},
	[9] = {
		type = "dropdown",
		name = "Group Notification Sound",
		tooltip = "Choose which sound to play for group notifications.",
		choices = alarmSoundsList,
		sort = "name-up",
		getFunc = function() return savedVariables.alarmSound1 end,
		setFunc = function(newSoundName) MastersVoice.SetAlarmSound1(newSoundName, true) end,
		width = "full",
		default = Default.alarmSound1,
		reference = "MastersVoice_ALARMSOUND1_DROPDOWN"
	},
	[10] = {
		type = "button",
		name = "Preview Group",
		tooltip = "Preview notification sound.",
		func = function() MastersVoice.PlayAlarm1() end,
		width = "full",
		reference = "MastersVoice_PREVIEW1_BUTTON"
	},
	[11] = {
		type = "dropdown",
		name = "Crown Notification Sound",
		tooltip = "Choose which sound to play for crown notifications.",
		choices = alarmSoundsList,
		sort = "name-up", --or "name-down", "numeric-up", "numeric-down" (optional) - if not provided, list will not be sorted
		getFunc = function() return savedVariables.alarmSound2 end,
		setFunc = function(newSoundName) MastersVoice.SetAlarmSound2(newSoundName, true) end,
		width = "full",
		default = Default.alarmSound2,
		reference = "MastersVoice_ALARMSOUND2_DROPDOWN"
	},
	[12] = {
		type = "button",
		name = "Preview Crown",
		tooltip = "Preview notification sound.",
		func = function() MastersVoice.PlayAlarm2() end,
		width = "full",
		reference = "MastersVoice_PREVIEW2_BUTTON"
	}
}

-------------------------------------------------------------------------------
-- Initialization section
-------------------------------------------------------------------------------

function MastersVoice:Initialize()
  savedVariables = ZO_SavedVars:New("MastersVoiceVars", 
    MastersVoice.configVersion, nil, Default)
  EVENT_MANAGER:RegisterForEvent(MastersVoice.name, 
    EVENT_CHAT_MESSAGE_CHANNEL, MastersVoice.OnChatMessageChannel)
  EVENT_MANAGER:UnregisterForEvent(MastersVoice.name, EVENT_ADD_ON_LOADED)
  LAM2:RegisterOptionControls("MastersVoiceOptions", optionsData)
  LAM2:RegisterAddonPanel("MastersVoiceOptions", panelData)
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
    isCustomerService)
  if not savedVariables.playerAlso then
    if fromName == GetRawUnitName("player") then
      -- don't play notification for yourself
      d("?:player, skip")
      return
    end
  end
  if savedVariables.allianceWarOnly then
    if not IsPlayerInAvAWorld() then
      -- skip if not in alliance war zone
      d("cond:!war, skip")
      return
    end
  end
  local alertChannel = false
  local allChannels = true
  if savedVariables.groupOnly then
    if messageType == CHAT_CHANNEL_PARTY then
      -- notify if group channel used
      d("?:party")
      alertChannel = true
    end
    allChannels = false
  end
  if savedVariables.yellOnly then
    if messageType == CHAT_CHANNEL_YELL then
      -- notify if yell channel used
      d("?:yell")
      alertChannel = true
    end
    allChannels = false
  end
  if not alertChannel and not allChannels then
    d("?:!channel, skip")
    return
  end
  local crownName = GetRawUnitName(GetGroupLeaderUnitTag())
  local crownSpeaks = false
  if fromName == crownName then
    crownSpeaks = true
  end
  if savedVariables.crownOnly then
    if not crownSpeaks then
      -- skip if not crown speaking
      d("?:!crown, skip")
      return
    end
  end
  if savedVariables.combatOnly then
    if not IsUnitInCombat("player") then
      -- skip if player is not in combat
      d("?:!combat, skip")
      return
    end
  end
  local timeDiff = GetDiffBetweenTimeStamps(GetTimeStamp(), lastCall)
  if timeDiff < savedVariables.silentTime then
    -- mute if notified too often
    d("?:mute, skip")
    return
  end
  lastCall = GetTimeStamp()
  if not crownSpeaks then
    MastersVoice.PlayAlarm1()
  else
    MastersVoice.PlayAlarm2()
  end
end

function MastersVoice.PlayAlarm1()
  --temp = "SOUNDS." .. savedVariables.alarmSound
	PlaySound(savedVariables.alarmSound1)
end

function MastersVoice.PlayAlarm2()
	--temp = "SOUNDS." .. savedVariables.alarmSound
	PlaySound(savedVariables.alarmSound2)
end
