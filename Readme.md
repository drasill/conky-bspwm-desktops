# Conky - bspwm-desktops
Draws desktop of BSPWM in a conky panel.

![4x5](/screenshots/4x5.png?raw=true "Vertical Conky")

A vertical conky, scale = 80

![1x20](/screenshots/1x20.png?raw=true "Horizontal Conky")

An horizontal conky, scale = 40

# Installation

TIMTOWTDI, but for example :

```bash
cd
mkdir -p .config/conky/lua
cd .config/conky/lua
git clone https://github.com/drasill/conky-bspwm-desktops.git bspwm-desktops
```

## Dependencies

You'll need the `dkjson` lua package :

```bash
sudo luarocks install dkjson
```

# Usage

In your conky settings, simply add `lua_load` with the full path of
`bspwm-desktops`, and a call to the `bspwm-desktops` function.

```lua
conky.config = {
   -- ...
	lua_load = '~/.config/conky/lua/bspwm-desktops/bspwm-desktops.lua',
   -- ...
}

conky.text = [[
...
...
${desktop_name}
${lua bspwm-desktops 10 20 80}
...
...
...
]]
```

Arguments to `bspwm-desktops` are as follow :

`bspwm-desktops x y scale`

with :
* `x`, `y` : top-left position of the widget
* `scale` : desktop representation scale

For exemple, if your desktop have a `1920x1080` size, a `scale` of `80` will
display your desktops as `24x13` pixels rectangles.

Using conky's `$desktop_name` seems to be working, and is a nice addition.

## Layout

The script displays the desktops from left to right, then top to bottom,
depending on the conky panel's width.

# Contributions

... are very welcome !

But the code is really quick'n dirty, even if simple.



