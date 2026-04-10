behaviour("FalconConfig") --v1.0.0

function FalconConfig:Awake()
    self.DebilFalconConfig_RealisticHARMTargetting = self.script.mutator.GetConfigurationBool("RealisticHARMTargetting")
    self.DebilFalconConfig_RadarAutoACMSlew = self.script.mutator.GetConfigurationBool("RadarAutoACMSlew")
    self.DebilFalconConfig_SidewinderAutoUncage = self.script.mutator.GetConfigurationBool("SidewinderAutoUncage")
    self.DebilFalconConfig_TGPAutoSnowplow = self.script.mutator.GetConfigurationBool("TGPAutoSnowplow")

    local lower = string.lower

    self.DebilFalconConfig_SidewinderUncage = lower(self.script.mutator.GetConfigurationString("SidewinderUncage"))
    self.DebilFalconConfig_GearToggle = lower(self.script.mutator.GetConfigurationString("GearToggle"))
    self.DebilFalconConfig_AirbrakeToggle = lower(self.script.mutator.GetConfigurationString("AirbrakeToggle"))
    self.DebilFalconConfig_LANTIRNToggle = lower(self.script.mutator.GetConfigurationString("LANTIRNToggle"))
    self.DebilFalconConfig_ZoomIn = lower(self.script.mutator.GetConfigurationString("ZoomIn"))
    self.DebilFalconConfig_ZoomOut = lower(self.script.mutator.GetConfigurationString("ZoomOut"))
    self.DebilFalconConfig_SwitchLeftMFD = lower(self.script.mutator.GetConfigurationString("SwitchLeftMFD"))
    self.DebilFalconConfig_SwitchRightMFD = lower(self.script.mutator.GetConfigurationString("SwitchRightMFD"))
    self.DebilFalconConfig_SwitchSOI = lower(self.script.mutator.GetConfigurationString("SwitchSOI"))
    self.DebilFalconConfig_F1 = lower(self.script.mutator.GetConfigurationString("F1"))
    self.DebilFalconConfig_F2 = lower(self.script.mutator.GetConfigurationString("F2"))
    self.DebilFalconConfig_Numpad0 = lower(self.script.mutator.GetConfigurationString("Numpad0"))
    self.DebilFalconConfig_Numpad2 = lower(self.script.mutator.GetConfigurationString("Numpad2"))
    self.DebilFalconConfig_Numpad4 = lower(self.script.mutator.GetConfigurationString("Numpad4"))
    self.DebilFalconConfig_Numpad7 = lower(self.script.mutator.GetConfigurationString("Numpad7"))
    self.DebilFalconConfig_Numpad8 = lower(self.script.mutator.GetConfigurationString("Numpad8"))
    self.DebilFalconConfig_Numpad9 = lower(self.script.mutator.GetConfigurationString("Numpad9"))
    self.DebilFalconConfig_NumpadPlus = lower(self.script.mutator.GetConfigurationString("NumpadPlus"))
    self.DebilFalconConfig_NumpadMinus = lower(self.script.mutator.GetConfigurationString("NumpadMinus"))
end