behaviour("HeightChecker") --v1.0.0

function HeightChecker:Start()
    self.height = 0

    self.transform = self.gameObject.transform
end

function HeightChecker:Update()
    local ray = Ray(self.transform.position, -Vector3.up)
    local raycast = Physics.Raycast(ray, Mathf.Infinity, RaycastTarget.Opaque)
    if raycast ~= nil then
        self.height = self.transform.position.y - raycast.point.y
    else
        self.height = self.transform.position.y
    end
end