-- Variables
local keys = {}

local mod = 'Mod4'
local tags = 7
keys.tags = tags

local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")


terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
editor_gui = "code-insiders"
web_browser = os.getenv("BROWSER")

-- Keybindings
keys.globalkeys = gears.table.join(
  -- Awesome
  awful.key({mod, 'Shift'}, 'r', awesome.restart),
  awful.key({mod}, 'd', function() dashboard.toggle() end),
  awful.key({mod, 'Shift'}, 'e', awesome.quit),
  awful.key({mod, 'Shift'}, 'l', function() awful.util.spawn('sh ~/.local/bin/lock') end),
  awful.key({ mod,           }, "s",      hotkeys_popup.show_help,
  {description="show help", group="awesome"}),

  --Hardware
  awful.key({}, 'XF86MonBrightnessUp', function() awful.spawn.with_shell('xbacklight +5') end),
  awful.key({}, 'XF86MonBrightnessDown', function() awful.spawn.with_shell('xbacklight -5') end),
  awful.key({}, 'XF86AudioRaiseVolume', function() awful.spawn.with_shell('pactl set-sink-volume @DEFAULT_SINK@ +5%') end),
  awful.key({}, 'XF86AudioLowerVolume', function() awful.spawn.with_shell('pactl set-sink-volume @DEFAULT_SINK@ -4%') end),

  -- Window management
  awful.key({'Mod1'}, 'Tab', function() awful.client.focus.byidx(1) end),
  awful.key({mod, "Shift"}, 'Right', function () awful.tag.incmwfact(0.025) end),
  awful.key({mod, "Shift"}, 'Left', function () awful.tag.incmwfact(-0.025) end),
  awful.key({mod, "Shift"}, 'Up', function () awful.client.incwfact(0.05) end),
  awful.key({mod, "Shift"}, 'Down', function () awful.client.incwfact(-0.05) end),

  -- Applications
  awful.key({mod}, 'Return', function() awful.util.spawn(terminal) end),
  awful.key({mod}, 'r', function() awful.util.spawn('rofi -show drun') end),
  awful.key({ mod,           }, "c", function () awful.spawn(editor_gui) end,
          { description = "Open text editor with gui", group = "launcher" }
  ),
  awful.key({ mod,           }, "b", function () awful.spawn(web_browser) end,
          { description = "Open OS default web browser", group = "launcher" }
  ),
  awful.key({ mod,           }, "*", function () awful.spawn("discord") end,
          { description = "Open discord", group = "launcher" }
  ),
  awful.key({ mod, "Shift"  }, "p", function () awful.spawn("spotify") end,
          { description = "Open spotify", group = "launcher" }
  ),

  -- Screenshots
  awful.key({}, 'Print', function() awful.util.spawn('flameshot gui') end)
)

-- -- Keyboard Control
-- keys.clientkeys = gears.table.join(
--   awful.key({mod}, 'q', function(c) c:kill() end),
--   awful.key({mod}, 'space', function(c) c.fullscreen = not c.fullscreen; c:raise() end),
--   awful.key({mod}, 'Tab', function() awful.client.floating.toggle() end)
-- )

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
  awful.key({ mod,           }, "Left",   awful.tag.viewprev,
            {description = "view previous", group = "tag"}),
  awful.key({ mod,           }, "Right",  awful.tag.viewnext,
            {description = "view next", group = "tag"}),
  awful.key({ mod,           }, "Escape", awful.tag.history.restore,
            {description = "go back", group = "tag"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
  awful.key({ mod,           }, "j",
      function ()
          awful.client.focus.byidx( 1)
      end,
      {description = "focus next by index", group = "client"}
  ),
  awful.key({ mod,           }, "k",
      function ()
          awful.client.focus.byidx(-1)
      end,
      {description = "focus previous by index", group = "client"}
  ),
  awful.key({ mod,           }, "Tab",
      function ()
          awful.client.focus.history.previous()
          if client.focus then
              client.focus:raise()
          end
      end,
      {description = "go back", group = "client"}),
  awful.key({ mod, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
            {description = "focus the next screen", group = "screen"}),
  awful.key({ mod, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
            {description = "focus the previous screen", group = "screen"}),
  awful.key({ mod, "Control" }, "n",
            function ()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                  c:activate { raise = true, context = "key.unminimize" }
                end
            end,
            {description = "restore minimized", group = "client"}),
})


-- Mouse controls
keys.clientbuttons = gears.table.join(
  awful.button({}, 1, function(c) client.focus = c end),
  awful.button({mod}, 1, function() awful.mouse.client.move() end),
  awful.button({mod}, 2, function(c) c:kill() end),
  awful.button({mod}, 3, function() awful.mouse.client.resize() end)
)

for i = 1, tags do
  keys.globalkeys = gears.table.join(keys.globalkeys,

  -- View tag
  awful.key({mod}, '#'..i + 9,
    function ()
      local tag = awful.screen.focused().tags[i]
      if tag then
         tag:view_only()
      end
    end),

  -- Move window to tag
  awful.key({mod, 'Shift'}, '#'..i + 9,
    function ()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:move_to_tag(tag)
        end
     end
    end))
end

client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({
      awful.key({ mod,           }, "f",
          function (c)
              c.fullscreen = not c.fullscreen
              c:raise()
          end,
          {description = "toggle fullscreen", group = "client"}),
      awful.key({ mod, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
      awful.key({ mod, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
      awful.key({ mod, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
      awful.key({ mod,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
      awful.key({ mod,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
      awful.key({ mod,           }, "n",
          function (c)
              -- The client currently has the input focus, so it cannot be
              -- minimized, since minimized clients can't have the focus.
              c.minimized = true
          end ,
          {description = "minimize", group = "client"}),
      awful.key({ mod,           }, "m",
          function (c)
              c.maximized = not c.maximized
              c:raise()
          end ,
          {description = "(un)maximize", group = "client"}),
      awful.key({ mod, "Control" }, "m",
          function (c)
              c.maximized_vertical = not c.maximized_vertical
              c:raise()
          end ,
          {description = "(un)maximize vertically", group = "client"}),
      awful.key({ mod, "Shift"   }, "m",
          function (c)
              c.maximized_horizontal = not c.maximized_horizontal
              c:raise()
          end ,
          {description = "(un)maximize horizontally", group = "client"}),
  })
end)

-- }}}

-- Set globalkeys
root.keys(keys.globalkeys)

return keys
