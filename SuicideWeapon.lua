behaviour("SuicideWeapon") --v1.0.1

function SuicideWeapon:Start()
    if self.targets.weaponObject ~= nil then
        self.weaponObject = self.targets.weaponObject.GetComponent(Weapon)
    else
        self.weaponObject = self.gameObject.GetComponent(Weapon)
    end

    self.weaponObject.onSpawnProjectiles.AddListener(self, "OnFire")
end

function SuicideWeapon:OnFire()
    self.weaponObject.user:Kill(self.weaponObject.user)
end
