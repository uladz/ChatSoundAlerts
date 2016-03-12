------------------------------------------
--	Libraries --
------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

------------------------------------------
--	Basic Stuff --
------------------------------------------
MastersVoice = {}

MastersVoice.name = "MastersVoice"
MastersVoice.version = 0.43
lastCall = 0								-- time of last alarm sound
local savedVariables = {}
local Default = {
	silentTime = 30,						-- number of seconds to wait before sounding again
	combatOnly = true,						-- whether to sound only when player is in combat
	groupOnly = true,						-- whether to sound only if crown speaks through /g or /y
	allianceWarOnly = true,					-- whether to sound only if in an alliance war zone
	alarmSound = "ABILITY_MORPH_PURCHASED"	-- number of the alarm sound in MastersVoice.AlarmSoundsList table
}
local alarmSoundsList = {
	"ABILITY_MORPH_PURCHASED",
	"AVA_GATE_OPENED",
	"DEFER_NOTIFICATION",
	"GENERAL_ALERT_ERROR",
	"NEW_MAIL",
	"NEW_NOTIFICATION",
	"STATS_PURCHASE"
}

------------------------------------------
-- Settings Control --
------------------------------------------

function MastersVoice.SetSilentTime(newTime)
	savedVariables.silentTime = newTime
end

function MastersVoice.SetCombatOnly(newBool)
	savedVariables.combatOnly = newBool
end

function MastersVoice.SetGroupOnly(newBool)
	savedVariables.groupOnly = newBool
end

function MastersVoice.SetAllianceWarOnly(newBool)
	savedVariables.allianceWarOnly = newBool
end

function MastersVoice.SetAlarmSound(newSoundName)
	savedVariables.alarmSound = newSoundName
end

------------------------------------------
-- Settings Menu --
------------------------------------------

local panelData = {
	type = "panel",
	name = "The Master's Voice",
	-- displayName = "My Longer Window Title",	--(optional) (can be useful for long addon names or if you want to colorize it)
	author = "HomoPuerRobustus",	--(optional)
	version = MastersVoice.version,	--(optional)
	-- slashCommand = "/myaddon",	--(optional) will register a keybind to open to this panel (don't forget to include the slash!)
	registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
	registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	resetFunc = function() print("defaults reset") end,	--(optional) custom function to run after settings are reset to defaults
}

local optionsData = {
	[1] = {
		type = "description",
		-- title = "My Title",	--(optional)
		text = "Set criteria for crown notifications and change notification sound.",
		width = "full",	--or "half" (optional)
		reference = "MastersVoice_DESCRIPTION"	--(optional) unique global reference to control
	},
	[2] = {
		type = "checkbox",
		name = "Combat Only",
		tooltip = "Notify only when player is in combat.",
		getFunc = function() return savedVariables.combatOnly end,
		setFunc = function(newBool) MastersVoice.SetCombatOnly(newBool) end,
		width = "full",	--or "half" (optional)
		-- disaled = function() return db.someBooleanSetting end,	--or boolean (optional)
		-- warnng = "Will need to reload the UI.",	--(optional)
		default = Default.combatOnly,	--(optional)
		reference = "MastersVoice_SETCOMBATONLY_CHECKBOX"	--(optional) unique global reference to control
	},
	[3] = {
		type = "checkbox",
		name = "Group Chat or Yell Only",
		tooltip = "Notify only when crown speaks through group chat or yells.",
		getFunc = function() return savedVariables.groupOnly end,
		setFunc = function(newBool) MastersVoice.SetGroupOnly(newBool) end,
		width = "full",	--or "half" (optional)
		-- disaled = function() return db.someBooleanSetting end,	--or boolean (optional)
		-- warnng = "Will need to reload the UI.",	--(optional)
		default = Default.groupOnly,	--(optional)
		reference = "MastersVoice_SETGROUPONLY_CHECKBOX"	--(optional) unique global reference to control
	},
	[4] = {
		type = "checkbox",
		name = "Alliance War Only",
		tooltip = "Notify only when player is in an Alliance War zone (e.g., Cyrodiil)",
		getFunc = function() return savedVariables.allianceWarOnly end,
		setFunc = function(newBool) MastersVoice.SetAllianceWarOnly(newBool) end,
		width = "full",	--or "half" (optional)
		-- disaled = function() return db.someBooleanSetting end,	--or boolean (optional)
		-- warnng = "Will need to reload the UI.",	--(optional)
		default = Default.allianceWarOnly,	--(optional)
		reference = "MastersVoice_SETALLIANCEWARONLY_CHECKBOX"	--(optional) unique global reference to control
	},
	[5] = {
		type = "slider",
		name = "Frequency",
		tooltip = "Number of seconds to wait between crown notifications.",
		min = 0,
		max = 120,
		step = 5,	--(optional)
		getFunc = function() return savedVariables.silentTime end,
		setFunc = function(newTime) MastersVoice.SetSilentTime(newTime) end,
		width = "full",	--or "half" (optional)
		-- disabled = function() return db.someBooleanSetting end,	--or boolean (optional)
		-- warning = "Will need to reload the UI.",	--(optional)
		default = Default.silentTime,	--(optional)
		reference = "MastersVoice_SILENTTIME_SLIDER"	--(optional) unique global reference to control
	},
	[6] = {
		type = "dropdown",
		name = "Notification Sound",
		tooltip = "Choose which sound to play for crown notifications.",
		choices = alarmSoundsList,
		sort = "name-up", --or "name-down", "numeric-up", "numeric-down" (optional) - if not provided, list will not be sorted
		getFunc = function() return savedVariables.alarmSound end,
		setFunc = function(newSoundName) MastersVoice.SetAlarmSound(newSoundName) end,
		width = "full",	--or "half" (optional)
		--disabled = function() return db.someBooleanSetting end,	--or boolean (optional)
		--warning = "Will need to reload the UI.",	--(optional)
		default = Default.alarmSound,	--(optional)
		reference = "MastersVoice_ALARMSOUND_DROPDOWN"	--(optional) unique global reference to control
	},
	[7] = {
		type = "button",
		name = "Preview",
		tooltip = "Preview notification sound.",
		func = function() MastersVoice.PlayAlarm() end,
		width = "full",	--or "half" (optional)
		--disabled = function() return db.someBooleanSetting end,	--or boolean (optional)
		--icon = "icon\\path.dds",	--(optional)
		--warning = "Will need to reload the UI.",	--(optional)
		reference = "MastersVoice_PREVIEW_BUTTON"	--(optional) unique global reference to control
	}
}


------------------------------------------
-- Initialization --
------------------------------------------
function MastersVoice:Initialize()
	savedVariables = ZO_SavedVars:New("MastersVoiceVars", MastersVoice.version, nil, Default)
	--MastersVoice.SetSilentTime(savedVariables.silentTime)
	--MastersVoice.SetCombatOnly(savedVariables.combatOnly)
	--MastersVoice.SetGroupOnly(savedVariables.groupOnly)
	--MastersVoice.SetAllianceWarOnly(savedVariables.allianceWarOnly)
	--MastersVoice.SetAlarmSound(savedVariables.alarmSound)
	EVENT_MANAGER:RegisterForEvent(MastersVoice.name, EVENT_CHAT_MESSAGE_CHANNEL, MastersVoice.OnChatMessageChannel)
	EVENT_MANAGER:UnregisterForEvent(MastersVoice.name, EVENT_ADD_ON_LOADED)
	LAM2:RegisterOptionControls("MastersVoiceOptions", optionsData)
	LAM2:RegisterAddonPanel("MastersVoiceOptions", panelData)
end

function MastersVoice.OnAddOnLoaded(event, addonName)
	if addonName == MastersVoice.name then
		MastersVoice:Initialize()
	end
end

------------------------------------------
-- Chat Event Handling --
------------------------------------------

function MastersVoice.OnChatMessageChannel(eventCode, messageType, fromName, messageText, isCustomerService)
	if savedVariables.allianceWarOnly then
		if not IsPlayerInAvAWorld() then return end
	end
	if savedVariables.groupOnly then
		if messageType ~= 3 then return end
	end
	if fromName ~= GetRawUnitName(GetGroupLeaderUnitTag()) then return end
	if savedVariables.combatOnly then
		if not IsUnitInCombat("player") then return end
	end
	if GetDiffBetweenTimeStamps(GetTimeStamp(), lastCall) < savedVariables.silentTime then return end
	lastCall = GetTimeStamp()
	MastersVoice.PlayAlarm()
end

function MastersVoice.PlayAlarm()
	--temp = "SOUNDS." .. savedVariables.alarmSound
	PlaySound(savedVariables.alarmSound)
end

EVENT_MANAGER:RegisterForEvent(MastersVoice.name, EVENT_ADD_ON_LOADED, MastersVoice.OnAddOnLoaded)