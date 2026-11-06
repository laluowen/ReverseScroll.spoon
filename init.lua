--- === ReverseScroll ===
---
--- Toggles the system-wide natural scrolling setting by driving System Settings.
--- Applies to trackpad and mouse alike, so it works for forwarded input such as Deskflow.
---
--- Features:
---   - Toggle natural scrolling with a hotkey (optional)
---   - Menubar icon shows current state: scroll (natural on) or crossed-out scroll (natural off)
---   - Optional on-screen alerts when toggling
---   - Runs the UI script asynchronously, so Hammerspoon stays responsive
---
--- Example:
---   hs.loadSpoon("ReverseScroll")
---   spoon.ReverseScroll:configure{
---     hotkey = {{"ctrl", "shift"}, "N"},
---     enableMenubar = true,
---     enableAlert = true
---   }

--- === ReverseScroll:configure ===
--- Method
--- Configures the ReverseScroll Spoon and binds the hotkey.
---
--- Parameters:
---  * opts - A table of options:
---    * hotkey (table) - Hotkey to toggle natural scrolling (default: nil)
---    * enableMenubar (boolean) - Show menubar icon (default: true)
---    * enableAlert (boolean) - Show alert when toggling (default: false)
---    * menuIconTemplate (boolean) - Render the menubar icon as a template so macOS tints it to the menubar colour. The crossed-out state becomes a gap in the silhouette (default: false)

--- === ReverseScroll:toggle ===
--- Method
--- Flips natural scrolling on or off. Ignored while a previous toggle is still running.

local obj = {}
obj.__index = obj

obj.name = "ReverseScroll"
obj.version = "27.2"
obj.author = "laluowen"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/laluowen/ReverseScroll.spoon"

obj.hotkey = nil
obj.enableMenubar = true
obj.enableAlert = false
obj.menuIconTemplate = false
obj.menuItem = nil
obj.natural = true
obj.running = false
obj.task = nil

local script = [[
set timeoutTries to 50

open location "x-apple.systempreferences:com.apple.Trackpad-Settings.extension"

tell application "System Events"
	tell application process "System Settings"
		set tries to 0
		repeat until window 1 exists
			delay 0.1
			set tries to tries + 1
			if tries > timeoutTries then error "System Settings window did not appear"
		end repeat

		set pane to group 3 of splitter group 1 of group 1 of window 1

		set tries to 0
		repeat until exists tab group 1 of group 1 of pane
			delay 0.1
			set tries to tries + 1
			if tries > timeoutTries then error "Trackpad tab group did not appear"
		end repeat

		click checkbox 2 of tab group 1 of group 1 of pane
		delay 0.2

		click checkbox 1 of group 1 of scroll area 1 of group 1 of pane
		delay 0.1

		set naturalState to value of checkbox 1 of group 1 of scroll area 1 of group 1 of pane
	end tell
end tell

tell application "System Settings" to quit

return naturalState
]]

local function renderIcon(emoji, points, strike, template)
  local px = points * 2
  local canvas = hs.canvas.new({ x = 0, y = 0, w = px, h = px })
  canvas[1] = { type = "text", text = emoji, textSize = px * 0.78, frame = { x = 0, y = px * 0.05, w = px, h = px }, textAlignment = "center" }
  if strike then
    canvas[2] = {
      type = "segments",
      coordinates = { { x = px * 0.08, y = px * 0.08 }, { x = px * 0.92, y = px * 0.92 } },
      strokeColor = { red = 0.9, green = 0.1, blue = 0.1, alpha = 1 },
      strokeWidth = px * 0.14,
      action = "stroke",
    }
    if template then
      canvas[2].compositeRule = "destinationOut"
    end
  end
  local image = canvas:imageFromCanvas()
  canvas:delete()
  image:size({ w = points, h = points }, true)
  image:template(template)
  return image
end

function obj:updateMenu()
  if not self.menuItem then return end
  self.menuItem:setTitle(nil)
  self.menuItem:setIcon(self.natural and self.icons.on or self.icons.off, self.menuIconTemplate)
end

function obj:setNatural(on)
  self.natural = on
  self:updateMenu()
  if self.enableAlert then
    local icon = on and self.alertIcons.on or self.alertIcons.off
    hs.alert.showWithImage("Natural scrolling: " .. (on and "on" or "off"), icon)
  end
end

function obj:readInitialState()
  local out = hs.execute("defaults read -g com.apple.swipescrolldirection 2>/dev/null")
  local value = out and out:gsub("%s+", "")
  if value == "0" then
    self.natural = false
  else
    self.natural = true
  end
end

function obj:toggle()
  if self.running then return self end
  self.running = true
  self.task = hs.task.new("/usr/bin/osascript", function(exitCode, stdOut, stdErr)
    self.running = false
    self.task = nil
    if exitCode ~= 0 then
      print("ReverseScroll error: " .. tostring(stdErr))
      hs.alert.show("ReverseScroll failed, see console")
      return
    end
    print("ReverseScroll readback: " .. tostring(stdOut))
    self:setNatural(tostring(stdOut):gsub("%s+", "") == "1")
  end, { "-e", script })
  self.task:start()
  return self
end

function obj:start()
  self.icons = {
    on = renderIcon("📜", 18, false, self.menuIconTemplate),
    off = renderIcon("📜", 18, true, self.menuIconTemplate),
  }
  self.alertIcons = {
    on = renderIcon("📜", 64, false, false),
    off = renderIcon("📜", 64, true, false),
  }
  self:readInitialState()

  if self.enableMenubar then
    self.menuItem = hs.menubar.new()
    if self.menuItem then
      self.menuItem:setClickCallback(function() self:toggle() end)
      self:updateMenu()
    end
  end
  return self
end

function obj:bindHotkeys(mapping)
  if mapping and mapping.toggle then
    hs.hotkey.bind(mapping.toggle[1], mapping.toggle[2], function() self:toggle() end)
  end
  return self
end

function obj:init()
  -- For compatibility with SpoonInstall
end

function obj:configure(opts)
  if opts then
    if opts.hotkey then self.hotkey = opts.hotkey end
    if opts.enableMenubar ~= nil then self.enableMenubar = opts.enableMenubar end
    if opts.enableAlert ~= nil then self.enableAlert = opts.enableAlert end
    if opts.menuIconTemplate ~= nil then self.menuIconTemplate = opts.menuIconTemplate end
  end

  self:start()
  if self.hotkey then
    self:bindHotkeys({ toggle = self.hotkey })
  end
  return self
end

return obj
