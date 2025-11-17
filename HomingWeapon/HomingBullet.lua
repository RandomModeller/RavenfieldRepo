behaviour("HomingBullet") --1.0.1

--function HomingBullet:Start()
--    self.projectile = self.gameObject.GetComponent(Projectile)
--end

function HomingBullet:Update()
    if (self.projectile == nil) or (self.target == nil) then
        return
    end

    self.projectile.velocity = Vector3.RotateTowards(self.projectile.velocity, self.target.centerPosition - self.transform.position, self.aimSpeed * Time.deltaTime, 0)
end
