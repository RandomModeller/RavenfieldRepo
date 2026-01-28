behaviour("CopyLocalRotation") --v1.0.0

function CopyLocalRotation:Start()
    self.target = self.targets.target.transform
    self.transform = self.gameObject.transform
end

function CopyLocalRotation:Update()
    self.transform.localRotation = self.target.localRotation
end
