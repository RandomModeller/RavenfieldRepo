behaviour("DisplayTargetRange") --v1.1.0

function DisplayTargetRange:Start()
    self.tgp = self.targets.tgp.GetComponent(ScriptedBehaviour).self
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.multiplier = self.dataContainer.GetFloat("multiplier")

    self.prefix = "T "
    if self.dataContainer.HasString("prefix") then
        self.prefix = self.dataContainer.GetString("prefix")
    end

    self.displayOnlyWhenLock = false
    if self.dataContainer.HasBool("displayOnlyWhenLock") then
        self.displayOnlyWhenLock = self.dataContainer.GetBool("displayOnlyWhenLock")
    end

    self.label = self.gameObject.GetComponent(Text)
end

function DisplayTargetRange:Update()
    if (not self.displayOnlyWhenLock) or self.tgp.isSTT then
        self.label.text = self.prefix .. tostring(Mathf.Round(self.tgp.targetRange * self.multiplier))
    else
        self.label.text = ""
    end
end
