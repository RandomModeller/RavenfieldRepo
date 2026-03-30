behaviour("ExplosionTrigger") --v1.0.0

function ExplosionTrigger:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.vehicle = self.targets.vehicle.GetComponent(Vehicle)

    self.range = self.dataContainer.GetFloat("range")

    self.transform = self.gameObject.transform
end

function ExplosionTrigger:Update()
    local ray = Ray(self.transform.position, self.transform.forward)
    local raycast = Physics.Raycast(ray, self.range, RaycastTarget.Opaque)
    if raycast ~= nil then
        self.vehicle.Damage(self.vehicle.driver, self.vehicle.health)
    end
end