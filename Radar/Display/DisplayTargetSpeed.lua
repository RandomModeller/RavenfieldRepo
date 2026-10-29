behaviour("DisplayTargetSpeed") --v1.0.0

function DisplayTargetSpeed:Start()
    self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.multiplier = self.dataContainer.GetFloat("multiplier")

    self.label = self.gameObject.GetComponent(Text)
end

function DisplayTargetSpeed:Update()
    self.label.text = tostring(Mathf.Round(self.radar.targetSpeed * self.multiplier))
end