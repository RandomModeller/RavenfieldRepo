behaviour("SetProjectileLineRendererOnEnd") --v1.1.0

function SetProjectileLineRendererOnEnd:Start()
    self.lineRenderer = self.targets.lineRenderer.GetComponent(LineRenderer)

    self.transform = self.gameObject.transform

    self.last = self.transform.position
    self.lineRenderer.SetPosition(0, self.transform.position)
end

function SetProjectileLineRendererOnEnd:Update()
    if self.last ~= self.transform.position then
        self.lineRenderer.SetPosition(1, self.transform.position)
        self.last = self.transform.position
    end
end
