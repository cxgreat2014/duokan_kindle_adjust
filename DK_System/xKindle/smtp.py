#! /usr/bin/python
#coding=utf-8
'''
# 20120531
#=============================================================================
#     FileName:         smtp.py
#     Desc:             semd email to duokan
#     Author:           forrest
#     Email:            chenm@duokan.com
#     HomePage:         NULL
#     Version:          0.0.1
#     LastChange:       2011-10-31 17:51:49
#     History:          
#=============================================================================
'''

import os,sys
import smtplib
 
from email import Encoders
from email.MIMEBase import MIMEBase
from email.MIMEMultipart import MIMEMultipart
from email.Utils import formatdate

#using smtplib to send mail with attachment
def sendEmail(host, username, password, FROM, TO, filePath):
    msg = MIMEMultipart()
    msg["From"] = FROM
    msg["To"] = TO
    msg["Subject"] = "You've got mail!"
    msg['Date']    = formatdate(localtime=True)
 
    # attach a file
    part = MIMEBase('application', "octet-stream")
    part.set_payload( open(filePath,"rb").read() )
    Encoders.encode_base64(part)
    part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(filePath))
    msg.attach(part)
 
    server = smtplib.SMTP(host)
    #server.login(username, password)  # optional
 
    try:
        failed = server.sendmail(FROM, TO, msg.as_string())
        server.close()
    except Exception, e:
        errorMsg = "Unable to send email. Error: %s" % str(e)
 
if __name__ == "__main__":

    if len(sys.argv) < 7:  
        print u'please input the host, username ,password , from, to, filepath\n'  
    
    # config Mail Server
    print "======== Please Config mail server: host, username ,password , from, to, filepath ========"
    host = sys.argv[1]
    smtp_user = sys.argv[2]
    smtp_pass = sys.argv[3]
    FROM = sys.argv[4]
    TO = sys.argv[5]
    file_path = sys.argv[6]
    
    if not os.path.exists(file_path):
        os.makedirs(file_path)

    sendEmail(host,smtp_user, smtp_pass, FROM, TO, file_path)