behaviour("HomingBullet") --v1.0.0

--function HomingBullet:Start()
--    self.projectile = self.gameObject.GetComponent(Projectile)
--end

function HomingBullet:Update()
    if (self.projectile == nil) then
        return
    end

    self.projectile.velocity = Vector3.RotateTowards(self.projectile.velocity, self.target.centerPosition - self.transform.position, self.aimSpeed * Time.deltaTime, 0)

end
