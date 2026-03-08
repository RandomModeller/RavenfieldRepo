behaviour("DisplaySpeedRotation") --v1.1.0

function DisplaySpeedRotation:Start()
    self.dataCon = self.gameObject.GetComponent(DataContainer)

    self.transform = self.gameObject.transform

    if self.targets.avionics then
        self.avionics = self.targets.avionics.GetComponent(ScriptedBehaviour).self
    elseif self.targets.radar then
        self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    elseif self.targets.rigidbody then
        self.rigidbody = self.targets.rigidbody.GetComponent(Rigidbody)
    end

    self.multiplier = self.dataCon.GetFloat("multiplier")
    self.vector = self.dataCon.GetVector("rotation")
    self.offset = Vector3.zero
    if self.dataCon.HasVector("offset") then
        self.offset = self.dataCon.GetVector("offset")
    end
end

function DisplaySpeedRotation:Update()
    local speed = 0

    if self.avionics then
        speed = self.avionics.mach
    elseif self.radar then
        if self.radar.lockedVehicle then
            speed = self.radar.lockedVehicle.rigidbody.velocity.magnitude
        end
    elseif self.rigidbody then
        speed = self.rigidbody.velocity.magnitude
    end

    self.transform.localEulerAngles = self.vector * speed * self.multiplier + self.offset
end
