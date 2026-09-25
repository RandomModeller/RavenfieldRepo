behaviour("PhantomBlip") --v1.0.0

function PhantomBlip:Init()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.rectTransform = self.gameObject.GetComponent(RectTransform)
    self.symbol = self.targets.symbol.GetComponent(Image)
    self.lockSymbol = self.targets.lockSymbol
    self.lockSymbolRectTransform = self.targets.lockSymbol.GetComponent(RectTransform)
    self.vehicle = nil
    self.outOfBounds = Vector2(0, -100)

    self.lockedSprite = nil
    if self.dataContainer.HasSprite("lockedSprite") then
        self.lockedSprite = self.dataContainer.GetSprite("lockedSprite")
    end

    self.normalSprite = nil
    if self.dataContainer.HasSprite("normalSprite") then
        self.normalSprite = self.dataContainer.GetSprite("normalSprite")
    end

    self.stabilizeLockSymbol = nil
    if self.dataContainer.HasBool("stabilizeLockSymbol") then
        self.stabilizeLockSymbol = self.dataContainer.GetBool("stabilizeLockSymbol")
    end
end

function PhantomBlip:Update()
    if self.stabilizeLockSymbol then
        self.lockSymbolRectTransform.localEulerAngles = -self.rectTransform.localEulerAngles
    end
end

function PhantomBlip:Hide()
    self.rectTransform.anchoredPosition = self.outOfBounds
end

function PhantomBlip:SetColor(color)
    self.symbol.color = color
end

function PhantomBlip:SetLockSymbol(value)
    if value ~= self.lockSymbol.activeSelf then
        self.lockSymbol.SetActive(value)
        if value and self.lockedSprite ~= nil then
            self.symbol.sprite = self.lockedSprite
        elseif self.normalSprite ~= nil then
            self.symbol.sprite = self.normalSprite
        end
    end
end
