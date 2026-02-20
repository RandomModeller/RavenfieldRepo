behaviour("CentreOfMassSetter") --v1.0.0

function CentreOfMassSetter:Start()
    if self.targets.rigidbody ~- nil then
        self.rigidbody = self.targets.rigidbody.GetComponent(Rigidbody)
    else
        self.rigidbody = self.gameObject.GetComponent(Rigidbody)
    end

    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.rigidbody.centerOfMass = self.dataContainer.GetVector("centreOfMass")
end
