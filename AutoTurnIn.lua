local addonName, ATI = ...
local common = QOLUtilsCommon

local origClicks = {}
local questList = {}

function ATI.CleanQuestName(originalTitle)
	-- Strip [<level crap>] <quest title>
	-- Strip color codes
	-- Strip (low level) at the end of a quest
	return string.gsub(text, '%[(.+)%]', '')
		:string.gsub(text, '|c%x%x%x%x%x%x%x%x(.+)|r', '%1')
		:string.gsub(text, '(.+) %((.+)%)', '%1')
end

function ATI.Initialize()
	ATI_List = ATI_List or {}
	ATI_Accept = ATI_Accept or {}
	-- Hook for auto accpet
	local orig_QuestAccept = QuestFrameAcceptButton:GetScript('OnClick')
	QuestFrameAcceptButton:SetScript('OnClick', function(self, ...)
		if IsControlKeyDown() and GetTitleText() then
			local text = ATI.CleanQuestName(GetTitleText())
			local questName = string.lower(string.trim(text))
			if ATI_Accept[questName] then
				ATI.LogAutoAcceptOff(text)
				ATI_Accept[questName] = nil
			else
				ATI.LogAutoAcceptOn(text)
				ATI_Accept[questName] = true
			end
			return
		end
		if orig_QuestAccept then
			orig_QuestAccept(self, ...)
		end
	end)
	-- Hook for auto turnin
	local orig_QuestComplete = QuestFrameCompleteQuestButton:GetScript('OnClick')
	QuestFrameCompleteQuestButton:SetScript('OnClick', function(self, ...)
		if IsAltKeyDown() and GetTitleText() then
			local text = ATI.CleanQuestName(GetTitleText())
			local questName = string.lower(string.trim(text))
			if ATI_List[questName] then
				ATI_List[questName] = nil
				ATI.LogAutoTurnInOff(text)
			else
				ATI_List[questName] = {}
				ATI.LogAutoTurnInOn(text)
			end
			return
		end
		if orig_QuestComplete then
			orig_QuestComplete(self, ...)
		end
	end)
end

-- Auto skip gossip
local function gossipOnClick(self, ...)
	-- Adding a new skip
	if IsAltKeyDown() and self:GetText() then
		-- If it already exists, remove it
		local text = ATI.CleanQuestName(self:GetText())
		local questName = string.lower(string.trim(text))
		if ATI_List[questName] then
			if self.type ~= 'Gossip' then
				ATI.LogAutoTurnInOff(text)
			else
				ATI.LogAutoSkipOff(text)
			end
			ATI_List[questName] = nil
		-- Gossip doesn't have item requirements
		elseif self.type == 'Gossip' then
			ATI.LogAutoSkipOn(text)
			ATI_List[questName] = true
		-- It's not gossip, so it could possibly have item requirements
		else
			ATI.LogAutoTurnInOn(text)
			ATI_List[questName] = {}
		end
		return
	-- Adding new auto acception
	elseif IsControlKeyDown() and self:GetText() and self.type ~= 'Gossip' then
		local text = ATI.CleanQuestName(self:GetText())
		local questName = string.lower(string.trim(text))
		if ATI_Accept[questName] then
			ATI.LogAutoAcceptOff(text)
			ATI_Accept[questName] = nil
		else
			ATI.LogAutoAcceptOn(text)
			ATI_Accept[questName] = true
		end
		return
	end
	origClicks[self:GetName()](self, ...)
end

-- Check if we need to auto skip
function ATI.GossipShow()
	if IsShiftKeyDown() then
		return
	end
	for i, questData in ipairs(C_GossipInfo.GetAvailableQuests()) do
		if ATI.IsAutoQuest(questData.questID then
			C_GossipInfo.SelectAvailableQuest(i)
		end
	end
	for i, questData in ipairs(C_GossipInfo.GetActiveQuests()) do
		if ATI.IsAutoQuest(questData.questID) then
			C_GossipInfo.SelectActiveQuest(i)
		end
	end
	for i, questData in ipairs(C_GossipInfo.GetOptions()) do
		if ATI.IsAutoQuest(questData.name) then
			C_GossipInfo.SelectOption(i)
		end
	end
end

function ATI.QuestProgress()
	if IsShiftKeyDown() then
		return
	end
	if IsQuestCompletable() and ATI.IsAutoQuest(GetTitleText()) then
		CompleteQuest()
	end
end

function ATI.QuestComplete()
	local questName = string.lower(string.trim(GetTitleText()))
	if not ATI_List[questName] then return end
	-- Unflag the quest as an item check so it can be auto completed
	if type(ATI_List[questName]) == 'table' then
		local hasItem
		for itemid in pairs(ATI_List[questName]) do
			hasItem = true
			break
		end
		if not hasItem then
			ATI_List[questName] = true
		end
	end		
	for k in pairs(questList) do
		questList[k] = nil
	end	
	questList[string.lower(string.trim(ATI.CleanQuestName(GetTitleText())))] = true
	if not IsShiftKeyDown() and ATI.IsAutoQuest(GetTitleText()) then
		if QuestFrameRewardPanel.itemChoice == 0 and GetNumQuestChoices() > 0 then
			QuestChooseRewardError()
		else
			PlaySound(SOUNDKIT.IG_QUEST_LIST_COMPLETE)
			GetQuestReward(QuestFrameRewardPanel.itemChoice)
		end
	end
end

function ATI.QuestDetail()
	if not IsShiftKeyDown() and ATI_Config_Acct.CompletedQuests[string.lower(string.trim(GetTitleText()))] then
		AcceptQuest()
	end
end

-- Check if the quest has been completed yet
function ATI.IsCompleted(name)
	for i=1, GetNumQuestLogEntries() do
		local questName, _, _, _, _, _, isComplete = GetQuestLogTitle(i)		
		if name == string.lower(string.trim(ATI.CleanQuestName(questName))) then
			if (isComplete and isComplete > 0) or GetNumQuestLeaderBoards(i) == 0 then
				return true
			end			
			return nil
		end
	end
	return true
end

-- Figure out if it's an auto turn in quest and if we can actually complete it
function ATI.HasItems(list)
	for itemid in pairs(list) do return true end
	return nil
end

function ATI.IsAutoQuest(title)
	local cleanTitle = string.lower(string.trim(ATI.CleanQuestName(title)))
	return ATI_List[cleanTitle]
end

function ATI.LogAutoAcceptOn(questTitle)
	ATI.Log(format(L.AutoAcceptOn, questTitle)
end

function ATI.LogAutoAcceptOff(questTitle)
	ATI.Log(format(L.AutoAcceptOff, questTitle)
end

function ATI.LogAutoTurnInOn(questTitle)
	ATI.Log(format(L.AutoTurnInOn, questTitle)
end

function ATI.LogAutoTurnInOff(questTitle)
	ATI.Log(format(L.AutoTurnInOff, questTitle)
end

function ATI.LogAutoSkipOn(questTitle)
	ATI.Log(format(L.AutoSkipOn, questTitle)
end

function ATI.LogAutoSkipOff(questTitle)
	ATI.Log(format(L.AutoSkipOff, questTitle)
end

function ATI.Log(message)
	common.Log(message, 'ATI')
end