behaviour("PlaneGearBlockWeapon") --v1.0.0

function PlaneGearBlockWeapon:Start()
    self.gearScript = self.targets.gearScript.GetComponent(ScriptedBehaviour).self
    self.weapon = self.targets.weapon.GetComponent(Weapon)
end

function PlaneGearBlockWeapon:Update()
    if self.gearScript.gearDown then
        self.weapon.LockWeapon()
    else
        self.weapon.UnlockWeapon()
    end
end