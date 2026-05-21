behaviour("CustomAmmoBelt") --v1.1.2

function CustomAmmoBelt:Start()
    self.weapon = self.gameObject.GetComponent(Weapon)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.weapon.onFire.AddListener(self, "onFire")

    self.belt = self.dataContainer.GetGameObjectArray("projectile")

    self.fireRandom = false
    if self.dataContainer.HasBool("fireRandom") then
        self.fireRandom = self.dataContainer.GetBool("fireRandom")
    end

    self.counter = 0
end

function CustomAmmoBelt:onFire()
    if self.fireRandom then
        self.weapon.SetProjectilePrefab(self.belt[Mathf.Round(Random.Range(1, #self.belt))])
        return
    end

    self.counter = (self.counter + 1) % #self.belt

    self.weapon.SetProjectilePrefab(self.belt[self.counter + 1])
end
