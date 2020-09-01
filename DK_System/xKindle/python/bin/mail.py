import poplib
import cStringIO
import email
import email.Header
import base64,os

os.chdir('/mnt/us')
M = poplib.POP3('mail.iduokan.com')
M.user('chenm@iduokan.com')
M.pass_('bestebook')


numMessages = len(M.list()[1])
print 'num of messages', numMessages

for i in range(numMessages):  
	m = M.retr(i+1)  
	buf = cStringIO.StringIO() 
	
	for j in m[1]:  
		print >>buf, j 
	
	buf.seek(0) 
	
	msg = email.message_from_file(buf) 
	
	for part in msg.walk(): 
		contenttype = part.get('Content-Disposition') 
		filename=email.Header.decode_header(part.get_filename()) 
		
		if filename and contenttype and contenttype[0:10]== 'attachment': 
			filename=os.path.basename(filename[0][0]) 
			print contenttype[0:10],filename 
			f = open(filename,'wb') 
			f.write(part.get_payload(decode=True)) 
			f.close()
		
M.quit()
print 'exit'