behaviour("SAMSpin") --v1.0.0

function SAMSpin:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.speed = self.dataContainer.GetVector("speed")
end

function SAMSpin:Update()
    local angle = self.transform.localEulerAngles

    angle = angle + self.speed * Time.deltaTime

    self.transform.localEulerAngles = angle
end