behaviour("AddRigidbodyExplosion") --v1.1.0

function AddRigidbodyExplosion:Start()
    self.rigidbody = self.gameObject.GetComponent(Rigidbody)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.centre = self.targets.centre.transform.position

    self.chance = 1

    if self.dataContainer.HasFloat("chance") then
        self.chance = self.dataContainer.GetFloat("chance")
    end

    if Random.Range(0, 1) <= self.chance then
        if self.dataContainer.HasFloat("force") then
            self.rigidbody.AddExplosionForce(self.dataContainer.GetFloat("force"), self.centre, 25)
        else
            self.rigidbody.AddExplosionForce(Mathf.Lerp(self.dataContainer.GetFloat("forceMin"), self.dataContainer.GetFloat("forceMax"), Random.Range(0, 1)), self.centre, 25)
        end
    end
end
