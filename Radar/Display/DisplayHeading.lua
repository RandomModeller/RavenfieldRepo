behaviour("DisplayHeading") --v1.0.0

function DisplayHeading:Start()
    self.vehicleObject = self.targets.vehicleObject.transform

    self.label = self.gameObject.GetComponent(Text)
end

function DisplayHeading:Update()
    self.label.text = Mathf.Round(self.vehicleObject.eulerAngles.y)
end