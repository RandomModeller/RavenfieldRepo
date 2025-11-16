behaviour("FalconRWRBlip") -- v1.0.0

function FalconRWRBlip:Init()
    self.rectTransform = self.gameObject.GetComponent(RectTransform)
    self.text = self.targets.text.GetComponent(Text)
    self.airborneStatus = self.targets.airborneStatus
    self.diamond = self.targets.diamond
    self.circle = self.targets.circle
    self.emitter = nil
    self.outOfBounds = Vector2(0, -100)

    self.blink = false

    self:Diamond(false)
end

function FalconRWRBlip:Hide()
    self:SetPosition(self.outOfBounds, Quaternion.identity)
    self.emitter = nil
end

function FalconRWRBlip:Airborne(val)
    self.airborneStatus.SetActive(val)
end

function FalconRWRBlip:Diamond(val)
    self.diamond.SetActive(val)
end

function FalconRWRBlip:Circle(val)
    self.circle.SetActive(val)
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
            self:Diamond(true)
            self:Circle(true)
        else
            self:Airborne(self.emitter.isAirborne)
            self:Circle(self.emitter.isLocking)
            self:SetName(self.emitter.displayName)
        end
    end

    if self.blink then
        local show = (Mathf.Floor(Time.time * 4) % 2) == 0

        self:Circle(show)
    end

end
