behaviour("CannonAmmoSwitcher") --v1.0.0

function CannonAmmoSwitcher:Start()
    self.weapon = self.gameObject.GetComponent(Weapon)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.projectiles = self.dataContainer.GetGameObjectArray("projectile")
end

function CannonAmmoSwitcher:Update()
    if self.weapon.isReloading then
        self.weapon.SetProjectilePrefab(self.projectiles[self.weapon.activeSightModeIndex + 1])
    end
end
