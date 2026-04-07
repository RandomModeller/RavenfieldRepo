behaviour("DisplayMissileTTI") --v1.0.0

function DisplayMissileTTI:Start()
    self.weapon = self.targets.weapon.GetComponent(Weapon)
    self.weapon.onSpawnProjectiles.AddListener(self, "OnFire")

    self.label = self.gameObject.GetComponent(Text)

    self.lastMissile = nil
end

function DisplayMissileTTI:Update()
    if self.lastMissile then
        if self.lastMissile.status == 2 or self.lastMissile.status == -1 then
            self.lastMissile = nil
        else

        self.label.text = tostring(Mathf.Floor(self.lastMissile.tti / 60)) .. ":" .. tostring(Mathf.Round(self.lastMissile.tti % 60))
    else
        self.label.text = ""
    end
end

function DisplayMissileTTI:OnFire(projectile)
    self.lastMissile = projectile[1].gameObject.GetComponent(ScriptedBehaviour).self
end
