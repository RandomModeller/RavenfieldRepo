behaviour("CustomAmmoBelt") --v1.0.0

function CustomAmmoBelt:Start()
    self.weapon = self.gameObject.GetComponent(Weapon)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.weapon.onSpawnProjectiles.AddListener(self, "onFire")

    self.belt = self.dataContainer.GetGameObjectArray("projectile")

    self.counter = 0
end

function CustomAmmoBelt:onFire()
    self.counter = (self.counter + 1) % #self.belt

    self.weapon.SetProjectilePrefab(self.belt[self.counter + 1])
end