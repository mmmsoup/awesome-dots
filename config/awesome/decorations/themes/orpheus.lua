local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local keys = require("keys")
local decorations = require("decorations")

-- This decoration theme will round clients according to your theme's
-- border_radius value
decorations.enable_rounding()

local gen_button_size = dpi(8)
local gen_button_margin = dpi(8)
local gen_button_shape = gears.shape.circle
local gen_button_color_unfocused = x.color8

-- Add a titlebar
client.connect_signal("request::titlebars", function(c)
    local title_widget = wibox.widget.textbox("")
    if beautiful.titlebar_title_enabled and c.name ~= "<unknown>" then
        title_widget = awful.titlebar.widget.titlewidget(c)
    end

    awful.titlebar(c, {font = beautiful.titlebar_font, position = beautiful.titlebar_position, size = beautiful.titlebar_size}) : setup {
        nil,
        {
            buttons = keys.titlebar_buttons,
            font = beautiful.titlebar_font,
            align = beautiful.titlebar_title_align or "center",
            widget = title_widget
        },
        {
            decorations.text_button(c, "", "Material Icons 16", x.color2, gen_button_color_unfocused, x.color10, gen_button_size, gen_button_margin, "maximize"),
            decorations.text_button(c, "", "Material Icons 16", x.color3, gen_button_color_unfocused, x.color11, gen_button_size, gen_button_margin, "minimize"),
            decorations.text_button(c, "", "Material Icons 16", x.color1, gen_button_color_unfocused, x.color9, gen_button_size, gen_button_margin, "close"),

            -- Create some extra padding at the edge
            helpers.horizontal_pad(dpi(3)),

            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end)
