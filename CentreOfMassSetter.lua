behaviour("CentreOfMassSetter") --v1.0.4d

function CentreOfMassSetter:Start()
    if self.targets.rigidbody then
        self.rigidbody = self.targets.rigidbody.GetComponent(Rigidbody)
    else
        self.rigidbody = self.gameObject.GetComponent(Rigidbody)
    end

    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.customCentreOfMass = self.dataContainer.GetVector("centreOfMass")
end

function CentreOfMassSetter:FixedUpdate()
    self.rigidbody.centerOfMass = self.customCentreOfMass

    if self.targets.debugCube then
        self.targets.debugCube.transform.localPosition = self.rigidbody.centerOfMass
        -- print("Moved the cube to " .. tostring(self.rigidbody.centerOfMass))
    end
end
