behaviour("AnimatorInWater")  --v1.0.0

function AnimatorInWater:Start()
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.targetAnimator = self.targets.animator.GetComponent(Animator)

    self.name = self.gameObject.GetComponent(DataContainer).GetString("name")
    self.value = self.targetAnimator.GetBool(self.name)
end

function AnimatorInWater:Update()
    if self.vehicle.isInWater ~= self.value then
        self.value = self.vehicle.isInWater
        self.targetAnimator.SetBool(self.name, self.value)
    end
end