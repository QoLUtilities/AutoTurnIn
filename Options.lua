local addonName, ATI = ...
local common = QOLUtilsCommon

function ATI.LoadDefaults()
	if ATI_Config_Acct == nil then
		ATI_Config_Acct = {}
	end
	ATI.LoadConfig(ATI_Config_Acct)
	if ATI_Config_Toon == nil then
		ATI_Config_Toon = {}
	end
	if ATI_Config_Toon.Active == nil then
		ATI_Config_Toon.Active = true
	end
	ATI.LoadConfig(ATI_Config_Toon)
end

function ATI.LoadConfig(config)
	if config.AutoTurnInActive == nil then
		config.AutoTurnInActive = false
	end
	if config.CompletedQuests == nil then
		config.CompletedQuests = {}
	end
	if config.IgnoredQuests == nil then
		config.IgnoredQuests = {}
	end
	if config.AcceptedQuests == nil then
		config.AcceptedQuests = {}
	end
end

function ATI.CreateConfig()
	ATI.Panel = common.CreateChildConfigPanel(ATI.Labels.Name)
	ATI.Acct = {}
	local acctHeader = common.CreateLabel(ATI.Panel, ATI.Panel, common.ConfigSpacing.Indent, -common.ConfigSpacing.SectionGap, common.Labels.Acct)
	ATI.Acct.CheckBoxReport = common.CreateCheckBox(ATI.Panel, acctHeader, common.ConfigSpacing.Indent, -common.ConfigSpacing.HeaderGap, ATI.Labels.Report, ATI_Config_Acct.ReportAtLogon, ATI.ToggleReportOnClick)
	local acctLabel = common.CreateLabel(ATI.Panel, ATI.Acct.CheckBoxReport, 0, -common.ConfigSpacing.HeaderGap, ATI.Labels.Levels)
	ATI.Acct.EditBoxLevels = common.CreateEditBox(ATI.Panel, acctLabel, common.ConfigSpacing.Indent, -10, common.TableToStr(ATI_Config_Acct.Levels), ATI.ParseVolumeLevels)	
	ATI.Toon = {}
	local toonHeader = common.CreateHeader(ATI.Panel, ATI.Acct.EditBoxLevels, -common.ConfigSpacing.Indent * 2, -common.ConfigSpacing.SectionGap, common.Labels.Toon)
	ATI.Toon.CheckBoxReport = common.CreateCheckBox(ATI.Panel, toonHeader, common.ConfigSpacing.Indent, -common.ConfigSpacing.HeaderGap, ATI.Labels.Report, ATI_Config_Toon.ReportAtLogon, ATI.ToggleReportOnClick)
	ATI.Toon.CheckBoxActive = common.CreateCheckBox(ATI.Panel, ATI.Toon.CheckBoxReport, 0, -common.ConfigSpacing.HeaderGap, common.Labels.UseToon, ATI_Config_Toon.Active, ATI.ToggleToonSpecific)
	local toonLabel = common.CreateLabel(ATI.Panel, ATI.Toon.CheckBoxActive, 0, -common.ConfigSpacing.HeaderGap, ATI.Labels.Levels)
	ATI.Acct.EditBoxLevels = common.CreateEditBox(ATI.Panel, toonLabel, common.ConfigSpacing.Indent, -10, common.TableToStr(ATI_Config_Toon.Levels), ATI.ParseVolumeLevels)	
end

function ATI.ToggleReportOnClick()
	ATI_Config_Acct.ReportAtLogon = ATI.Acct.CheckBoxReport:GetChecked()
	ATI_Config_Toon.ReportAtLogon = ATI.Toon.CheckBoxReport:GetChecked()
end

function ATI.ToggleToonSpecific()
	ATI_Config_Toon.Active = ATI.Toon.CheckBoxActive:GetChecked()
end

function ATI.ParseVolumeLevels(self)
	local configLevels = self == ATI.Acct.EditBoxLevels and ATI_Config_Acct.Levels or ATI_Config_Toon.Levels
	local enteredPresets = common.StrToTable(self:GetText(), common.Patterns.Numbers)
	local validPresets = {}
	for i = 1, table.getn(enteredPresets) do
		if ATI.ValidLevel(enteredPresets[i]) then
			table.insert(validPresets, enteredPresets[i])
		end
	end
	configLevels = validPresets
	self:SetText(common.TableToStr(configLevels))
end