import os
import resend
from dotenv import load_dotenv

load_dotenv()

resend.api_key = os.getenv("RESEND_API_KEY")

FROM_EMAIL = os.getenv("FROM_EMAIL")
FRONTEND_URL = os.getenv("FRONTEND_URL")


def send_reset_email(to_email: str, token: str):
    reset_link = f"{FRONTEND_URL}/reset-password?token={token}"

    resend.Emails.send({
        "from": FROM_EMAIL,
        "to": to_email,
        "subject": "Reset Your PayShare Password",
        "html": f"""
            <h2>Password Reset</h2>
            <p>You requested to reset your PayShare password.</p>
            <p>Click the link below:</p>
            <a href="{reset_link}">{reset_link}</a>
            <br><br>
            <small>If you did not request this, ignore this email.</small>
        """
    })