import pwn
import time
from pan.xapi import PanXapi
import xml.etree.ElementTree as ET


def connect_to_device():
    xapi = PanXapi(api_username='admin', api_password='Changeme!', hostname='192.168.1.41')
    key = xapi.keygen()
    pwn.log.info(f"API Key: {key}")
    return xapi


def commit_changes(xapi):
    xapi.commit()


def kill_logins():
    xapi = connect_to_device()
    xapi.op(cmd='<show><admins></admins></show>')

    # Parse the XML string
    root = ET.fromstring(xapi.xml_result())
    admin_count = 0
    # Iterate over each entry
    for entry in root.findall('.//entry'):
        admin_count = admin_count + 1
        admin = entry.find('admin').text
        from_location = entry.find('from').text
        login_type = entry.find('type').text
        idle_time = entry.find('idle-for').text

        # Print the information
        pwn.log.info(f"{admin} is logged in from {from_location} using the {login_type} and has been idle for {idle_time}.")

    pwn.log.critical(f"Killing sessions for {admin_count} logged in admins...")
    xapi.op(cmd='<delete><admin-sessions></admin-sessions></delete>')


if __name__ == "__main__":
    kill_logins()
