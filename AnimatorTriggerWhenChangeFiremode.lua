behaviour("AnimatorTriggerWhenChangeFiremode") --v1.0.0

function AnimatorTriggerWhenChangeFiremode:Start()
    self.animator = self.targets.animator.GetComponent(Animator)
    self.name = self.animator.StringToHash(self.gameObject.GetComponent(DataContainer).GetString("triggerName"))
end

function AnimatorTriggerWhenChangeFiremode:Update()
    if Input.GetKeyBindButtonDown(KeyBinds.FireMode) then
        if activeWeapon.isReloading then
            return
        end

        self.animator.SetTrigger(self.name)
    end
end