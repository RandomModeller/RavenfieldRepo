behaviour("FirstDraw") --v1.0.0

function FirstDraw:Start()
    self.animator = self.targets.animator.GetComponent(Animator)
    self.name = self.gameObject.GetComponent(DataContainer).GetString("name")
    if self.animator ~= nil and self.name ~= nil then
        self.animator.SetBool(self.name, true)
    end
end

function FirstDraw:OnDisable()
    if self.animator ~= nil and self.name ~= nil then
        self.animator.SetBool(self.name, false)
    end
end