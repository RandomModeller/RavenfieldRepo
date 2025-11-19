behaviour("DisableOnAmmoLessVehicle") -- v1.0.0

function DisableOnAmmoLessVehicle:Start()
    self.weapon = self.targets.weaponObject.GetComponent(Weapon)
    self.renderer = self.gameObject.GetComponent(Renderer)
    self.num = self.gameObject.GetComponent(DataContainer).GetInt("cap")
end

function DisableOnAmmoLessVehicle:Update()
    local isMore = self.weapon.ammo > self.num

    if isMore ~= self.renderer.enabled then
        self.renderer.enabled = isMore-- and not self.weapon.isReloading
    end
end