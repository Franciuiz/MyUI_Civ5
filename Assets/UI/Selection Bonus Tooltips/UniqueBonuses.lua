-------------------------------------------------
-- Unique Bonuses

-- This is a file intended to be shared
-------------------------------------------------
include( "IconSupport" );
include( "InfoTooltipInclude" );

-- List the textures that we will need here
local defaultErrorTextureSheet = "IconFrame64.dds";

questionOffset, questionTextureSheet = IconLookup( 23, 64, "CIV_COLOR_ATLAS" );
unknownString = Locale.ConvertTextKey( "TXT_KEY_MISC_UNKNOWN" );

-- Added by bacon
local bExpansionActive = ContentManager.IsActive("0E3751A1-F840-4e1b-9706-519BF484E59D", ContentType.GAMEPLAY);
------------------------------------------------------------------
------------------------------------------------------------------
function AdjustArtOnUniqueUnitButton( thisButton, thisFrame, thisUnitInfo, textureSize, extendedTooltip, noTooltip)
	if thisButton then
		if (noTooltip ~= true) then
			--if (extendedTooltip) then
			--	thisButton:SetToolTipString( Locale.ConvertTextKey(GetHelpTextForUnit(thisUnitInfo.ID, true)));
			--else
				thisButton:SetToolTipString( Locale.ConvertTextKey( GetHelpTextForUnitFrontEnd(thisUnitInfo, true) ) );
			--end
		else
			thisButton:SetToolTipString("");
		end

		-- if we have one, update the unit picture
		local textureOffset, textureSheet = IconLookup( thisUnitInfo.PortraitIndex, textureSize, thisUnitInfo.IconAtlas );				
		if textureOffset == nil then
			textureSheet = defaultErrorTextureSheet;
			textureOffset = nullOffset;
		end				
		thisButton:SetTexture( textureSheet );
		thisButton:SetTextureOffset( textureOffset );
		thisButton:SetHide( false );
		thisFrame:SetHide( false );

	end
end

-- UNITS cooked by bacon
function GetHelpTextForUnitFrontEnd(thisUnitInfo, bIncludeRequirementsInfo)
	local pUnitInfo = GameInfo.Units[thisUnitInfo.ID];
	local pBaseUnitInfo = GameInfo.Units[GameInfo.UnitClasses[pUnitInfo.Class].DefaultUnit];

	local strHelpText = "";
	
	-- TODO: Compare stats to base unit

	-- Name
	strHelpText = strHelpText .. Locale.ConvertTextKey( pUnitInfo.Description );
	strHelpText = strHelpText .. " (" .. Locale.ConvertTextKey( pBaseUnitInfo.Description ) .. ")";

	-- Cost
	strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
	strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_COST", pUnitInfo.Cost);
	if (pBaseUnitInfo.Cost ~= pUnitInfo.Cost) then
		strHelpText = strHelpText .. " (base: " .. pBaseUnitInfo.Cost .. ")";
	end

	-- Moves
	strHelpText = strHelpText .. "[NEWLINE]";
	strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_MOVEMENT", pUnitInfo.Moves);
	if (pBaseUnitInfo.Moves ~= pUnitInfo.Moves) then
		strHelpText = strHelpText .. " (base: " .. pBaseUnitInfo.Moves .. ")";
	end
	
	-- Range
	local iRange = pUnitInfo.Range;
	if (iRange ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_RANGE", iRange);
		if (pBaseUnitInfo.Range ~= iRange) then
			strHelpText = strHelpText .. " (base: " .. pBaseUnitInfo.Range .. ")";
		end
	end
	
	-- Ranged Strength
	local iRangedStrength = pUnitInfo.RangedCombat;
	if (iRangedStrength ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_RANGED_STRENGTH", iRangedStrength);
		if (pBaseUnitInfo.RangedCombat ~= iRangedStrength) then
			strHelpText = strHelpText .. " (base: " .. pBaseUnitInfo.RangedCombat .. ")";
		end
	end
	
	-- Strength
	local iStrength = pUnitInfo.Combat;
	if (iStrength ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_STRENGTH", iStrength);
		if (pBaseUnitInfo.Combat ~= iStrength) then
			strHelpText = strHelpText .. " (base: " .. pBaseUnitInfo.Combat .. ")";
		end
	end
	
	-- Resource Requirements (disabled)

	-- promotion descriptions!
	local unitPromotions = GameInfo.Unit_FreePromotions( "UnitType = '" .. pUnitInfo.Type .. "'" );
	local unitPromotionList = {};
	for row in unitPromotions do
		unitPromotionList[row.PromotionType] = "new";
	end
	local baseUnitPromotions = GameInfo.Unit_FreePromotions( "UnitType = '" .. pBaseUnitInfo.Type .. "'" );
	for base in baseUnitPromotions do
		if (unitPromotionList[base.PromotionType] ~= nil) then
			unitPromotionList[base.PromotionType] = "both";
		else
			--unitPromotionList[base.PromotionType] = "removed";
		end
	end
	
	strHelpText = strHelpText .. "[NEWLINE]----------------";
	for k, v in pairs(unitPromotionList) do
		strHelpText = strHelpText .. "[NEWLINE]";
		if (v == "new") then 
			strHelpText = strHelpText .. "[COLOR_POSITIVE_TEXT]NOVO[ENDCOLOR] ";
		elseif (v == "removed") then 
			strHelpText = strHelpText .. "[COLOR_NEGATIVE_TEXT]ANTIGO[ENDCOLOR] ";
		end
		local promotion = GameInfo.UnitPromotions[k];
		strHelpText = strHelpText .. "[COLOR_UNIT_TEXT]" .. Locale.ConvertTextKey( promotion.Description ) .. "[ENDCOLOR] ";
		strHelpText = strHelpText .. Locale.ConvertTextKey( promotion.Help );
	end
	
	-- Pre-written Help text
	if (not pUnitInfo.Help) then
		print("Invalid unit help");
		print(strHelpText);
	else
		local strWrittenHelpText = Locale.ConvertTextKey( pUnitInfo.Help );
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
			strHelpText = strHelpText .. strWrittenHelpText;
		end	
	end
	
	
	-- Requirements?
	if (bIncludeRequirementsInfo) then
		if (pUnitInfo.Requirements) then
			strHelpText = strHelpText .. Locale.ConvertTextKey( pUnitInfo.Requirements );
		end
	end
	
	return strHelpText;
end

------------------------------------------------------------------
------------------------------------------------------------------
function AdjustArtOnUniqueBuildingButton( thisButton, thisFrame, thisBuildingInfo, textureSize, extendedTooltip, noTooltip)
	if thisButton then
		if(noTooltip ~= true) then
			--if (extendedTooltip) then
			--	thisButton:SetToolTipString( Locale.ConvertTextKey(GetHelpTextForBuilding(thisBuildingInfo.ID, false, false, false)));
			--else
				thisButton:SetToolTipString( Locale.ConvertTextKey( GetHelpTextForBuildingFrontEnd(thisBuildingInfo.ID, false, false, false) ) );
			--end
		else
			thisButton:SetToolTipString("");
		end

		-- if we have one, update the building (or wonder) picture
		local textureOffset, textureSheet = IconLookup( thisBuildingInfo.PortraitIndex, textureSize, thisBuildingInfo.IconAtlas );				
		if textureOffset == nil then
			textureSheet = defaultErrorTextureSheet;
			textureOffset = nullOffset;
		end
		
		thisButton:SetTexture( textureSheet );
		thisButton:SetTextureOffset( textureOffset );
		thisButton:SetHide( false );
		thisFrame:SetHide( false );
	end
end

-- BUILDING baked by bacon
function GetHelpTextForBuildingFrontEnd(iBuildingID, bExcludeName, bExcludeHeader, bNoMaintenance)
	local pBuildingInfo = GameInfo.Buildings[iBuildingID];
	local pBaseBuildingInfo = GameInfo.Buildings[GameInfo.BuildingClasses[pBuildingInfo.BuildingClass].DefaultBuilding];
	
	local strHelpText = "";
	
	-- function for getting yield change (integer)
	local GetBuildingYieldChange = function(buildingID, yieldType)
		if(Game ~= nil) then
			return Game.GetBuildingYieldChange(buildingID, YieldTypes[yieldType]);
		else
			local yieldModifier = 0;
			local buildingType = GameInfo.Buildings[buildingID].Type;
			for row in GameInfo.Building_YieldChanges{BuildingType = buildingType, YieldType = yieldType} do
				yieldModifier = yieldModifier + row.Yield;
			end
			
			return yieldModifier;
		end
	
	end
	
	-- function for getting yield modifier (percentage)
	local GetBuildingYieldModifier = function(buildingID, yieldType)
		if(Game ~= nil) then
			return Game.GetBuildingYieldModifier(buildingID, YieldTypes[yieldType]);
		else
			local yieldModifier = 0;
			local buildingType = GameInfo.Buildings[buildingID].Type;
			for row in GameInfo.Building_YieldModifiers{BuildingType = buildingType, YieldType = yieldType} do
				yieldModifier = yieldModifier + row.Yield;
			end
			
			return yieldModifier;
		end
		
	end
	
	-- function to append to the help text
	local AppendHelpText = function(value, baseValue, bUseTextKey, sTextKey, seperator)
		if (value ~= nil and value ~= 0) then
			strHelpText = strHelpText .. (seperator or "[NEWLINE]");
			if (bUseTextKey) then
				strHelpText = strHelpText .. Locale.ConvertTextKey(sTextKey, value);
			else
				strHelpText = strHelpText .. sTextKey;
			end
			if (value ~= baseValue and baseValue ~= nil) then
				strHelpText = strHelpText .. " (base: " .. baseValue .. ")";
			end
		end
	end
	
	if (not bExcludeHeader) then
		
		if (not bExcludeName) then
			-- Name
			strHelpText = strHelpText .. Locale.ConvertTextKey( pBuildingInfo.Description );
			strHelpText = strHelpText .. " (" .. Locale.ConvertTextKey( pBaseBuildingInfo.Description ) .. ")";
			strHelpText = strHelpText .. "[NEWLINE]----------------";
		end
		
		-- Cost
		AppendHelpText(pBuildingInfo.Cost, pBaseBuildingInfo.Cost, true, "TXT_KEY_PRODUCTION_COST", nil);
		
		-- Maintenance
		if (not bNoMaintenance) then
			AppendHelpText(pBuildingInfo.GoldMaintenance, pBaseBuildingInfo.GoldMaintenance, true, "TXT_KEY_PRODUCTION_BUILDING_MAINTENANCE", nil);
		end
		
	end
	
	-- Happiness (from all sources)
	local iHappinessTotal = (pBuildingInfo.Happiness or 0) + (pBuildingInfo.UnmoddedHappiness or 0);
	local iBaseHappiness = (pBaseBuildingInfo.Happiness or 0) + (pBaseBuildingInfo.UnmoddedHappiness or 0);
	AppendHelpText(iHappinessTotal, iBaseHappiness, true, "TXT_KEY_PRODUCTION_BUILDING_HAPPINESS", nil);
	
	-- Defense
	AppendHelpText(pBuildingInfo.Defense / 100, pBaseBuildingInfo.Defense / 100, true, "TXT_KEY_PRODUCTION_BUILDING_DEFENSE", nil);
	
	if bExpansionActive then
		AppendHelpText(pBuildingInfo.ExtraCityHitPoints, pBaseBuildingInfo.ExtraCityHitPoints, true, "TXT_KEY_PEDIA_DEFENSE_HITPOINTS", ", ");
	end
	
	-- Culture
	local iCulture = GetBuildingYieldChange(iBuildingID, "YIELD_CULTURE");
	local iBaseCulture = GetBuildingYieldChange(pBaseBuildingInfo.ID, "YIELD_CULTURE");
	if not bExpansionActive then
		iCulture = pBuildingInfo.Culture;
		iBaseCulture = pBaseBuildingInfo.Culture;
	end
	AppendHelpText(iCulture, iBaseCulture, true, "TXT_KEY_PRODUCTION_BUILDING_CULTURE", nil);
	
	-- Faith
	local iFaith = GetBuildingYieldChange(iBuildingID, "YIELD_FAITH");
	local iBaseFaith = GetBuildingYieldChange(pBaseBuildingInfo.ID, "YIELD_FAITH");
	AppendHelpText(iFaith, iBaseFaith, true, "TXT_KEY_PRODUCTION_BUILDING_FAITH", nil);
	
	-- Food
	local iFood = GetBuildingYieldChange(iBuildingID, "YIELD_FOOD");
	local iBaseFaith = GetBuildingYieldChange(pBaseBuildingInfo.ID, "YIELD_FOOD");
	AppendHelpText(iFood, iBaseFaith, true, "TXT_KEY_PRODUCTION_BUILDING_FOOD", nil);
	
	-- Food Mod
	local iFoodMod = GetBuildingYieldModifier(iBuildingID, "YIELD_FOOD");
	local iBaseFoodMod = GetBuildingYieldModifier(pBaseBuildingInfo.ID, "YIELD_FOOD");
	AppendHelpText(iFoodMod, iBaseFoodMod, false, "[ICON_FOOD] Food: +" .. iFoodMod .. "%", nil); -- WHY NO TXT_KEY? FU!
	
	-- Gold
	local iGold = GetBuildingYieldChange(iBuildingID, "YIELD_GOLD");
	local iBaseGold = GetBuildingYieldChange(pBaseBuildingInfo.ID, "YIELD_GOLD");
	AppendHelpText(iGold, iBaseGold, true, "TXT_KEY_PRODUCTION_BUILDING_GOLD_CHANGE", nil);
	
	-- Gold Mod
	local iGoldMod = GetBuildingYieldModifier(iBuildingID, "YIELD_GOLD");
	local iBaseGoldMod = GetBuildingYieldModifier(pBaseBuildingInfo.ID, "YIELD_GOLD");
	AppendHelpText(iGoldMod, iBaseGoldMod, true, "TXT_KEY_PRODUCTION_BUILDING_GOLD", nil);
	
	-- Science
	local iScience = GetBuildingYieldChange(iBuildingID, "YIELD_SCIENCE");
	local iBaseScience = GetBuildingYieldChange(pBaseBuildingInfo.ID, "YIELD_SCIENCE");
	AppendHelpText(iScience, iBaseScience, true, "TXT_KEY_PRODUCTION_BUILDING_SCIENCE_CHANGE", nil);
	
	-- Science Mod
	local iScienceMod = GetBuildingYieldModifier(iBuildingID, "YIELD_SCIENCE");
	local iBaseScienceMod = GetBuildingYieldModifier(pBaseBuildingInfo.ID, "YIELD_SCIENCE");
	AppendHelpText(iScienceMod, iBaseScienceMod, true, "TXT_KEY_PRODUCTION_BUILDING_SCIENCE", nil);

	-- Production
	local iProduction = GetBuildingYieldChange(iBuildingID, "YIELD_PRODUCTION");
	local iBaseProduction = GetBuildingYieldChange(pBaseBuildingInfo.ID, "YIELD_PRODUCTION");
	AppendHelpText(iProduction, iBaseProduction, true, "TXT_KEY_PRODUCTION_BUILDING_PRODUCTION_CHANGE", nil);
	
	-- Production Mod
	local iProductionMod = GetBuildingYieldModifier(iBuildingID, "YIELD_PRODUCTION");
	local iBaseProductionMod = GetBuildingYieldModifier(pBaseBuildingInfo.ID, "YIELD_PRODUCTION");
	AppendHelpText(iProductionMod, iBaseProductionMod, true, "TXT_KEY_PRODUCTION_BUILDING_PRODUCTION", nil);
	
	-- Great People
	local specialistType = pBuildingInfo.SpecialistType;
	if specialistType ~= nil then
		local iNumPoints = pBuildingInfo.GreatPeopleRateChange;
		if (iNumPoints > 0) then
			strHelpText = strHelpText .. "[NEWLINE]";
			strHelpText = strHelpText .. "[ICON_GREAT_PEOPLE] " .. Locale.ConvertTextKey(GameInfo.Specialists[specialistType].GreatPeopleTitle) .. " " .. iNumPoints;
		end
		
		if(pBuildingInfo.SpecialistCount > 0) then
			strHelpText = strHelpText .. "[NEWLINE]";
			
			-- Append a key such as TXT_KEY_SPECIALIST_ARTIST_SLOTS
			local specialistSlotsKey = GameInfo.Specialists[specialistType].Description .. "_SLOTS";
			strHelpText = strHelpText .. "[ICON_GREAT_PEOPLE] " .. Locale.ConvertTextKey(specialistSlotsKey) .. " " .. pBuildingInfo.SpecialistCount;
		end
	end
	
	-- Pre-written Help text
	if (pBuildingInfo.Help ~= nil) then
		local strWrittenHelpText = Locale.ConvertTextKey( pBuildingInfo.Help );
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
			strHelpText = strHelpText .. strWrittenHelpText;
		end
	end
	
	return strHelpText;
	
end

------------------------------------------------------------------
------------------------------------------------------------------
function AdjustArtOnUniqueImprovementButton( thisButton, thisFrame, thisImprovmentInfo, textureSize, extendedTooltip, noTooltip)
	if thisButton then
		if(noTooltip ~= true) then
			-- if (extendedTooltip) then
				-- thisButton:SetToolTipString( Locale.ConvertTextKey(GetHelpTextForImprovement(thisImprovmentInfo.ID, false, false, false)));
			-- else
				thisButton:SetToolTipString( Locale.ConvertTextKey( GetHelpTextForImprovementFrontEnd( thisImprovmentInfo.ID, false, false, false ) ) );
			-- end
		else
			thisButton:SetToolTipString("");
		end

		-- if we have one, update the building (or wonder) picture
		local textureOffset, textureSheet = IconLookup( thisImprovmentInfo.PortraitIndex, textureSize, thisImprovmentInfo.IconAtlas );				
		if textureOffset == nil then
			textureSheet = defaultErrorTextureSheet;
			textureOffset = nullOffset;
		end
		
		thisButton:SetTexture( textureSheet );
		thisButton:SetTextureOffset( textureOffset );
		thisButton:SetHide( false );
		thisFrame:SetHide( false );
	end
end

-- IMPROVEMENT nom by bacon
function GetHelpTextForImprovementFrontEnd(iImprovementID, bExcludeName, bExcludeHeader, bNoMaintenance)
	local pImprovementInfo = GameInfo.Improvements[iImprovementID];
	
	--local pActivePlayer = Players[Game.GetActivePlayer()];
	--local pActiveTeam = Teams[Game.GetActiveTeam()];
	
	local strHelpText = "";
	
	if (not bExcludeHeader) then
		
		if (not bExcludeName) then
			-- Name
			strHelpText = strHelpText .. Locale.ConvertTextKey( pImprovementInfo.Description );
			strHelpText = strHelpText .. "[NEWLINE]----------------";
		end
				
	end
	
	-- function to append to the help text
	local AppendHelpText = function(value, sTextKey, moarText)
		if (value ~= nil and value ~= 0) then
			strHelpText = strHelpText .. "[NEWLINE]";
			strHelpText = strHelpText .. Locale.ConvertTextKey(sTextKey, value);
			strHelpText = strHelpText .. moarText;
		end
	end
	
	-- Get base yield increase
	local yields = {
		FOOD = "YIELD_FOOD", 
		GOLD_CHANGE = "YIELD_GOLD", 
		PRODUCTION_CHANGE = "YIELD_PRODUCTION", 
		SCIENCE_CHANGE = "YIELD_SCIENCE", 
		CULTURE = "YIELD_CULTURE", 
		FAITH = "YIELD_FAITH" }
	for yield, yieldType in pairs(yields) do 
		for row in GameInfo.Improvement_Yields{ImprovementType = pImprovementInfo.Type, YieldType = yieldType} do
			AppendHelpText(row.Yield, "TXT_KEY_PRODUCTION_BUILDING_" .. yield, "");
		end
		
		for row in GameInfo.Improvement_TechYieldChanges{ImprovementType = pImprovementInfo.Type, YieldType = yieldType} do
			AppendHelpText(row.Yield, "TXT_KEY_PRODUCTION_BUILDING_" .. yield, 
				" com [COLOR_RESEARCH_STORED]" .. Locale.ConvertTextKey(GameInfo.Technologies[row.TechType].Description) .. "[ENDCOLOR]");
		end
	end
	
	AppendHelpText(pImprovementInfo.DefenseModifier, "TXT_KEY_PRODUCTION_BUILDING_DEFENSE", "%");
	
	-- Vanilla culture hack crap
	if not bExpansionActive then
		AppendHelpText(pImprovementInfo.Culture, "TXT_KEY_PRODUCTION_BUILDING_CULTURE", "");
	end
		
	-- if we end up having a lot of these we may need to add some more stuff here
	
	-- Pre-written Help text
	if (pImprovementInfo.Help ~= nil) then
		local strWrittenHelpText = Locale.ConvertTextKey( pImprovementInfo.Help );
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
			strHelpText = strHelpText .. strWrittenHelpText;
		end
	end
	
	return strHelpText;
	
end

------------------------------------------------------------------
-- Developer Note:
-- The argument noTooltip is an additional argument to specify no tooltip should be used.
-- This is an additional argument instead of modifying extendedTooltip so that pre-existing calls
-- will behave the same way.
------------------------------------------------------------------
function PopulateUniqueBonuses( controlTable, civ, _, extendedTooltip, noTooltip)

	local maxSmallButtons = 2;
	local BonusText = {};

	function PopulateButton(button, buttonFrame)
		local textureSize = 64;

		for row in DB.Query([[SELECT ID, Description, PortraitIndex, IconAtlas from Units INNER JOIN 
							Civilization_UnitClassOverrides ON Units.Type = Civilization_UnitClassOverrides.UnitType 
							WHERE Civilization_UnitClassOverrides.CivilizationType = ? AND
							Civilization_UnitClassOverrides.UnitType IS NOT NULL]], civ.Type) do
			AdjustArtOnUniqueUnitButton(button, buttonFrame, row, textureSize, extendedTooltip, noTooltip);
 			button, buttonFrame = coroutine.yield(row.Description);	
		end
		
		for row in DB.Query([[SELECT ID, Description, PortraitIndex, IconAtlas from Buildings INNER JOIN 
							Civilization_BuildingClassOverrides ON Buildings.Type = Civilization_BuildingClassOverrides.BuildingType 
							WHERE Civilization_BuildingClassOverrides.CivilizationType = ? AND
							Civilization_BuildingClassOverrides.BuildingType IS NOT NULL]], civ.Type) do
			AdjustArtOnUniqueBuildingButton(button, buttonFrame, row, textureSize, extendedTooltip, noTooltip);
 			button, buttonFrame = coroutine.yield(row.Description);	
		end
			
		for row in DB.Query([[SELECT ID, Description, PortraitIndex, IconAtlas from Improvements where CivilizationType = ?]], civ.Type) do
			AdjustArtOnUniqueImprovementButton( button, buttonFrame, row, textureSize, extendedTooltip, noTooltip);
 			button, buttonFrame = coroutine.yield(row.Description);
		end
	end
	

	local co = coroutine.create(PopulateButton);
	for buttonNum = 1, maxSmallButtons, 1 do
		local buttonName = "B"..tostring(buttonNum);
		local buttonFrameName = "BF"..tostring(buttonNum);

		local button = controlTable[buttonName];
		local buttonFrame = controlTable[buttonFrameName];
		
		if(button and buttonFrame) then
			button:SetHide(true);
			buttonFrame:SetHide(true);
			local _, text = coroutine.resume(co, button, buttonFrame);
			table.insert(BonusText, text);
		end
	end
    
    return BonusText;
end


------------------------------------------------------------------
-- This method generates a method optimized for reuse for 
-- populating unique bonus icons.
------------------------------------------------------------------
function PopulateUniqueBonuses_CreateCached()
	
	local uniqueUnitsQuery = DB.CreateQuery([[SELECT ID, Description, PortraitIndex, IconAtlas from Units INNER JOIN 
								Civilization_UnitClassOverrides ON Units.Type = Civilization_UnitClassOverrides.UnitType 
								WHERE Civilization_UnitClassOverrides.CivilizationType = ? AND
								Civilization_UnitClassOverrides.UnitType IS NOT NULL]]);
								
	local uniqueBuildingsQuery = DB.CreateQuery([[SELECT ID, Description, PortraitIndex, IconAtlas from Buildings INNER JOIN 
								Civilization_BuildingClassOverrides ON Buildings.Type = Civilization_BuildingClassOverrides.BuildingType 
								WHERE Civilization_BuildingClassOverrides.CivilizationType = ? AND
								Civilization_BuildingClassOverrides.BuildingType IS NOT NULL]]);
								
	local uniqueImprovementsQuery = DB.CreateQuery([[SELECT ID, Description, PortraitIndex, IconAtlas from Improvements where CivilizationType = ?]]);
	
	return function(controlTable, civType, extendedTooltip, noTooltip) 
		local maxSmallButtons = 2;
		local BonusText = {};

		local textureSize = 64;

		local buttonFuncs = {};
		
		for row in uniqueUnitsQuery(civType) do
			table.insert(buttonFuncs, function(button, buttonFrame)
				AdjustArtOnUniqueUnitButton(button, buttonFrame, row, textureSize, extendedTooltip, noTooltip);
				return row.Description;
			end);
		end
		
		if(#buttonFuncs < maxSmallButtons) then
			for row in uniqueBuildingsQuery(civType) do
				table.insert(buttonFuncs, function(button, buttonFrame)
					AdjustArtOnUniqueBuildingButton(button, buttonFrame, row, textureSize, extendedTooltip, noTooltip);
					return row.Description;
				end);	
			end
		
			if(#buttonFuncs < maxSmallButtons) then	
				for row in uniqueImprovementsQuery(civType) do
					table.insert(buttonFuncs, function(button, buttonFrame)
						AdjustArtOnUniqueImprovementButton( button, buttonFrame, row, textureSize, extendedTooltip, noTooltip);
						return row.Description;
					end);
				end
			end
		end
	
		for buttonNum = 1, maxSmallButtons, 1 do
			local buttonName = "B"..tostring(buttonNum);
			local buttonFrameName = "BF"..tostring(buttonNum);

			local button = controlTable[buttonName];
			local buttonFrame = controlTable[buttonFrameName];
			
			if(button and buttonFrame) then
				button:SetHide(true);
				buttonFrame:SetHide(true);
				local text = buttonFuncs[buttonNum](button, buttonFrame);
				table.insert(BonusText, text);
			end
		end
	    
		return BonusText;
	end;
end