behaviour("SimpleFireMode") --v1.0.0

function SimpleFireMode:Start()
    self.weapon = self.targets.weapon.GetComponent(Weapon)
    self.animator = self.targets.weapon.GetComponent(Animator)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.isAuto = self.dataContainer.GetBool("isAuto")
    self.weapon.isAuto = self.isAuto
    self.animatorParameter = self.animator.StringToHash(self.dataContainer.GetString("firemodeSwitchParameterName"))
    self.switchKeybind = self.dataContainer.GetString("firemodeSwitchKeybind")
end

function SimpleFireMode:Update()
    if Input.GetKeyDown(self.switchKeybind) then
        self.isAuto = not self.isAuto
        self.weapon.isAuto = self.isAuto

        self.animator.SetBool(self.animatorParameter, self.isAuto)
    end
end