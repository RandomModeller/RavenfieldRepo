behaviour("AttitudeIndicator") --v1.0.0

function AttitudeIndicator:Start()
    self.transform = self.gameObject.GetComponent(RectTransform)
    self.parent = self.gameObject.transform.parent
    self.vehicleObject = self.targets.vehicleObject.transform

    self.multiplier = -self.gameObject.GetComponent(DataContainer).GetFloat("multiplier")
end

function AttitudeIndicator:Update()
    local vehicleRot = self.vehicleObject.localEulerAngles

    self.parent.localEulerAngles = Vector3(0, 0, -vehicleRot.z)--(self.flightPathMarker.localEulerAngles.x + 540) % 360 - 270)

    self.transform.anchoredPosition = Vector2(0, ((vehicleRot.x + 540) % 360 - 180) * self.multiplier)
end