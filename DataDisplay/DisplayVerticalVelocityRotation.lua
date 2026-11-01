behaviour("DisplayVerticalVelocityRotation") --v1.0.0

function DisplayVerticalVelocityRotation:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.avionics = self.targets.avionics.GetComponent(ScriptedBehaviour).self
    self.transform = self.targets.background.GetComponent(RectTransform)

    self.multiplier = self.dataContainer.GetFloat("multiplier")
    self.vector = self.dataContainer.GetVector("rotation")
    self.min = self.dataContainer.GetFloat("min")
    self.max = self.dataContainer.GetFloat("max")
    self.offset = Vector3.zero
    if self.dataContainer.HasVector("offset") then
        self.offset = self.dataContainer.GetVector("offset")
    end
end

function DisplayVerticalVelocityRotation:Update()
    self.transform.localEulerAngles = self.vector * Mathf.Clamp(self.avionics.gForce * self.multiplier + self.offset, self.min, self.max)
end