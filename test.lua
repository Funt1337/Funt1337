local ffi = require('ffi')
local bit = require('bit')
local vector = require('vector')
local csgo_weapons = require("gamesense/csgo_weapons")
local images = require('gamesense/images')
---@diagnostic disable: undefined-global
if database.read('[NeverHit] preset list') == nil then
    database.write('[NeverHit] preset list', { [1] = "Main" })
end






database.write('[NeverHit] Main preset', 'true|Default|At targets|Default|20|0|0|Off|0|Static|0|-|false|3|Wall Direction|Peek Fake|20|Default|60|60|20|0|true|Minimal|At targets|According Side|20|-7|17|Center|50|Jitter|0|Anti-Bruteforce|true|1|Wall Direction|Peek Fake|20|Default|59|60|20|0|true|Minimal|At targets|According Side|7|-5|7|Center|46|Jitter|0|Anti-Bruteforce|true|1|Dmg Threat|Peek Fake|20|Default|60|5|11|0|true|Minimal|At targets|According Side|20|-7|17|Center|50|Jitter|0|Anti-Bruteforce|true|1|Wall Direction|Peek Fake|20|Default|59|10|20|0|true|Minimal|At targets|According Side|20|-5|15|Center|40|Jitter|0|Anti-Bruteforce|true|1|Wall Direction|Peek Fake|20|Default|59|60|20|0|true|Minimal|At targets|According Side|20|-5|10|Center|45|Jitter|0|Anti-Bruteforce|true|1|Wall Direction|Peek Fake|20|Default|60|60|20|0|true|Minimal|At targets|According Side|20|-7|15|Center|70|Jitter|0|-|true|1|Wall Direction|Peek Fake|20|Default|60|60|20|0|true|Off|Local view|Default|20|180|0|Off|0|Static|180|Anti-Bruteforce,Freestanding|false|2|Wall Direction|Peek Real|20|Default|60|60|20|0|false|Off|Local view|Default|20|0|0|Off|0|Off|0|-|false|3|Wall Direction|Peek Fake|20|Default|60|60|20|0|false|Off|Local view|Default|11|0|0|Off|0|Off|0|-|false|3|Wall Direction|Peek Fake|20|Default|60|60|20|0|false|Off|Local view|Default|20|0|0|Off|0|Off|0|-|false|3|Wall Direction|Peek Fake|20|Default|60|60|20|0|false|Off|Local view|Default|20|0|0|Off|0|Off|0|-|false|3|Wall Direction|Peek Fake|20|Default|60|60|20|0|')

local cache = database.read('[NeverHit] preset list')

local refs = {
    enable_ragebot = { ui.reference("RAGE", "Aimbot", "Enabled") },
    fake_duck = ui.reference("RAGE","Other","Duck peek assist"),
    min_dmg = ui.reference("RAGE", "Aimbot", "Minimum damage"),
    pitch = ui.reference("AA","Anti-aimbot angles","Pitch"),
    yaw_target = ui.reference("AA","Anti-aimbot angles","Yaw Base"),
    fs = { ui.reference("AA","Anti-aimbot angles","Freestanding") },
    os_aa = { ui.reference("AA","Other","On shot anti-aim") },
    yaw = { ui.reference("AA","Anti-aimbot angles","Yaw") },
    jyaw = { ui.reference("AA","Anti-aimbot angles","Yaw Jitter") },
    byaw = { ui.reference("AA","Anti-aimbot angles","Body yaw") },
    fs_body_yaw = ui.reference("AA","Anti-aimbot angles","Freestanding body yaw"),
    fake_yaw = ui.reference("AA","Anti-aimbot angles","Fake yaw limit"),
    edge_yaw = ui.reference("AA","Anti-aimbot angles","Edge yaw"),
    slowwalk = { ui.reference("AA","Other","Slow motion") },
    sw_type = ui.reference("AA","Other","Slow motion type"),
    lm = ui.reference("AA","Other","Leg movement"),
    enablefl = ui.reference("AA","Fake lag","Enabled"),
    fl_amount = ui.reference("AA", "Fake lag", "Amount"),
    fl_limit = ui.reference("AA","Fake lag","Limit"),
    fl_var = ui.reference("AA", "fake lag", "variance"),
    dt = { ui.reference("RAGE", "Other", "Double tap") },
    dt_mode = ui.reference("RAGE", "Other", "Double tap mode"),
    dt_fl = ui.reference("RAGE", "Other", "Double tap fake lag limit"),
    roll_aa = ui.reference("AA","Anti-aimbot angles", "Roll"),
    tp = { ui.reference("VISUALS","Effects","Force third person (alive)") },
    qp = { ui.reference("RAGE", "Other", "Quick peek assist") },
    qp_mode = ui.reference("RAGE", "Other", "Quick peek assist mode"),
    g_fov = ui.reference("MISC", "Miscellaneous", "Override FOV"),
    z_fov = ui.reference("MISC", "Miscellaneous", "Override zoom FOV"),
    rs = ui.reference("CONFIG","Lua","Reload active scripts"),
    ascope = ui.reference("RAGE", "Aimbot","Automatic Scope"),
    force_sp = ui.reference("RAGE", "Aimbot", "Force safe point"),
    prefer_sp = ui.reference("RAGE", "Aimbot", "Prefer safe point"),
    fake_ping = { ui.reference("MISC", "Miscellaneous", "Ping spike") }
}

local funcs = {
    enable = ui.new_checkbox("AA", "Anti-aimbot angles", "Enable"),
    lua_text = ui.new_label("AA", "Anti-aimbot angles", "NNSENSEYAW anti-aim system"),
    old_lua_text = ui.new_label("AA", "Anti-aimbot angles", "Powered by \a82B1ECFFNN1337NN"),
    tab_select = ui.new_combobox("AA", "Anti-aimbot angles", "Tab Selection", "Anti-Aim", "Visuals", "Config"),
    anti_aim = {
        features = ui.new_multiselect("AA", "Anti-aimbot angles", "Features", "[Yaw Management]", "[Anti-Aim on Use]"),
        freestand_key = ui.new_hotkey("AA", "Anti-aimbot angles", "Freestand"),
        disable_freestand = ui.new_multiselect("AA", "Anti-aimbot angles", "Disable Freestand", "Standing", "Moving", "Slow-motion", "Air", "Crouching", "Head hittable"),
        edgeyaw_key = ui.new_hotkey("AA", "Anti-aimbot angles", "Edge yaw"),
        disable_edgeyaw = ui.new_multiselect("AA", "Anti-aimbot angles", "Disable Edge yaw", "Standing", "Moving", "Slow-motion", "Air", "Crouching", "Fake duck", "Head hittable"),
        left_key = ui.new_hotkey("AA","Anti-aimbot angles", "Left"),
        right_key = ui.new_hotkey("AA","Anti-aimbot angles", "Right"),
        back_key = ui.new_hotkey("AA","Anti-aimbot angles", "Back"),
        forward_key = ui.new_hotkey("AA","Anti-aimbot angles", "Forward"),
        legit_key = ui.new_hotkey("AA","Anti-aimbot angles", "Legit AA"),
        tab_cond = ui.new_combobox("AA", "Anti-aimbot angles", "Condition Tab", "Global", "Standing", "Moving", "Slow-motion", "Air", "Air-Crouch", "Crouching", "Legit-key", "Dormant", "High Ground", "Lethal", "On Shot"),
    },
    visuals = {
        ui_ind = ui.new_multiselect("AA","Anti-aimbot angles", "UI Indicators", "Watermark", "Keybinds", "Spectators"),
        ui_style = ui.new_checkbox("AA", "Anti-aimbot angles", "UI Enable Glow [low fps warning]"),
        debug_panel = ui.new_checkbox("AA", "Anti-aimbot angles", "Debug Panel"),
        center_ind = ui.new_checkbox("AA", "Anti-aimbot angles", "Enable Crosshair Indicators"),
        center_ind_style = ui.new_combobox("AA", "Anti-aimbot angles", "Crosshair Indicators Style", "First", "Second"),
        color_name = ui.new_label("AA", "Anti-aimbot angles", "Color"),
        color = ui.new_color_picker("AA","Anti-aimbot angles","RGBA",200, 170, 255, 255),
    },
}

local custom_aa = { }
local spaces = { [1] = "", [2] = " ", [3] = "  ", [4] = "   ", [5] = "    ", [6] = "     ", [7] = "      ", [8] = "       ", [9] = "        ", [10] = "         ", [11] = "          ", [12] = "           " }

for p = 1, 12 do 
    custom_aa[p] = {
        enabled = ui.new_checkbox("AA", "Anti-aimbot angles", "Enable Condition"..spaces[p]),
        pitch = ui.new_combobox("AA", "Anti-aimbot angles", "Pitch"..spaces[p], "Off", "Default", "Up", "Down", "Minimal", "Random"),  
        yaw_target = ui.new_combobox("AA", "Anti-aimbot angles", "Yaw base"..spaces[p], "Local view", "At targets"),
        yaw_mode = ui.new_combobox("AA", "Anti-aimbot angles", "Yaw Mode"..spaces[p], "Default", "According Side", "Flick", "Jitter", "Random"),
        yaw_slider_main = ui.new_slider("AA", "Anti-aimbot angles", "\n"..spaces[p], -180, 180, 0),
        yaw_slider_next = ui.new_slider("AA", "Anti-aimbot angles", "\n            "..spaces[p], -180, 180, 0),
        flick_delay = ui.new_slider("AA", "Anti-aimbot angles", "Flick delay"..spaces[p], 1, 50, 20, true, "t", 1),
        yaw_jitter = ui.new_combobox("AA", "Anti-aimbot angles", "Yaw jitter"..spaces[p], "Off", "Offset", "Center", "Random", "Proggresive"),
        yaw_jitter_slider = ui.new_slider("AA", "Anti-aimbot angles", "\n                        "..spaces[p], -180, 180, 0),
        yaw_body = ui.new_combobox("AA", "Anti-aimbot angles", "Body yaw"..spaces[p], "Off", "Jitter", "Static", "Opposite", "Randomize Jitter"),
        yaw_body_slider = ui.new_slider("AA", "Anti-aimbot angles", "\n                                    "..spaces[p], -180, 180, 0),
        additions = ui.new_multiselect("AA", "Anti-aimbot angles", "Additions"..spaces[p], "Anti-Bruteforce", "Freestanding", "Avoid Overlap", "Reset Angle"),
        highjitter_antibrute = ui.new_checkbox("AA", "Anti-aimbot angles", "Jitter Anti-Bruteforce"..spaces[p]),
        antibruteforce_time = ui.new_slider("AA", "Anti-aimbot angles", "Anti-Bruteforce Time"..spaces[p], 1, 5, 3, true, "s", 1),
        freestanding_mode = ui.new_combobox("AA", "Anti-aimbot angles", "Freestanding Mode"..spaces[p], "Wall Direction", "Dmg Threat"),
        freestanding_type = ui.new_combobox("AA", "Anti-aimbot angles", "Freestanding Type"..spaces[p], "Peek Fake", "Peek Real"),
        resetangle_ang = ui.new_slider("AA", "Anti-aimbot angles", "Angle to reset"..spaces[p], 0, 60, 20, true, "°", 1),
        fake_yaw_mode = ui.new_combobox("AA", "Anti-aimbot angles", "Fake yaw Mode"..spaces[p], "Default", "According Side", "Flick", "Jitter", "Random"),
        fake_slider_main = ui.new_slider("AA", "Anti-aimbot angles", "\n                                                "..spaces[p], 0, 60, 60, true, "°", 1),
        fake_slider_next = ui.new_slider("AA", "Anti-aimbot angles", "\n                                                            "..spaces[p], 0, 60, 60, true, "°", 1),
        flick_delay2 = ui.new_slider("AA", "Anti-aimbot angles", "Flick delay       "..spaces[p], 1, 50, 20, true, "t", 1),
        roll_slider = ui.new_slider("AA", "Anti-aimbot angles", "Roll"..spaces[p], -50, 50, 0, true, "°", 1),
    }
end

local vars = {
    bodyyaw = 0,
    shot_time = 0,
    cam_yaw_normalize_time = 0,
    cam_yaw_backup = 0,
    bruteforce_tick = 0,
    should_swap = 0,
    left_side = 0,
    right_side = 0,
    classnames = { "CWorld", "CCSPlayer", "CFuncBrush" },
    cur_alpha = 255,
    target_alpha = 0,
    max_alpha = 255,
    min_alpha = 0,
    speed = 0.04,
}

local rounding = 4
local o = 20
local rad = rounding + 2
local n = 45
local RoundedRect = function(x, y, w, h, radius, r, g, b, a) renderer.rectangle(x+radius,y,w-radius*2,radius,r,g,b,a)renderer.rectangle(x,y+radius,radius,h-radius*2,r,g,b,a)renderer.rectangle(x+radius,y+h-radius,w-radius*2,radius,r,g,b,a)renderer.rectangle(x+w-radius,y+radius,radius,h-radius*2,r,g,b,a)renderer.rectangle(x+radius,y+radius,w-radius*2,h-radius*2,r,g,b,a)renderer.circle(x+radius,y+radius,r,g,b,a,radius,180,0.25)renderer.circle(x+w-radius,y+radius,r,g,b,a,radius,90,0.25)renderer.circle(x+radius,y+h-radius,r,g,b,a,radius,270,0.25)renderer.circle(x+w-radius,y+h-radius,r,g,b,a,radius,0,0.25) end
local OutlineGlow = function(x, y, w, h, radius, r, g, b, a) renderer.rectangle(x+2,y+radius+rad,1,h-rad*2-radius*2,r,g,b,a)renderer.rectangle(x+w-3,y+radius+rad,1,h-rad*2-radius*2,r,g,b,a)renderer.rectangle(x+radius+rad,y+2,w-rad*2-radius*2,1,r,g,b,a)renderer.rectangle(x+radius+rad,y+h-3,w-rad*2-radius*2,1,r,g,b,a)renderer.circle_outline(x+radius+rad,y+radius+rad,r,g,b,a,radius+rounding,180,0.25,1)renderer.circle_outline(x+w-radius-rad,y+radius+rad,r,g,b,a,radius+rounding,270,0.25,1)renderer.circle_outline(x+radius+rad,y+h-radius-rad,r,g,b,a,radius+rounding,90,0.25,1)renderer.circle_outline(x+w-radius-rad,y+h-radius-rad,r,g,b,a,radius+rounding,0,0.25,1) end
local FadedRoundedGlow = function(x, y, w, h, radius, r, g, b, a, glow, r1, g1, b1) local n=a/255*n;renderer.rectangle(x+radius,y,w-radius*2,1,r,g,b,n)renderer.circle_outline(x+radius,y+radius,r,g,b,n,radius,180,0.25,1)renderer.circle_outline(x+w-radius,y+radius,r,g,b,n,radius,270,0.25,1)renderer.rectangle(x,y+radius,1,h-radius*2,r,g,b,n)renderer.rectangle(x+w-1,y+radius,1,h-radius*2,r,g,b,n)renderer.circle_outline(x+radius,y+h-radius,r,g,b,n,radius,90,0.25,1)renderer.circle_outline(x+w-radius,y+h-radius,r,g,b,n,radius,0,0.25,1)renderer.rectangle(x+radius,y+h-1,w-radius*2,1,r,g,b,n) for radius=4,glow do local radius=radius/2;OutlineGlow(x-radius,y-radius,w+radius*2,h+radius*2,radius,r1,g1,b1,glow-radius*2)end end
local container = function(x,y,w,h,r,g,b,a,box_a) if a*255>0 then renderer.blur(x, y, w, h) end; RoundedRect(x, y, w, h, rounding, 17, 17, 17, box_a); OutlineGlow(x-2, y-2, w+4, h+4, rounding-3, r, g, b, a) end
local container_glow = function(x, y, w, h, r, g, b, a, alpha,r1, g1, b1, fn) if alpha*255>0 then renderer.blur(x,y,w,h)end;RoundedRect(x,y,w,h,rounding,17,17,17,a)FadedRoundedGlow(x,y,w,h,rounding,r,g,b,alpha*255,alpha*o,r1,g1,b1)if not fn then return end;fn(x+rounding,y+rounding,w-rounding*2,h-rounding*2.0) end
local menu_c = ui.reference("MISC", "Settings", "Menu color")
local menu_r, menu_g, menu_b, menu_a = ui.get(menu_c)
local android_notify=(function()local a={callback_registered=false,maximum_count=7,data2={}}function a:register_callback()if self.callback_registered then return end;client.set_event_callback('paint_ui',function()local b={client.screen_size()}local c={56,56,57}local d=5;local e=self.data2;for f=#e,1,-1 do self.data2[f].time=self.data2[f].time-globals.frametime()local g,h=255,0;local i=e[f]if i.time<0 then table.remove(self.data2,f)else local j=i.def_time-i.time;local j=j>1 and 1 or j;if i.time<0.5 or j<0.5 then h=(j<1 and j or i.time)/0.5;g=h*255;if h<0.2 then d=d+15*(1.0-h/0.2)end end;local k={renderer.measure_text(nil,i.draw)}local l={b[1]/2-k[1]/2+3,b[2]-b[2]/100*17.4+d}renderer.circle(l[1],l[2]-8,20,20,20,g,12,180,0.5)renderer.circle(l[1]+k[1],l[2]-8,20,20,20,g,12,0,0.5)renderer.rectangle(l[1],l[2]-20,k[1],24,20,20,20,g)renderer.circle_outline(l[1],l[2]-8,menu_r,menu_g,menu_b,g,12,90,0.5,1)renderer.circle_outline(l[1]+k[1],l[2]-8,menu_r,menu_g,menu_b,g,12,270,0.5,1)renderer.rectangle(l[1],l[2]-20,k[1],1,menu_r,menu_g,menu_b,g)renderer.rectangle(l[1],l[2]-20+23,k[1],1,menu_r,menu_g,menu_b,g)renderer.text(l[1]+k[1]/2,l[2]-8,255,255,255,g,'c',nil,i.draw)d=d-50 end end;self.callback_registered=true end)end;function a:paint(m,n)local o=tonumber(m)+1;for f=self.maximum_count,2,-1 do self.data2[f]=self.data2[f-1]end;self.data2[1]={time=o,def_time=o,draw=n}self:register_callback()end;return a end)()
local dragging = function(name, base_x, base_y) return (function()local a={}local b,c,d,e,f,g,h,i,j,k,l,m,n,o;local p={__index={drag=function(self,...)local q,r=self:get()local s,t=a.drag(q,r,...)if q~=s or r~=t then self:set(s,t)end;return s,t end,set=function(self,q,r)local j,k=client.screen_size()ui.set(self.x_reference,q/j*self.res)ui.set(self.y_reference,r/k*self.res)end,get=function(self)local j,k=client.screen_size()return ui.get(self.x_reference)/self.res*j,ui.get(self.y_reference)/self.res*k end}}function a.new(u,v,w,x)x=x or 10000;local j,k=client.screen_size()local y=ui.new_slider('LUA','A',u..' window position',0,x,v/j*x)local z=ui.new_slider('LUA','A','\n'..u..' window position y',0,x,w/k*x)ui.set_visible(y,false)ui.set_visible(z,false)return setmetatable({name=u,x_reference=y,y_reference=z,res=x},p)end;function a.drag(q,r,A,B,C,D,E)if globals.framecount()~=b then c=ui.is_menu_open()f,g=d,e;d,e=ui.mouse_position()i=h;h=client.key_state(0x01)==true;m=l;l={}o=n;n=false;j,k=client.screen_size()end;if c and i~=nil then if(not i or o)and h and f>q and g>r and f<q+A and g<r+B then n=true;q,r=q+d-f,r+e-g;if not D then q=math.max(0,math.min(j-A,q))r=math.max(0,math.min(k-B,r))end end end;table.insert(l,{q,r,A,B})return q,r,A,B end;return a end)().new(name, base_x, base_y) end
local scr_x, scr_y = client.screen_size()
local hotkeys_dragging = dragging('keybinds', 500, 500)
local spec_dragging = dragging('spectators', 300, 700)
local debug_dragging = dragging('debug',5, scr_y/2)
local m_active = { }
local references = { }
local spectators = {
    avatars = true,
    auto_position = true,
}
local hotkey_modes = { 'holding', 'toggled', 'disabled' }
local GLOBAL_ALPHA = 0
local GLOBAL_ALPHA2 = 0

local function is_crouching(player)
    if player == nil then return end
    local flags = entity.get_prop(player, "m_fFlags")
    if flags == nil then return end

    if bit.band(flags, 4) == 4 then
        return true
    end
    
    return false
end

local function in_air(player)
    if player == nil then return end
    local flags = entity.get_prop(player, "m_fFlags")
    if flags == nil then return end
    
    if bit.band(flags, 1) == 0 then
        return true
    end
    
    return false
end

local function contains(table, value)

	if table == nil then
		return false
	end
	
    table = ui.get(table)
    for i=0, #table do
        if table[i] == value then
            return true
        end
    end
    return false
end


ffi.cdef [[
	typedef int(__thiscall* get_clipboard_text_count)(void*);
	typedef void(__thiscall* set_clipboard_text)(void*, const char*, int);
	typedef void(__thiscall* get_clipboard_text)(void*, int, const char*, int);
]]

local VGUI_System010 =  client.create_interface("vgui2.dll", "VGUI_System010") or print( "Error finding VGUI_System010")
local VGUI_System = ffi.cast(ffi.typeof('void***'), VGUI_System010 )

local get_clipboard_text_count = ffi.cast("get_clipboard_text_count", VGUI_System[ 0 ][ 7 ] ) or print( "get_clipboard_text_count Invalid")
local set_clipboard_text = ffi.cast( "set_clipboard_text", VGUI_System[ 0 ][ 9 ] ) or print( "set_clipboard_text Invalid")
local get_clipboard_text = ffi.cast( "get_clipboard_text", VGUI_System[ 0 ][ 11 ] ) or print( "get_clipboard_text Invalid")

local function clipboard_import( )
    local clipboard_text_length = get_clipboard_text_count( VGUI_System )
  local clipboard_data = ""

  if clipboard_text_length > 0 then
      buffer = ffi.new("char[?]", clipboard_text_length)
      size = clipboard_text_length * ffi.sizeof("char[?]", clipboard_text_length)

      get_clipboard_text( VGUI_System, 0, buffer, size )

      clipboard_data = ffi.string( buffer, clipboard_text_length-1 )
  end
  return clipboard_data
end

local function clipboard_export(string)
	if string then
		set_clipboard_text(VGUI_System, string, string:len())
	end
end

local function arr_to_string(arr)
	arr = ui.get(arr)
	local str = ""
	for i=1, #arr do
		str = str .. arr[i] .. (i == #arr and "" or ",")
	end

	if str == "" then
		str = "-"
	end

	return str
end

local function str_to_sub(input, sep)
	local t = {}
	for str in string.gmatch(input, "([^"..sep.."]+)") do
		t[#t + 1] = string.gsub(str, "\n", "")
	end
	return t
end

local function to_boolean(str)
	if str == "true" then
		return true
	else
		return false
	end
end

local function load_cfg(input)
	local tbl = str_to_sub(input, "|")
    local val_plus = {[1] = 0, [2] = 22, [3] = 44, [4] = 66, [5] = 88, [6] = 110, [7] = 132, [8] = 154, [9] = 176, [10] = 198, [11] = 220, [12] = 242}

    for i=1, 12 do
        ui.set(custom_aa[i].enabled, to_boolean(tbl[1 + val_plus[i]]))
        ui.set(custom_aa[i].pitch, tbl[2 + val_plus[i]])
        ui.set(custom_aa[i].yaw_target, tbl[3 + val_plus[i]])
        ui.set(custom_aa[i].yaw_mode, tbl[4 + val_plus[i]])
        ui.set(custom_aa[i].flick_delay, tonumber(tbl[5 + val_plus[i]]))
        ui.set(custom_aa[i].yaw_slider_main, tonumber(tbl[6 + val_plus[i]]))
        ui.set(custom_aa[i].yaw_slider_next, tonumber(tbl[7 + val_plus[i]]))
        ui.set(custom_aa[i].yaw_jitter, tbl[8 + val_plus[i]])
        ui.set(custom_aa[i].yaw_jitter_slider, tonumber(tbl[9 + val_plus[i]]))
        ui.set(custom_aa[i].yaw_body, tbl[10 + val_plus[i]])
        ui.set(custom_aa[i].yaw_body_slider, tonumber(tbl[11 + val_plus[i]]))
        ui.set(custom_aa[i].additions, str_to_sub(tbl[12 + val_plus[i]], ","))
        ui.set(custom_aa[i].highjitter_antibrute, to_boolean(tbl[13 + val_plus[i]]))
        ui.set(custom_aa[i].antibruteforce_time, tonumber(tbl[14 + val_plus[i]]))
        ui.set(custom_aa[i].freestanding_mode, tbl[15 + val_plus[i]])
        ui.set(custom_aa[i].freestanding_type, tbl[16 + val_plus[i]])
        ui.set(custom_aa[i].resetangle_ang, tonumber(tbl[17 + val_plus[i]]))
        ui.set(custom_aa[i].fake_yaw_mode, tbl[18 + val_plus[i]])
        ui.set(custom_aa[i].fake_slider_main, tonumber(tbl[19 + val_plus[i]]))
        ui.set(custom_aa[i].fake_slider_next, tonumber(tbl[20 + val_plus[i]]))
        ui.set(custom_aa[i].flick_delay2, tonumber(tbl[21 + val_plus[i]]))
        ui.set(custom_aa[i].roll_slider, tonumber(tbl[22 + val_plus[i]]))
    end
end

local function save_cfg_to_clip()
	local str = ""

	for i=1, 12 do

		str = str .. tostring(ui.get(custom_aa[i].enabled)) .. "|"
        .. tostring(ui.get(custom_aa[i].pitch)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_target)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_mode)) .. "|"
        .. tostring(ui.get(custom_aa[i].flick_delay)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_slider_main)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_slider_next)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_jitter)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_jitter_slider)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_body)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_body_slider)) .. "|"
		.. arr_to_string(custom_aa[i].additions) .. "|"
        .. tostring(ui.get(custom_aa[i].highjitter_antibrute)) .. "|"
        .. tostring(ui.get(custom_aa[i].antibruteforce_time)) .. "|"
        .. tostring(ui.get(custom_aa[i].freestanding_mode)) .. "|"
        .. tostring(ui.get(custom_aa[i].freestanding_type)) .. "|"
        .. tostring(ui.get(custom_aa[i].resetangle_ang)) .. "|"
        .. tostring(ui.get(custom_aa[i].fake_yaw_mode)) .. "|"
		.. tostring(ui.get(custom_aa[i].fake_slider_main)) .. "|"
        .. tostring(ui.get(custom_aa[i].fake_slider_next)) .. "|"
        .. tostring(ui.get(custom_aa[i].flick_delay2)) .. "|"
        .. tostring(ui.get(custom_aa[i].roll_slider)) .. "|"
	end

	clipboard_export(str)
end

local presetlist = ui.new_combobox("AA", "Anti-aimbot angles", "Preset tab", database.read('[NeverHit] preset list'))

local load_cfg_but = ui.new_button("AA", "Anti-aimbot angles", "Load Preset", function()
    load_cfg(database.read('[NeverHit] '..ui.get(presetlist)..' preset'))
    client.log("Loaded custom preset")
end)

local delete_preset = function(preset, tbl)
    for i=1,#tbl do
        if preset == tbl[i] then
            table.remove(tbl, i)
        end
    end
end

local delete_cfg_but = ui.new_button("AA", "Anti-aimbot angles", "Delete Preset", function()
    if ui.get(presetlist) == "Main" then
        error('you can not delete this preset')
        return
    end

    delete_preset(ui.get(presetlist), cache)
    database.write('[NeverHit] preset list', cache)
    client.log("Deleted custom preset")
    client.reload_active_scripts()
end)

local presetname = ui.new_textbox("AA", "Anti-aimbot angles", "Please enter preset name")

local save_cfg_but = ui.new_button("AA", "Anti-aimbot angles", "Save Preset", function()
    if ui.get(presetname) == "White" then
        error('you can not save this preset')
        return
    end
    if ui.get(presetname) == "" then
        error('Please enter preset name')
        return
    end

    local str = ""

	for i=1, 12 do

		str = str .. tostring(ui.get(custom_aa[i].enabled)) .. "|"
        .. tostring(ui.get(custom_aa[i].pitch)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_target)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_mode)) .. "|"
        .. tostring(ui.get(custom_aa[i].flick_delay)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_slider_main)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_slider_next)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_jitter)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_jitter_slider)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_body)) .. "|"
		.. tostring(ui.get(custom_aa[i].yaw_body_slider)) .. "|"
		.. arr_to_string(custom_aa[i].additions) .. "|"
        .. tostring(ui.get(custom_aa[i].highjitter_antibrute)) .. "|"
        .. tostring(ui.get(custom_aa[i].antibruteforce_time)) .. "|"
        .. tostring(ui.get(custom_aa[i].freestanding_mode)) .. "|"
        .. tostring(ui.get(custom_aa[i].freestanding_type)) .. "|"
        .. tostring(ui.get(custom_aa[i].resetangle_ang)) .. "|"
        .. tostring(ui.get(custom_aa[i].fake_yaw_mode)) .. "|"
		.. tostring(ui.get(custom_aa[i].fake_slider_main)) .. "|"
        .. tostring(ui.get(custom_aa[i].fake_slider_next)) .. "|"
        .. tostring(ui.get(custom_aa[i].flick_delay2)) .. "|"
        .. tostring(ui.get(custom_aa[i].roll_slider)) .. "|"
	end

    for _, k in pairs(database.read('[NeverHit] preset list')) do
        if ui.get(presetname) == tostring(k) then
            database.write('[NeverHit] '..ui.get(presetname)..' preset', str)
            client.reload_active_scripts()
            return
        end
    end

    cache[#database.read('[NeverHit] preset list') + 1] = ui.get(presetname)
    database.write('[NeverHit] preset list', cache)
    database.write('[NeverHit] '..ui.get(presetname)..' preset', str)
    client.log("Saved custom preset")
    client.reload_active_scripts()
end)

client.set_event_callback("console_input", function(input)
    if string.find(input, "//save") then
		save_cfg_to_clip()
        client.log("Saved custom preset to clipboard")
	elseif string.find(input, "//load") then
		load_cfg(clipboard_import())
        client.log("Loaded custom preset from clipboard")
    end
end)

client.set_event_callback('run_command', function(cmd)
    if cmd.chokedcommands == 0 then
        vars.bodyyaw = entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) * 120 - 60
    end
end)

local function Angle_Vector(angle_x, angle_y)
	local sp, sy, cp, center_y = nil
    sy = math.sin(math.rad(angle_y));
    center_y = math.cos(math.rad(angle_y));
    sp = math.sin(math.rad(angle_x));
    cp = math.cos(math.rad(angle_x));
    return cp * center_y, cp * sy, -sp;
end

local function normalize_yaw(yaw)
	while yaw > 180 do yaw = yaw - 360 end
	while yaw < -180 do yaw = yaw + 360 end
	return yaw
end

local function CalcAngle(localplayerxpos, localplayerypos, enemyxpos, enemyypos)
    local relativeyaw = math.atan( (localplayerypos - enemyypos) / (localplayerxpos - enemyxpos) )
    return relativeyaw * 180 / math.pi
end

local function extrapolate_position(xpos,ypos,zpos,ticks,player)
	local x,y,z = entity.get_prop(player, "m_vecVelocity")
    if x == nil or y == nil or z == nil then return end
	for i=0, ticks do
		xpos =  xpos + (x*globals.tickinterval())
		ypos =  ypos + (y*globals.tickinterval())
		zpos =  zpos + (z*globals.tickinterval())
	end
	return xpos,ypos,zpos
end

local function get_velocity(player)
	local x,y,z = entity.get_prop(player, "m_vecVelocity")
	if x == nil then return end
	return math.sqrt(x*x + y*y + z*z)
end

local function DoFreestanding(enemy, ...)
	local lx, ly, lz = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
	local viewangle_x, viewangle_y, roll = client.camera_angles()
	local headx, heady, headz = entity.hitbox_position(entity.get_local_player(), 0)
	local enemyx, enemyy, enemyz = entity.get_prop(enemy, "m_vecOrigin")
	local bestangle = nil
	local lowest_dmg = math.huge

	if (entity.is_alive(enemy)) then
		local yaw = CalcAngle(lx, ly, enemyx, enemyy)
		for i,v in pairs({...}) do
			local dir_x, dir_y, dir_z = Angle_Vector(0, (yaw + v))
			local end_x = lx + dir_x * 55
			local end_y = ly + dir_y * 55
			local end_z = lz + 80			
			
			local index, damage = client.trace_bullet(enemy, enemyx, enemyy, enemyz + 70, end_x, end_y, end_z,true)
			local index2, damage2 = client.trace_bullet(enemy, enemyx, enemyy, enemyz + 70, end_x + 12, end_y, end_z,true) --test
			local index3, damage3 = client.trace_bullet(enemy, enemyx, enemyy, enemyz + 70, end_x - 12, end_y, end_z,true) --test

			if(damage < lowest_dmg) then
				lowest_dmg = damage
				if(damage2 > damage) then
					lowest_dmg = damage2
				end
				if(damage3 > damage) then
					lowest_dmg = damage3
				end	
				if(lx - enemyx > 0) then
					bestangle = v
				else
					bestangle = v * -1
				end
			elseif(damage == lowest_dmg) then
					return 0
			end
		end
	end
	return bestangle
end

local function DoEarlyFreestanding(enemy, ...)
	local lx, ly, lz = entity.get_prop(enemy, "m_vecOrigin")
	local viewangle_x, viewangle_y, roll = client.camera_angles()
	local localplayer = entity.get_local_player()
	local headx, heady, headz = entity.hitbox_position(localplayer, 0)
	local enemyx, enemyy, enemyz = entity.get_prop(localplayer, "m_vecOrigin")
	local bestangle = nil
	local lowest_dmg = math.huge
	local last_moved = 0
	local fs_stored_eyepos_x, fs_stored_eyepos_y, fs_stored_eyepos_z = nil

	if (entity.is_alive(enemy)) then
		local yaw = CalcAngle(enemyx, enemyy, lx, ly)
		for i,v in pairs({...}) do
			local dir_x, dir_y, dir_z = Angle_Vector(0, (yaw + v))
			local end_x = lx + dir_x * 55
			local end_y = ly + dir_y * 55
			local end_z = lz + 80
			local eyepos_x, eyepos_y, eyepos_z = client.eye_position()
			local local_velocity = get_velocity(entity.get_local_player())
			local can_be_extrapolated = local_velocity > 15
			local ticks_to_extrapolate = 11
			if (local_velocity < 50) then
				ticks_to_extrapolate = 90
			elseif (local_velocity >= 50 and local_velocity < 120) then
				ticks_to_extrapolate = 50
			elseif (local_velocity >= 120 and local_velocity < 190) then
				ticks_to_extrapolate = 40
			elseif (local_velocity >= 190) then
				ticks_to_extrapolate = 20
			end

			if can_be_extrapolated then
				eyepos_x, eyepos_y, eyepos_z = extrapolate_position(eyepos_x, eyepos_y, eyepos_z, ticks_to_extrapolate, entity.get_local_player())
				fs_stored_eyepos_x, fs_stored_eyepos_y, fs_stored_eyepos_z = eyepos_x, eyepos_y, eyepos_z
				last_moved = globals.curtime() + 1
			else
				if last_moved ~= 0 then
					if globals.curtime() > last_moved then
						last_moved = 0
						fs_stored_eyepos_x, fs_stored_eyepos_y, fs_stored_eyepos_z = nil
					else
						eyepos_x, eyepos_y, eyepos_z = fs_stored_eyepos_x, fs_stored_eyepos_y, fs_stored_eyepos_z
					end
				else
					eyepos_x, eyepos_y, eyepos_z = extrapolate_position(eyepos_x, eyepos_y, eyepos_z, ticks_to_extrapolate, entity.get_local_player())
				end
			end
			
			local index, damage = client.trace_bullet(localplayer, enemyx, enemyy, enemyz + 70, end_x, end_y, end_z,true)
			local index2, damage2 = client.trace_bullet(localplayer, enemyx, enemyy, enemyz + 70, end_x + 12, end_y, end_z,true)
			local index3, damage3 = client.trace_bullet(localplayer, enemyx, enemyy, enemyz + 70, end_x - 12, end_y, end_z,true)

			if fs_stored_eyepos_x ~= nil then
				index, damage = client.trace_bullet(localplayer, fs_stored_eyepos_x, fs_stored_eyepos_y, fs_stored_eyepos_z + 70, end_x, end_y, end_z,true)
				index2, damage2 = client.trace_bullet(localplayer, fs_stored_eyepos_x, fs_stored_eyepos_y, fs_stored_eyepos_z + 70, end_x + 12, end_y, end_z,true)
				index3, damage3 = client.trace_bullet(localplayer, fs_stored_eyepos_x, fs_stored_eyepos_y, fs_stored_eyepos_z + 70, end_x - 12, end_y, end_z,true)
			end

			if(damage < lowest_dmg) then
				lowest_dmg = damage
				if(damage2 > damage) then
					lowest_dmg = damage2
				end
				if(damage3 > damage) then
					lowest_dmg = damage3
				end	
				if(enemyx - lx > 0) then
					bestangle = v
				else
				bestangle = v * -1
				end
			elseif(damage == lowest_dmg) then
				return 0
			end
		end
	end
	return bestangle
end

local function entity_has_c4(ent)
	local bomb = entity.get_all("CC4")[1]
	return bomb ~= nil and entity.get_prop(bomb, "m_hOwnerEntity") == ent
end

local function weapon_is_enabled(idx)
	if (idx == 38 or idx == 11) then
		return true
	elseif (idx == 40) then
		return true
	elseif (idx == 9) then
		return true
	elseif (idx == 64) then
		return true
	elseif (idx == 1) then
		return true
	else
		return true
	end
	return false
end

local function is_lethal(target, idx)
    if target == nil or not entity.is_alive(target) then return end
    local origin = vector(entity.get_prop(target, "m_vecAbsOrigin"))
    local distance = origin:dist(vector(entity.get_prop(idx, "m_vecOrigin")))
    local enemy_health = entity.get_prop(idx, "m_iHealth")

	local weapon_ent = entity.get_player_weapon(target)
	if weapon_ent == nil then return end
	
	local weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
	if weapon_idx == nil then return end
	
	local weapon = csgo_weapons[weapon_idx]
	if weapon == nil then return end

	if not weapon_is_enabled(weapon_idx) then return end

	local dmg_after_range = (weapon.damage * math.pow(weapon.range_modifier, (distance * 0.002))) * 1.25
	local armor = entity.get_prop(idx,"m_ArmorValue")
	local newdmg = dmg_after_range * (weapon.armor_ratio * 0.5)
    if dmg_after_range == nil or armor == nil or newdmg == nil then return end
    
	if dmg_after_range - (dmg_after_range * (weapon.armor_ratio * 0.5)) * 0.5 > armor then
		newdmg = dmg_after_range - (armor / 0.5)
	end
	return newdmg >= enemy_health
end

local function get_entities(enemy_only, alive_only)
    local enemy_only = enemy_only ~= nil and enemy_only or false
    local alive_only = alive_only ~= nil and alive_only or true

    local result = {}

    local me = entity.get_local_player()
    local player_resource = entity.get_player_resource()

    for player = 1, globals.maxplayers() do
        local is_enemy, is_alive = true, true

        if enemy_only and not entity.is_enemy(player) then is_enemy = false end
        if is_enemy then
            if alive_only and entity.get_prop(player_resource, 'm_bAlive', player) ~= 1 then is_alive = false end
            if is_alive then table.insert(result, player) end
        end
    end

    return result
end

local function state(lp_vel)
    if lp_vel < 5 and not in_air(entity.get_local_player()) and not ((is_crouching(entity.get_local_player())) or ui.get(refs.fake_duck)) then
        cnds = 1
    elseif in_air(entity.get_local_player()) and not is_crouching(entity.get_local_player()) then
        cnds = 4
    elseif in_air(entity.get_local_player()) and is_crouching(entity.get_local_player()) then
        cnds = 5
    elseif ((is_crouching(entity.get_local_player()) and not in_air(entity.get_local_player())) or ui.get(refs.fake_duck)) then
        cnds = 6
    else
        if ui.get(refs.slowwalk[1]) and ui.get(refs.slowwalk[2]) then
        cnds = 3
        else
        cnds = 2 
        end
    end

    return cnds
end

client.set_event_callback('aim_fire', function(e)
    vars.shot_time = globals.realtime()
end)

local function GetClosestPoint(A, B, P)
    local a_to_p = { P[1] - A[1], P[2] - A[2] }
    local a_to_b = { B[1] - A[1], B[2] - A[2] }

    local atb2 = a_to_b[1]^2 + a_to_b[2]^2

    local atp_dot_atb = a_to_p[1]*a_to_b[1] + a_to_p[2]*a_to_b[2]
    local t = atp_dot_atb / atb2
        
    return vector(A[1] + a_to_b[1]*t, A[2] + a_to_b[2]*t)
end

local function distance3d(x1, y1, z1, x2, y2, z2)
	return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1))
end

client.set_event_callback("bullet_impact", function(c)
    local ent = client.userid_to_entindex(c.userid)
    local lp_vel = get_velocity(entity.get_local_player())
    local local_head = vector(entity.hitbox_position(entity.get_local_player(), "head_0"))
    local enemy_head = vector(entity.hitbox_position(ent, "head_0"))
    local test, dmg_check = client.trace_bullet(ent, enemy_head.x, enemy_head.y, enemy_head.z, local_head.x, local_head.y, local_head.z, true)
    local local_hg = local_head.z > (enemy_head.z + 150)
    local local_lethal = is_lethal(ent, entity.get_local_player()) and dmg_check ~= 0

    local local_dormant = true

    if ui.get(custom_aa[9].enabled) then
        local enemy_list = get_entities(true, true)
        for c, players in pairs(enemy_list) do
            if players == nil then goto skip end
            if entity.is_dormant(players) then goto skip end
    
            local_dormant = false
            ::skip::
        end
    end

    local in_attack = vars.shot_time + 0.2 > globals.realtime()
    
    local state = state(lp_vel)
    local state = ui.get(custom_aa[state + 1].enabled) and state + 1 or 1
    local state = (ui.get(custom_aa[10].enabled) and local_hg) and 10 or state
    local state = (ui.get(custom_aa[11].enabled) and local_lethal) and 11 or state
    local state = (ui.get(custom_aa[9].enabled) and local_dormant) and 9 or state
    local state = (ui.get(custom_aa[12].enabled) and in_attack) and 12 or state
    local state = (ui.get(custom_aa[8].enabled) and contains(funcs.anti_aim.features, "[Anti-Aim on Use]") and ui.get(funcs.anti_aim.legit_key)) and 8 or state
    if not contains(custom_aa[state].additions, "Anti-Bruteforce") then return end
    if not entity.is_dormant(ent) and entity.is_enemy(ent) then
        local bullet_vec = vector(c.x, c.y, c.z)
        local tracer_vec = GetClosestPoint({ enemy_head.x, enemy_head.y, enemy_head.z }, { bullet_vec.x, bullet_vec.y, bullet_vec.z }, { local_head.x, local_head.y, local_head.z })
        local distance = distance3d(tracer_vec.x, tracer_vec.y, tracer_vec.z, local_head.x, local_head.y, local_head.z)
        local delta = { local_head.x-tracer_vec.x, local_head.y-tracer_vec.y }
        local delta_2d = math.sqrt(delta[1]^2+delta[2]^2)

        if distance <= 350 then
            vars.should_swap = globals.realtime()
            vars.bruteforce_tick = globals.tickcount()
            if ui.get(custom_aa[state].highjitter_antibrute) then
                if ui.get(refs.jyaw[2]) == ui.get(custom_aa[state].yaw_jitter_slider) then
                    vars.right_side = true
                    vars.left_side = false
                    return
                else
                    vars.left_side = true
                    vars.right_side = false
                    return
                end
            else
                if vars.bodyyaw < 0 then
                    vars.left_side = true
                    vars.right_side = false
                    return
                elseif vars.bodyyaw > 0 then
                    vars.right_side = true
                    vars.left_side = false
                    return
                end
            end
        end
    end
end)

local function wall_freestand()

    local data = {
        side = 1,
        last_side = 0,
    
        last_hit = 0,
        hit_side = 0
    }

    local me = entity.get_local_player()

    if (not me or entity.get_prop(me, "m_lifeState") ~= 0) then
        return
    end
    

    local now = globals.curtime()

    if data.hit_side ~= 0 and now - data.last_hit > 5 then

        data.last_side = 0

        data.last_hit = 0
        data.hit_side = 0
    end

    local x, y, z = client.eye_position()
    local _, yaw = client.camera_angles()

    local trace_data = {left = 0, right = 0}

    for i = yaw - 120, yaw + 120, 30 do

        if i ~= yaw then

            local rad = math.rad(i)

            local px, py, pz = x + 256 * math.cos(rad), y + 256 * math.sin(rad), z

            local fraction = client.trace_line(me, x, y, z, px, py, pz)
            local side = i < yaw and "left" or "right"

            trace_data[side] = trace_data[side] + fraction
        end
    end

    data.side = trace_data.left < trace_data.right and 1 or -1

    if data.side == data.last_side then
        return
    end

    data.last_side = data.side

    if data.hit_side ~= 0 then
        data.side = data.hit_side == 1 and 1 or -1
    end

    local result = data.side == 1 and 1 or -1

    return result
end

local function manual_direction()
    if ui.get(funcs.anti_aim.back_key) or back_dir == nil then
        back_dir = true
        right_dir = false
        left_dir = false
        forward_dir = false
        vars.last_press_t = globals.realtime()
    elseif ui.get(funcs.anti_aim.right_key) then
        if right_dir == true and vars.last_press_t + 0.07 < globals.realtime() then
        back_dir = true
        right_dir = false
        left_dir = false
        forward_dir = false
        elseif right_dir == false and vars.last_press_t + 0.07 < globals.realtime() then
        right_dir = true
        back_dir = false
        left_dir = false
        forward_dir = false
        end
        vars.last_press_t = globals.realtime()
    elseif ui.get(funcs.anti_aim.left_key) then
        if left_dir == true and vars.last_press_t + 0.07 < globals.realtime() then
        back_dir = true
        right_dir = false
        left_dir = false
        forward_dir = false
        elseif left_dir == false and vars.last_press_t + 0.07 < globals.realtime() then
        left_dir = true
        back_dir = false
        right_dir = false
        forward_dir = false
        end
        vars.last_press_t = globals.realtime()
    elseif ui.get(funcs.anti_aim.forward_key) then
        if forward_dir == true and vars.last_press_t + 0.07 < globals.realtime() then
        back_dir = true
        right_dir = false
        left_dir = false
        forward_dir = false
        elseif forward_dir == false and vars.last_press_t + 0.07 < globals.realtime() then
        left_dir = false
        back_dir = false
        right_dir = false
        forward_dir = true
        end
        vars.last_press_t = globals.realtime()
    end

    return back_dir, right_dir, left_dir, forward_dir
end

local function flick_yaw(ticks, v1_y, v2_y)
    local ticks_to_flick_yaw = globals.tickcount() % (ticks + 1)
    local flicks_yaw = ticks_to_flick_yaw == 1

    if flick_value_yaw == nil then flick_value_yaw = v1_y end

    if flicks_yaw == true then
        flick_value_yaw = (flick_value_yaw == v1_y and v2_y or v1_y)
    end

    return flick_value_yaw
end

local function flick_fake(ticks, v1_f, v2_f)
    local ticks_to_flick_fake = globals.tickcount() % (ticks + 1)
    local flicks_fake = ticks_to_flick_fake == 1

    if flick_value_fake == nil then flick_value_fake = v1_f end

    if flicks_fake == true then
        flick_value_fake = (flick_value_fake == v1_f and v2_f or v1_f)
    end

    return flick_value_fake
end


local function aa_on_use(cmd)
    local plocal = entity.get_local_player()
    
    local distance = 100
    local bomb = entity.get_all("CPlantedC4")[1]
    local bomb_x, bomb_y, bomb_z = entity.get_prop(bomb, "m_vecOrigin")

    if bomb_x ~= nil then
        local player_x, player_y, player_z = entity.get_prop(plocal, "m_vecOrigin")
        distance = distance3d(bomb_x, bomb_y, bomb_z, player_x, player_y, player_z)
    end
    
    local team_num = entity.get_prop(plocal, "m_iTeamNum")
    local defusing = team_num == 3 and distance < 62

    local on_bombsite = entity.get_prop(plocal, "m_bInBombZone")

    local has_bomb = entity_has_c4(plocal)
    local trynna_plant = on_bombsite ~= 0 and team_num == 2 and has_bomb
    
    local px, py, pz = client.eye_position()
    local pitch, yaw = client.camera_angles()

    local sin_pitch = math.sin(math.rad(pitch))
    local cos_pitch = math.cos(math.rad(pitch))
    local sin_yaw = math.sin(math.rad(yaw))
    local cos_yaw = math.cos(math.rad(yaw))

    local dir_vec = { cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch }

    local fraction, entindex = client.trace_line(plocal, px, py, pz, px + (dir_vec[1] * 8192), py + (dir_vec[2] * 8192), pz + (dir_vec[3] * 8192))

    local using = true

    if entindex ~= nil then
        if vars.classnames == nil then return end
        for i=0, #vars.classnames do
            if entity.get_classname(entindex) == vars.classnames[i] then
                using = false
            end
        end
    end

    if not using and not trynna_plant and not defusing then
        cmd.in_use = 0
    end
end

local function custom_preset(cmd, state, side, back_dir, right_dir, left_dir, forward_dir, bodyyaw, vel, player)
    if player ~= nil then
        early_freestand = DoEarlyFreestanding(player, -180, 180) 
        default_freestand = DoFreestanding(player, -180, 180)
        local_head = vector(entity.hitbox_position(entity.get_local_player(), "head_0"))
        enemy_head = vector(entity.hitbox_position(player, "head_0"))
        ent, dmg_check = client.trace_bullet(player, enemy_head.x, enemy_head.y, enemy_head.z, local_head.x, local_head.y, local_head.z, true)
        local_hg = local_head.z > (enemy_head.z + 150)
        local_lethal = is_lethal(player, entity.get_local_player()) and dmg_check ~= 0
    else
        early_freestand = 0
        default_freestand = 0
        local_hg = false
        local_lethal = false
    end

    local local_dormant = true
    local wall_direction = wall_freestand()

    if ui.get(custom_aa[9].enabled) then
        local enemy_list = get_entities(true, true)
        for c, players in pairs(enemy_list) do
            if players == nil then goto skip end
            if entity.is_dormant(players) then goto skip end

            local_dormant = false
            ::skip::
        end
    end

    local cam_pitch, cam_yaw, cam_roll = client.camera_angles()
    
    local grenade_pin = entity.get_prop(active_weapon, "m_bPinPulled")
    local in_attack = vars.shot_time + 0.2 > globals.realtime()

    local state = ui.get(custom_aa[state + 1].enabled) and state + 1 or 1
    local state = (ui.get(custom_aa[10].enabled) and local_hg) and 10 or state
    local state = (ui.get(custom_aa[11].enabled) and local_lethal) and 11 or state
    local state = (ui.get(custom_aa[9].enabled) and local_dormant) and 9 or state
    local state = (ui.get(custom_aa[12].enabled) and in_attack) and 12 or state
    local state = (ui.get(custom_aa[8].enabled) and contains(funcs.anti_aim.features, "[Anti-Aim on Use]") and ui.get(funcs.anti_aim.legit_key)) and 8 or state

    ui.set(refs.pitch, ui.get(custom_aa[state].pitch))
    if left_dir and contains(funcs.anti_aim.features, "[Yaw Management]") and state ~= 8 then
        ui.set(refs.yaw_target, "Local view")
        ui.set(refs.yaw[2], -90)
    elseif right_dir and contains(funcs.anti_aim.features, "[Yaw Management]") and state ~= 8 then
        ui.set(refs.yaw_target, "Local view")
        ui.set(refs.yaw[2], 90)
    elseif forward_dir and contains(funcs.anti_aim.features, "[Yaw Management]") and state ~= 8 then
        ui.set(refs.yaw_target, "Local view")
        ui.set(refs.yaw[2], 180)
    else
        ui.set(refs.yaw_target, ui.get(custom_aa[state].yaw_target))
        if ui.get(custom_aa[state].yaw_mode) == "Default" then
            ui.set(refs.yaw[2], ui.get(custom_aa[state].yaw_slider_main))
        elseif ui.get(custom_aa[state].yaw_mode) == "According Side" then
            if cmd.chokedcommands == 0 then
                ui.set(refs.yaw[2], (side == 1 and ui.get(custom_aa[state].yaw_slider_main) or ui.get(custom_aa[state].yaw_slider_next)))
            end
        elseif ui.get(custom_aa[state].yaw_mode) == "Flick" then
            ui.set(refs.yaw[2], flick_yaw(ui.get(custom_aa[state].flick_delay), ui.get(custom_aa[state].yaw_slider_main), ui.get(custom_aa[state].yaw_slider_next)))
        elseif ui.get(custom_aa[state].yaw_mode) == "Jitter" then
            ui.set(refs.yaw[2], flick_yaw(1, ui.get(custom_aa[state].yaw_slider_main), ui.get(custom_aa[state].yaw_slider_next)))
        elseif ui.get(custom_aa[state].yaw_mode) == "Random" then 
            ui.set(refs.yaw[2], client.random_int(ui.get(custom_aa[state].yaw_slider_main), ui.get(custom_aa[state].yaw_slider_next)))
        end
    end
    if ui.get(custom_aa[state].yaw_jitter) == "Proggresive" then
        ui.set(refs.jyaw[1], "Center")
    else
        ui.set(refs.jyaw[1], ui.get(custom_aa[state].yaw_jitter))
    end
    if ui.get(custom_aa[state].yaw_jitter) == "Proggresive" then
        if ui.get(custom_aa[state].yaw_jitter_slider) == 0 then
            ui.set(refs.jyaw[2], 0)
        else
            ui.set(refs.jyaw[2], globals.curtime()*20 % math.abs(ui.get(custom_aa[state].yaw_jitter_slider)))
        end
    else
        ui.set(refs.jyaw[2], ui.get(custom_aa[state].yaw_jitter_slider))
    end

    if ui.get(custom_aa[state].yaw_body) == "Randomize Jitter" then
        ui.set(refs.byaw[1], "Static")
    else
        ui.set(refs.byaw[1], ui.get(custom_aa[state].yaw_body))
    end

    if ui.get(custom_aa[state].yaw_body) == "Randomize Jitter" then
        ui.set(refs.byaw[2], (client.random_int(1,2) == 1 and ui.get(custom_aa[state].yaw_body_slider) or -ui.get(custom_aa[state].yaw_body_slider)))
    else
        ui.set(refs.byaw[2], ui.get(custom_aa[state].yaw_body_slider))
    end

    if ui.get(custom_aa[state].fake_yaw_mode) == "Default" then
        fake_to_set = ui.get(custom_aa[state].fake_slider_main)
    elseif ui.get(custom_aa[state].fake_yaw_mode) == "According Side" then
        if cmd.chokedcommands == 0 then
            fake_to_set = (side == 1 and ui.get(custom_aa[state].fake_slider_main) or ui.get(custom_aa[state].fake_slider_next))
        end
    elseif ui.get(custom_aa[state].fake_yaw_mode) == "Flick" then
        fake_to_set = flick_fake(ui.get(custom_aa[state].flick_delay2), ui.get(custom_aa[state].fake_slider_main), ui.get(custom_aa[state].fake_slider_next))
    elseif ui.get(custom_aa[state].fake_yaw_mode) == "Jitter" then
        fake_to_set = flick_fake(1, ui.get(custom_aa[state].fake_slider_main), ui.get(custom_aa[state].fake_slider_next))
    elseif ui.get(custom_aa[state].fake_yaw_mode) == "Random" then 
        fake_to_set = client.random_int(ui.get(custom_aa[state].fake_slider_main), ui.get(custom_aa[state].fake_slider_next))
    end

    local jitter_check = ui.get(refs.jyaw[1]) ~= "Off" and ui.get(refs.jyaw[2]) ~= 0
    local fake_check = ui.get(custom_aa[state].fake_yaw_mode) ~= "Default" and ui.get(custom_aa[state].fake_slider_main) ~= ui.get(custom_aa[state].fake_slider_next)
    local yaw_check = ui.get(custom_aa[state].yaw_mode) ~= "Default" and ui.get(custom_aa[state].yaw_slider_main) ~= ui.get(custom_aa[state].yaw_slider_next)
    local skeet_bug = ui.get(refs.byaw[1]) == "Jitter" and (jitter_check or fake_check or yaw_check)

    if fake_to_set == nil then
        ui.set(refs.fake_yaw, 59)
    elseif fake_to_set == 60 and skeet_bug and fake_to_set > 0 then
        ui.set(refs.fake_yaw, fake_to_set - 1)
    else
        ui.set(refs.fake_yaw, fake_to_set)
    end

    ui.set(refs.roll_aa, ui.get(custom_aa[state].roll_slider))

    if contains(custom_aa[state].additions, "Avoid Overlap") and ((vars.cam_yaw_backup + 70 < cam_yaw) or (vars.cam_yaw_backup - 70 > cam_yaw)) then
        vars.cam_yaw_normalize_time = globals.realtime()
        vars.cam_yaw_backup = cam_yaw
    end

    if vars.cam_yaw_normalize_time + 1 > globals.realtime() then
        ui.set(refs.jyaw[1], "Off")
        ui.set(refs.byaw[1], "Opposite")
        ui.set(refs.fake_yaw, 60)
    end

    if contains(custom_aa[state].additions, "Reset Angle") and math.abs(bodyyaw) <= ui.get(custom_aa[state].resetangle_ang) then
        ui.set(refs.jyaw[1], "Off")
        ui.set(refs.byaw[1], "Opposite")
        ui.set(refs.fake_yaw, 60)
    end
    
    if early_freestand == -180 or default_freestand == -180 then
        adaptive_freestand = -180
    elseif early_freestand == 180 or default_freestand == 180 then
        adaptive_freestand = 180
    else
        adaptive_freestand = 0
    end

    local freestand_side = wall_direction == -1 and 180 or -180

    if vars.should_swap + ui.get(custom_aa[state].antibruteforce_time) > globals.realtime() and contains(custom_aa[state].additions, "Anti-Bruteforce") then
        if ui.get(custom_aa[state].highjitter_antibrute) then
            if vars.right_side then
                ui.set(refs.jyaw[2], -ui.get(custom_aa[state].yaw_jitter_slider))
            elseif vars.left_side then
                ui.set(refs.jyaw[2], ui.get(custom_aa[state].yaw_jitter_slider))
            end
        else
            if vars.left_side then
                ui.set(refs.byaw[1], "Static")
                ui.set(refs.byaw[2], 180)
            elseif vars.right_side then
                ui.set(refs.byaw[1], "Static")
                ui.set(refs.byaw[2], -180)
            end
        end
    end
    if contains(custom_aa[state].additions, "Freestanding") then
        if ui.get(custom_aa[state].freestanding_mode) == "Wall Direction" then
            if ui.get(custom_aa[state].freestanding_type) == "Peek Fake" then
                ui.set(refs.byaw[1], "Static")
                ui.set(refs.byaw[2], freestand_side)
            elseif ui.get(custom_aa[state].freestanding_type) == "Peek Real" then
                ui.set(refs.byaw[1], "Static")
                ui.set(refs.byaw[2], -freestand_side)
            end
        else
            if adaptive_freestand ~= 0 then
                if ui.get(custom_aa[state].freestanding_type) == "Peek Fake" then
                    ui.set(refs.byaw[1], "Static")
                    ui.set(refs.byaw[2], adaptive_freestand)
                elseif ui.get(custom_aa[state].freestanding_type) == "Peek Real" then
                    ui.set(refs.byaw[1], "Static")
                    ui.set(refs.byaw[2], -adaptive_freestand)
                end
            end
        end
    end
end

client.set_event_callback("setup_command", function(cmd)
    if contains(funcs.anti_aim.features, "[Anti-Aim on Use]") then aa_on_use(cmd) end
    local lp_vel = get_velocity(entity.get_local_player())
    local state = state(lp_vel)
    local side = math.floor(vars.bodyyaw) < 0 and 1 or -1
    local back_dir, right_dir, left_dir, forward_dir = manual_direction()
    local player = client.current_threat()

    ui.set(refs.yaw[1], "180")
    ui.set(refs.fs[1], "Default")

    if player ~= nil and (ui.get(funcs.anti_aim.edgeyaw_key) or ui.get(funcs.anti_aim.freestand_key)) then
        local local_head = vector(entity.hitbox_position(entity.get_local_player(), "head_0"))
        local enemy_head = vector(entity.hitbox_position(player, "head_0"))
        local ent, scan_dmg = client.trace_bullet(player, enemy_head.x, enemy_head.y, enemy_head.z, local_head.x, local_head.y, local_head.z, true)
        head_hittable = scan_dmg ~= 0
    else
        head_hittable = false
    end

    if ui.get(funcs.anti_aim.edgeyaw_key) and not (contains(funcs.anti_aim.features, "[Anti-Aim on Use]") and ui.get(funcs.anti_aim.legit_key)) and not ((contains(funcs.anti_aim.disable_edgeyaw, "Standing") and state == 1) or (contains(funcs.anti_aim.disable_edgeyaw, "Moving") and state == 2) or (contains(funcs.anti_aim.disable_edgeyaw, "Slow-motion") and state == 3) or (contains(funcs.anti_aim.disable_edgeyaw, "Air") and (state == 4 or state == 5)) or (contains(funcs.anti_aim.disable_edgeyaw, "Crouching") and (state == 6 and not ui.get(refs.fake_duck))) or (contains(funcs.anti_aim.disable_edgeyaw, "Fake duck") and ui.get(refs.fake_duck)) or (contains(funcs.anti_aim.disable_edgeyaw, "Head hittable") and head_hittable)) then
        ui.set(refs.edge_yaw, true)
        back_dir = true
        right_dir = false
        left_dir = false
        forward_dir = false
    elseif ui.get(funcs.anti_aim.freestand_key) and not (contains(funcs.anti_aim.features, "[Anti-Aim on Use]") and ui.get(funcs.anti_aim.legit_key)) and not ((contains(funcs.anti_aim.disable_freestand, "Standing") and state == 1) or (contains(funcs.anti_aim.disable_freestand, "Moving") and state == 2) or (contains(funcs.anti_aim.disable_freestand, "Slow-motion") and state == 3) or (contains(funcs.anti_aim.disable_freestand, "Air") and (state == 4 or state == 5)) or (contains(funcs.anti_aim.disable_freestand, "Crouching") and state == 6) or (contains(funcs.anti_aim.disable_freestand, "Head hittable") and head_hittable)) then
        ui.set(refs.fs[2], "Always on")
        back_dir = true
        right_dir = false
        left_dir = false
        forward_dir = false
    else
        ui.set(refs.fs[2], "On hotkey")
        ui.set(refs.edge_yaw, false)
        back_dir = back_dir
        right_dir = right_dir
        left_dir = left_dir
        forward_dir = forward_dir
    end

    custom_preset(cmd, state, side, back_dir, right_dir, left_dir, forward_dir, vars.bodyyaw, lp_vel, player)
end)

local function item_count(tab)
    if tab == nil then return 0 end
    if #tab == 0 then
        local val = 0
        for k in pairs(tab) do
            val = val + 1
        end

        return val
    end

    return #tab
end

local function create_item(tab, container, name, arg, cname)
    local collected = { }
    local reference = { ui.reference(tab, container, name) }

    for i=1, #reference do
        if i <= arg then
            collected[i] = reference[i]
        end
    end

    references[cname or name] = collected
end


local function get_spectating_players()
    local players, observing = { }, entity.get_local_player()

    for i = 1, globals.maxplayers() do
        if entity.get_classname(i) == 'CCSPlayer' then
            local m_iObserverMode = entity.get_prop(i, 'm_iObserverMode')
            local m_hObserverTarget = entity.get_prop(i, 'm_hObserverTarget')

            if m_hObserverTarget ~= nil and m_hObserverTarget <= 64 and not entity.is_alive(i) and (m_iObserverMode == 4 or m_iObserverMode == 5) then
                if players[m_hObserverTarget] == nil then
                    players[m_hObserverTarget] = { }
                end

                if i == me then
                    observing = m_hObserverTarget
                end

                table.insert(players[m_hObserverTarget], i)
            end
        end
    end

    return players, observing
end

local function keybind_list(r, g, b, a)
    local frames = 8 * globals.frametime()
    local latest_item = false
    local maximum_offset = 0

    for c_name, c_ref in pairs(references) do
        local item_active = true

        local items = item_count(c_ref)
        local state = { ui.get(c_ref[items]) }

        if items > 1 then
            item_active = ui.get(c_ref[1])
        end

        if item_active and state[2] ~= 0 and (state[2] == 3 and not state[1] or state[2] ~= 3 and state[1]) then
            latest_item = true

            if m_active[c_name] == nil then
                m_active[c_name] = {
                    mode = '', alpha = 0, offset = 0, active = true
                }
            end

            local text_width = renderer.measure_text(nil, c_name)

            m_active[c_name].active = true
            m_active[c_name].offset = text_width
            m_active[c_name].mode = hotkey_modes[state[2]]
            m_active[c_name].alpha = m_active[c_name].alpha + frames

            if m_active[c_name].alpha > 1 then
                m_active[c_name].alpha = 1
            end
        elseif m_active[c_name] ~= nil then
            m_active[c_name].active = false
            m_active[c_name].alpha = m_active[c_name].alpha - frames

            if m_active[c_name].alpha <= 0 then
                m_active[c_name] = nil
            end
        end

        if m_active[c_name] ~= nil and m_active[c_name].offset > maximum_offset then
            maximum_offset = m_active[c_name].offset
        end
    end

    if ui.is_menu_open() and not latest_item then
        local case_name = 'Menu toggled'
        local text_width = renderer.measure_text(nil, case_name)

        latest_item = true
        maximum_offset = maximum_offset < text_width and text_width or maximum_offset

        m_active[case_name] = {
            active = true,
            offset = text_width,
            mode = '~',
            alpha = 1,
        }
    end

    local text = 'keybinds'
    local x, y = hotkeys_dragging:get()

    local height_offset = 23
    local w, h = 60 + maximum_offset, 50

    if ui.get(funcs.visuals.ui_style) then -- чекбокс на глоу красивее но фпсик жрет
        container_glow(x, y + 2, w, 18, r, g, b, GLOBAL_ALPHA*a, GLOBAL_ALPHA*1.2, r, g, b)
    else
        container(x, y + 2, w, 18, r, g, b, GLOBAL_ALPHA*200,  GLOBAL_ALPHA*a)
    end

    renderer.text(x + w/2 - 20, y + 4, 255, 255, 255, GLOBAL_ALPHA*255, '', 0, text)

    for c_name, c_ref in pairs(m_active) do
        local key_type = '[' .. c_ref.mode .. ']'

        renderer.text(x + 5, y + height_offset, 255, 255, 255, GLOBAL_ALPHA*c_ref.alpha*255, '', 0, c_name)
        renderer.text(x + w - renderer.measure_text(nil, key_type) - 5, y + height_offset, 255, 255, 255, GLOBAL_ALPHA*c_ref.alpha*255, '', 0, key_type)

        height_offset = height_offset + 15
    end

    hotkeys_dragging:drag(w, (3 + (15 * item_count(m_active))) * 2)

    if item_count(m_active) > 0 and latest_item then
        GLOBAL_ALPHA = GLOBAL_ALPHA + frames; if GLOBAL_ALPHA > 1 then GLOBAL_ALPHA = 1 end
    else
        GLOBAL_ALPHA = GLOBAL_ALPHA - frames; if GLOBAL_ALPHA < 0 then GLOBAL_ALPHA = 0 end 
    end

    if ui.is_menu_open() then
        m_active['Menu toggled'] = nil
    end
end

local function spectator_list(r, g, b, a)
    local data_sp = spectators or { }
    local is_menu_open = ui.is_menu_open()
    local frames = 8 * globals.frametime()
    local unsorted = { }
    local m_alpha, m_active, m_contents, unsorted = 0, {}, {}, {}

    local latest_item = false
    local maximum_offset = 85

    local spectators, player = get_spectating_players()

    for i=1, 64 do 
        unsorted[i] = {
            idx = i,
            active = false
        }
    end

    if spectators[player] ~= nil then
        for _, spectator in pairs(spectators[player]) do
            unsorted[spectator] = { 
                idx = spectator,

                active = (function()
                    if spectator == entity.get_local_player() then
                        return false
                    end

                    return true
                end)(),

                avatar = (function()
                    if not data_sp.avatars then
                        return nil
                    end

                    local steam_id = entity.get_steam64(spectator)
                    local avatar = images.get_steam_avatar(steam_id)

                    if steam_id == nil or avatar == nil then
                        return nil
                    end

                    if m_contents[spectator] == nil or m_contents[spectator].conts ~= avatar.contents then
                        m_contents[spectator] = {
                            conts = avatar.contents,
                            texture = renderer.load_rgba(avatar.contents, avatar.width, avatar.height)
                        }
                    end

                    return m_contents[spectator].texture
                end)()
            }
        end
    end

    for _, c_ref in pairs(unsorted) do
        local c_id = c_ref.idx
        local c_nickname = entity.get_player_name(c_ref.idx)

        if c_ref.active then
            latest_item = true

            if m_active[c_id] == nil then
                m_active[c_id] = {
                    alpha = 0, offset = 0, active = true
                }
            end

            local text_width = renderer.measure_text(nil, c_nickname)

            m_active[c_id].active = true
            m_active[c_id].offset = text_width
            m_active[c_id].alpha = m_active[c_id].alpha + frames
            m_active[c_id].avatar = c_ref.avatar
            m_active[c_id].name = c_nickname

            if m_active[c_id].alpha > 1 then
                m_active[c_id].alpha = 1
            end
        elseif m_active[c_id] ~= nil then
            m_active[c_id].active = false
            m_active[c_id].alpha = m_active[c_id].alpha - frames

            if m_active[c_id].alpha <= 0 then
                m_active[c_id] = nil
            end
        end

        if m_active[c_id] ~= nil and m_active[c_id].offset > maximum_offset then
            maximum_offset = m_active[c_id].offset
        end
    end

    if is_menu_open and not latest_item then
        local case_name = ' '
        local text_width = renderer.measure_text(nil, case_name)

        latest_item = true
        maximum_offset = maximum_offset < text_width and text_width or maximum_offset

        m_active[case_name] = {
            name = '',
            active = true,
            offset = text_width,
            alpha = 1
        }
    end

    local text = 'spectators'
    local x, y = spec_dragging:get()

    local height_offset = 23
    local w, h = 55 + maximum_offset, 50

    w = w - (data_sp.avatars and 0 or 17) 

    local right_offset = data_sp.auto_position and (x+w/2) > (({ client.screen_size() })[1] / 2)

    if ui.get(funcs.visuals.ui_style) then
        container_glow(x, y + 2, w, 18, r, g, b, GLOBAL_ALPHA2*a, GLOBAL_ALPHA2*1.2, r, g, b)
    else
        container(x, y + 2, w, 18, r, g, b, GLOBAL_ALPHA2*200, GLOBAL_ALPHA2*a)
    end

    renderer.text(x - renderer.measure_text(nil, text) / 2 + w/2, y + 4, 255, 255, 255, GLOBAL_ALPHA2*255, '', 0, text)

    for c_name, c_ref in pairs(m_active) do
        local _, text_h = renderer.measure_text(nil, c_ref.name)

        renderer.text(x + ((c_ref.avatar and not right_offset) and text_h or -5) + 10, y + height_offset, 255, 255, 255, GLOBAL_ALPHA2*255, '', 0, c_ref.name)

        if c_ref.avatar ~= nil then
            renderer.texture(c_ref.avatar, x + (right_offset and w - 15 or 5), y + height_offset, text_h, text_h, 255, 255, 255, GLOBAL_ALPHA2*255, 'f')
        end

        height_offset = height_offset + 15
    end

    spec_dragging:drag(w, (3 + (15 * item_count(m_active))) * 2)

    if item_count(m_active) > 0 and latest_item then
        GLOBAL_ALPHA2 = GLOBAL_ALPHA2 + frames; if GLOBAL_ALPHA2 > 1 then GLOBAL_ALPHA2 = 1 end
    else
        GLOBAL_ALPHA2 = GLOBAL_ALPHA2 - frames; if GLOBAL_ALPHA2 < 0 then GLOBAL_ALPHA2 = 0 end 
    end

    if is_menu_open then
        m_active[' '] = nil
    end
end

local function watermark_render(r, g, b, a)
    local scrsize_x, scrsize_y = client.screen_size()
    local hour, minute, seconds, milliseconds = client.system_time()
    local delay = client.latency()
    if hour < 10 then hour = "0"..tostring(hour) end
    if minute < 10 then minute = "0"..tostring(minute) end
    if seconds < 10 then seconds = "0"..tostring(seconds) end
    local user = "NN1337"
    local build = "admin"
    local text = "NNSENSE["..build.."] "..user.." delay: "..delay.." time "..hour
    local width = renderer.measure_text(nil, text) + 9
    if ui.get(funcs.visuals.ui_style) then
        container_glow(scrsize_x - width - 5, 5, width, 20, r, g, b, a, 1.2, r, g, b)
    else
        container(scrsize_x - width - 5, 5, width, 20, r, g, b, 200, a)
    end
    renderer.text(scrsize_x - width, 8, 255, 255, 255, 255, nil, 0, "NNSE")
    renderer.text(scrsize_x - width + renderer.measure_text(nil, "NNSE"), 8, r, g, b, 255, nil, 0, "NSE")
    renderer.text(scrsize_x - width + renderer.measure_text(nil, "NNSENSE"), 8, 255, 255, 255, 255, nil, 0, "["..build.."] "..user.." delay: "..math.floor(delay*1000).." time "..hour..":"..minute..":"..seconds)
end

local function debug_panel(r, g, b, a)
    local x, y = debug_dragging:get()
    if ui.get(funcs.visuals.ui_style) then
        container_glow(x, y, 165, 43, r, g, b, a, 1.2, r, g, b)
    else
        container(x, y, 165, 43, r, g, b, 200, a)
    end
    local user = "NN1337"
    local build = "admin"
    renderer.text(x + 5, y + 3, 255, 255, 255, 255, nil, 0, "» NNSENSE anti aim")
    renderer.text(x + 5 + renderer.measure_text(nil, "» NNSENSE anti aim"), y + 3, r, g, b, 255, nil, 0, " technology")
    renderer.text(x + 5, y + 15, 255, 255, 255, 255, nil, 0, "» user: ")
    renderer.text(x + 5 + renderer.measure_text(nil, "» user: "), y + 15, r, g, b, 255, nil, 0, user)
    renderer.text(x + 5, y + 27, 255, 255, 255, 255, nil, 0, "» build: ")
    renderer.text(x + 5 + renderer.measure_text(nil, "» build: "), y + 27, r, g, b, 255, nil, 0, build)
    debug_dragging:drag(165, 43)
end

local function crosshair(r, g, b, a)
    local scrsize_x, scrsize_y = client.screen_size()
    local center_x, center_y = scrsize_x / 2, scrsize_y / 2

    if (vars.cur_alpha < vars.min_alpha + 2) then
        vars.target_alpha = vars.max_alpha
    elseif (vars.cur_alpha > vars.max_alpha - 2) then
        vars.target_alpha = vars.min_alpha
    end

    vars.cur_alpha = vars.cur_alpha + (vars.target_alpha - vars.cur_alpha) * vars.speed * (globals.absoluteframetime() * 100)

    local bodyyaw = entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) * 120 - 60
    
    local angle = math.abs(bodyyaw)

    local active_weapon = entity.get_prop(entity.get_local_player(), "m_hActiveWeapon")

    if active_weapon == nil then return end

    local zoom_lvl = entity.get_prop(active_weapon, 'm_zoomLevel')
    local nextAttack = entity.get_prop(entity.get_local_player(),"m_flNextAttack") 
    local nextShot = entity.get_prop(active_weapon,"m_flNextPrimaryAttack")
    local nextShotSecondary = entity.get_prop(active_weapon,"m_flNextSecondaryAttack")

    if nextAttack == nil or nextShot == nil or nextShotSecondary == nil then return end

    nextAttack = nextAttack + 0.5
    nextShot = nextShot + 0.5
    nextShotSecondary = nextShotSecondary + 0.5

    if bodyyaw > 10 then
        side = "R"
    elseif bodyyaw < -10 then
        side = "L"
    else
        side = "0"
    end

    if ui.get(funcs.visuals.center_ind_style) == "First" then
        renderer.text(center_x - 32, center_y + 20, 255, 255, 255, 255, '-', 0, "NNSENSEYAW")
        renderer.text(center_x + 13, center_y + 20, r, g, b, vars.cur_alpha, '-', 0, "BETA")
        renderer.text(center_x - 20, center_y + 30, r, g, b, 255, '-', 0, "FAKE YAW")
        renderer.text(center_x + 15, center_y + 30, 255, 255, 255, 255, '-', 0, side)
        renderer.triangle(center_x + 55, center_y + 2, center_x + 42, center_y - 7, center_x + 42, center_y + 11, ui.get(refs.yaw[2]) == 90 and r or 35, ui.get(refs.yaw[2]) == 90 and g or 35, ui.get(refs.yaw[2]) == 90 and b or 35, ui.get(refs.yaw[2]) == 90 and 255 or 150)
        renderer.triangle(center_x - 55, center_y + 2, center_x - 42, center_y - 7, center_x - 42, center_y + 11, ui.get(refs.yaw[2]) == -90 and r or 35, ui.get(refs.yaw[2]) == -90 and g or 35, ui.get(refs.yaw[2]) == -90 and b or 35, ui.get(refs.yaw[2]) == -90 and 255 or 150)
        renderer.rectangle(center_x + 38, center_y - 7, 2, 18, bodyyaw < -10 and r or 35, bodyyaw < -10 and g or 35, bodyyaw < -10 and b or 35, bodyyaw < -10 and 255 or 150)
        renderer.rectangle(center_x - 40, center_y - 7, 2, 18, bodyyaw > 10 and r or 35, bodyyaw > 10 and g or 35, bodyyaw > 10 and b or 35, bodyyaw > 10 and 255 or 150)
        if ui.get(refs.dt[2]) then
            if ui.get(refs.os_aa[2]) then
                renderer.text( center_x-16, center_y+50, 255, 0, 0, 255, "-", 0, "ONSHOT")
            end
            if math.max(nextShot,nextShotSecondary) < nextAttack then
                if nextAttack - globals.curtime() > 0.00 then
                    renderer.text( center_x-6, center_y+40, 255, 0, 0, 255, "-", 0, "DT")
                else
                    renderer.text( center_x-6, center_y+40, 132, 196, 20, 255, "-", 0, "DT")
                end
            else
                if math.max(nextShot,nextShotSecondary) - globals.curtime() > 0.00  then
                    renderer.text( center_x-6, center_y+40, 255, 0, 0, 255, "-", 0, "DT")
                else
                    if math.max(nextShot,nextShotSecondary) - globals.curtime() < 0.00  then
                        renderer.text( center_x-6, center_y+40, 132, 196, 20, 255, "-", 0, "DT")
                    else
                        renderer.text( center_x-6, center_y+40, 132, 196, 20, 255, "-", 0, "DT")
                    end
                end
            end
        else
            if ui.get(refs.os_aa[2]) then
                renderer.text( center_x-16, center_y+40, 132, 196, 20, 255, "-", 0, "ONSHOT")
            end
        end
    else
        renderer.triangle(center_x + 55, center_y + 2, center_x + 42, center_y - 7, center_x + 42, center_y + 11, ui.get(refs.yaw[2]) == 90 and r or 35, ui.get(refs.yaw[2]) == 90 and g or 35, ui.get(refs.yaw[2]) == 90 and b or 35, ui.get(refs.yaw[2]) == 90 and 255 or 150)
        renderer.triangle(center_x - 55, center_y + 2, center_x - 42, center_y - 7, center_x - 42, center_y + 11, ui.get(refs.yaw[2]) == -90 and r or 35, ui.get(refs.yaw[2]) == -90 and g or 35, ui.get(refs.yaw[2]) == -90 and b or 35, ui.get(refs.yaw[2]) == -90 and 255 or 150)
        renderer.rectangle(center_x + 38, center_y - 7, 2, 18, bodyyaw < -10 and r or 35, bodyyaw < -10 and g or 35, bodyyaw < -10 and b or 35, bodyyaw < -10 and 255 or 150)
        renderer.rectangle(center_x - 40, center_y - 7, 2, 18, bodyyaw > 10 and r or 35, bodyyaw > 10 and g or 35, bodyyaw > 10 and b or 35, bodyyaw > 10 and 255 or 150)
        renderer.text(center_x - 23, center_y + 20, r, g, b, 255, '-', 0, "NNSENSEYAW")
        renderer.rectangle(center_x - 30/1.5, center_y + 34, 60/1.5, 2, 35, 35, 35, 100)
        renderer.gradient(center_x - 30/1.5, center_y + 34, angle/1.5, 2, r, g, b, 255, r, g, b, 255, true)
        if ui.get(refs.dt[2]) then
            if ui.get(refs.os_aa[2]) then
                renderer.text( center_x-12, center_y+50, 255, 0, 0, 255, "-", 0, "OS-AA")
            end
            if math.max(nextShot,nextShotSecondary) < nextAttack then
                if nextAttack - globals.curtime() > 0.00 then
                    renderer.text( center_x-11.5, center_y+40, 255, 0, 0, 255, "-", 0, "RAPID")
                else
                    renderer.text( center_x-11.5, center_y+40, 255, 255, 255, 255, "-", 0, "RAPID")
                end
            else
                if math.max(nextShot,nextShotSecondary) - globals.curtime() > 0.00  then
                    renderer.text( center_x-11.5, center_y+40, 255, 0, 0, 255, "-", 0, "RAPID")
                else
                    if math.max(nextShot,nextShotSecondary) - globals.curtime() < 0.00  then
                        renderer.text( center_x-11.5, center_y+40, 255, 255, 255, 255, "-", 0, "RAPID")
                    else
                        renderer.text( center_x-11.5, center_y+40, 255, 255, 255, 255, "-", 0, "RAPID")
                    end
                end
            end
        else
            if ui.get(refs.os_aa[2]) then
                renderer.text( center_x-12, center_y+40, 132, 196, 20, 255, "-", 0, "OS-AA")
            end
        end
    end
end

client.set_event_callback('paint', function()
    local r, g, b, a = ui.get(funcs.visuals.color)

    if contains(funcs.visuals.ui_ind, "Watermark") then
        watermark_render(r, g, b, a)
    end

    if not entity.is_alive(entity.get_local_player()) or entity.get_local_player() == nil then return end

    if ui.get(funcs.visuals.debug_panel) then
        debug_panel(r, g, b, a)
    end

    if ui.get(funcs.visuals.center_ind) then
        crosshair(r, g, b, a)
    end

    if contains(funcs.visuals.ui_ind, "Keybinds") then
        keybind_list(r, g, b, a)
    end

    if contains(funcs.visuals.ui_ind, "Spectators") then
        spectator_list(r, g, b, a)
    end
end)

create_item('RAGE', 'Aimbot', 'Force safe point', 1, 'Safe point')
create_item('RAGE', 'Other', 'Quick stop', 2)
create_item('RAGE', 'Other', 'Force body aim', 1)
create_item('RAGE', 'Other', 'Quick peek assist', 2)
create_item('RAGE', 'Other', 'Duck peek assist', 1)
create_item('RAGE', 'Other', 'Double tap', 2)
create_item('AA', 'Anti-aimbot angles', 'Freestanding', 2)
create_item('AA', 'Other', 'Slow motion', 2)
create_item('AA', 'Other', 'On shot anti-aim', 2)
create_item('MISC', 'Movement', 'Jump at edge', 2)
create_item('MISC', 'Miscellaneous', 'Ping spike', 2)

local function show_aatab(value)
    for _, k in pairs(funcs.anti_aim) do
        ui.set_visible(k, value)
    end
end

local function show_vistab(value)
    for _, k in pairs(funcs.visuals) do
        ui.set_visible(k, value)
    end
end

local function show_cfgtab(value)
    ui.set_visible(presetlist, value)
    ui.set_visible(load_cfg_but, value)
    ui.set_visible(delete_cfg_but, value)
    ui.set_visible(presetname, value)
    ui.set_visible(save_cfg_but, value)
end

local function hideall_custom(value)
    for p = 1, 12 do
        for _, k in pairs(custom_aa[p]) do
            ui.set_visible(k, value)
        end
    end
end

local function hidecur_custom(value, tabnum)
    ui.set_visible(custom_aa[tabnum].enabled, value)
    if not ui.get(custom_aa[tabnum].enabled) then return end
    for _, k in pairs(custom_aa[tabnum]) do
        ui.set_visible(k, value)
    end
end

local function hideadd_custom(tabnum)
    if not ui.get(custom_aa[tabnum].enabled) then return end
    if ui.get(custom_aa[tabnum].yaw_mode) == "Default" then
        ui.set_visible(custom_aa[tabnum].yaw_slider_next, false)
    else
        ui.set_visible(custom_aa[tabnum].yaw_slider_next, true)
    end

    if ui.get(custom_aa[tabnum].yaw_mode) == "Flick" then
        ui.set_visible(custom_aa[tabnum].flick_delay, true)
    else
        ui.set_visible(custom_aa[tabnum].flick_delay, false)
    end

    if ui.get(custom_aa[tabnum].yaw_jitter) == "Off" then
        ui.set_visible(custom_aa[tabnum].yaw_jitter_slider, false)
    else
        ui.set_visible(custom_aa[tabnum].yaw_jitter_slider, true)
    end

    if ui.get(custom_aa[tabnum].yaw_body) == "Off" or ui.get(custom_aa[tabnum].yaw_body) == "Opposite" then
        ui.set_visible(custom_aa[tabnum].yaw_body_slider, false)
    else
        ui.set_visible(custom_aa[tabnum].yaw_body_slider, true)
    end

    if not contains(custom_aa[tabnum].additions, "Anti-Bruteforce") then
        ui.set_visible(custom_aa[tabnum].antibruteforce_time, false)
        ui.set_visible(custom_aa[tabnum].highjitter_antibrute, false)
    else
        ui.set_visible(custom_aa[tabnum].antibruteforce_time, true)
        ui.set_visible(custom_aa[tabnum].highjitter_antibrute, true)
    end

    if not contains(custom_aa[tabnum].additions, "Freestanding") then
        ui.set_visible(custom_aa[tabnum].freestanding_mode, false)
        ui.set_visible(custom_aa[tabnum].freestanding_type, false)
    else
        ui.set_visible(custom_aa[tabnum].freestanding_mode, true)
        ui.set_visible(custom_aa[tabnum].freestanding_type, true)
    end
    
    if not contains(custom_aa[tabnum].additions, "Reset Angle") then
        ui.set_visible(custom_aa[tabnum].resetangle_ang, false)
    else
        ui.set_visible(custom_aa[tabnum].resetangle_ang, true)
    end

    if ui.get(custom_aa[tabnum].fake_yaw_mode) == "Default" then
        ui.set_visible(custom_aa[tabnum].fake_slider_next, false)
    else
        ui.set_visible(custom_aa[tabnum].fake_slider_next, true)
    end

    if ui.get(custom_aa[tabnum].fake_yaw_mode) ~= "Flick" then
        ui.set_visible(custom_aa[tabnum].flick_delay2, false)
    else
        ui.set_visible(custom_aa[tabnum].flick_delay2, true)
    end
end

local function hide_lua(value)
    ui.set_visible(funcs.tab_select, value)
    ui.set_visible(funcs.lua_text, value)
    ui.set_visible(funcs.old_lua_text, value)
    show_aatab(value)
    show_vistab(value)
end

local function hide_refs(value)
    value = not value

    ui.set_visible(ui.reference("AA", "Anti-aimbot angles", "Enabled"), value)
    ui.set_visible(refs.edge_yaw, value)
    ui.set_visible(refs.fs[1], value)
    ui.set_visible(refs.fs[2], value)
    ui.set_visible(refs.pitch, value)
    ui.set_visible(refs.yaw_target, value)
    ui.set_visible(refs.yaw[1], value)
    ui.set_visible(refs.yaw[2], value)
    ui.set_visible(refs.jyaw[1], value)
    ui.set_visible(refs.jyaw[2], value)
    ui.set_visible(refs.byaw[1], value)
    ui.set_visible(refs.byaw[2], value)
    ui.set_visible(refs.fs_body_yaw, value)
    ui.set_visible(refs.fake_yaw, value)
    ui.set_visible(refs.roll_aa, value)
end

client.set_event_callback("paint_ui", function()
    local edgeyawkey_rf, edgeyawactive_rf, edgeyawbind_rf = ui.get(funcs.anti_aim.edgeyaw_key)
    local freestandkey_rf, freestandactive_rf, freestandbind_rf = ui.get(funcs.anti_aim.freestand_key)
    local cond_num = { ["Global"] = 1, ["Standing"] = 2, ["Moving"] = 3, ["Slow-motion"] = 4, ["Air"] = 5, ["Air-Crouch"] = 6, ["Crouching"] = 7, ["Legit-key"] = 8, ["Dormant"] = 9, ["High Ground"] = 10, ["Lethal"] = 11, ["On Shot"] = 12 }
    hide_refs(ui.get(funcs.enable))
    hide_lua(ui.get(funcs.enable))
    hideall_custom(false)
    show_cfgtab(false)
    if not ui.get(funcs.enable) then return end
    if ui.get(funcs.tab_select) == "Anti-Aim" then
        hideall_custom(false)
        hidecur_custom(true, cond_num[ui.get(funcs.anti_aim.tab_cond)])
        ui.set_visible(custom_aa[1].enabled, false)
        ui.set(custom_aa[1].enabled, true)
        show_cfgtab(false)
        hideadd_custom(cond_num[ui.get(funcs.anti_aim.tab_cond)])
        show_aatab(true)
        if edgeyawkey_rf or edgeyawbind_rf ~= nil then 
            ui.set_visible(funcs.anti_aim.disable_edgeyaw, true)
        else
            ui.set_visible(funcs.anti_aim.disable_edgeyaw, false)
        end
        if freestandkey_rf or freestandbind_rf ~= nil then 
            ui.set_visible(funcs.anti_aim.disable_freestand, true)
        else
            ui.set_visible(funcs.anti_aim.disable_freestand, false)
        end
        if not contains(funcs.anti_aim.features, "[Yaw Management]") then
            ui.set_visible(funcs.anti_aim.left_key, false)
            ui.set_visible(funcs.anti_aim.right_key, false)
            ui.set_visible(funcs.anti_aim.back_key, false)
            ui.set_visible(funcs.anti_aim.forward_key, false)
            ui.set_visible(funcs.anti_aim.freestand_key, false)
            ui.set_visible(funcs.anti_aim.edgeyaw_key, false)
            ui.set_visible(funcs.anti_aim.disable_edgeyaw, false)
            ui.set_visible(funcs.anti_aim.disable_freestand, false)
        end
        if not contains(funcs.anti_aim.features, "[Anti-Aim on Use]") then
            ui.set_visible(funcs.anti_aim.legit_key, false)
        end
        show_vistab(false)
        show_cfgtab(false)
    elseif ui.get(funcs.tab_select) == "Visuals" then
        hideall_custom(false)
        show_aatab(false)
        show_vistab(true)
        show_cfgtab(false)
        if not contains(funcs.visuals.ui_ind, "Watermark") and not contains(funcs.visuals.ui_ind, "Keybinds") and not contains(funcs.visuals.ui_ind, "Hud") then
            ui.set_visible(funcs.visuals.ui_style, false)
        end
        if not ui.get(funcs.visuals.center_ind) then
            ui.set_visible(funcs.visuals.center_ind_style, false)
        end
    else
        hideall_custom(false)
        show_aatab(false)
        show_vistab(false)
        show_cfgtab(true)
    end
end)

client.set_event_callback("shutdown", function()
    hide_refs(false)
end)
