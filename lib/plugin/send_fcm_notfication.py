from push_notifications.models import GCMDevice

def send_notification(device_token, title, message, data):
    device = GCMDevice.objects.get(registration_id=device_token)
    device.send_message(title=title, body=message, data=data)

token = input("Enter device Token");
notificationTitle = "Notification From Backend"
text="Can you override this notification?"
payload = {"type": "backend", "action": "show_progress"}
groupId = "be01"
# Usage
send_notification(
    token, 
    notificationTitle, 
text, 
    {"payload": payload, "group_id": groupId}
)
