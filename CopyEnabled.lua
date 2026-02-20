behaviour("CopyEnabled") --v1.0.0

function CopyEnabled:Start()
    self.a = self.targets.a
    self.b = self.targets.b
end

function CopyEnabled:Update()
    self.a.enabled = self.b.enabled
end