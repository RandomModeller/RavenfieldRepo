behaviour("CentreOfMassSetter") --v1.0.2d

function CentreOfMassSetter:Update()
    if self.finished then
        return
    end

    self:BakeRigidbody()
    self.finished = true
end

function CentreOfMassSetter:BakeRigidbody()
    if self.targets.rigidbody ~= nil then
        self.rigidbody = self.targets.rigidbody.GetComponent(Rigidbody)
    else
        self.rigidbody = self.gameObject.GetComponent(Rigidbody)
    end

    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.rigidbody.centerOfMass = self.dataContainer.GetVector("centreOfMass")

    if self.targets.debugCube then
        self.targets.debugCube.transform.localPosition = self.rigidbody.centerOfMass
        print("moved the cube to " .. tostring(self.rigidbody.centerOfMass))
    end
end
