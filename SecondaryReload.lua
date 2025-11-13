behaviour("SecondaryReload")

function SecondaryReload:Start()
    self.weapon = self.targets.weaponObject.GetComponent(Weapon)
    self.weapon.onSpawnProjectiles.AddListener(self, "OnFire")
    self.targetAnimator = self.targets.animator.GetComponent(Animator)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.dryFireAudioSource = self.targets.dryFireAudioSource.GetComponent(AudioSource)

    self.name = self.dataContainer.GetString("name")
    self.delay = self.dataContainer.GetFloat("delay")
    self.reloadDuration = self.dataContainer.GetFloat("reloadDuration")
    self.secondaryMagMaxCapacity = self.dataContainer.GetInt("secondaryMagMaxCapacity")
    self.secondaryMagCapacity = self.secondaryMagMaxCapacity

    self.last = Time.time
    self.clicked = false
end

function SecondaryReload:OnFire()
    self.secondaryMagCapacity = self.secondaryMagCapacity - 1

    if self.secondaryMagCapacity <= 0 then
        self.weapon:LockWeapon()
    end
end

function SecondaryReload:OnEnable()
    if self.secondaryMagCapacity <= 0 then
        self.weapon:LockWeapon()
    end
end


function SecondaryReload:Update()
    if Input.GetKeyBindButtonDown(KeyBinds.Reload) and not self.weapon.isReloading then
        if not self.clicked then
            self.last = Time.time
            self.clicked = true
        else
            if Time.time - self.last <= self.delay then
                self.script.StartCoroutine("SecondaryReload")
            end
        end
    end

    if Time.time - self.last > self.delay and self.clicked then
        self.clicked = false
    end

    if Input.GetKeyBindButtonDown(KeyBinds.Fire) and self.weapon.isLocked then
        self.dryFireAudioSource:Play()
    end
end

function SecondaryReload:SecondaryReload()
    self.clicked = false

    self.targetAnimator.SetTrigger("reload")
    self.targetAnimator.SetBool(self.name, true)

    coroutine.yield(WaitForSeconds(self.reloadDuration))

    self.targetAnimator.SetBool(self.name, false)
    self.weapon:UnlockWeapon()
    self.secondaryMagCapacity = self.secondaryMagMaxCapacity
end