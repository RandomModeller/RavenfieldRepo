behaviour("MeleeProjectile") --v1.0.0

function MeleeProjectile:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.weapon = self.targets.weapon.GetComponent(MeleeWeapon)

    self.onlyCountHits = self.dataContainer.GetBool("onlyCountHits")
    self.chance = self.dataContainer.GetFloat("chance")
    
    self.projectile = self.targets.projectile
end

function MeleeProjectile:Update()
    local valid = true

    if self.onlyCountHits then
        local ray = Ray(self.weapon.transform.position - self.weapon.user.facingDirection * 2 * self.weapon.radius,  self.weapon.user.facingDirection)
        local raycast = Physics.Spherecast(ray, self.weapon.radius, self.weapon.range + 2 * self.weapon.radius, RaycastTarget.ProjectileHit)
        if raycast ~= nil then
            valid = raycast.transform.gameObject.layer == 8
        end
    end

    if valid and Random.Range(0, 1) <= self.chance then
        GameObject.Instantiate(self.projectile, self.weapon.currentMuzzleTransform.position, self.weapon.currentMuzzleTransform.rotation)
    end
end