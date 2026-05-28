behaviour("DisableReloadIfBulletExists") --v1.0.1

function DisableReloadIfBulletExists:Start()
    self.weapon = self.gameObject.GetComponent(Weapon)

    self.weapon.onSpawnProjectiles.AddListener(self, "onFire")

    self.lastProjectile = nil
end

function DisableReloadIfBulletExists:Update()
    if self.lastProjectile == nil then
        self.weapon.spareAmmo = 1
    else
        if self.lastProjectile.isActive then
            self.weapon.spareAmmo = 0
        else
            self.weapon.spareAmmo = 1
        end
    end
end

function DisableReloadIfBulletExists:onFire(projectile)
    self.lastProjectile = projectile[1]
end
