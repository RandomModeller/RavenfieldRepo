behaviour("Clock") --v1.0.0

function Clock:Start()
    self.hour = self.targets.hour.transform
    self.minute = self.targets.minute.transform
    self.second = self.targets.second.transform

    self.rotationVector = Vector3(0, 1, 0)
end

function Clock:Update()
    self.hour.localEulerAngles = self.rotationVector * Time.systemTimeHour * 30
    self.minute.localEulerAngles = self.rotationVector * Time.systemTimeMinute * 6
    self.second.localEulerAngles = self.rotationVector * Time.systemTimeSecond * 6
end