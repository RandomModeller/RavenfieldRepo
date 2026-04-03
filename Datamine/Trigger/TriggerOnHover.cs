using System;
using UnityEngine.EventSystems;

namespace Ravenfield.Trigger
{
    [AddComponentMenu("Trigger/Events/Trigger On Hoverh")]
    [TriggerDoc("Sends Trigger Signals when Hovering a UI Graphics Element.")]
    public partial class TriggerOnHover : TriggerBaseComponent
    {
        [SignalDoc("Sent when a Component is Hovered")]
        public TriggerSend onHoverBegin;
        [SignalDoc("Sent when a Component is Not Hovered Anymore")]
        public TriggerSend onHoverEnd;
    }
}
