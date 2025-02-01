--------------------------------------------------------------------------------
-- GMacros v1.0 by Gunjak                                                     --
--------------------------------------------------------------------------------

local VERSION = "1.0"

if not GMacrosDB then
    GMacrosDB = {}
end

local function Log(text)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCCCGMacros ::|r " .. text)
end

--------------------------------------------------------------------------------
-- CleverMacro Conditions                                                                  -
--------------------------------------------------------------------------------

CleverMacro.Conditions.distance = function(args)
    local v = args.v
    local index
    if v.one == true or v[1] == true then
        index = 1
    elseif v.two == true or v[2] == true then
        index = 2
    elseif v.three == true or v[3] == true then
        index = 3
    elseif v.four == true or v[4] == true then
        index = 4
    else
        return false
    end
    return CheckInteractDistance(args.target, index) 
end

CleverMacro.Conditions.dist = CleverMacro.Conditions.distance

---------------------------------------------------------------------------------
-- Event Handlers
---------------------------------------------------------------------------------
local EventHandlers = {
    LOOT_OPENED = function()
        if GMacrosDB.toggleLootScreenshot == "ON" then
            Screenshot()
            Log("loot screenshot captured")
        end
    end
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("LOOT_OPENED")

frame:SetScript("OnEvent", function() EventHandlers[event]() end)


--------------------------------------------------------------------------------
-- Slash Commands                                                              -
--------------------------------------------------------------------------------

SlashCmdList["ASSISTPRESET"] = function()
    local assistTarget = getglobal("GMacrosAssistPreset")
    if (assistTarget and assistTarget ~= "") then
        AssistByName(assistTarget)
    end
end

SlashCmdList["AUTOSHOT"] = function()
    for i = 1, 120 do 
        if IsAutoRepeatAction(i) then return end 
    end 
    CastSpellByName("Auto Shot")
end

SlashCmdList["CLEARASSIST"] = function()
    local assistName = getglobal("GMacrosAssistPreset")
    assistName = not assistName and "" or assistName
    if assistName == "" then 
        Log("no assist preset to clear")
    else 
        Log("cleared assist: " .. assistName)
        setglobal("GMacrosAssistPreset", "")
    end
end

local FeedPetFromBags = function(foodName)
    for bag = 0, 4 do 
        for slot = 1, GetContainerNumSlots(bag) do 
            local item = GetContainerItemLink(bag, slot)
            if item and string.find(item, foodName) then 
                CastSpellByName("Feed Pet")
                PickupContainerItem(bag, slot)
                Log("fed your pet <" .. foodName .. ">")
                return
            end
        end
    end
    Log("did not find <" .. foodName .. "> in your bags!")
end

SlashCmdList["FEEDPET"] = function(msg)
    local arg = CleverMacro.GetArg(CleverMacro.ParseArguments(msg))
    if arg then
        if not HasPetUI() then
            Log("you don't have a pet")
            return
        end
        if UnitClass("player") ~= "Hunter" then 
            Log("you can only feed Hunter pets")
            return 
        end
        if UnitAffectingCombat("player") or UnitAffectingCombat("pet") then
            Log("you are in combat")
            return
        end
        if arg.text and arg.text ~= "" then
            FeedPetFromBags(arg.text)    
        elseif GMacrosDB.petFood and GMacrosDB.petFood ~= "" then
            FeedPetFromBags(GMacrosDB.petFood)
        else 
            Log("you must specify a pet food")
        end
    end
end

SlashCmdList["PETATTACK"] = function(msg)
    local arg, target = CleverMacro.GetArg(CleverMacro.ParseArguments(msg))
    if (arg and GMacrosDB.togglePetAttack == "ON") then 
        local retarget = not UnitIsUnit(target, "target") -- UnitIsUnit() determines if the arguments are the same unit
        if retarget then TargetUnit(target) end         
        PetAttack(target)
        if retarget then TargetLastTarget() end       
    end
end

SlashCmdList["PETFOLLOW"] = function()
    PetFollow()
end

SlashCmdList["PETFOOD"] = function(msg)
    if UnitClass("player") ~= "Hunter" then
        Log("Only Hunters can set a pet food type")
    end
    local arg = CleverMacro.GetArg(CleverMacro.ParseArguments(msg))
    if arg then
        if arg.text == "" then
            if GMacrosDB.petFood and GMacrosDB.petFood ~= "" then 
                Log("current pet food is: <" .. GMacrosDB.petFood .. ">")
            else
                Log("you must specify a pet food, e.g. /petfood Roasted Quail")
            end
        else
            GMacrosDB.petFood = arg.text 
            Log("pet food set to: <".. GMacrosDB.petFood .. ">")
        end
    end
end

SlashCmdList["SAFETARGET"] = function(msg)
    local arg, target = CleverMacro.GetArg(CleverMacro.ParseArguments(msg))
    if arg then 
        local playerHasLivingTarget = (UnitExists(target) and not UnitIsDeadOrGhost(target))
        if not playerHasLivingTarget then
            TargetNearestEnemy()
            if GMacrosDB.toggleSafeTarget == "ON" then return false end
        end
    end
end

SlashCmdList["SETASSIST"] = function(msg)
    local arg, target = CleverMacro.GetArg(CleverMacro.ParseArguments(msg))
    if arg then
        local assistName = arg.text
        if assistName and UnitIsFriend("player", assistName) then
            setglobal("GMacrosAssistPreset", assistName)
        elseif UnitExists(target) and UnitIsFriend("player", target) then
            assistName = UnitName(target)
            setglobal("GMacrosAssistPreset", assistName)
        end
        if (assistName and assistName ~= "") then
            Log("assist target set to: " .. assistName)
        else
            Log("no assist target set!!!")
        end
    end
end

SlashCmdList["SAVESPEC"] = function(msg)
    local arg = CleverMacro.GetArg(CleverMacro.ParseArguments(msg))
    if arg then
        if not ABP_SlashCommand then
            Log("install Action Bar Profiles to use this feature")
            return false
        elseif not arg.text or arg.text == "" then
            Log("you must specify a profile to save")
            return false
        else
            ABP_SlashCommand("save " .. arg.text)
            Log("saved spec <" .. arg.text .. ">")
        end
    end
end

SlashCmdList["LOADSPEC"] = function(msg)
    local arg = CleverMacro.GetArg(CleverMacro.ParseArguments(msg))
    if arg then
        if not ABP_SlashCommand then
            Log("install Action Bar Profiles to use this feature")
            return false
        elseif not arg.text or arg.text == "" then
            Log("you must specify a profile to load")
            return false
        else
            ABP_SlashCommand("load " .. arg.text)
            Log("loaded spec <" .. arg.text .. ">")
        end
    end
end

SlashCmdList["TOGGLEPETATTACK"] = function()
    local t = GMacrosDB.togglePetAttack
    local condition = not t or t == "" or t == "OFF"
    GMacrosDB.togglePetAttack = condition and "ON" or "OFF"
    Log("pet attack toggled to: " .. GMacrosDB.togglePetAttack)
end

SlashCmdList["TOGGLESAFETARGET"] = function(msg)
    local condition = GMacrosDB.toggleSafeTarget == "ON"
    GMacrosDB.toggleSafeTarget = condition and "OFF" or "ON"
    Log("safe target toggled to: " .. GMacrosDB.toggleSafeTarget)
end

SlashCmdList["TOGGLELOOTSCREENSHOT"] = function(msg)
    local condition = GMacrosDB.toggleLootScreenshot == "ON"
    GMacrosDB.toggleLootScreenshot = condition and "OFF" or "ON"
    Log("loot screenshot toggled to: " .. GMacrosDB.toggleLootScreenshot)
end

SlashCmdList["UNBUFF"] = function(msg)
    local arg = CleverMacro.GetArg(CleverMacro.ParseArguments(msg))
    if arg then
        local i = 0
        while not(GetPlayerBuff(i) == -1) do 
            if (strfind(GetPlayerBuffTexture(GetPlayerBuff(i)), arg.text)) then 
                CancelPlayerBuff(GetPlayerBuff(i))
            end 
            i = i + 1
        end
    end
end
------------------------------------------
SLASH_ASSISTPRESET1 = "/assistpreset"
SLASH_AUTOSHOT1 = "/autoshot"
SLASH_CLEARASSIST1 = "/clearassist"
SLASH_FEEDPET1 = "/feedpet"
SLASH_PETATTACK1 = "/petattack"
SLASH_PETFOLLOW1 = "/petfollow"
SLASH_PETFOOD1 = "/petfood"
SLASH_SAFETARGET1 = "/safetarget"
SLASH_SETASSIST1 = "/setassist"
SLASH_SAVESPEC1 = "/savespec"
SLASH_SAVESPEC2 = "/ss"
SLASH_LOADSPEC1 = "/loadspec"
SLASH_LOADSPEC2 = "/ls"
SLASH_TOGGLELOOTSCREENSHOT1 = "/togglelootscreenshot"
SLASH_TOGGLEPETATTACK1 = "/togglepetattack"
SLASH_TOGGLESAFETARGET1 = "/togglesafetarget"
SLASH_UNBUFF1 = "/unbuff"

-- Exports

GMacros = {}

GMacros.Log = Log

DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCCCGMacros |r" .. VERSION .. "|cFF00CCCC loaded|r")
