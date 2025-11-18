behaviour("SetProjectileLineRendererOnEnd")

function SetProjectileLineRendererOnEnd:Start()
    self.lineRenderer = self.targets.lineRenderer.GetComponent(LineRenderer)

    self.transform = self.gameObject.transform

    self.last = self.transform.position
end

function SetProjectileLineRendererOnEnd:Update()
    if self.last ~= self.transform.position then
        self.lineRenderer.SetPosition(0, self.last)
        self.lineRenderer.SetPosition(1, self.transform.position)
        self.last = self.transform.position
    end
end