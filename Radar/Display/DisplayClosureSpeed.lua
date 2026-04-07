behaviour("DisplayClosureSpeed") --v1.0.0

function DisplayClosureSpeed:Start()
    self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.multiplier = self.dataContainer.GetFloat("multiplier")

    self.suffix = ""
    if self.dataContainer.HasString("suffix") then
        self.suffix = self.dataContainer.GetString("suffix")
    end

    self.displayOnlyWhenLock = false
    if self.dataContainer.HasBool("displayOnlyWhenLock") then
        self.displayOnlyWhenLock = self.dataContainer.GetBool("displayOnlyWhenLock")
    end

    self.label = self.gameObject.GetComponent(Text)
end

function DisplayClosureSpeed:Update()
    if (not self.displayOnlyWhenLock) or self.radar.isSTT then
        self.label.text = (self.radar.closureSpeed > 0 and "++" or "--") .. tostring(Mathf.Round(self.radar.closureSpeed * self.multiplier)) .. self.suffix
    else
        self.label.text = ""
    end
end
