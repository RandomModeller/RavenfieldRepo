behaviour("DisplaySTTLine") --v1.0.0

function DisplaySTTLine:Start()
    self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    self.rectTransform = self.gameObject.GetComponent(RectTransform)
end

function DisplaySTTLine:Update()
    if self.radar.isSTT or true then
        self.rectTransform.localEulerAngles = -Vector3.forward * Mathf.Atan2(self.radar.targetBlipPosition.x, self.radar.targetBlipPosition.y) * Mathf.Rad2Deg
        self.rectTransform.localScale = Vector3.one
    else
        self.rectTransform.localScale = Vector3.zero
    end
end