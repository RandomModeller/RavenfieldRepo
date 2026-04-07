behaviour("DisplayTargetAspect") --v1.0.0

function DisplayTargetAspect:Start()
    self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.displayOnlyWhenLock = false
    if self.dataContainer.HasBool("displayOnlyWhenLock") then
        self.displayOnlyWhenLock = self.dataContainer.GetBool("displayOnlyWhenLock")
    end

    self.label = self.gameObject.GetComponent(Text)
end

function DisplayTargetAspect:Update()
    if (not self.displayOnlyWhenLock) or self.radar.isSTT then
        self.label.text = tostring(Mathf.Round(self.radar.targetAspect)) .. (self.radar.targetAspect > 0 and "R" or "L")
    else
        self.label.text = ""
    end
end