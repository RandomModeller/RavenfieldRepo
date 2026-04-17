behaviour("UnparentOnDeath") --v1.0.0

function UnparentOnDeath:Start()
    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
end

function UnparentOnDeath:Update()
    if self.vehicleObject.isDead then
        self.targets.target.SetActive(true)
        self.targets.target.transform.parent = nil
        self.gameObject.SetActive(false)
    end
end
