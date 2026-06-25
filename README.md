# Raidframe Punch-Through (PunchThrough)

**Raidframe Punch-Through** is a lightweight World of Warcraft retail addon that prevents unit frames (like Blizzard's default raid frames) from intercepting and "eating" physical side mouse clicks (Mouse 4 and Mouse 5) without needing to write custom macros for every spell.

---

## The Problem

By default, World of Warcraft raid frames and unit frames intercept clicks from Mouse 4 (`BUTTON4`) and Mouse 5 (`BUTTON5`). If you bind these buttons directly to abilities in your keybindings, clicking them while your cursor is hovering over a raid frame does nothing. 

To work around this, players traditionally had to write hover-over macros or use third-party binding software.

## The Solution

**PunchThrough** programmatically binds these physical mouse clicks (along with modifiers like Shift, Ctrl, and Alt) to trigger specific Action Bar slots (e.g. `MultiBarBottomLeftButton12`). This forces the clicks to "punch through" the secure frame barrier and trigger whatever ability is placed on that slot.

---

## Features

- **Blizzard Options Integration:** Fully integrated options panel located under *Options -> AddOns -> Raidframe Punch-Through*.
- **Dynamic Mappings List:** Add, configure, and delete as many custom mouse mappings as you need.
- **Modifier Support:** Supports `None`, `Shift`, `Ctrl`, and `Alt` modifiers.
- **Combat Safety:** Keybindings in WoW are restricted during combat. PunchThrough detects when you are in combat, warns you, and safely defers applying your settings until you exit combat (listening to `PLAYER_REGEN_ENABLED`).
- **Session Cleanup:** Clears old bindings set by the addon during the current session when you modify or delete them, keeping your bindings clean.
- **CurseForge Packaging Ready:** Includes `.pkgmeta` for automatic dependency resolution on CurseForge releases.

---

## Usage

1. Open the configuration panel by typing **`/pt`** or **`/punchthrough`** in chat.
2. In-game, type **`/fstack`** and hover your mouse cursor over the action slot you want to bind to check its internal frame name (e.g., `MultiBarBottomLeftButton12` or `MultiBarLeftButton10`). Type `/fstack` again to turn it off.
3. In the PunchThrough settings, click **Add New Mapping**.
4. Set the modifier, the mouse button (Mouse 4 or 5), and paste the action slot frame name.
5. Click **Apply & Save Changes** (outside of combat).

---

## Local Development & Testing

If you cloned this repository directly and want to test it locally:

1. **Fetch Dependencies:**
   Run the helper script in the repository root to download `LibStub`, `CallbackHandler-1.0`, and the required `Ace3` library modules:
   ```bash
   ./fetch_libs.sh
   ```
2. **Install the Addon:**
   Copy or symlink the `PunchThrough` folder into your WoW retail `AddOns` directory:
   ```bash
   cp -r PunchThrough "/path/to/World of Warcraft/_retail_/Interface/AddOns/"
   ```
