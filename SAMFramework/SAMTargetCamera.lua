behaviour("SAMTargetCamera") --v1.0.0

function SAMTargetCamera:Start()
    self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    self.camera = self.targets.camera.transform
end

function SAMTargetCamera:Update()
    if self.radar.lockedVehicle then
        self.camera.LookAt(self.radar.lockedVehicle.transform.position)
    else
        self.camera.localRotation = Quaternion.identity
    end
end