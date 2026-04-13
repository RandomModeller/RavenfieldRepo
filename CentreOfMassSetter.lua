behaviour("CentreOfMassSetter") --v1.0.3d

function CentreOfMassSetter:Awake()
    if self.targets.rigidbody then
        self.rigidbody = self.targets.rigidbody.GetComponent(Rigidbody)
    else
        self.rigidbody = self.gameObject.GetComponent(Rigidbody)
    end

    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.rigidbody.centerOfMass = self.dataContainer.GetVector("centreOfMass")

    if self.targets.debugCube then
        self.targets.debugCube.transform.localPosition = self.rigidbody.centerOfMass
        print("Moved the cube to " .. tostring(self.rigidbody.centerOfMass))
    end
end
