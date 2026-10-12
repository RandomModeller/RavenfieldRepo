behaviour("PhantomBlip") --v1.2.0

function PhantomBlip:Init()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.rectTransform = self.gameObject.GetComponent(RectTransform)
    self.symbol = self.targets.symbol.GetComponent(Image)
    self.lockSymbol = self.targets.lockSymbol
    self.lockSymbolRectTransform = self.targets.lockSymbol.GetComponent(RectTransform)
    self.vehicle = nil
    self.friendly = false
    self.outOfBounds = Vector2(0, -100)

    self.lockedSprite = nil
    if self.dataContainer.HasSprite("lockedSprite") then
        self.lockedSprite = self.dataContainer.GetSprite("lockedSprite")
    end

    self.normalSprite = nil
    if self.dataContainer.HasSprite("normalSprite") then
        self.normalSprite = self.dataContainer.GetSprite("normalSprite")
    end

    self.lockedEnemySprite = nil
    if self.dataContainer.HasSprite("lockedEnemySprite") then
        self.lockedEnemySprite = self.dataContainer.GetSprite("lockedEnemySprite")
    end

    self.enemySprite = nil
    if self.dataContainer.HasSprite("enemySprite") then
        self.enemySprite = self.dataContainer.GetSprite("enemySprite")
    end

    self.stabilizeLockSymbol = nil
    if self.dataContainer.HasBool("stabilizeLockSymbol") then
        self.stabilizeLockSymbol = self.dataContainer.GetBool("stabilizeLockSymbol")
    end

    self.rangeTextSTT = nil
    if self.targets.rangeTextSTT then
        self.rangeTextSTT = self.targets.rangeTextSTT.GetComponent(Text)
        self.rangeTextSTTMultiplier = self.dataContainer.GetFloat("rangeTextSTTMultiplier")
    end

    self.speedText = nil
    if self.targets.speedText then
        self.speedText = self.targets.speedText.GetComponent(Text)
        self.speedTextMultiplier = self.dataContainer.GetFloat("speedTextMultiplier")
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
        if value then
            if (self.friendly or not (self.lockedEnemySprite)) and self.lockedSprite then
                self.symbol.sprite = self.lockedSprite
            elseif not self.friendly and self.lockedEnemySprite then
                self.symbol.sprite = self.lockedEnemySprite
            end
        else
            if (self.friendly or not (self.enemySprite)) and self.normalSprite then
                self.symbol.sprite = self.normalSprite
            elseif not self.friendly and self.enemySprite then
                self.symbol.sprite = self.enemySprite
            end
        end
    end
end

function PhantomBlip:SetSpeed(value)
    if self.speedText then
        self.speedText.text = tostring(Mathf.Round(value * self.speedTextMultiplier))
    end
end

function PhantomBlip:SetRangeSTT(value)
    if self.rangeTextSTT then
        self.rangeTextSTT.text = tostring(Mathf.Round(value * self.rangeTextSTTMultiplier))
    end
end
