behaviour("DisplaySpeedRotation")

function DisplaySpeedRotation:Start()
    self.dataCon = self.gameObject.GetComponent(DataContainer)

    self.transform = self.gameObject.transform

    if self.targets.avionics then
        self.avionics = self.targets.avionics.GetComponent(ScriptedBehaviour).self
    else
        self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    end

    self.multiplier = self.dataCon.GetFloat("multiplier")
    self.vector = self.dataCon.GetVector("rotation")
    self.offset = Vector3.zero
    if self.dataCon.HasVector("offset") then
        self.offset = self.dataCon.GetVector("offset")
    end
end

function DisplaySpeedRotation:Update()
    if self.avionics then
        self.transform.localEulerAngles = self.vector * self.avionics.mach * self.multiplier + self.offset
    elseif self.radar then
        if self.radar.lockedVehicle then
            self.transform.localEulerAngles = self.vector * self.radar.lockedVehicle.rigidbody.velocity.magnitude * self.multiplier + self.offset
        else
            self.transform.localEulerAngles = self.offset
        end
        return
    end
end
