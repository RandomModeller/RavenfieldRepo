behaviour("SAMMissileBlip") --v1.0.0

function SAMMissileBlip:Awake()
    self.rectTransform = self.gameObject.GetComponent(RectTransform)
    self.rectTransform.anchoredPosition = Vector2(1000, 1000)
    self.symbol = self.targets.symbol.GetComponent(Image)
    self.symbolRectTransform = self.targets.symbol.GetComponent(RectTransform)

    self.velocityStick = nil
    if self.targets.velocityStick ~= nil then
        self.velocityStick = self.targets.velocityStick.transform
    end
end

function SAMMissileBlip:Update()
end