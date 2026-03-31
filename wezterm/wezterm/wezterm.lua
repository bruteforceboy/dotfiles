local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

config.window_background_opacity = 0.97
config.inactive_pane_hsb = {
	saturation = 0.58,
	brightness = 0.50,
}

config.window_padding = {
	left = 10,
	right = 10,
	top = 8,
	bottom = 8,
}

config.colors = {
	foreground = "#7F88A8",
	background = "#0F1220",
	cursor_bg = "#C8D0F0",
	cursor_border = "#C8D0F0",
	selection_bg = "#23293D",
	selection_fg = "#FFFFFF",

	ansi = {
		"#0F1220",
		"#C95B65",
		"#6FA77E",
		"#B79B52",
		"#4F73C9",
		"#9F73C9",
		"#5FAFB7",
		"#9AA3C6",
	},

	brights = {
		"#31384F",
		"#E97B84",
		"#86C793",
		"#D7BF76",
		"#7092E6",
		"#B88BDC",
		"#79CCD4",
		"#F2F4FF",
	},

	tab_bar = {
		background = "#0B0E18",
		active_tab = {
			bg_color = "#171B29",
			fg_color = "#EEF0F8",
		},
		inactive_tab = {
			bg_color = "#0B0E18",
			fg_color = "#66708F",
		},
		inactive_tab_hover = {
			bg_color = "#20263A",
			fg_color = "#FFFFFF",
		},
		new_tab = {
			bg_color = "#0B0E18",
			fg_color = "#66708F",
		},
		new_tab_hover = {
			bg_color = "#20263A",
			fg_color = "#FFFFFF",
		},
	},
}

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
	local title = tab.active_pane.title or "Pane"
	title = wezterm.truncate_right(title, max_width - 2)
	return { { Text = " " .. title .. " " } }
end)

return config
