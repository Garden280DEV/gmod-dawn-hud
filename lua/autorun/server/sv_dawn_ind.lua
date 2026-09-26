util.AddNetworkString('DawnHUDAlertAttacker')
util.AddNetworkString('DawnHUDAlertVictim')

CreateConVar('dawnhud_enabled', '1')

hook.Add('EntityTakeDamage', 'DawnHUDTakeDamage', function(target, dmg)
	if not GetConVar('dawnhud_enabled'):GetBool() then return end

    if dmg:GetAttacker():IsPlayer() and dmg:GetAttacker():IsValid() and (target:IsNPC() or target:IsPlayer() or target:IsNextBot()) then
        net.Start('DawnHUDAlertAttacker')
        net.WriteUInt(dmg:GetDamage(), 16)
        net.Send(dmg:GetAttacker())
    end

    if target:IsPlayer() and target:IsValid() and dmg:GetAttacker():IsValid() then
        net.Start('DawnHUDAlertVictim')
        net.WriteUInt(dmg:GetDamage(), 16)
        net.Send(target)
    end
end)