behaviour("CarAntenna") --v1.0.0

function CarAntenna:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.mass = self.dataContainer.GetFloat("mass")
    self.dragConstant = self.dataContainer.GetFloat("dragConstant")
    self.springConstant = self.dataContainer.GetFloat("springConstant")
    self.length = self.dataContainer.GetFloat("length")

    self.restPosition = self.targets.restPosition.transform
    self.mover = self.targets.mover.transform
    self.mover.parent = nil
    self.model = self.targets.model.transform

    self.distance = Vector3.zero
    self.force = Vector3.zero
    self.velocity = Vector3.zero
end

function CarAntenna:FixedUpdate()
    self.distance = self.restPosition.position - self.mover.position
    
    self.force = self.distance * self.springConstant - self.velocity * self.dragConstant

    self.velocity = self.velocity + self.force / self.mass * Time.fixedDeltaTime
    self.mover.Translate(self.velocity)

    local localDistance = self.model.InverseTransformDirection(self.distance)

    local xRot = Mathf.Atan2(localDistance.y, self.length) * Mathf.Rad2Deg
    local yRot = Mathf.Atan2(localDistance.x, self.length) * Mathf.Rad2Deg

    self.model.localEulerAngles = Vector3(0, yRot, xRot)

    -- self.model.LookAt(self.mover.position)

end
