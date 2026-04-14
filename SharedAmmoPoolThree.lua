behaviour("SharedAmmoPoolThree") --v1.0.1

function SharedAmmoPoolThree:Start()
    self.mainWep = self.targets.main.GetComponent(Weapon)
    self.secondaryWep = self.targets.secondary.GetComponent(Weapon)
    self.tertiaryWep = self.targets.tertiary.GetComponent(Weapon)
end

function SharedAmmoPoolThree:Update()
    local activeWeapon

    if self.mainWep.activeSubWeapon == self.secondaryWep then
        activeWeapon = self.secondaryWep
    elseif self.mainWep.activeSubWeapon == self.tertiaryWep then
        activeWeapon = self.tertiaryWep
    else
        activeWeapon = self.mainWep
    end

    if Input.GetKeyBindButtonDown(KeyBinds.FireMode) then
        if activeWeapon.isReloading then
            return
        end

        if activeWeapon == self.mainWep then            
            self.mainWep.ammo = self.tertiaryWep.ammo
            self.mainWep.spareAmmo = self.tertiaryWep.spareAmmo
        end
        if activeWeapon == self.secondaryWep then
            self.secondaryWep.ammo = self.mainWep.ammo
            self.secondaryWep.spareAmmo = self.mainWep.spareAmmo
        end
        if activeWeapon == self.tertiaryWep then
            self.tertiaryWep.ammo = self.secondaryWep.ammo
            self.tertiaryWep.spareAmmo = self.secondaryWep.spareAmmo
        end
    end
end
