#!/mnt/us/python/bin/python

import poplib
import string
import time

server = poplib.POP3('mail.iduokan.com')
server.user('chenm@iduokan.com')
server.pass_('bestebook')

# server.list returns message info from server in
# form of response, message_list, size where message_list
# is a list of messages in form of 'message_id size'
message_list = server.list()

i = 0
for message in message_list[1]:
   i += 1

   message_parts = string.split(message,' ')
   message_id = message_parts[0]
   print 'message id is %s\n' % message_id
   total_email_message = server.retr(message_id)[1]
   for line in total_email_message:
       print line
   print 'deleting message....'
   # not deleting for right now
   # server.dele(message_id)
   time.sleep(1)
   print 'done'

server.quit()
