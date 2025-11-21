behaviour("SAMBlip") --v1.0.0

function SAMBlip:Awake()
    self.rectTransform = self.gameObject.GetComponent(RectTransform)
    self.available = true
    self.endTime = 0
    self.vehicle = vehicle
    self.rectTransform.anchoredPosition = Vector2(1000, 1000)
    self.symbol = self.targets.symbol.GetComponent(Image)
    self.symbolRectTransform = self.targets.symbol.GetComponent(RectTransform)

    self.name = nil
    if self.targets.name ~= nil then
        self.name = self.targets.name.GetComponent(Text)
    end

    self.range = nil
    if self.targets.range ~= nil then
        self.range = self.targets.range.GetComponent(Text)
    end

    self.velocity = nil
    if self.targets.velocity ~= nil then
        self.velocity = self.targets.velocity.GetComponent(Text)
    end

    self.velocityStick = nil
    if self.targets.velocityStick ~= nil then
        self.velocityStick = self.targets.velocityStick.transform
    end

    self.height = nil
    if self.targets.height ~= nil then
        self.height = self.targets.height.GetComponent(Text)
    end
end

function SAMBlip:Update()
    if not self.available or self.vehicle == nil then
        if Time.time > self.endTime or self.vehicle == nil then
            self.available = true
            self.rectTransform.anchoredPosition = Vector2(1000, 1000)
            self.vehicle = nil
        end
    end
end