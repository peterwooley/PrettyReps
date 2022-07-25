--[[
			

								$$$$$$$\                       $$\     $$\                     $$$$$$$\                                
								$$  __$$\                      $$ |    $$ |                    $$  __$$\                               
								$$ |  $$ | $$$$$$\   $$$$$$\ $$$$$$\ $$$$$$\   $$\   $$\       $$ |  $$ | $$$$$$\   $$$$$$\   $$$$$$$\ 
								$$$$$$$  |$$  __$$\ $$  __$$\\_$$  _|\_$$  _|  $$ |  $$ |      $$$$$$$  |$$  __$$\ $$  __$$\ $$  _____|
								$$  ____/ $$ |  \__|$$$$$$$$ | $$ |    $$ |    $$ |  $$ |      $$  __$$< $$$$$$$$ |$$ /  $$ |\$$$$$$\  
								$$ |      $$ |      $$   ____| $$ |$$\ $$ |$$\ $$ |  $$ |      $$ |  $$ |$$   ____|$$ |  $$ | \____$$\ 
								$$ |      $$ |      \$$$$$$$\  \$$$$  |\$$$$  |\$$$$$$$ |      $$ |  $$ |\$$$$$$$\ $$$$$$$  |$$$$$$$  |
								\__|      \__|       \_______|  \____/  \____/  \____$$ |      \__|  \__| \_______|$$  ____/ \_______/ 
								                                               $$\   $$ |                          $$ |                
								                                               \$$$$$$  |                          $$ |                
								                                                \______/                           \__|                
												
												Author: https://wow.curseforge.com/members/Sida2
												Curse: https://wow.curseforge.com/projects/pretty-reps
												Thanks to: https://worldofwarcraft.com/en-gb/character/ravencrest/Dayanne

]]


PrettyRepsDB = {Structure = {}, Options = {}}
local gender
local playerName, playerRealm
local characterRepStructure
local flatReps
local selectedFaction
local EXALTED_STANDING_ID = 8
local BEST_FRIEND_STANDING_ID = 5
local isAlliance, isHorde
local playerOptions = {}
local fakeHeadersCollapsedStatus = {}
local guildRep = {}
local loadDone

--[[
	

	 $$$$$$\             $$\                         
	$$  __$$\            $$ |                        
	$$ /  \__| $$$$$$\ $$$$$$\   $$\   $$\  $$$$$$\  
	\$$$$$$\  $$  __$$\\_$$  _|  $$ |  $$ |$$  __$$\ 
	 \____$$\ $$$$$$$$ | $$ |    $$ |  $$ |$$ /  $$ |
	$$\   $$ |$$   ____| $$ |$$\ $$ |  $$ |$$ |  $$ |
	\$$$$$$  |\$$$$$$$\  \$$$$  |\$$$$$$  |$$$$$$$  |
	 \______/  \_______|  \____/  \______/ $$  ____/ 
	                                       $$ |      
	                                       $$ |      
	                                       \__|      


]]

local objectScripts = {}
function HookScript(obj, scriptName, func)
	table.insert(objectScripts, {obj = obj, scriptName = scriptName, original = obj:GetScript(scriptName), new = func})
end

local disabledHooks = {}
function AddDisabledHook(func)
	table.insert(disabledHooks, func)
end

function TogglePREnabled(enabled)
	for _, v in pairs(objectScripts) do
		v.obj:SetScript(v.scriptName, enabled and v.new or v.original)
	end

	if enabled then
		ReloadCharacterData()
		ModifyRepPanel()
		Refresh()
	else
		for _, v in pairs(disabledHooks) do
			v()
		end
		ReputationFrame_Update()
	end
end

function GetOption(name, default)
	if playerOptions[name] ~= nil then
		return playerOptions[name]
	else
		return default
	end
end

local frame = CreateFrame("FRAME", "PrettyRepsEventFrame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("UPDATE_FACTION")
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LEAVING_WORLD" or event == "PLAYER_LOGOUT" then
		Save()
	else
		if not loadDone then	
			playerOptions = PrettyRepsDB.Options or playerOptions
			fakeHeadersCollapsedStatus = PrettyRepsDB.Headers or fakeHeadersCollapsedStatus
			playerOptions.Enabled = true

			gender = UnitSex("player")
			playerName, playerRealm = UnitName("player")
			isAlliance = UnitFactionGroup("player") == "Alliance"
			isHorde = UnitFactionGroup("player") == "Horde"
			--CharacterFrameTab2:SetText("Pretty Reps")

			HookScripts()
			ModifyRepPanel()
			TogglePREnabled(playerOptions.Enabled)
			loadDone = true
		end
		ReloadCharacterData()
		Refresh()
	end
end)

HookScript(ReputationFrame, "OnShow", function(self)
	if not guildRep.standingID then
		local guildName = GetGuildInfo("player")
		if guildName ~= nil then
			ReloadCharacterData()
			Refresh()
		end
	end
	ReputationFrame_OnShow(self)
end)

function Save()
	if characterRepStructure then
		PrettyRepsDB.Structure = characterRepStructure
		PrettyRepsDB.Options = playerOptions
		PrettyRepsDB.Headers = fakeHeadersCollapsedStatus
	end
end

--[[
	

$$$$$$$\                                  $$\                $$\     $$\                           $$\   $$\ $$$$$$\ 
$$  __$$\                                 $$ |               $$ |    \__|                          $$ |  $$ |\_$$  _|
$$ |  $$ | $$$$$$\   $$$$$$\  $$\   $$\ $$$$$$\    $$$$$$\ $$$$$$\   $$\  $$$$$$\  $$$$$$$\        $$ |  $$ |  $$ |  
$$$$$$$  |$$  __$$\ $$  __$$\ $$ |  $$ |\_$$  _|   \____$$\\_$$  _|  $$ |$$  __$$\ $$  __$$\       $$ |  $$ |  $$ |  
$$  __$$< $$$$$$$$ |$$ /  $$ |$$ |  $$ |  $$ |     $$$$$$$ | $$ |    $$ |$$ /  $$ |$$ |  $$ |      $$ |  $$ |  $$ |  
$$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |  $$ |$$\ $$  __$$ | $$ |$$\ $$ |$$ |  $$ |$$ |  $$ |      $$ |  $$ |  $$ |  
$$ |  $$ |\$$$$$$$\ $$$$$$$  |\$$$$$$  |  \$$$$  |\$$$$$$$ | \$$$$  |$$ |\$$$$$$  |$$ |  $$ |      \$$$$$$  |$$$$$$\ 
\__|  \__| \_______|$$  ____/  \______/    \____/  \_______|  \____/ \__| \______/ \__|  \__|       \______/ \______|
                    $$ |                                                                                             
                    $$ |                                                                                             
                    \__|                                                                                             


]]

function Refresh()
	if playerOptions.Enabled then
		ReputationFrame_Refresh()
	end
end

function ReputationFrame_Refresh(self, offset)
	ReputationFrame.paragonFramesPool:ReleaseAll()
	local numFactions = #flatReps

	if ( not FauxScrollFrame_Update(ReputationListScrollFrame, numFactions, NUM_FACTIONS_DISPLAYED, REPUTATIONFRAME_FACTIONHEIGHT ) ) then
		ReputationListScrollFrameScrollBar:SetValue(0)
	end
	local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
	
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		local factionIndex = factionOffset + i
		local factionRow = _G["ReputationBar"..i]
		local factionBar = _G["ReputationBar"..i.."ReputationBar"]
		local factionTitle = _G["ReputationBar"..i.."FactionName"]
		local factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
		local factionStanding = _G["ReputationBar"..i.."ReputationBarFactionStanding"]
		local factionBackground = _G["ReputationBar"..i.."Background"]
		if ( factionIndex <= numFactions ) then
			local factionData = flatReps[factionIndex]
			local name = factionData.name
			local description = factionData.description
			local standingID = factionData.standingID
			local barMin = factionData.bottomValue
			local barMax = factionData.topValue
			local barValue = factionData.earnedValue
			local atWarWith = factionData.atWarWith
			local canToggleAtWar = factionData.canToggleAtWar
			local isHeader = factionData.isHeader
			local isCollapsed = factionData.isCollapsed
			local hasRep = factionData.hasRep
			local isWatched = factionData.isWatched
			local isChild = factionData.isChild
			local isLayoutChild = factionData.isLayoutChild
			local factionID = factionData.factionID
			local hasBonusRepGain = factionData.hasBonusRepGain
			local isFriendship = factionData.isFriendship
			local factionStandingtext = factionData.factionStandingtext
			local colorIndex = factionData.colorIndex
			local friendshipID = factionData.friendshipID
			local playerName = factionData.playerName
			local hasEncountered = factionData.hasEncountered
			local isInactive = factionData.isInactive
			local isFavourite = factionData.isFavourite

			if playerOptions["GroupTotals"] and factionData.exaltedCount then
				name = name .. " (" .. factionData.exaltedCount .. "/" .. factionData.exaltedTotal .. ")"
			end
			factionTitle:SetText(name)
			if ( isCollapsed ) then
				factionButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
			else
				factionButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up") 
			end

			factionRow.factionData = factionData
			factionButton.factionData = factionData
			factionRow.index = factionIndex
			factionRow.barIndex = i

			factionStanding:SetText(factionStandingtext)

			barMax = barMax - barMin
			barValue = barValue - barMin
			barMin = 0

			if standingID == EXALTED_STANDING_ID then
				barMax = 21000
				barValue = 21000
			end
			
			factionRow.standingText = factionStandingtext
			factionRow.rolloverText = playerOptions["ShowNameOnHover"] and playerName or HIGHLIGHT_FONT_COLOR_CODE.." "..barValue.." / "..barMax..FONT_COLOR_CODE_CLOSE
			factionBar:SetMinMaxValues(0, barMax)
			factionBar:SetValue(barValue)
			local color = FACTION_BAR_COLORS[colorIndex]
			factionBar:SetStatusBarColor(color.r, color.g, color.b)

			if playerOptions["ShowParagonBars"] or playerOptions["ShowParagonIcons"] then
				if factionID and C_Reputation.IsFactionParagon(factionID) then
					local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)

					if currentValue then
						if playerOptions["ShowParagonBars"] then
							barMax = threshold
							barMin = 0
							barValue = mod(currentValue, threshold)
							factionBar:SetMinMaxValues(0, threshold)
							factionBar:SetValue(barValue)
							factionBar:SetStatusBarColor(0, 0.5, 0.9)
							factionStanding:SetText("Paragon")
							factionRow.rolloverText = HIGHLIGHT_FONT_COLOR_CODE.." "..barValue.." / "..barMax..FONT_COLOR_CODE_CLOSE
						end

						if playerOptions["ShowParagonIcons"] and (not playerOptions["ParagonIconsRewardOnly"] or (not tooLowLevelForParagon and hasRewardPending)) then
							local paragonFrame = ReputationFrame.paragonFramesPool:Acquire()
							paragonFrame.factionID = factionID
							paragonFrame:SetPoint("RIGHT", factionRow, 11, 0)
							C_Reputation.RequestFactionParagonPreloadRewardData(factionID)
							paragonFrame.Glow:SetShown(not tooLowLevelForParagon and hasRewardPending)
							paragonFrame.Check:SetShown(not tooLowLevelForParagon and hasRewardPending)
							paragonFrame:Show()
						end
					end
				end
			end
			
			factionBar.BonusIcon:SetShown(false)

			ReputationFrame_SetRowType(factionRow, isLayoutChild, isHeader, hasRep)
			
			factionRow:Show()

			if ( atWarWith ) then
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:Show()
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:Show()
			else
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:Hide()
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:Hide()
			end

			if selectedFaction and factionData == selectedFaction then
				ReputationDetailFactionName:SetText(name)
				ReputationDetailFactionDescription:SetText(description)
				if factionData.isGuild then
					PrettyRepsFavouriteFrame:Hide()
				else
					PrettyRepsFavouriteFrame:Show()
					PrettyRepsFavouriteStar:SetChecked(selectedFaction.isFavourite)
				end

				if not hasEncountered then
					ReputationDetailInactiveCheckBox:Hide()
					ReputationDetailMainScreenCheckBox:Hide()
					PrettyRepsEncounterFrame:Show()

					if isInactive then
						PrettyRepInactiveButton:SetChecked(1)
					else
						PrettyRepInactiveButton:SetChecked(nil)
					end
				else
					ReputationDetailInactiveCheckBox:Show()
					ReputationDetailMainScreenCheckBox:Show()
					PrettyRepsEncounterFrame:Hide()

					local _, _, _, _, _, watchedFactionID = GetWatchedFactionInfo()

					if factionID == watchedFactionID then
						ReputationDetailMainScreenCheckBox:SetChecked(true)
					else
						ReputationDetailMainScreenCheckBox:SetChecked(false)
					end

					if ( atWarWith ) then
						ReputationDetailAtWarCheckBox:SetChecked(1)
					else
						ReputationDetailAtWarCheckBox:SetChecked(nil)
					end
					if ( canToggleAtWar and (not isHeader)) then
						ReputationDetailAtWarCheckBox:Enable()
						ReputationDetailAtWarCheckBoxText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
					else
						ReputationDetailAtWarCheckBox:Disable()
						ReputationDetailAtWarCheckBoxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
					end
					if ( not isHeader ) then
						ReputationDetailInactiveCheckBox:Enable()
						ReputationDetailInactiveCheckBoxText:SetTextColor(ReputationDetailInactiveCheckBoxText:GetFontObject():GetTextColor())
					else
						ReputationDetailInactiveCheckBox:Disable()
						ReputationDetailInactiveCheckBoxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
					end
					if ( isInactive ) then
						ReputationDetailInactiveCheckBox:SetChecked(1)
					else
						ReputationDetailInactiveCheckBox:SetChecked(nil)
					end
				end
				_G["ReputationBar"..i.."ReputationBarHighlight1"]:Show()
				_G["ReputationBar"..i.."ReputationBarHighlight2"]:Show()
			else
				_G["ReputationBar"..i.."ReputationBarHighlight1"]:Hide()
				_G["ReputationBar"..i.."ReputationBarHighlight2"]:Hide()
			end
		else
			factionRow:Hide()
		end
	end
end

--[[
		

	 $$$$$$\                      $$\            $$\           $$\   $$\                     $$\                 
	$$  __$$\                     \__|           $$ |          $$ |  $$ |                    $$ |                
	$$ /  \__| $$$$$$$\  $$$$$$\  $$\  $$$$$$\ $$$$$$\         $$ |  $$ | $$$$$$\   $$$$$$\  $$ |  $$\  $$$$$$$\ 
	\$$$$$$\  $$  _____|$$  __$$\ $$ |$$  __$$\\_$$  _|        $$$$$$$$ |$$  __$$\ $$  __$$\ $$ | $$  |$$  _____|
	 \____$$\ $$ /      $$ |  \__|$$ |$$ /  $$ | $$ |          $$  __$$ |$$ /  $$ |$$ /  $$ |$$$$$$  / \$$$$$$\  
	$$\   $$ |$$ |      $$ |      $$ |$$ |  $$ | $$ |$$\       $$ |  $$ |$$ |  $$ |$$ |  $$ |$$  _$$<   \____$$\ 
	\$$$$$$  |\$$$$$$$\ $$ |      $$ |$$$$$$$  | \$$$$  |      $$ |  $$ |\$$$$$$  |\$$$$$$  |$$ | \$$\ $$$$$$$  |
	 \______/  \_______|\__|      \__|$$  ____/   \____/       \__|  \__| \______/  \______/ \__|  \__|\_______/ 
	                                  $$ |                                                                       
	                                  $$ |                                                                       
	                                  \__|                                                                       


]]

function HookScripts()
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		local factionRow = _G["ReputationBar"..i]
		local factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]

		HookScript(factionButton, "OnClick", FactionButton_Click)
		HookScript(factionRow, "OnLeave", FactionRow_Leave)
		HookScript(factionRow, "OnClick", FactionRow_Click)
		HookScript(factionRow, "OnEnter", FactionRow_Enter)
	end

	HookScript(ReputationDetailInactiveCheckBox, "OnClick", InactiveCheckbox_Click)
	HookScript(ReputationListScrollFrame, "OnVerticalScroll", ReputationListScrollFrame_VerticalScroll)
	HookScript(ReputationDetailMainScreenCheckBox, "OnClick", ReputationDetailMainScreenCheckBox_Click)
	HookScript(ReputationDetailAtWarCheckBox, "OnClick", ReputationDetailAtWarCheckBox_Click)
end

ReputationFrame_UpdateOrig = ReputationFrame_Update
ReputationFrame_Update = function() if not playerOptions.Enabled then ReputationFrame_UpdateOrig() end end

function ReputationListScrollFrame_VerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, REPUTATIONFRAME_FACTIONHEIGHT, ReputationFrame_Refresh)
end

function FactionButton_Click(self)
	self.factionData.isCollapsed = not self.factionData.isCollapsed

	if fakeHeadersCollapsedStatus[self.factionData.name] ~= nil then
		fakeHeadersCollapsedStatus[self.factionData.name] = self.factionData.isCollapsed
	end

	FlattenStructure()
	Refresh()
end

function FactionRow_Enter(self)
	if (self.rolloverText) then
		_G[self:GetName().."ReputationBarFactionStanding"]:SetText(self.rolloverText)
	end
	_G[self:GetName().."ReputationBarHighlight1"]:Show()
	_G[self:GetName().."ReputationBarHighlight2"]:Show()
	if ( self.factionData.friendshipID ) then
		-- ShowFriendshipReputationTooltip(self.factionData.friendshipID, self, "ANCHOR_BOTTOMRIGHT")
	elseif (_G[self:GetName().."FactionName"]:IsTruncated()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(_G[self:GetName().."FactionName"]:GetText(), nil, nil, nil, nil, true)
		GameTooltip:Show()
	end
end

function FactionRow_Leave(self)
	if self.factionData ~= selectedFaction then
		_G["ReputationBar"..self.barIndex.."ReputationBarHighlight1"]:Hide()
		_G["ReputationBar"..self.barIndex.."ReputationBarHighlight2"]:Hide()
	end
	GameTooltip:Hide()
	Refresh()
end

function FactionRow_Click(self)
	if ReputationDetailFrame:IsShown() and self.factionData == selectedFaction then
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
		ReputationDetailFrame:Hide()
		selectedFaction = nil
	else
		if (self.hasRep) then
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
			selectedFaction = self.factionData
			ReputationDetailFrame:Show()
			Refresh()
		end
	end
end

function FactionRowLFGButton_Click(self)
	self.factionData.isFavourite = false
	FlattenStructure()
	Refresh()
end

function FactionRowLFGButton_Enter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Remove from favourites", nil, nil, nil, nil, true)
	GameTooltip:Show()
end

function InactiveCheckbox_Click(self)
	if self:GetChecked() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		-- SetFactionInactive(selectedFaction.internalIndex)
		selectedFaction.isInactive = true
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		-- SetFactionActive(selectedFaction.internalIndex)
		selectedFaction.isInactive = nil
	end
	FlattenStructure()
	Refresh()
end

function ReputationDetailMainScreenCheckBox_Click(self)
	if self:GetChecked() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		SetWatchedFactionIndex(selectedFaction.internalIndex)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		SetWatchedFactionIndex(0)
	end
	ReloadCharacterData(true)
	Refresh()
end

function ReputationDetailAtWarCheckBox_Click(self)
	FactionToggleAtWar(selectedFaction.internalIndex)
	if self:GetChecked() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
	ReloadCharacterData(true)
	Refresh()
end

--[[
	

	$$$$$$$\             $$\                     $$\      $$\                                                                                      $$\     
	$$  __$$\            $$ |                    $$$\    $$$ |                                                                                     $$ |    
	$$ |  $$ | $$$$$$\ $$$$$$\    $$$$$$\        $$$$\  $$$$ | $$$$$$\  $$$$$$$\   $$$$$$\   $$$$$$\   $$$$$$\  $$$$$$\$$$$\   $$$$$$\  $$$$$$$\ $$$$$$\   
	$$ |  $$ | \____$$\\_$$  _|   \____$$\       $$\$$\$$ $$ | \____$$\ $$  __$$\  \____$$\ $$  __$$\ $$  __$$\ $$  _$$  _$$\ $$  __$$\ $$  __$$\\_$$  _|  
	$$ |  $$ | $$$$$$$ | $$ |     $$$$$$$ |      $$ \$$$  $$ | $$$$$$$ |$$ |  $$ | $$$$$$$ |$$ /  $$ |$$$$$$$$ |$$ / $$ / $$ |$$$$$$$$ |$$ |  $$ | $$ |    
	$$ |  $$ |$$  __$$ | $$ |$$\ $$  __$$ |      $$ |\$  /$$ |$$  __$$ |$$ |  $$ |$$  __$$ |$$ |  $$ |$$   ____|$$ | $$ | $$ |$$   ____|$$ |  $$ | $$ |$$\ 
	$$$$$$$  |\$$$$$$$ | \$$$$  |\$$$$$$$ |      $$ | \_/ $$ |\$$$$$$$ |$$ |  $$ |\$$$$$$$ |\$$$$$$$ |\$$$$$$$\ $$ | $$ | $$ |\$$$$$$$\ $$ |  $$ | \$$$$  |
	\_______/  \_______|  \____/  \_______|      \__|     \__| \_______|\__|  \__| \_______| \____$$ | \_______|\__| \__| \__| \_______|\__|  \__|  \____/ 
	                                                                                        $$\   $$ |                                                     
	                                                                                        \$$$$$$  |                                                     
	                                                                                         \______/                                                      


]]

function ExtractRepData(repStructure, factionID)
	local function Get(parent)
		if parent.factionID == factionID then
			return parent
		elseif parent.children then
			for _, child in ipairs(parent.children) do
				local result = Get(child)
				if result then
					return result
				end
			end
		end
	end

	for _, expansion in ipairs(repStructure) do
		local result = Get(expansion)
		if result then
			return result
		end
	end
end

function MergeRepData(characterStructuredData)
	local function Merge(characterFaction)
		local dbFaction = ExtractRepData(PrettyRepsDB.Structure, characterFaction.factionID)
		if dbFaction then
			if characterFaction.children then
				for i, child in ipairs(characterFaction.children) do
					Merge(child)
				end
			end
			if dbFaction.isActive then
				if dbFaction.earnedValue and (not characterFaction.earnedValue or dbFaction.earnedValue > characterFaction.earnedValue) then
					CopyData(dbFaction, characterFaction)
				end
			end
			characterFaction.isInactive = dbFaction.isInactive
			characterFaction.isCollapsed = dbFaction.isCollapsed
			characterFaction.isFavourite = dbFaction.isFavourite
		end
	end

	for i, characterExpansion in ipairs(characterStructuredData) do
		Merge(characterExpansion)
	end
end

function ReloadCharacterData(saveFirst)
	if (saveFirst) then
		Save()
	end

	characterRepStructure = CopyTable(_G.PrettyReps.Structure)
	local guildName = GetGuildInfo("player")

	for i = 1, 230, 1 do
		local name, description, standingID, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain = GetFactionInfo(i)
		if standingID then

			local rep

			if guildName ~= nil and name == guildName then
				rep = guildRep
				rep.isGuild = true
			else
				rep = ExtractRepData(characterRepStructure, factionID)
			end

			if rep then
				rep.internalIndex = i
				rep.isActive = true
				rep.hasEncountered = true
				rep.playerName = playerName
				rep.playerRealm = playerRealm
				rep.name = name
				rep.description = description
				rep.standingID = standingID
				rep.bottomValue = bottomValue
				rep.topValue = topValue
				rep.earnedValue = earnedValue
				rep.atWarWith = atWarWith
				rep.canToggleAtWar = canToggleAtWar
				rep.hasRep = hasRep
				rep.isWatched = isWatched
				rep.factionID = factionID
				rep.hasBonusRepGain = false
				rep.isMaxed = standingID == EXALTED_STANDING_ID

				-- Friendship
				local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
				if (friendID ~= nil) then
					rep.isFriendship = true
					rep.friendshipID = friendID
					if nextFriendThreshold then
						rep.bottomValue, rep.topValue, rep.earnedValue = friendThreshold, nextFriendThreshold, friendRep
						rep.isMaxed = false
					else
						rep.bottomValue, rep.topValue, rep.earnedValue = 0, 42999, 42999
						rep.isMaxed = true
					end
				end

				if rep.isFriendship then
					rep.factionStandingtext = friendTextLevel
					rep.colorIndex = BEST_FRIEND_STANDING_ID
				else
					rep.factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender)
					rep.colorIndex = standingID
				end
			end
		end
	end

	MergeRepData(characterRepStructure)
	FlattenStructure()
end

function FlattenStructure()
	local reps = {}
	local inactives = {}
	local unobtainable = {}
	local favourites = {}
	local function Flatten(parent, child)
		if child.isActive then
			child.isHeader = child.children and true or false
			child.parent = parent
			child.isChild = child ~= parent and true or false
			child.isExpansion = child == parent and true or false
			child.isLayoutChild = (not parent.isExpansion or (child.isHeader and child.isChild)) and true or false

			if child.isFavourite then
				child.isLayoutChild = false
				table.insert(favourites, child)
			elseif child.isInactive then
				child.isLayoutChild = false
				table.insert(inactives, child)
			elseif playerOptions["UseUnobtainableGroup"] and child.isUnobtainable and child.standingID < EXALTED_STANDING_ID then
				table.insert(unobtainable, child)
			elseif not playerOptions["HideOppositeFaction"] or IsSameFaction(child) then

				if child.isHeader then
					child.exaltedCount, child.exaltedTotal = 0, 0
				end

				if child.isChild and parent.exaltedCount and not child.isHeader then
					parent.exaltedTotal = parent.exaltedTotal + 1
					parent.exaltedCount = child.isMaxed and parent.exaltedCount + 1 or parent.exaltedCount
				end

				local insertIndex
				if (not parent.isCollapsed and (not parent.parent or not parent.parent.isCollapsed)) or child.isExpansion then
					table.insert(reps, child)
					insertIndex = #reps
				end
				if child.isHeader then
					for _, _child in ipairs(child.children) do
						Flatten(child, _child)
					end
				end

				if child.isChild and child.exaltedCount and parent.exaltedCount then
					parent.exaltedTotal = parent.exaltedTotal + child.exaltedTotal
					parent.exaltedCount = parent.exaltedCount + child.exaltedCount
				end

				if child.exaltedTotal == 0 then
					table.remove(reps, insertIndex)
				end
			end
		end
	end

	-- Guild
	if guildRep.factionID and playerOptions["ShowGuild"] then
		local guildHeader = CreateFakeHeader("Guild")
		guildHeader.exaltedTotal, guildHeader.exaltedCount = 1, guildRep.standingID == EXALTED_STANDING_ID and 1 or 0
		table.insert(reps, guildHeader)
		if not guildHeader.isCollapsed then
			guildRep.parent = guildHeader
			table.insert(reps, guildRep)
		end
	end

	-- All Reps
	for _, expansion in ipairs(characterRepStructure) do
		Flatten(expansion, expansion)
	end

	-- Favourites
	if #favourites > 0 then
		local favouritesHeader = CreateFakeHeader("Favourites")
		table.insert(reps, 1, favouritesHeader)
		if not favouritesHeader.isCollapsed then
			for i = 1, #favourites do
				local fav = favourites[i]
				fav.parent = favouritesHeader
				table.insert(reps, i + 1, fav)
			end
		end
	end

	-- Unobtainable
	if not playerOptions["HideUnobtainableGroup"] and #unobtainable > 0 then
		local unobtainableHeader = CreateFakeHeader("Unobtainable")
		table.insert(reps, unobtainableHeader)
		if not unobtainableHeader.isCollapsed then
			for _, unobtainableRep in ipairs(unobtainable) do
				unobtainableRep.parent = unobtainableHeader
				table.insert(reps, unobtainableRep)
			end
		end
	end

	-- Inactive
	if not playerOptions["HideInactiveGroup"] and #inactives > 0 then
		local inactiveHeader = CreateFakeHeader("Inactive")
		table.insert(reps, inactiveHeader)
		if not inactiveHeader.isCollapsed then
			for _, inactiveRep in ipairs(inactives) do
				inactiveRep.parent = inactiveHeader
				table.insert(reps, inactiveRep)
			end
		end
	end

	flatReps = reps
end

local lastFakeId = 0
local fakes = {}
function CreateFakeHeader(name)
	if fakes[name] then
		fakes[name].isCollapsed = fakeHeadersCollapsedStatus[name]
		return fakes[name]
	end

	local fakeHeader = CopyData(ExtractRepData(characterRepStructure, 1118), {})
	fakeHeader.isCollapsed = fakeHeadersCollapsedStatus[name] and true or false
	fakeHeader.name = name
	fakeHeader.isHeader = true
	lastFakeId = lastFakeId - 1
	fakeHeader.factionID = lastFakeId
	fakeHeader.exaltedTotal, fakeHeader.exaltedCount = nil, nil
	fakeHeadersCollapsedStatus[name] = fakeHeader.isCollapsed and true or false
	fakes[name] = fakeHeader
	return fakeHeader
end

function ExpandAll(expand)
	local function Expand(parent)
		if parent.isHeader then
			parent.isCollapsed = not expand
		end

		if parent.children then
			for _, child in ipairs(parent.children) do
				Expand(child)
			end
		end
	end

	for _, expansion in ipairs(characterRepStructure) do
		expansion.isCollapsed = not expand
		Expand(expansion)
	end

	for _, fakeHeader in pairs(fakes) do
		fakeHeadersCollapsedStatus[fakeHeader.name] = not expand
	end
end

function IsSameFaction(factionData)
	if not factionData.isHorde and not factionData.isAlliance then
		return true
	elseif factionData.isHorde and isHorde then
		return true
	elseif factionData.isAlliance and isAlliance then
		return true
	end
end

function CopyData(from, to)
	local dontOverwrite = {["internalIndex"] = true, ["hasEncountered"] = true, ["canToggleAtWar"] = true, }

	for key, value in pairs(from) do
		if type(value) ~= "table" and type(value) ~= "userdata" and not dontOverwrite[key] then
			to[key] = value
		end
	end
	return to
end

--[[


	$$$$$$\            $$\                          $$$$$$\                               
	\_$$  _|           $$ |                        $$  __$$\                              
	  $$ |  $$$$$$$\ $$$$$$\    $$$$$$\   $$$$$$\  $$ /  \__|$$$$$$\   $$$$$$$\  $$$$$$\  
	  $$ |  $$  __$$\\_$$  _|  $$  __$$\ $$  __$$\ $$$$\     \____$$\ $$  _____|$$  __$$\ 
	  $$ |  $$ |  $$ | $$ |    $$$$$$$$ |$$ |  \__|$$  _|    $$$$$$$ |$$ /      $$$$$$$$ |
	  $$ |  $$ |  $$ | $$ |$$\ $$   ____|$$ |      $$ |     $$  __$$ |$$ |      $$   ____|
	$$$$$$\ $$ |  $$ | \$$$$  |\$$$$$$$\ $$ |      $$ |     \$$$$$$$ |\$$$$$$$\ \$$$$$$$\ 
	\______|\__|  \__|  \____/  \_______|\__|      \__|      \_______| \_______| \_______|
                                    
                  
]]

function ModifyRepPanel()
	-- Reputation Detail Frame
	do
		if not PrettyRepsEncounterFrame then
			CreateFrame("FRAME", "PrettyRepsEncounterFrame", ReputationDetailFrame)
			PrettyRepsEncounterFrame:CreateFontString("PrettyRepsEncounterText", "OVERLAY", "GameFontNormalSmall")

			PrettyRepsEncounterFrame:SetPoint("BOTTOMLEFT", ReputationDetailFrame, "BOTTOMLEFT", 12, 10)
			PrettyRepsEncounterFrame:SetSize(188, 50)
			PrettyRepsEncounterFrame:Hide()

			PrettyRepsEncounterText:SetPoint("CENTER", PrettyRepsEncounterFrame, "CENTER", 0, -10)
			PrettyRepsEncounterText:SetText("This character has not yet\nencountered this faction.")

			local checkbox = CreateFrame("CheckButton", "PrettyRepInactiveButton", PrettyRepsEncounterFrame, "OptionsSmallCheckButtonTemplate")
			checkbox:SetSize(26, 26)
			checkbox:SetPoint("TOPLEFT", ReputationDetailFrame, "TOPLEFT", 14, -143)
			PrettyRepInactiveButtonText:SetText("Move to Inactive")
			PrettyRepInactiveButton:SetScript("OnClick", InactiveCheckbox_Click)

			AddDisabledHook(function()
				ReputationDetailAtWarCheckBox:Show()
				ReputationDetailInactiveCheckBox:Show()
				ReputationDetailMainScreenCheckBox:Show()
				PrettyRepsEncounterFrame:Hide()
				ReputationDetailInactiveCheckBox:SetPoint("TOPLEFT", ReputationDetailFrame, "TOPLEFT", 80, -143)
			end)
		end
	end

	ReputationDetailAtWarCheckBox:Hide()
	ReputationDetailInactiveCheckBox:SetPoint("TOPLEFT", ReputationDetailFrame, "TOPLEFT", 14, -143)

	-- Favourites Star
	do
		if not PrettyRepsFavouriteFrame then
			CreateFrame("FRAME", "PrettyRepsFavouriteFrame", ReputationDetailFrame)
			PrettyRepsFavouriteFrame:SetSize(7, 7)
			PrettyRepsFavouriteFrame:SetPoint("BOTTOMRIGHT", ReputationDetailFrame, "BOTTOMRIGHT", -25, 45)

			local checkbox = CreateFrame("CheckButton", "PrettyRepsFavouriteStar", PrettyRepsFavouriteFrame, "ChatConfigCheckButtonTemplate")
			checkbox:SetNormalTexture("Interface/Common/ReputationStar")
			checkbox:SetCheckedTexture("Interface/Common/ReputationStar")
			checkbox:SetHighlightTexture("Interface/Common/ReputationStar")
			checkbox:SetPushedTexture("Interface/Common/ReputationStar")
			checkbox:SetSize(20, 20)
			-- checkbox:GetNormalTexture():SetTexCoord(0.5, 1, 0, 0.5)
			checkbox:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
			checkbox:GetHighlightTexture():SetTexCoord(0, 0.5, 0.5, 1)
			checkbox:GetCheckedTexture():SetTexCoord(0, 0.5, 0, 0.5)
			checkbox:GetPushedTexture():SetTexCoord(0, 0.5, 0, 0.5)
			checkbox:SetPoint("CENTER", PrettyRepsFavouriteFrame)
			checkbox.tooltip = "Mark as favourite"
			checkbox:SetScript("OnClick", function(self)
				selectedFaction.isFavourite = self:GetChecked()
				FlattenStructure()
				Refresh()
			end)

			AddDisabledHook(function()
				PrettyRepsFavouriteFrame:Hide()
			end)
		end

		PrettyRepsFavouriteFrame:Show()
	end

	-- Tab Frame
	do
		if not PrettyRepsTabFrame then
			CreateFrame("FRAME", "PrettyRepsTabFrame", ReputationFrame)
			PrettyRepsTabFrame:CreateFontString("PrettyRepsExaltedText", "ARTWORK", "GameFontHighlight")
			PrettyRepsTabFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPLEFT", 0, -20)
			PrettyRepsTabFrame:SetSize(335, 50)
			PrettyRepsExaltedText:SetPoint("CENTER", PrettyRepsTabFrame, "CENTER", 0, 0)
			ReputationFrameStandingLabel:Hide()
			ReputationFrameFactionLabel:Hide()
		end	
	end

	if not PrettyRepsOptionsButton then
		CreateFrame("Button", "PrettyRepsOptionsButton", ReputationFrame)
		PrettyRepsOptionsButton:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -4, -30)
		PrettyRepsOptionsButton:SetSize(30, 30)
		PrettyRepsOptionsButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Up")
		PrettyRepsOptionsButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Down")
		PrettyRepsOptionsButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Disabled")
		PrettyRepsOptionsButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
		PrettyRepsOptionsButton:SetScript("OnClick", function()
			ReputationDetailFrame:Hide()
			PrettyRepsOptionsFrame:Show()
			PrettyRepsOptionsButton:Hide()
			PrettyRepsOptionsHideButton:Show()
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
		end)

		CreateFrame("Button", "PrettyRepsOptionsHideButton", ReputationFrame)
		PrettyRepsOptionsHideButton:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -4, -30)
		PrettyRepsOptionsHideButton:SetSize(30, 30)
		PrettyRepsOptionsHideButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Up")
		PrettyRepsOptionsHideButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Down")
		PrettyRepsOptionsHideButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Disabled")
		PrettyRepsOptionsHideButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
		PrettyRepsOptionsHideButton:Hide()
		PrettyRepsOptionsHideButton:SetScript("OnClick", function()
			PrettyRepsOptionsFrame:Hide()
			PrettyRepsOptionsButton:Show()
			PrettyRepsOptionsHideButton:Hide()
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
		end)
	end

	if not PrettyRepsOptionsFrame then
		local frameWidth, frameHeight = 250, 390
		CreateFrame("FRAME", "PrettyRepsOptionsFrame", ReputationFrame, "UIPanelDialogTemplate")
		PrettyRepsOptionsFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", -15, -30)
		PrettyRepsOptionsFrame:SetSize(frameWidth, frameHeight)
		PrettyRepsOptionsFrame:SetFrameStrata("LOW")
		PrettyRepsOptionsFrame:Hide()

		-- Close Button
		PrettyRepsOptionsFrameClose:SetScript("OnClick", function()
			PrettyRepsOptionsFrame:Hide()
			PrettyRepsOptionsButton:Show()
			PrettyRepsOptionsHideButton:Hide()
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
		end)

		-- Title
		local title = PrettyRepsOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightCenter")
		title:SetPoint("CENTER", PrettyRepsOptionsFrame, "TOP", 0, -16)
		title:SetText("Pretty Reps")

		local yPos = -10
		local itemSpacing = 30

		-- Options Title
		yPos = yPos - itemSpacing
		local optionsTitle = PrettyRepsOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalCenter")
		optionsTitle:SetPoint("CENTER", PrettyRepsOptionsFrame, "TOP", -15, -50)
		optionsTitle:SetText("Configure Pretty Reps Tab")

		-- Options Help
		local helpButton = CreateFrame("Button", nil, PrettyRepsOptionsFrame, "UIPanelInfoButton")
		helpButton:SetPoint("TOPRIGHT", PrettyRepsOptionsFrame, -12, -35)
		local helpTooltip = "Pretty Reps can only include factions that have been encountered by at least one character.\n\n"
		helpTooltip = helpTooltip .. "The " .. playerName .. " tab shows the default WoW reputation UI for this character."
		helpButton:SetScript("OnEnter", function() GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT") GameTooltip:SetText(helpTooltip) end)
		helpButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

		yPos = yPos - itemSpacing
		-- Header Totals
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, yPos)
		checkbox.Text:SetText("Display Group Totals")
		checkbox.optionsName = "GroupTotals"
		checkbox:SetChecked(GetOption(checkbox.optionsName, true))
		checkbox.tooltip = "Display completed reputations in group titles (Completed/Total).\n\n"
		checkbox.tooltip = checkbox.tooltip  .. "Exalted and Best Friend reputations are considered completed."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked() 
			Refresh()
		end)

		yPos = yPos - itemSpacing
		-- Enable Unobtainable
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, yPos)
		checkbox.optionsName = "UseUnobtainableGroup"
		checkbox:SetChecked(GetOption(checkbox.optionsName, true))
		checkbox.Text:SetText("Use Unobtainable Group")
		checkbox.tooltip = "Reputations that can no longer be earned will be placed here unless you already have exalted."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			FlattenStructure()
			Refresh()
		end)

		yPos = yPos - itemSpacing * 0.7
		-- Hide Unobtainable
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetSize(20, 20)
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 60, yPos)
		checkbox.optionsName = "HideUnobtainableGroup"
		checkbox:SetChecked(GetOption(checkbox.optionsName, false))
		checkbox.Text:SetText("Hide")
		checkbox.tooltip = "Hide the unobtainable group and all reputations inside it."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			FlattenStructure()
			Refresh()
		end)

		yPos = yPos - itemSpacing * 0.7
		-- Hide Inactive
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, yPos)
		checkbox.optionsName = "HideInactiveGroup"
		checkbox:SetChecked(GetOption(checkbox.optionsName, false))
		checkbox.Text:SetText("Hide Inactive Group")
		checkbox.tooltip = "Hide the inactive group and all reputations inside it."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			FlattenStructure()
			Refresh()
		end)

		yPos = yPos - itemSpacing
		-- Show Name On Hover
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, yPos)
		checkbox.optionsName = "ShowNameOnHover"
		checkbox:SetChecked(GetOption(checkbox.optionsName, false))
		checkbox.Text:SetText("Show Name On Hover")
		checkbox.tooltip = "Show the name of the character that earned the reputation."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			Refresh()
		end)

		yPos = yPos - itemSpacing
		-- Show Opposite Faction
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, yPos)
		checkbox.optionsName = "HideOppositeFaction"
		checkbox:SetChecked(GetOption(checkbox.optionsName, true))
		checkbox.Text:SetText("Hide Opposite Faction")
		checkbox.tooltip = "Only show reputations for your current faction (Alliance/Horde)."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			FlattenStructure()
			Refresh()
		end)

		yPos = yPos - itemSpacing
		-- Show Guild
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, yPos)
		checkbox.optionsName = "ShowGuild"
		checkbox:SetChecked(GetOption(checkbox.optionsName, true))
		checkbox.Text:SetText("Show Guild Reputation")
		checkbox.tooltip = "Display guild reputation for the current character."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			FlattenStructure()
			Refresh()
		end)

		yPos = yPos - itemSpacing
		-- Paragon Bars
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, yPos)
		checkbox.optionsName = "ShowParagonBars"
		checkbox:SetChecked(GetOption(checkbox.optionsName, true))
		checkbox.Text:SetText("Show Paragon Bars")
		checkbox.tooltip = "Replace green exalted bars with paragon reputation bars for this character."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			FlattenStructure()
			Refresh()
		end)

		yPos = yPos - itemSpacing
		-- Paragon
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, yPos)
		checkbox.optionsName = "ShowParagonIcons"
		checkbox:SetChecked(GetOption(checkbox.optionsName, true))
		checkbox.Text:SetText("Show Paragon Reward Icons")
		checkbox.tooltip = "Display paragon reward icons next to reputation bars."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			FlattenStructure()
			Refresh()
		end)

		yPos = yPos - itemSpacing * 0.7
		-- Paragon Bars
		checkbox = CreateFrame("CheckButton", nil, PrettyRepsOptionsFrame, "ChatConfigCheckButtonTemplate")
		checkbox:SetSize(20, 20)
		checkbox:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 60, yPos)
		checkbox.optionsName = "ParagonIconsRewardOnly"
		checkbox:SetChecked(GetOption(checkbox.optionsName, true))
		checkbox.Text:SetText("Only When Available")
		checkbox.tooltip = "Only show paragon reward icons when a reward is available."
		playerOptions[checkbox.optionsName] = checkbox:GetChecked() 
		checkbox:SetScript("OnClick", function(self) 
			playerOptions[self.optionsName] = self:GetChecked()
			FlattenStructure()
			Refresh()
		end)

		local order = {2, 2, 2, 1, 2, 1, 1}
		local orderIndex = 0

		local function inc(val)
			orderIndex = orderIndex + 1
			if order[orderIndex] ~= val then
				orderIndex = 0
			elseif orderIndex == #order then
				PrettyRepsOptionsFrame:SetSize(frameWidth, frameHeight + 20)
				orderIndex = 0
				local title = PrettyRepsOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				title:SetPoint("BOTTOM", PrettyRepsOptionsFrame, "BOTTOM", 0, 15)
				title:SetText("Created with love for\nDayanne-RavencrestEU <3")
			end
		end

		-- Expand All Button
		local button = CreateFrame("Button", nil, PrettyRepsOptionsFrame, "UIPanelButtonTemplate")
		button:SetSize(100, 20)
		button:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 30, -350)
		button:SetText("Expand All")
		button:SetScript("OnClick", function()
			inc(1)
			ExpandAll(true)
			FlattenStructure()
			Refresh()
		end)

		-- Collapse All Button
		button = CreateFrame("Button", nil, PrettyRepsOptionsFrame, "UIPanelButtonTemplate")
		button:SetSize(100, 20)
		button:SetPoint("TOPLEFT", PrettyRepsOptionsFrame, 130, -350)
		button:SetText("Collapse All")
		button:SetScript("OnClick", function()
			inc(2)
			ExpandAll(false)
			FlattenStructure()
			Refresh()
		end)

		local function SetButtonTextures(button, enabled)
			if enabled then
				button:SetNormalTexture("Interface/PaperDollInfoFrame/UI-Character-ActiveTab")
				button:SetPushedTexture("Interface/PaperDollInfoFrame/UI-Character-ActiveTab")
				button:SetHighlightTexture("Interface/PaperDollInfoFrame/UI-Character-ActiveTab")
			else
				button:SetNormalTexture("Interface/PaperDollInfoFrame/UI-Character-InActiveTab")
				button:SetPushedTexture("Interface/PaperDollInfoFrame/UI-Character-InActiveTab")
				button:SetHighlightTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-RealHighlight")
				button:GetHighlightTexture():SetPoint("BOTTOM", -10, -4)
			end
			SetClampedTextureRotation(button:GetNormalTexture(), 180)
			SetClampedTextureRotation(button:GetPushedTexture(), 180)
			SetClampedTextureRotation(button:GetHighlightTexture(), 180)
		end

		-- Account Active
		accountActiveButton = CreateFrame("Button", nil, PrettyRepsTabFrame)
		accountActiveButton:SetSize(120, 50)
		accountActiveButton:SetPoint("CENTER", PrettyRepsTabFrame, -55, 7)
		accountActiveButton:SetText("Expand All")
		SetButtonTextures(accountActiveButton, true)
		local txt = accountActiveButton:CreateFontString(nil, "HIGH", "GameFontNormalSmall")
		txt:SetPoint("CENTER", accountActiveButton, "CENTER", 0, -12)
		txt:SetText("Pretty Reps")


		-- Account Inactive
		accountInactiveButton = CreateFrame("Button", nil, PrettyRepsTabFrame)
		accountInactiveButton:SetSize(120, 26)
		accountInactiveButton:SetPoint("CENTER", PrettyRepsTabFrame, -55, -3)
		accountInactiveButton:SetText("Expand All")
		accountInactiveButton:SetScript("OnClick", function(self)
			Save()
			playerOptions["Enabled"] = true
			TogglePREnabled(true)
			ReputationDetailFrame:Hide()
			accountActiveButton:Show()
			accountInactiveButton:Hide()
			characterActiveButton:Hide()
			characterInactiveButton:Show()
		end)
		SetButtonTextures(accountInactiveButton, false)
		local txt = accountInactiveButton:CreateFontString(nil, "HIGH", "GameFontNormalSmall")
		txt:SetPoint("CENTER", accountInactiveButton, "CENTER", 0, -4)
		txt:SetText("Pretty Reps")
		accountInactiveButton:Hide()

		-- Character Active
		characterActiveButton = CreateFrame("Button", nil, PrettyRepsTabFrame)
		characterActiveButton:SetSize(120, 50)
		characterActiveButton:SetPoint("CENTER", PrettyRepsTabFrame, 55, 7)
		characterActiveButton:SetText("Expand All")
		SetButtonTextures(characterActiveButton, true)
		local txt = characterActiveButton:CreateFontString(nil, "HIGH", "GameFontNormalSmall")
		txt:SetPoint("CENTER", characterActiveButton, "CENTER", 0, -12)
		txt:SetText(playerName)
		characterActiveButton:Hide()


		-- Character Inactive
		characterInactiveButton = CreateFrame("Button", nil, PrettyRepsTabFrame)
		characterInactiveButton:SetSize(120, 26)
		characterInactiveButton:SetPoint("CENTER", PrettyRepsTabFrame, 55, -3)
		characterInactiveButton:SetText("Expand All")
		characterInactiveButton:SetScript("OnClick", function(self)
			Save()
			playerOptions["Enabled"] = false
			TogglePREnabled(false)
			ReputationDetailFrame:Hide()
			characterActiveButton:Show()
			characterInactiveButton:Hide()
			accountActiveButton:Hide()
			accountInactiveButton:Show()
		end)
		SetButtonTextures(characterInactiveButton, false)
		local txt = characterInactiveButton:CreateFontString(nil, "HIGH", "GameFontNormalSmall")
		txt:SetPoint("CENTER", characterInactiveButton, "CENTER", 0, -4)
		txt:SetText(playerName)
	end
end