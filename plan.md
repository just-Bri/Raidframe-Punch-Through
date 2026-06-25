Original addon created using addon.bool.no can be found in `/Mouse Buttons Fix` folder.
Below is the plan to turn it in to a full addon I can upload to CurseForge.

To turn this into a fully dynamic, release-ready addon with a settings UI, you need three elements:SavedVariables: A persistent data store to remember what settings the user picked.  An Options UI Panel: Built using the community standard Ace3 framework.  An Input Engine: Code that loops through those saved preferences and dynamically runs SetBindingClick at launch.  Below is the complete structure and code to convert this into a premium, configurable CurseForge project.1. File LayoutCreate a new folder inside your _retail_\Interface\AddOns\ directory named PunchThrough. Inside it, create the following four files:PunchThrough.tocembeds.xmlCore.luaConfig.lua2. File ContentsPunchThrough.tocThis is the manifest file telling World of Warcraft how to load your addon, what libraries it needs, and how to save user choices.  Code snippet## Interface: 120007
## Title: Raidframe Punch-Through
## Notes: Prevents Raidframes from eating Mouse4/Mouse5 bindings without macros.
## Author: YourName
## Version: 1.0.0
## SavedVariables: PunchThroughDB
## OptionalDeps: Ace3

embeds.xml
Core.lua
Config.lua
embeds.xmlInstead of packing bulky library files into your zip, fetching them cleanly through CurseForge dependency management using an embeds file is the industry standard approach.  XML<Ui xmlns="http://www.blizzard.com/wow/ui/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.blizzard.com/wow/ui/ ..\FrameXML\UI.xsd">
    <!-- Ace3 Libraries -->
    <Script file="Libs\LibStub\LibStub.lua"/>
    <Include file="Libs\AceAddon-3.0\AceAddon-3.0.xml"/>
    <Include file="Libs\AceDB-3.0\AceDB-3.0.xml"/>
    <Include file="Libs\AceConsole-3.0\AceConsole-3.0.xml"/>
    <Include file="Libs\AceGUI-3.0\AceGUI-3.0.xml"/>
    <Include file="Libs\AceConfig-3.0\AceConfig-3.0.xml"/>
</Ui>
Core.luaThis handles the logic: loading saved settings, cleaning old overrides, and executing the SetBindingClick injection engine dynamically.  LuaPunchThrough = LibStub("AceAddon-3.0"):NewAddon("PunchThrough", "AceConsole-3.0")

-- Default profile layout if the database is clean
local defaults = {
    profile = {
        bindings = {
            { mouseButton = "BUTTON4", modifier = "NONE", actionButton = "MultiBarLeftButton10" },
            { mouseButton = "BUTTON5", modifier = "NONE", actionButton = "MultiBarLeftButton11" },
            { mouseButton = "BUTTON4", modifier = "SHIFT", actionButton = "MultiBarLeftButton10" },
        }
    }
}

function PunchThrough:OnInitialize()
    -- Initialize the saved variables database
    self.db = LibStub("AceDB-3.0"):New("PunchThroughDB", defaults, true)
    
    -- Register slash commands to quickly open the menu
    self:RegisterChatCommand("pt", "OpenConfig")
    self:RegisterChatCommand("punchthrough", "OpenConfig")
    
    self:ApplyAllBindings()
end

-- Core layout engine executing our frame punch-through fix
function PunchThrough:ApplyAllBindings()
    if InCombatLockdown() then return end -- Guard rail against secure frame action restrictions

    for _, data in ipairs(self.db.profile.bindings) do
        if data.mouseButton and data.actionButton then
            local bindKey = data.mouseButton
            if data.modifier and data.modifier ~= "NONE" then
                bindKey = data.modifier .. "-" .. bindKey
            end
            
            -- Inject secure link to force mouse clicks through frame barriers
            SetBindingClick(bindKey, data.actionButton)
        end
    end
end

function PunchThrough:OpenConfig()
    -- Native interface window opening call
    Settings.OpenToCategory("Raidframe Punch-Through")
end
Config.luaThis UI script builds a clean configuration window that automatically populates in the retail Options -> AddOns sidebar panel.  Lualocal PunchThrough = LibStub("AceAddon-3.0"):GetAddon("PunchThrough")

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
        bindingsGroup = {
            type = "group",
            name = "Configured Mappings",
            inline = true,
            order = 3,
            args = {}
        }
    }
}

-- Generate interface configuration fields dynamically based on the DB layout
local function RefreshConfigUI()
    local args = options.args.bindingsGroup.args
    table.wipe(args) -- Clear frame junk out before rendering
    
    for i, data in ipairs(PunchThrough.db.profile.bindings) do
        args["mod"..i] = {
            type = "select",
            name = "Modifier #"..i,
            values = { NONE = "None", SHIFT = "Shift", CTRL = "Ctrl", ALT = "Alt" },
            get = function() return data.modifier end,
            set = function(_, val) data.modifier = val end,
            order = i * 4,
        }
        args["mouse"..i] = {
            type = "select",
            name = "Mouse Click",
            values = { BUTTON4 = "Mouse 4", BUTTON5 = "Mouse 5" },
            get = function() return data.mouseButton end,
            set = function(_, val) data.mouseButton = val end,
            order = i * 4 + 1,
        }
        args["targetSlot"..i] = {
            type = "input",
            name = "Action Slot Frame Name",
            desc = "Hover using /fstack to check the target internal name (e.g. MultiBarLeftButton10)",
            get = function() return data.actionButton end,
            set = function(_, val) data.actionButton = val:trim() end,
            order = i * 4 + 2,
        }
    end
end

-- Register layout settings cleanly into internal tables
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

PunchThrough:RegisterEvent("PLAYER_LOGIN", function()
    RefreshConfigUI()
    AceConfig:RegisterOptionsTable("PunchThrough", options)
    AceConfigDialog:AddToBlizOptions("PunchThrough", "Raidframe Punch-Through")
end)
3. Shipping to CurseForgeWhen pushing your project to CurseForge, you don't need to manually hunt down the code for the Ace3 libraries. CurseForge can automatically bundle them during packaging.Create a file named .pkgmeta in your root addon folder.Put the following library tracking configuration inside it:YAMLexternals:
  Libs/LibStub: https://repos.wowace.com/wow/libstub/mainline/trunk
  Libs/AceAddon-3.0: https://repos.wowace.com/wow/ace3/mainline/trunk/AceAddon-3.0
  Libs/AceDB-3.0: https://repos.wowace.com/wow/ace3/mainline/trunk/AceDB-3.0
  Libs/AceConsole-3.0: https://repos.wowace.com/wow/ace3/mainline/trunk/AceConsole-3.0
  Libs/AceGUI-3.0: https://repos.wowace.com/wow/ace3/mainline/trunk/AceGUI-3.0
  Libs/AceConfig-3.0: https://repos.wowace.com/wow/ace3/mainline/trunk/AceConfig-3.0
Zip up your folder and upload it. When users download your addon, the CurseForge packager will read this meta file and auto-insert the required dependencies directly into the Libs/ directory for them. Users will be able to type /pt to configure their custom layouts instantly!