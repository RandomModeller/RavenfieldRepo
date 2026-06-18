behaviour("StickyProjectile") -- v1.0.0

function StickyProjectile:Start()
    self.dataContainer = self.targets.dataContainer
    self.projectile = self.targets.projectile

    self.radius = self.dataContainer.GetFloat("radius")

    self.hit = false

    self.position = Vector3.zero
    self.rotation = Quaternion.identity
end

function StickyProjectile:Update()
    if self.projectile.velocity.sqrMagnitude <= 0.001 and not self.hit then
        self.hit = true

        local colliders = Physics.OverlapSphere(self.projectile.transform.position, self.radius, RaycastTarget.ProjectileHit)

        if colliders[1] ~= nil then
            self.projectile.transform.parent = colliders[1].transform
            self.position = self.projectile.transform.position
            self.rotation = self.projectile.transform.rotation
        end
    end

    if self.hit then
        self.projectile.transform.position = self.position
        self.projectile.transform.rotation = self.rotation
        self.projectile.velocity = Vector3.zero
    end
end