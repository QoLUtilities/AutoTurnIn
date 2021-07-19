local addonName, ATI = ...

ATI.EventFrame = CreateFrame('Frame')
ATI.Events = {}

function ATI.Events:ADDON_LOADED(...)
	local loadedAddon = ...
	if loadedAddon == addonName then
		ATI.LoadDefaults()
		ATI.CreateConfig()
		ATI.EventFrame:UnregisterEvent('ADDON_LOADED')
	end
end

function ATI.Events.GOSSIP_SHOW(...)
	ATI.GossipShow()
end

function ATI.Events.QUEST_DETAIL(...)
	ATI.QuestDetail()
end

function ATI.Events.QUEST_PROGRESS(...)
	ATI.QuestProgress()
end

function ATI.Events.QUEST_COMPLETE(...)
	ATI.QuestComplete()
end

function ATI.Events.QUEST_TURNED_IN(...)
	local questID = ...
	ATI.QuestTurnedIn(questID)
end

----------------------------------
------  Event Registration  ------
----------------------------------

ATI.EventFrame:SetScript('OnEvent',
	function(self, event, ...)
		ATI.Events[event](self, ...)
	end
)

for k, v in pairs(ATI.Events) do
	ATI.EventFrame:RegisterEvent(k)
end
