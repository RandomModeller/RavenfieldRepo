behaviour("ThirdPersonCCIP") --v1.0.0

function ThirdPersonCCIP:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.ballisticCalculator = self.targets.ballisticCalculator.GetComponent(ScriptedBehaviour).self
    self.avionics = self.targets.avionics.GetComponent(ScriptedBehaviour).self
    self.heightChecker = self.targets.heightChecker.GetComponent(ScriptedBehaviour).self
    self.crosshair = self.targets.crosshair.GetComponent(RectTransform)
    self.camera = self.targets.camera.GetComponent(Camera)

    self.muzzle = self.targets.muzzle.transform
    self.projectileSpeed = self.dataContainer.GetFloat("projectileSpeed")
    self.inheritVelocity = self.dataContainer.GetBool("inheritVelocity")
    self.planar = self.dataContainer.GetBool("planar")

    self.skip = true
    self.targetPoint = Vector3.zero
end

function ThirdPersonCCIP:Update()
    self.crosshair.gameObject.SetActive(self.camera.enabled)

    self.skip = not self.skip

    if self.skip then
        return
    end

    self.targetPoint = self.ballisticCalculator:GetCCIPPosition(self.muzzle.position, self.heightChecker.height, self.avionics.rigidbody.velocity + (self.inheritVelocity and self.muzzle.forward * self.projectileSpeed or Vector3.zero), true)

    if self.planar then
        local position = self.camera.WorldToScreenPoint(self.targetPoint)

        position.z = 0 

        self.crosshair.position = position
    else
        self.crosshair.position = self.targetPoint

        local pos = self.targetPoint - self.camera.transform.parent.position

        self.crosshair.LookAt(self.crosshair.position + Vector3.up, pos)
        self.crosshair.localScale = Vector3.one * pos.magnitude / 200
    end
end