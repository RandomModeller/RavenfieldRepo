behaviour("ResetWeaponIndexWhenReloading") --v1.0.0

function ResetWeaponIndexWhenReloading:Start()
    self.weaponObject = self.targets.weaponObject.GetComponent(Weapon)

    self.last = self.weaponObject.isReloading
end

function ResetWeaponIndexWhenReloading:Update()
    if self.weaponObject.isReloading ~= self.last then
        if not self.weaponObject.isReloading then
            self.weaponObject.currentMuzzleIndex = 0
        end
        
        self.last = self.weaponObject.isReloading
    end
end