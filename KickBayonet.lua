behaviour("KickBayonet") --v1.0.0

function KickBayonet:Start()
    if self.weapon == nil then
        self.weapon = self.targets.weapon.GetComponent(Weapon)
    end

    if self.weapon.user ~= Player.actor then
        return
    end

    self.animator = self.targets.weapon.GetComponent(Animator)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    if self.feet == nil then
        self.feet = GameObject.Find("KickFoot")
    end

    self.requiresEquip = false
    self.isEquipped = true

    if self.dataContainer.HasBool("requiresEquip") then
        self.requiresEquip = self.dataContainer.GetBool("requiresEquip")
        self.equipKeybind = self.dataContainer.GetString("equipKeybind")
        self.animatorParameter = self.animator.StringToHash(self.dataContainer.GetString("isEquippedParameterName"))

        self.isEquipped = self.dataContainer.GetBool("isEquipped")
        self.animator.SetBool(self.animatorParameter, self.isEquipped)
    end
end

function KickBayonet:Update()
    if self.weapon.user ~= Player.actor then
        return
    end

    if self.requiresEquip then
        if Input.GetKeyDown(self.equipKeybind) then
            self.isEquipped = not self.isEquipped
            self.animator.SetBool(self.animatorParameter, self.isEquipped)
            self.feet.SetActive(not self.isEquipped)
        end
    end
end

function KickBayonet:OnEnable()
    if self.weapon == nil then
        self.weapon = self.targets.weapon.GetComponent(Weapon)
    end

    if self.weapon.user ~= Player.actor then
        return
    end

    if self.feet == nil then
        self.feet = GameObject.Find("KickFoot")
    end

    self.feet.SetActive(not self.isEquipped)
end

function KickBayonet:OnDisable()
    if self.weapon == nil then
        self.weapon = self.targets.weapon.GetComponent(Weapon)
    end

    if self.weapon.user ~= Player.actor then
        return
    end

    if self.feet == nil then
        self.feet = GameObject.Find("KickFoot")
    end

    self.feet.SetActive(true)
end

function KickBayonet:OnDestroy()
    if self.weapon == nil then
        self.weapon = self.targets.weapon.GetComponent(Weapon)
    end

    if self.weapon.user ~= Player.actor then
        return
    end

    if self.feet == nil then
        self.feet = GameObject.Find("KickFoot")
    end

    self.feet.SetActive(true)
end