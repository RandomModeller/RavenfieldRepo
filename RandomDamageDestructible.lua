behaviour("RandomDamageDestructible") --v1.0.0

function RandomDamageDestructible:Start()
    self.finished = false
end

function RandomDamageDestructible:Init()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.damageMultiplierMin = self.dataContainer.GetFloat("damageMultiplierMin")
    self.damageMultiplierMax = self.dataContainer.GetFloat("damageMultiplierMax")

    if self.targets.destructible == nil then
        self.destructible = self.gameObject.GetComponent(Destructible)
    else
        self.destructible = self.targets.destructible.GetComponent(Destructible)
    end
    self.vehicle = self.targets.vehicle.GetComponent(Vehicle)

    self.destructible.onTakeDamage.AddListener(self, "OnTakeDamage")

    self.finished = true
end

function RandomDamageDestructible:Update()
    if not self.finished then
        self:Init()
    end
end

function RandomDamageDestructible:OnTakeDamage(info)
    if info.healthDamage > 0 then
        self.vehicle.Damage(info.sourceActor, info.healthDamage * Random.Range(self.damageMultiplierMin, self.damageMultiplierMax))
    end
end