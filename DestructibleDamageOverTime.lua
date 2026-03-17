behaviour("DestructibleDamageOverTime") --v1.0.0

function DestructibleDamageOverTime:OnEnable()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.vehicle = self.targets.vehicle.GetComponent(Vehicle)

    self.damage = self.dataContainer.GetFloat("damage")
    self.finish = Time.time + self.dataContainer.GetFloat("duration")
end

function DestructibleDamageOverTime:Update()
    if Time.time <= self.finish then
        self.vehicle.Damage(nil, self.damage * Time.deltaTime)
    end
end