behaviour("TankSuspension") --v1.1.1

function TankSuspension:Start()
    self.pointA = self.targets.pointA.transform
    self.pointB = self.targets.pointB.transform
    if self.targets.vertical ~= nil then
        self.vertical = self.targets.vertical.transform
        self.verticalDefault = self.vertical.localPosition
    end
    self.rotate = self.targets.rotate.transform
    self.vehicleObject = self.targets.vehicleObject.transform

    self.pointADefault = self.pointA.localPosition.y
    self.pointBDefault = self.pointB.localPosition.y
    self.rotateDefault = self.rotate.localPosition
end

function TankSuspension:Update()
    local aDeviation = self.pointA.localPosition.y - self.pointADefault
    local bDeviation = self.pointB.localPosition.y - self.pointBDefault

    if self.vertical ~= nil then
        self.vertical.localPosition = self.verticalDefault + Vector3.forward * ((aDeviation + bDeviation) / 2)
        self.vertical.rotation = Quaternion.LookRotation(self.pointA.position - self.pointB.position, self.vehicleObject.up)
        self.rotate.rotation = Quaternion.LookRotation(self.vertical.position - self.rotate.position, self.vehicleObject.up)
    else
        self.rotate.rotation = Quaternion.LookRotation(self.pointB.position - self.pointA.position, self.vehicleObject.up)
    end
end
