behaviour("AddRigidbodyExplosion") --v1.0.0

function AddRigidbodyExplosion:Start()
    self.rigidbody = self.gameObject.GetComponent(Rigidbody)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.centre = self.targets.centre.transform.position

    self.rigidbody.AddExplosionForce(self.dataContainer.GetFloat("force"), self.centre, 25)
end