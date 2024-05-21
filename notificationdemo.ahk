#Persistent
#Include <UIA_Interface>

UIA := UIA_Interface() ; Initialize UIA interface
handler := UIA_CreateEventHandler("NotificationEvent", "Notification")
UIA.AddNotificationEventHandler(UIA.GetRootElement(), 0x5, 0, handler) ; Set up a NotificationEventHandler for root element, capturing events from all descendants
OnExit("ExitFunc") ; Set up an OnExit call to clean up the handler when exiting the script
return

NotificationEvent(sender, notificationKind, notificationProcessing, displayString, activityId) {
    MsgBox, % "Notification caught!"
    . "`nSender element: " sender.Dump()
    . "`nNotification kind: " UIA_Enum.NotificationKind(notificationKind)
    . "`nNotification processing: " UIA_Enum.NotificationProcessing(notificationProcessing)
    . "`nDisplay string: " displayString
    . "`nActivity Id: " activityId
}

ExitFunc() {
	global UIA, handler
	try UIA.RemoveNotificationEventHandler(UIA.GetRootElement(), handler) ; Remove the event handler. Alternatively use UIA.RemoveAllEventHandlers() to remove all handlers. If the Notepad window doesn't exist any more, this throws an error.
}

F5::ExitApp