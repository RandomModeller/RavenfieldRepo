behaviour("DisableReloadIfBulletExists") --v1.0.0

function DisableReloadIfBulletExists:Start()
    self.weapon = self.gameObject.GetComponent(Weapon)

    self.weapon.onSpawnProjectiles.AddListener(self, "onFire")

    self.lastProjectile = nil
end

function DisableReloadIfBulletExists:Update()
    if self.lastProjectile == nil then
        self.weapon:UnlockWeapon()
    else
        if self.lastProjectile.isActive then
            self.weapon:LockWeapon()
        else
            self.weapon:UnlockWeapon()
        end
    end
end

function DisableReloadIfBulletExists:onFire(projectile)
    self.lastProjectile = projectile[1]
end