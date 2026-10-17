behaviour("DoubleReload") --v1.0.1

function DoubleReload:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.weapon = self.targets.weapon.GetComponent(Weapon)
    self.weapon.onSpawnProjectiles.AddListener(self, "onFire")

    self.barrelCount = self.dataContainer.GetInt("barrelCount")
    self.reloadDuration = self.dataContainer.GetFloat("reloadDuration")

    self.reloadEnd = {}

    for i = 1, self.barrelCount do
        self.reloadEnd[i] = -1
    end
end

function DoubleReload:Update()
    for i, time in pairs(self.reloadEnd) do
        if time <= Time.time then
            self.reloadEnd[i] = -1

            self.weapon.ammo = self.weapon.ammo + 1
        end
    end
end

function DoubleReload:onFire()
    for i, time in pairs(self.reloadEnd) do
        if time < 0 then
            self.reloadEnd[i] = Time.time + self.reloadDuration
        end
    end
end
