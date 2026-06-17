behaviour("CopyLocalRotationClamp") --v1.0.0

function CopyLocalRotationClamp:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.target = self.targets.target.transform
    self.transform = self.gameObject.transform

    self.minX = self.dataContainer.GetFloat("minX")
    self.maxX = self.dataContainer.GetFloat("maxX")
    self.minY = self.dataContainer.GetFloat("minY")
    self.maxY = self.dataContainer.GetFloat("maxY")
    self.minZ = self.dataContainer.GetFloat("minZ")
    self.maxZ = self.dataContainer.GetFloat("maxZ")
end

function CopyLocalRotationClamp:Update()
    local rotation = self.target.localEulerAngles

    rotation.x = Mathf.Clamp((rotation.x + 540) % 360 - 180, self.minX, self.maxX)
    rotation.y = Mathf.Clamp((rotation.y + 540) % 360 - 180, self.minY, self.maxY)
    rotation.z = Mathf.Clamp((rotation.z + 540) % 360 - 180, self.minZ, self.maxZ)

    self.transform.localEulerAngles = rotation
end