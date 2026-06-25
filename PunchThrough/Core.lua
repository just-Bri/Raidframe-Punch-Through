PunchThrough = LibStub("AceAddon-3.0"):NewAddon("PunchThrough", "AceConsole-3.0", "AceEvent-3.0")

-- Default profile layout if the database is clean (matching the original Mouse Buttons Fix addon)
local defaults = {
    profile = {
        bindings = {
            { mouseButton = "BUTTON4", modifier = "NONE", actionButton = "MultiBarBottomLeftButton12" },
            { mouseButton = "BUTTON5", modifier = "NONE", actionButton = "MultiBarBottomLeftButton11" },
            { mouseButton = "BUTTON4", modifier = "SHIFT", actionButton = "MultiBarBottomRightButton12" },
            { mouseButton = "BUTTON5", modifier = "SHIFT", actionButton = "MultiBarBottomRightButton11" },
        }
    }
}

function PunchThrough:OnInitialize()
    -- Initialize the saved variables database
    self.db = LibStub("AceDB-3.0"):New("PunchThroughDB", defaults, true)
    
    -- Register slash commands to quickly open the menu
    self:RegisterChatCommand("pt", "OpenConfig")
    self:RegisterChatCommand("punchthrough", "OpenConfig")
    
    -- Table to track bindings that we've set during this session, allowing us to clear them if modified/deleted
    self.appliedKeys = {}
end

function PunchThrough:OnEnable()
    self:ApplyAllBindings()
end

-- Core layout engine executing our frame punch-through fix
function PunchThrough:ApplyAllBindings()
    -- Guard rail against secure frame action restrictions during combat
    if InCombatLockdown() then
        self:Print("Cannot apply bindings during combat. Deferring until combat ends.")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    -- Clear previously applied bindings from this session first to prevent key clutter
    for _, key in ipairs(self.appliedKeys) do
        SetBinding(key, nil)
    end
    wipe(self.appliedKeys)

    -- Inject secure links to force mouse clicks through frame barriers
    for _, data in ipairs(self.db.profile.bindings) do
        if data.mouseButton and data.actionButton and data.actionButton ~= "" then
            local bindKey = data.mouseButton
            if data.modifier and data.modifier ~= "NONE" then
                bindKey = data.modifier .. "-" .. bindKey
            end
            
            SetBindingClick(bindKey, data.actionButton)
            table.insert(self.appliedKeys, bindKey)
        end
    end
    
    -- Ensure bindings are saved to the client
    SaveBindings(GetCurrentBindingSet())
end

-- Callback when exiting combat
function PunchThrough:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:ApplyAllBindings()
end

function PunchThrough:OpenConfig()
    if self.optionsCategoryId then
        Settings.OpenToCategory(self.optionsCategoryId)
    else
        -- Fallback if for some reason the ID is not ready
        Settings.OpenToCategory("Raidframe Punch-Through")
    end
end
