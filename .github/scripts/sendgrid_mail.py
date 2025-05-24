import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

sg = SendGridAPIClient(os.environ['SENDGRID'])
message = Mail(
    from_email='no-reply@yourdomain.com',
    to_emails=os.environ['TO'],
    subject=os.environ['SUBJECT'],
    html_content=os.environ['BODY']
)
try:
    response = sg.send(message)
    print(f"Status: {response.status_code}")
except Exception as e:
    print(e)
