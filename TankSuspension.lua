behaviour("TankSuspension") --v1.0.0

function TankSuspension:Start()
    self.pointA = self.targets.pointA.transform
    self.pointB = self.targets.pointB.transform
    self.vertical = self.targets.vertical.transform
    self.rotate = self.targets.rotate.transform
    self.vehicleObject = self.targets.vehicleObject.transform

    self.pointADefault = self.pointA.localPosition.y
    self.pointBDefault = self.pointB.localPosition.y
    self.verticalDefault = self.vertical.localPosition
    self.rotateDefault = self.rotate.localPosition
end

function TankSuspension:Update()
    local aDeviation = self.pointA.localPosition.y - self.pointADefault
    local bDeviation = self.pointB.localPosition.y - self.pointBDefault

    self.vertical.localPosition = self.verticalDefault + Vector3.forward * ((aDeviation + bDeviation) / 2)
    self.vertical.rotation = Quaternion.LookRotation(self.pointA.position - self.pointB.position, self.vehicleObject.up)
    self.rotate.rotation = Quaternion.LookRotation(self.vertical.position - self.rotate.position, self.vehicleObject.up)
end