behaviour("UVOffsetRandomizer") --v1.0.0

function UVOffsetRandomizer:Start()
    self.renderer = self.gameObject.GetComponent(MeshRenderer)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.offsetMin = self.dataContainer.GetVector("offsetMin")
    self.offsetMax = self.dataContainer.GetVector("offsetMax")

    self.renderer.material.mainTextureOffset = Vector2(Random.Range(self.offsetMin.x, self.offsetMax.x), Random.Range(self.offsetMin.y, self.offsetMax.y))
end
