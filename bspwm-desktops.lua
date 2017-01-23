--this is a lua script for use in conky
require 'cairo'

function conky_bspwm_desktops(init_x, init_y, scale)

	if not scale then
		scale = 80
	end
	local gap = 3

	if conky_window == nil then
		return
	end
	local cs = cairo_xlib_surface_create(conky_window.display,
	conky_window.drawable,
	conky_window.visual,
	conky_window.width,
	conky_window.height)
	cairo = cairo_create(cs)
	cairo_set_antialias(cairo, CAIRO_ANTIALIAS_NONE)

	local file = io.popen("bspc wm -d")
	local output = file:read("*a")
	file:close()
	local json = require("dkjson")
	local tab = json.decode(output)

	local cx = init_x
	local cy = init_y

	local focusedNodeId = nil
	local focusHistory = tab.focusHistory
	if focusHistory then
		focusedNodeId = focusHistory[#focusHistory].nodeId
	end

	local monitor = tab.monitors[1]

	local focusedDesktopId = monitor.focusedDesktopId

	local monW = monitor.rectangle.width
	local monH = monitor.rectangle.height
	monW = monW - monitor.padding.left - monitor.padding.right
	monH = monH - monitor.padding.top - monitor.padding.bottom

	function round(number)
		return number
	end

	function draw_childs(root)


		if root.client then

			local coords
			if root.client.state == 'floating' then
				coords = root.client.floatingRectangle
			else
				coords = root.client.tiledRectangle
			end
			local x = cx + (coords.x - monitor.padding.left) / scale
			local y = cy + (coords.y - monitor.padding.top ) / scale
			local w = coords.width / scale
			local h = coords.height / scale

			cairo_rectangle(cairo, round(x), round(y), round(w), round(h))
			if root.id == focusedNodeId then
				cairo_set_source_rgba(cairo, 0.2, 0.85, 0.6, 0.8)
			elseif root.client.urgent then
				cairo_set_source_rgba(cairo, 0.85, 0.2, 0.6, 0.8)
			else
				cairo_set_source_rgba(cairo, 0.2, 0.45, 0.6, 0.5)
			end
			cairo_fill(cairo)

			cairo_set_line_width(cairo, 1)
			cairo_rectangle(cairo, round(x), round(y), round(w), round(h))
			cairo_set_source_rgba(cairo, 0.1, 0.1, 0.2, 1)
			cairo_stroke(cairo)

		end

		if root.firstChild then
			draw_childs(root.firstChild)
		end

		if root.secondChild then
			draw_childs(root.secondChild)
		end

	end

	cairo_set_line_width(cairo, 1.0)
	for index,desktop in pairs(monitor.desktops) do
		local dw = monW / scale
		local dh = monH / scale
		if cx + dw > conky_window.width then
			cx = init_x
			cy = math.floor(cy + dh + gap + 0.5)
		end

		cairo_set_source_rgba(cairo, 0.5, 0.5, 0.7, 0.2)
		cairo_rectangle(cairo, round(cx), round(cy), round(dw), round(dh))
		cairo_fill(cairo)

		-- draw shadow on focusedDesktopId
		if desktop.id == focusedDesktopId then
			cairo_rectangle(cairo, round(cx), round(cy), round(dw), round(dh))
			cairo_set_source_rgba(cairo, 0.1, 0.8, 0.2, 0.8)
			cairo_stroke(cairo)
			cairo_rectangle(cairo, round(cx-1), round(cy-1), round(dw+2), round(dh+2))
			cairo_set_source_rgba(cairo, 0.1, 0.8, 0.2, 0.5)
			cairo_stroke(cairo)
			cairo_rectangle(cairo, round(cx-2), round(cy-2), round(dw+4), round(dh+4))
			cairo_set_source_rgba(cairo, 0.1, 0.8, 0.2, 0.2)
			cairo_stroke(cairo)
		end

		-- draw childs (nodes)
		if desktop.root then
			draw_childs(desktop.root)
		end

		-- draw X on monocle
		if desktop.layout == "monocle" then
			cairo_set_antialias(cairo, CAIRO_ANTIALIAS_DEFAULT)
			cairo_move_to(cairo, round(cx), round(cy))
			cairo_rel_line_to(cairo, round(dw), round(dh))
			cairo_move_to(cairo, round(cx+dw), round(cy))
			cairo_rel_line_to(cairo, round(-dw), round(dh))
			cairo_set_source_rgba(cairo, 0, 0, 0, 0.3)
			cairo_set_line_width(cairo, 3);
			cairo_stroke(cairo)
			cairo_set_antialias(cairo, CAIRO_ANTIALIAS_NONE)
		end



		cx = math.floor(cx + dw + gap + 0.5)
	end

	cairo_destroy(cairo)
	cairo_surface_destroy(cs)
	cairo=nil

	return ""
end
