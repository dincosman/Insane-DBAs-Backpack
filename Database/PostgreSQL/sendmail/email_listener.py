import psycopg2
import select
from datetime import datetime
import subprocess
import logging
import time

#Configure logging
logging.basicConfig(
    filename='/var/log/postgresql_email_listener/postgresql_email_listener.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def send_mail(email_data):
    # This section is Docstring. Not a madatory section but  a best practice for code quality, maintainability and usability.
    """
        Sends an email using the `sendmail`command.

        Args:
        email_data(str): Concatenated email data using '€€' as delimiter.

        Returns:
            bool: True if the email is sent succesfully, False otherwise.
    """
    # Split the email data using '€€' delimiter
    email_from, email_to, subject, body = email_data.split('€€')

    # Construct the email message in the `sendmail` format
    message = f"""From: {email_from}
To: {email_to}
Subject: {subject}
Content-Type: text/plain; charset="UTF-8"

{body}
"""
    try:
    # Use the sendmail command with -t option
        process = subprocess.Popen(["/usr/sbin/sendmail", "-t"], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate(message.encode("utf-8"))

        if process.returncode == 0:
            logging.info(f"Email sent succesfully to {email_to}")
            return True
        else:
            logging.error(f"Failed to send email to  {email_to}. Error: {stderr.decode('utf-8').strip()}")
            return False
    except Exception as e:
        logging.error(f"An error occurred while sending email: {e}")
        return False

def process_email(cur, email_id):
    """ Fetch and process a single email by ID."""
    cur.execute("""
        SELECT email_from || '€€' || email_to ||  '€€' || email_subject ||  '€€' || email_body
        FROM mailer.t_email_notifications where id = %s;
    """, (email_id,))

    email = cur.fetchone()
    if email:
       # Email data will be in the format of '€€' concatenated string
       email_data = email[0]
       # Send the email using sendmail
       success = send_mail(email_data)
       if success:
           # Update the record to mark it as sent and set the sent_time
           cur.execute("UPDATE mailer.t_email_notifications SET sent= TRUE, sent_time = %s WHERE id = %s;",
                       (datetime.now(), email_id))
           logging.info(f"Email ID {email_id} marked as sent.")

def process_unsent_emails(cur):
    """ Fetch and process all unsent emails."""
    cur.execute("SELECT id FROM mailer.t_email_notifications WHERE sent = FALSE;")
    unsent_emails = cur.fetchall()
    for email in unsent_emails:
        process_email(cur,email[0])

def listen_notifications(conn_params):
    """Main loop to listen for PostgreSQL notifications."""
    while True:
       try:

          # Establish a connection to the database
          logging.info("Connecting to the database...")

          # Connect to the PostgreSQL database  via Unix socket
          conn = psycopg2.connect(**conn_params)
          conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
          cur = conn.cursor()

          # Listen to the new_email channel
          cur.execute("LISTEN new_email;")
          logging.info("Waiting for notications on channel 'new_email'...")

          while True:
              # Use select to wait for 60 seconds(like sleep) any input on the connection
              if select.select([conn],[],[],60) == ([],[],[]):
                  continue # No notification received, loop back and wait again
              conn.poll()
              while conn.notifies:
                  notify = conn.notifies.pop(0)
                  logging.info(f"Received notification:  {notify.payload}")

                  # Process the email corresponding to the received ID
                  process_email(cur, notify.payload)

                  # After processing the first notified email, process all unsent emails
                  process_unsent_emails(cur)

       except (psycopg2.OperationalError,psycopg2.DatabaseError) as e:
           logging.error(f"Database connection error: {e}. Reconnecting in 60 seconds...")
           time.sleep(60) # Wait before trying to reconnect


       except KeyboardInterrupt:
           logging.info("Listener stopped.")
           break

       finally:
           # Ensure the cursor and connection are closed if open
           try:
               cur.close()
               conn.close()
               logging.info("Connection closed.")
           except NameError:
               pass # If cur/conn not defined, skip closing

if __name__ == "__main__":
    conn_params = {
     'dbname': 'postgres',
     'host': 'pgcluster.localdomain',
     'port': 5000,
     'user': 'mailer',
     'password': 'XXXXX'
    }

    listen_notifications(conn_params)
