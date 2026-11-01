behaviour("VVIIndicator") --v1.0.0

function VVIIndicator:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.multiplier = self.dataContainer.GetFloat("multiplier")
    self.min = self.dataContainer.GetFloat("min")
    self.max = self.dataContainer.GetFloat("max")

    self.avionics = self.targets.avionics.GetComponent(ScriptedBehaviour).self
    self.transform = self.targets.background.GetComponent(RectTransform)
end

function VVIIndicator:Update()
    self.transform.anchoredPosition = Vector2(0, Mathf.Clamp(self.avionics.rigidbody.velocity.y * self.multiplier, self.min, self.max))
end