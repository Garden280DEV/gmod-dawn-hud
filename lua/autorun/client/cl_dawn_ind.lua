local radius = ScrH() * .1

local small_dmg_sound = Sound('clk.ogg')
local big_dmg_sound = Sound('lowed_clk.ogg')

local attack_indicators = {}
local damage_indicators = {}

CreateClientConVar('dawnhud_client_sound_normal_enabled', '1', true)
CreateClientConVar('dawnhud_client_sound_strong_enabled', '1', true)
CreateClientConVar('dawnhud_client_upper_enabled', '1', true)
CreateClientConVar('dawnhud_client_lower_enabled', '1', true)
CreateClientConVar('dawnhud_client_upper_r', '255', true)
CreateClientConVar('dawnhud_client_upper_g', '255', true)
CreateClientConVar('dawnhud_client_upper_b', '255', true)
CreateClientConVar('dawnhud_client_lower_r', '247', true)
CreateClientConVar('dawnhud_client_lower_g', '41', true)
CreateClientConVar('dawnhud_client_lower_b', '21', true)
CreateClientConVar('dawnhud_max_indicators', '5', true, false, '', 1, 15)
CreateClientConVar('dawnhud_lifetime', '5', true, false, '', 2, 10)

hook.Add('AddToolMenuTabs', 'myHookClass', function()
	spawnmenu.AddToolCategory('Options', 'dawnHUDCategory', 'Dawn HUD') -- Add a category into that new tab

    spawnmenu.AddToolMenuOption('Options', 'dawnHUDCategory', 'dawnHUDOptionServerSide', 'ServerSide', '', '', function(panel)
		panel:CheckBox("#dawnhud.toggler", 'dawnhud_enabled')
	end)
 
	spawnmenu.AddToolMenuOption('Options', 'dawnHUDCategory', 'dawnHUDOptionClientSide', 'ClientSide', '', '', function(panel)
		panel:CheckBox("#dawnhud.sound_normal", 'dawnhud_client_sound_normal_enabled')
		panel:CheckBox("#dawnhud.sound_strong", 'dawnhud_client_sound_strong_enabled')
		panel:CheckBox("#dawnhud.upper_toggler", 'dawnhud_client_upper_enabled')
        panel:CheckBox("#dawnhud.lower_toggler", 'dawnhud_client_lower_enabled')
        panel:NumSlider("#dawnhud.max_inds", 'dawnhud_max_indicators', 1, 15, 0)
        panel:NumSlider("#dawnhud.lifetime", 'dawnhud_lifetime', 2, 10, 0)
        panel:ColorPicker("#dawnhud.upper_picker", 'dawnhud_client_upper_r', 'dawnhud_client_upper_g', 'dawnhud_client_upper_b')
        panel:ColorPicker("#dawnhud.lower_picker", 'dawnhud_client_lower_r', 'dawnhud_client_lower_g', 'dawnhud_client_lower_b')
	end)
end)

net.Receive('DawnHUDAlertAttacker', function(len, ply)
    if GetConVar('dawnhud_client_upper_enabled'):GetBool() then
        local dmg = net.ReadUInt(16)

        if dmg < 100 then
            if GetConVar('dawnhud_client_sound_normal_enabled'):GetBool() then
				surface.PlaySound(small_dmg_sound)
			end
        else
			if GetConVar('dawnhud_client_sound_strong_enabled'):GetBool() then
				surface.PlaySound(big_dmg_sound)
			end
        end

        table.insert(attack_indicators, {dmg=dmg, startTime=CurTime()})
    end
end)

net.Receive('DawnHUDAlertVictim', function(len, ply)
    if GetConVar('dawnhud_client_lower_enabled'):GetBool() then
        local dmg = net.ReadUInt(16)
        table.insert(damage_indicators, {dmg=dmg, startTime=CurTime()})
    end
end)

hook.Add('HUDPaint', 'DawnHUDPaint', function()
    local time = CurTime()
    local dead_attack_indicator_count = 0
    local dead_damage_indicator_count = 0

    if #attack_indicators > GetConVar('dawnhud_max_indicators'):GetInt() then
        table.remove(attack_indicators, 1)
    end

    if #damage_indicators > GetConVar('dawnhud_max_indicators'):GetInt() then
        table.remove(damage_indicators, 1)
    end

    for i, v in ipairs(attack_indicators) do
        local delta_time = (time - v.startTime)
        local alpha = 255 - delta_time * (255 / (GetConVar('dawnhud_lifetime'):GetInt() - 1))

        if delta_time > GetConVar('dawnhud_lifetime'):GetInt() - 1 then
            table.remove(attack_indicators, 1)
            continue
        end

        local pos_x = math.sin(math.rad((180 / (#attack_indicators + 1) * i + 90))) * radius + ScrW() * .5
        local pos_y = math.cos(math.rad((180 / (#attack_indicators + 1) * i + 90))) * radius + ScrH() * .5

        local color = Color(
            GetConVar('dawnhud_client_upper_r'):GetInt(),
            GetConVar('dawnhud_client_upper_g'):GetInt(),
            GetConVar('dawnhud_client_upper_b'):GetInt(),
            alpha
        )

        draw.SimpleTextOutlined(v.dmg, 'DermaDefaultBold', pos_x, pos_y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
    end

    for i, v in ipairs(damage_indicators) do
        local delta_time = (time - v.startTime)
        local alpha = 255 - delta_time * (255 / (GetConVar('dawnhud_lifetime'):GetInt() - 1))

        if delta_time > GetConVar('dawnhud_lifetime'):GetInt() - 1 then
            table.remove(damage_indicators, 1)
            continue
        end

        local pos_x = math.sin(math.rad((180 / (#damage_indicators + 1) * i - 90))) * radius + ScrW() * .5
        local pos_y = math.cos(math.rad((180 / (#damage_indicators + 1) * i - 90))) * radius + ScrH() * .5

        local color = Color(
            GetConVar('dawnhud_client_lower_r'):GetInt(),
            GetConVar('dawnhud_client_lower_g'):GetInt(),
            GetConVar('dawnhud_client_lower_b'):GetInt(),
            alpha
        )

        draw.SimpleTextOutlined(v.dmg, 'DermaDefaultBold', pos_x, pos_y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
    end
end)