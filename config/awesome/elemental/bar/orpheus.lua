local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local apps = require("apps")

local keys = require("keys")
local helpers = require("helpers")

local math = require("math")

local padding = wibox.widget {
  forced_width = dpi(20),
  widget = wibox.widget.textbox() }

local time_widget = wibox.widget {
  font = "Monospace 11",
  align = "center",
  valign = "middle",
  widget = wibox.widget.textclock("%H:%M") }
time_widget.point = { x=936, y=(beautiful.wibar_height)/2 - 8 }

local battery_percentage_widget = wibox.widget {
  font = "Monospace 11",
  align = "left",
  valign = "middle",
  widget = wibox.widget.textbox() }
local battery_icon_widget = wibox.widget {
  font = "Monospace 13",
  align = "right",
  valign = "middle",
  widget = wibox.widget.textbox() }
local discharging_icons = { "", "", "", "", "", "", "", "", "", "", }
local charging_icons = { "", "", "", "", "", "", "", "", "", "", }
--local is_charging = true
--awesome.connect_signal("evil::plugged", function(value)
--    is_charging = value
--end)
awesome.connect_signal("evil::battery", function(value)
    awful.spawn.easy_async_with_shell("sh -c 'cat /sys/class/power_supply/ACAD/online'", function (stdout, _, __, exit_code)
        local icon_colour = x.foreground
        if stdout == "1\n" then
          icon_colour = x.color10
          battery_icon_widget.markup = "<span foreground='" .. icon_colour .."'>" .. charging_icons[math.floor(value/10)] .. "</span>"
          battery_icon_widget.font = "Monospace 20"
        else
          if value < 20 then
            icon_colour = x.color9
          end
          battery_icon_widget.markup = "<span foreground='" .. icon_colour .."'>" .. discharging_icons[math.floor(value/10)] .. "</span>"
          battery_icon_widget.font = "Monospace 13"
        end

        battery_percentage_widget.markup = "<span foreground='" .. x.foreground .."'> " .. tostring(value) .. "%</span>"
    end)
end)

local volume_percentage_widget = wibox.widget {
  font = "Monospace 11",
  align = "left",
  valign = "middle",
  widget = wibox.widget.textbox() }
local volume_icon_widget = wibox.widget {
  font = "icomoon 14",
  align = "right",
  valign = "middle",
  widget = wibox.widget.textbox() }
awesome.connect_signal("evil::volume", function(level, muted)
  if muted or level == 0 then
    volume_percentage_widget.markup = "<span></span>"
    volume_icon_widget.markup = "<span foreground='" .. x.foreground .. "'></span>"
  else
    volume_percentage_widget.markup = "<span foreground='" .. x.foreground .. "'> " .. tostring(level) .. "%</span>"
    if level < 33 then
      volume_icon_widget.markup = "<span foreground='" .. x.foreground .. "'></span>"
    elseif level < 67 then
      volume_icon_widget.markup = "<span foreground='" .. x.foreground .. "'></span>"
    else
      volume_icon_widget.markup = "<span foreground='" .. x.foreground .. "'></span>"
    end
  end
end)
volume_percentage_widget:buttons(gears.table.join(
    -- Left click - Mute / Unmute
    awful.button({ }, 1, function ()
        helpers.volume_control(0)
    end)
))
volume_icon_widget:buttons(gears.table.join(
    -- Left click - Mute / Unmute
    awful.button({ }, 1, function ()
        helpers.volume_control(0)
    end)
))

local network_text_widget = wibox.widget {
    font = "Monospace 11",
    align = "left",
    valign = "middle",
    text = "boi",
    widget = wibox.widget.textbox() }
local network_icon_widget = wibox.widget {
    font = "icomoon 14",
    align = "right",
    valign = "middle",
    text = "",
    widget = wibox.widget.textbox() }
network_text_widget:buttons(gears.table.join(
    -- Left click - Mute / Unmute
    awful.button({ }, 1, function ()
        helpers.run_or_raise({class = 'nm-connection-editor'}, false, "nm-connection-editor", { switchtotag = true })
    end)
))
network_icon_widget:buttons(gears.table.join(
    -- Left click - Mute / Unmute
    awful.button({ }, 1, function ()
        helpers.run_or_raise({class = 'nm-connection-editor'}, false, "nm-connection-editor", { switchtotag = true })
    end)
))

local power_menu_widget = wibox.widget {
  font = "icomoon bold 11",
  align = "center",
  valign = "middle",
  text = "",
  widget = wibox.widget.textbox() }
power_menu_widget:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        exit_screen_show()
    end)
))


--local brightness_icon_widget = wibox.widget {
--  font = "Monospace 20",
--  align = "left",
--  valign = "middle",
--  margin = dpi(200),
--  text = "",
--  widget = wibox.widget.textbox() }
--brightness_icon_widget:buttons(gears.table.join(
--   awful.button({ }, 1, function ()
--        awesome.emit_signal("evil::togglebrightnessslider")
--    end)
--))

local tag_colors_empty = { x.color0, x.color0, x.color0, x.color0, x.color0, x.color0, x.color0, x.color0, x.color0, x.color0, }

local tag_colors_urgent = {
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background
}

local tag_colors_focused = {
    x.color1,
    x.color5,
    x.color4,
    x.color6,
    x.color2,
    x.color3,
    x.color1,
    x.color5,
    x.color4,
    x.color6,
}

local tag_colors_occupied = {
    x.color1.."55",
    x.color5.."55",
    x.color4.."55",
    x.color6.."55",
    x.color2.."55",
    x.color3.."55",
    x.color1.."55",
    x.color5.."55",
    x.color4.."55",
    x.color6.."55",
}

-- Helper function that updates a taglist item
local update_taglist = function (item, tag, index)
    if tag.selected then
        item.bg = tag_colors_focused[index]
    elseif tag.urgent then
        item.bg = tag_colors_urgent[index]
    elseif #tag:clients() > 0 then
        item.bg = tag_colors_occupied[index]
    else
        item.bg = tag_colors_empty[index]
    end
end

awful.screen.connect_for_each_screen(function(s)
--    s.brightness_slider = wibox.widget {
--        bar_shape           = gears.shape.rounded_rect,
--        bar_height          = 3,
--        bar_color           = beautiful.border_color,
--        handle_color        = beautiful.bg_normal,
--        handle_shape        = gears.shape.circle,
--        handle_border_color = beautiful.border_color,
--        handle_border_width = 1,
--        value               = 25,
--        widget              = wibox.widget.slider }
--    s.brightness_slider_container = wibox.widget {
--      brightness_slider,
--      bg = bg_color,
--      widget = wibox.container.background }
--    awesome.connect_signal("evil::togglebrightnessslider", function()
--      s.brightness_slider.visible = true;
--    end)

    -- Create a taglist for every screen
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = keys.taglist_buttons,
        layout = wibox.layout.flex.horizontal,
        widget_template = {
            widget = wibox.container.background,
            create_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
            update_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
        }
    }

    -- Create a tasklist for every screen
    s.mytasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = keys.tasklist_buttons,
        style    = {
            font = beautiful.tasklist_font,
            bg = x.color0,
        },
        layout   = {
            -- spacing = dpi(10),
            -- layout  = wibox.layout.fixed.horizontal
            layout  = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    id     = 'text_role',
                    align  = "center",
                    widget = wibox.widget.textbox,
                },
                forced_width = dpi(220),
                left = dpi(15),
                right = dpi(15),
                -- Add margins to top and bottom in order to force the
                -- text to be on a single line, if needed. Might need
                -- to adjust them according to font size.
                top  = dpi(4),
                bottom = dpi(4),
                widget = wibox.container.margin
            },
            -- shape = helpers.rrect(dpi(8)),
            -- border_width = dpi(2),
            id = "bg_role",
            -- id = "background_role",
            -- shape = gears.shape.rounded_bar,
            widget = wibox.container.background,
        },
    }


    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox.resize = true
    s.mylayoutbox.forced_width  = beautiful.wibar_height - dpi(5)
    s.mylayoutbox.forced_height = beautiful.wibar_height - dpi(5)
    s.mylayoutbox:buttons(gears.table.join(
    awful.button({ }, 1, function () awful.layout.inc( 1) end),
    awful.button({ }, 3, function () awful.layout.inc(-1) end),
    awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create the wibox
    s.mywibox = awful.wibar({screen = s, visible = true, ontop = true, type = "dock", position = "top"})
    s.mywibox.height = beautiful.wibar_height
    -- s.mywibox.width = beautiful.wibar_width

    -- For antialiasing
    -- The actual background color is defined in the wibar items
    -- s.mywibox.bg = "#00000000"

    -- s.mywibox.bg = x.color8
    -- s.mywibox.bg = x.foreground
    -- s.mywibox.bg = x.background.."88"
    -- s.mywibox.bg = x.background
    s.mywibox.bg = x.color0

    -- Bar placement
    awful.placement.maximize_horizontally(s.mywibox)

    -- Wibar items
    -- Add or remove widgets here
    s.mywibox:setup {
        nil,
        {
          time_widget,
          layout = wibox.layout.manual
        },
        {
            
            volume_icon_widget,
            volume_percentage_widget,
            padding,
            --network_icon_widget,
            --network_text_widget,
            --padding,
            battery_icon_widget,
            battery_percentage_widget,
            padding,
            power_menu_widget,
            padding,
            layout = wibox.layout.fixed.horizontal
        },
        -- expand = "none",
        layout = wibox.layout.align.horizontal
    }


    -- Create the top bar
    s.mytopwibox = awful.wibar({screen = s, visible = true, ontop = false, type = "dock", position = "top", height = dpi(5)})
    -- Bar placement
    awful.placement.maximize_horizontally(s.mytopwibox)
    s.mytopwibox.bg = "#00000000"

    s.mytopwibox:setup {
        widget = s.mytaglist,
    }

    -- Create a system tray widget
    s.systray = wibox.widget.systray()

    -- Create a wibox that will only show the tray
    -- Hidden by default. Can be toggled with a keybind.
    s.traybox = wibox({visible = false, ontop = true, type = "normal"})
    s.traybox.width = dpi(120)
    s.traybox.height = beautiful.wibar_height
    awful.placement.bottom_left(s.traybox, {honor_workarea = true, margins = beautiful.screen_margin * 2})
    s.traybox.bg = "#00000000"
    s.traybox:setup {
        s.systray,
        bg = beautiful.bg_systray,
        shape = helpers.rrect(beautiful.border_radius),
        widget = wibox.container.background()
    }

    s.traybox:buttons(gears.table.join(
    -- Middle click - Hide traybox
    awful.button({ }, 2, function ()
        s.traybox.visible = false
    end)
    ))
    -- Hide traybox when mouse leaves
    s.traybox:connect_signal("mouse::leave", function ()
        s.traybox.visible = false
    end)

    -- Place bar at the bottom and add margins
    -- awful.placement.bottom(s.mywibox, {margins = beautiful.screen_margin * 2})
    -- Also add some screen padding so that clients do not stick to the bar
    -- For "awful.wibar"
    -- s.padding = { bottom = s.padding.bottom + beautiful.screen_margin * 2 }
    -- For "wibox"
    -- s.padding = { bottom = s.mywibox.height + beautiful.screen_margin * 2 }

end)

-- We have set the wibar(s) to be ontop, but we do not want it to be above fullscreen clients
local function no_wibar_ontop(c)
    local s = awful.screen.focused()
    if c.fullscreen then
        s.mywibox.ontop = false
    else
        s.mywibox.ontop = true
    end
end

client.connect_signal("focus", no_wibar_ontop)
client.connect_signal("unfocus", no_wibar_ontop)
client.connect_signal("property::fullscreen", no_wibar_ontop)

-- Every bar theme should provide these fuctions
function wibars_toggle()
    local s = awful.screen.focused()
    s.mywibox.visible = not s.mywibox.visible
    s.mytopwibox.visible = not s.mytopwibox.visible
end

function tray_toggle()
    local s = awful.screen.focused()
    s.traybox.visible = not s.traybox.visible
end
