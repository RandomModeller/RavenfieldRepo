behaviour("FalconRWRBlip") --v1.1.0

function FalconRWRBlip:Init()
    self.rectTransform = self.gameObject.GetComponent(RectTransform)
    self.text = self.targets.text.GetComponent(Text)
    if self.targets.airborneStatus then
        self.airborneStatus = self.targets.airborneStatus
    end
    if self.targets.groundStatus then
        self.groundStatus = self.targets.groundStatus
    end
    self.diamond = self.targets.diamond
    self.circle = self.targets.circle
    if self.targets.missileAboveSymbol then
        self.missileAboveSymbol = self.targets.missileAboveSymbol
    end
    if self.targets.missileBelowSymbol then
        self.missileBelowSymbol = self.targets.missileBelowSymbol
    end
    self.emitter = nil
    self.outOfBounds = Vector2(0, -100)

    self.blink = false
    self.missileAbove = false
    self.missileBelow = false

    self:Diamond(false)
end

function FalconRWRBlip:Hide()
    self:SetPosition(self.outOfBounds, Quaternion.identity)
    self.emitter = nil
end

function FalconRWRBlip:Airborne(val)
    self.airborneStatus.SetActive(val)
end

function FalconRWRBlip:Ground(val)
    if self.groundStatus then
        self.groundStatus.SetActive(val)
    end
end

function FalconRWRBlip:Diamond(val)
    self.diamond.SetActive(val)
end

function FalconRWRBlip:Circle(val)
    self.circle.SetActive(val)
end

function FalconRWRBlip:MissileAbove(val)
    if self.missileAboveSymbol then
        self.missileAboveSymbol.SetActive(val)
    end
end

function FalconRWRBlip:MissileBelow(val)
    if self.missileBelowSymbol then
        self.missileBelowSymbol.SetActive(val)
    end
end

function FalconRWRBlip:Name(val)
    self.text.gameObject.SetActive(val)
end

function FalconRWRBlip:SetName(val)
    self.text.text = val
end

function FalconRWRBlip:SetPosition(pos, rot)
    self.rectTransform.anchoredPosition = pos

    if rot ~= Quaternion.identity then
        self.rectTransform.rotation = rot
    end
end

function FalconRWRBlip:Update()
    self:Diamond(false)
    if self.emitter ~= nil then
        if self.emitter == -1 then
            self:Airborne(false)
            self:Ground(false)
            self:Diamond(true)
            self:Circle(true)
            self:MissileAbove(self.missileAbove)
            self:MissileBelow(self.missileBelow)
        else
            self:Airborne(self.emitter.isAirborne)
            self.Ground(not (self.emitter.isAirborne or self.emitter.isShip))
            self:Circle(self.emitter.isLocking)
            self:SetName(self.emitter.displayName)
            self:MissileAbove(false)
            self:MissileBelow(false)
        end
    end

    if self.blink then
        local show = (Mathf.Floor(Time.time * 4) % 2) == 0

        self:Circle(show)
    end
end
