behaviour("SAMMover") --v1.0.1

function SAMMover:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.target = self.gameObject.transform
    if self.targets.target then
        self.target = self.targets.target.transform
    end

    local position = self.target.position

    position.y = position.y + 2000
    
    local ray = Physics.Raycast(Ray(position, -Vector3.up), Mathf.Infinity, RaycastTarget.Opaque)

    if ray ~= nil then
        self.target.position = ray.point + Vector3(0, self.dataContainer.GetFloat("yOffset"), 0)
    end
end
