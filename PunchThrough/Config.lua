local PunchThrough = LibStub("AceAddon-3.0"):GetAddon("PunchThrough")

local options = {
    name = "Raidframe Punch-Through",
    type = "group",
    args = {
        desc = {
            type = "description",
            name = "Map your physical mouse side clicks cleanly to target action slots to stop frames from intercepting them.",
            order = 1,
        },
        applyBtn = {
            type = "execute",
            name = "Apply & Save Changes",
            desc = "Forces engine to push modifications to active action slots immediately.",
            func = function() PunchThrough:ApplyAllBindings() end,
            order = 2,
        },
        addBtn = {
            type = "execute",
            name = "Add New Mapping",
            desc = "Creates a new mapping row.",
            func = function()
                table.insert(PunchThrough.db.profile.bindings, {
                    mouseButton = "BUTTON4",
                    modifier = "NONE",
                    actionButton = ""
                })
                PunchThrough:RefreshConfigUI()
            end,
            order = 3,
        },
        bindingsGroup = {
            type = "group",
            name = "Configured Mappings",
            inline = true,
            order = 10,
            args = {}
        }
    }
}

-- Generate interface configuration fields dynamically based on the DB layout
function PunchThrough:RefreshConfigUI()
    local args = options.args.bindingsGroup.args
    wipe(args) -- Clear out before rendering to prevent visual glitches
    
    for i, data in ipairs(PunchThrough.db.profile.bindings) do
        args["bindingGroup"..i] = {
            type = "group",
            name = "Mapping #"..i,
            inline = true,
            order = i,
            args = {
                modifier = {
                    type = "select",
                    name = "Modifier",
                    values = { NONE = "None", SHIFT = "Shift", CTRL = "Ctrl", ALT = "Alt" },
                    get = function() return data.modifier end,
                    set = function(_, val) data.modifier = val end,
                    order = 1,
                },
                mouse = {
                    type = "select",
                    name = "Mouse Click",
                    values = { BUTTON4 = "Mouse 4", BUTTON5 = "Mouse 5" },
                    get = function() return data.mouseButton end,
                    set = function(_, val) data.mouseButton = val end,
                    order = 2,
                },
                targetSlot = {
                    type = "input",
                    name = "Action Slot Frame Name",
                    desc = "Hover using /fstack to check the target internal name (e.g. MultiBarLeftButton10)",
                    get = function() return data.actionButton end,
                    set = function(_, val) data.actionButton = strtrim(val) end,
                    order = 3,
                },
                deleteBtn = {
                    type = "execute",
                    name = "Delete",
                    desc = "Delete this mapping.",
                    func = function()
                        table.remove(PunchThrough.db.profile.bindings, i)
                        PunchThrough:RefreshConfigUI()
                    end,
                    order = 4,
                }
            }
        }
    end
    
    -- Notify the AceConfig registry that the structure of options has changed
    LibStub("AceConfigRegistry-3.0"):NotifyChange("PunchThrough")
end

-- Register layout settings cleanly into internal tables
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

PunchThrough:RegisterEvent("PLAYER_LOGIN", function()
    PunchThrough:RefreshConfigUI()
    AceConfig:RegisterOptionsTable("PunchThrough", options)
    local _, categoryId = AceConfigDialog:AddToBlizOptions("PunchThrough", "Raidframe Punch-Through")
    PunchThrough.optionsCategoryId = categoryId
end)
