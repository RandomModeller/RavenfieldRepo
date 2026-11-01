behaviour("DisplayHeightBarometricRotation") --v1.0.0

function DisplayHeightBarometricRotation:Start()
    self.dataCon = self.gameObject.GetComponent(DataContainer)

    self.transform = self.gameObject.transform
    self.target = self.gameObject.transform

    if self.targets.radar then
        self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    end

    self.multiplier = self.dataCon.GetFloat("multiplier")
    self.vector = self.dataCon.GetVector("rotation")
    self.offset = Vector3.zero
    if self.dataCon.HasVector("offset") then
        self.offset = self.dataCon.GetVector("offset")
    end
end

function DisplayHeightBarometricRotation:Update()
    if self.radar then
        if self.radar.lockedVehicle then
            self.transform.localEulerAngles = self.vector * self.radar.lockedVehicle.transform.position.y * self.multiplier + self.offset
        else
            self.transform.localEulerAngles = self.offset
        end
        return
    end

    self.transform.localEulerAngles = self.vector * self.target.position.y * self.multiplier + self.offset
end