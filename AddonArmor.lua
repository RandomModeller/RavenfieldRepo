behaviour("AddonArmor") --v1.0.1

function AddonArmor:Start()
    self.finished = false
end

function AddonArmor:Init()
    if self.targets.destructible == nil then
        self.destructible = self.gameObject.GetComponent(Destructible)
    else
        self.destructible = self.targets.destructible.GetComponent(Destructible)
    end
    self.vehicle = self.targets.vehicle.GetComponent(Vehicle)

    self.destructible.onTakeDamage.AddListener(self, "OnTakeDamage")

    self.finished = true
end

function AddonArmor:Update()
    if not self.finished then
        self:Init()
    end
end

function AddonArmor:OnTakeDamage(info)
    local damage = info.healthDamage - self.destructible.health

    if damage > 0 then
        self.vehicle.Damage(info.sourceActor, damage)
    end
end
