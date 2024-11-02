local Currency = {}

local frame=CreateFrame("frame",nil,Playerframe)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent",function()
	if event == "PLAYER_ENTERING_WORLD" then
		Currency:Initialize()
	end
end)

Currency.frame=frame

function Currency:Initialize()
	if not miniMap then
		miniMap = {
			dragable = true,
			angle = 300,
			radius = 80,
			rounding = 10,
			Hidden = false
		}
	end
	-- MinimapFrame
	local f = CreateFrame("Frame", "Currency".."Minimap", Minimap)
	f:SetFrameStrata("LOW")
	f:SetWidth(33)
	f:SetHeight(33)
	f:SetPoint("CENTER")
	f:EnableMouse(true)
	f:Show()
	self.Minimap = f
	
	-- Minimap
	local b = CreateFrame("Button", nil, f)
	b:SetAllPoints(f)
	b:SetHighlightTexture("Interface\\Minimap\\UI-MoneyButton-Hilight")
	
	-- MinimapIcon
	local t = b:CreateTexture(nil, "BACKGROUND")
	t:SetWidth(20)
	t:SetHeight(20)
	t:SetPoint("CENTER")
	MinimapIconTexture = t
	t:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
	
	-- MinimapBorder
	t = b:CreateTexture(nil, "OVERLAY")
	t:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	t:SetWidth(52)
	t:SetHeight(52)
	t:SetPoint("TOPLEFT")
	
	-- set some scripts
	b:SetScript("OnDragStart", function()
			if(miniMap.dragable) then
				this.dragme = true
				this:LockHighlight()
			end
		end)

	b:SetScript("OnDragStop", function()
			this.dragme = false
			this:UnlockHighlight()
		end)
	b:SetScript("OnUpdate", function()
			if(this.dragme == true) then
				Currency:MinimapBeingDragged()
			end
		end)
	b:SetScript("OnEnter", function()
		
		local currencystring=""
		local cu = GetMoney();
		currencystring=GetCoinTextureString(cu,"12")
		GameTooltip:SetOwner(this, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPRIGHT", this, "BOTTOM")
		GameTooltip:SetText("Currency")
		GameTooltip:AddLine(currencystring,250,125,50)
		GameTooltip:AddLine(CurrencyButton_GetTooltipText(),1,1,1)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

	
	-- init dragging
	b:RegisterForDrag("LeftButton")
	b.dragme = false
	

	
	-- update the position of the button
	Currency:MinimapUpdatePosition()

end
function CurrencyButton_GetTooltipText()
     
   local display="";
   local tooltip="";
   local name, myindex, isHeader, isExpanded, isUnused, isWatched, count, cCount, PVPIndex;
   cCount = GetCurrencyListSize();
   for index=1, cCount do 
      name, isHeader, isExpanded, isUnused, isWatched, count = GetCurrencyListInfo(index);
      if (count~=0) then
         display=strconcat(name," -- ",count)
         -- trace(display)
         tooltip=strconcat(tooltip,display,"|r\n")
      end
      
      
      myindex=index
   end 
final_tooltip=tooltip
     return ""..final_tooltip;     
end

function Currency:SetMinimapPosition(angle, radius, rounding)
	miniMap.angle = angle
	if(radius) then
		miniMap.radius = radius
	end
	if(rounding) then
		miniMap.rounding = rounding
	end
	Currency:MinimapUpdatePosition()
	
end

function Currency:MinimapBeingDragged()
	local mx, my = Minimap:GetCenter()
	local mz = MinimapCluster:GetScale()
	local cx, cy = GetCursorPosition(UIParent)
	local cz = UIParent:GetEffectiveScale()
	local v = math.deg(math.atan2(cy / cz - my * mz, cx / cz - mx * mz))
	if v < 0 then
		v = v + 360
	elseif v > 360 then
		v = v - 360
	end
	Currency:SetMinimapPosition(v)
end

local MinimapShapes = {
	-- quadrant booleans (same order as SetTexCoord)
	-- {upper-left, lower-left, upper-right, lower-right}
	-- true = rounded, false = squared
	["ROUND"] 								= {true, true, true, true},
	["SQUARE"] 								= {false, false, false, false},
	["CORNER-TOPLEFT"] 				= {true, false, false, false},
	["CORNER-TOPRIGHT"] 			= {false, false, true, false},
	["CORNER-BOTTOMLEFT"] 		= {false, true, false, false},
	["CORNER-BOTTOMRIGHT"]	 	= {false, false, false, true},
	["SIDE-LEFT"] 						= {true, true, false, false},
	["SIDE-RIGHT"] 						= {false, false, true, true},
	["SIDE-TOP"] 							= {true, false, true, false},
	["SIDE-BOTTOM"] 					= {false, true, false, true},
	["TRICORNER-TOPLEFT"] 		= {true, true, true, false},
	["TRICORNER-TOPRIGHT"] 		= {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] 	= {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {false, true, true, true},
	}
function Currency:MinimapUpdatePosition()
	local radius, rounding, angle
	
	radius = miniMap.radius
	rounding = miniMap.rounding
	angle = math.rad(miniMap.angle)
	
	local x = math.cos(angle)
	local y = math.sin(angle)
	local q = 1;
	if x < 0 then
		q = q + 1;	-- lower
	end
	if y > 0 then
		q = q + 2;	-- right
	end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = MinimapShapes[minimapShape]
	if quadTable[q] then
		x = x*radius
		y = y*radius
	else
		local diagRadius = math.sqrt(2*(radius)^2)-rounding
		x = math.max(-radius, math.min(x*diagRadius, radius))
		y = math.max(-radius, math.min(y*diagRadius, radius))
	end
	Currency.Minimap:SetPoint("CENTER", Minimap, "CENTER", x, y-1)
end