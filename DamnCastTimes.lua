local DCT = {}
local spellFormat = "%.1f"
local channelDelay = "|cffff2020%-.2f|r"
local castDelay = "|cffff2020%+.2f|r"

function DCT:Enable()
	local path = GameFontHighlight:GetFont()

	self.castTimeText = CastingBarFrame:CreateFontString(nil, "ARTWORK")
	self.castTimeText:SetPoint("TOPRIGHT", CastingBarFrame, "TOPRIGHT", 0, 19)
	self.castTimeText:SetFont(path, 11, "OUTLINE")
	
	local onHide = CastingBarFrame:GetScript("OnHide")
	CastingBarFrame:SetScript("OnHide", function(...)
		if( onHide ) then
			onHide(...)
		end
		
		CastingBarFrame.spellPushback = nil
	end)
end

local orig_CastingBarFrame_OnUpdate = CastingBarFrame_OnUpdate
function CastingBarFrame_OnUpdate(...)
	orig_CastingBarFrame_OnUpdate(...)
	
	if( CastingBarFrame.unit ~= "player" ) then
		return
	end
	
	if( this.casting ) then
		if( not this.spellPushback ) then
			DCT.castTimeText:SetText(format(spellFormat, CastingBarFrame.maxValue - GetTime()))
		else
			DCT.castTimeText:SetText(format(castDelay .. " " .. spellFormat, this.spellPushback, CastingBarFrame.maxValue - GetTime()))
		end
		
		DCT.castTimeText:Show()
	elseif( this.channeling ) then
		if( not this.spellPushback ) then
			DCT.castTimeText:SetText(format(channelFormat, CastingBarFrame.endTime - GetTime()))
		else
			DCT.castTimeText:SetText(format(channelDelay .. " " .. spellFormat, this.spellPushback, CastingBarFrame.endTime - GetTime()))
		end
		DCT.castTimeText:Show()
	else
		DCT.castTimeText:Hide()
	end
end

local orig_CastingBarFrame_OnEvent = CastingBarFrame_OnEvent
function CastingBarFrame_OnEvent(event, unit, ...)
	if( event == "UNIT_SPELLCAST_DELAYED" and unit == "player" ) then
		local name, _, _, _, startTime, endTime = UnitCastingInfo(CastingBarFrame.unit);
		if( not name ) then
			return
		end
		
		this.spellPushback = CastingBarFrame.maxValue - ( endTime / 1000 )
	end

	orig_CastingBarFrame_OnEvent(event, unit, ...)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
	if( addon == "DamnCastTimes" ) then
		DCT.Enable(DCT)
	end
end)