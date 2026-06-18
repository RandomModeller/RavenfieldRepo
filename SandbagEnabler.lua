behaviour("SandbagEnabler") --v1.0.0

function SandbagEnabler:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.range = self.dataContainer.GetFloat("range")

    self.origin = self.gameObject.transform
    if self.targets.origin ~= nil then
        self.origin = self.targets.origin.transform
    end
end

function SandbagEnabler:Update()
    local ray = Ray(self.origin.position, self.origin.forward)
    local raycast = Physics.Raycast(ray, self.range, RaycastTarget.Opaque)
    if raycast == nil then
        self.targets.sandbag.SetActive(true)
    end
end