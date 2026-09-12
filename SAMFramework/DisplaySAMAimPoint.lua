behaviour("DisplaySAMAimPoint") --v1.0.0

function DisplaySAMAimPoint:Start()
    self.camera = self.targets.camera.GetComponent(Camera)
    self.leadIndicator = self.targets.leadIndicator.GetComponent(RectTransform)

    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.bulletVelocity = self.dataContainer.GetFloat("bulletVelocity")
end

function DisplaySAMAimPoint:Update()
    if self.radar == nil then
        if self.targets.radar.activeInHierarchy then
            self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
        else
            return
        end
    end

    if self.radar.lockedVehicle == nil then
        self.leadIndicator.position = Vector3.one * -1000
        return
    end

    local pos = self.radar.lockedVehicle.transform.position

    local velocity = self.radar.lockedVehicle.rigidbody.velocity

    local tof = Vector3.Distance(pos, self.camera.transform.position) / self.bulletVelocity

    pos = pos + velocity * tof

    pos = pos - 1/2 * tof * tof * Physics.gravity 

    local indicatorPos = self.camera.WorldToScreenPoint(pos)

    if indicatorPos.z < 0 then
        return
    end

    indicatorPos.z = 0
    self.leadIndicator.position = indicatorPos
end