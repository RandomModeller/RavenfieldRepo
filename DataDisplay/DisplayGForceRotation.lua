behaviour("DisplayGForceRotation") --v1.0.0

function DisplayGForceRotation:Start()
    self.dataCon = self.gameObject.GetComponent(DataContainer)
    self.transform = self.gameObject.transform

    self.avionics = self.targets.avionics.GetComponent(ScriptedBehaviour).self
    self.vector = self.dataCon.GetVector("rotation")
    self.multiplier = self.dataCon.GetFloat("multiplier")
    self.offset = self.dataCon.GetVector("offset")
end

function DisplayGForceRotation:Update()
    self.transform.localEulerAngles = self.vector * self.avionics.gForce * self.multiplier + self.offset
end