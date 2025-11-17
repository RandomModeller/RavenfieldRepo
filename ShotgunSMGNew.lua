behaviour("ShotgunSMGNew")

function ShotgunSMGNew:Start()
    self.shotgun = self.targets.shotgun.GetComponent(Weapon)
    self.smg = self.targets.smg.GetComponent(Weapon)
    self.shotgun.onSpawnProjectiles.AddListener(self, "OnShotgunFire")
    self.smg.onSpawnProjectiles.AddListener(self, "OnSMGFire")

    self.ammo = self.smg.ammo
    self.maxSmg = self.smg.maxAmmo
    self.maxShotgun = self.shotgun.maxAmmo

    self.lastSmg = self.maxSmg
    self.lastShotgun = self.maxShotgun

    self.hasDepleted = false
end

function ShotgunSMGNew:Update()
    self.shotgun.projectilesPerShot = Mathf.Min(3, self.ammo)

    if (self.smg.ammo == self.maxSmg or self.shotgun.ammo == self.maxShotgun) and self.hasDepleted then
        self.ammo = self.maxSmg
        self.hasDepleted = false
    end
end

function ShotgunSMGNew:OnShotgunFire()
    self.ammo = self.ammo - 3
    self.hasDepleted = true

    self:UpdateAmmo()
end

function ShotgunSMGNew:OnSMGFire()
    self.ammo = self.ammo - 1
    self.hasDepleted = true

    self:UpdateAmmo()
end

function ShotgunSMGNew:UpdateAmmo()
    self.smg.ammo = Mathf.Max(self.ammo, 0)
    self.shotgun.ammo = Mathf.Max(self.ammo, 0)
end