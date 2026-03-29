behaviour("LookAtTarget") -- v1.0.1

function LookAtTarget:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.weapon = self.targets.weapon.GetComponent(Weapon)

    self.speed = self.dataContainer.GetFloat("speed") * Mathf.Deg2Rad
end

function LookAtTarget:Update()
    if self.weapon.user ~= nil then
        local delta = self.weapon.user.facingDirection
        local direction = Vector3.RotateTowards(self.transform.forward, delta, self.speed * Time.deltaTime, 0)
        self.transform.rotation = Quaternion.LookRotation(direction)
    end
end
