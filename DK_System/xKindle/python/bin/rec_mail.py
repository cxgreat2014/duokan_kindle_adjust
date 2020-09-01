#! /usr/bin/python
#coding=utf-8
'''
#=============================================================================
#     FileName:         pop_imap_recv_mail.py
#     Desc:                 Fetch mail by POP and IMAP
#     Author:           forrest
#     Email:            hongsun924@gmail.com
#     HomePage:         NULL
#     Version:          0.0.1
#     LastChange:       2011-08-09 17:51:49
#     History:          
#=============================================================================
'''

import os, sys, re, string, getpass, email, poplib, imaplib
import logging


# 如果get_charsets()查找不到编码信息, 则采用下面方式:
def check_code(msg):
    for code in ('gb2312', 'gb18030', 'gbk', 'big5', 'utf-8', 'utf16', 'utf32', 'jp', 'euc_kr'):
        try:
            return unicode(msg, code, 'ignore' )
        except:
            pass
    return msg

# 检查编码信息
def check_sub(sub, code, msg):
    if code != None:
        subject = unicode(sub, code, 'ignore')
        return subject
    elif msg.get_charsets()[0] !=None:
        subject = unicode(sub, msg.get_charsets()[0], 'ignore')
        return subject
    else:
        subject = check_code(sub)
        return subject

# 解析邮件头以及附件名称
def mail_parser(msg, obj):
    obj = ' '.join(obj.split())
    obj = obj.replace("?=", "?= ")
    reobj = re.compile(r'q\?= ', re.I)
    obj = reobj.sub(r'Q?=', obj)
    try:
        decode_obj = email.Header.decode_header(obj)
        obj_list = []
        for decode_obj_item in decode_obj:
            obj_sub, obj_code = decode_obj_item
            obj_list.append(check_sub(obj_sub, obj_code, msg))
        return ''.join(obj_list)
    except:
        return obj


# 解析text/plain信息, 如果 part.get_charsets()不能获取编码信息, 则使用check_content_code来检测编码
def text_plain_msg(part):
    text_plain = part.get_payload(decode=True)
    charset = part.get_charsets()[0]
    if charset == "x-gbk":
        charset = "gbk"

    if len(text_plain):
        if charset != None:
            try:
                return unicode(text_plain, charset, 'ignore')
            except:
                pass
        else:
            return check_code(text_plain)

# 解析text/html信息, 如果 part.get_charsets()不能获取编码信息, 则使用check_content_code来检测编码
def text_html_msg(part):
    text_html = part.get_payload(decode=True)
    charset = part.get_charsets()[0]
    if charset == "x-gbk":
        charset = "gbk"

    if len(text_html):
        if charset != None:
            try:
                return unicode(text_html, charset, 'ignore')
            except:
                pass
        else:
            return check_code(text_html)

# 解析附件, 分析两种情况:
    #1. Content-ID: 如果使用了Content-ID内嵌资源, 则以该ID命名,获取此资源
    #2. Content-Disposition: 如果使用了Content-Disposition,则分为两种情形, inline资源 和 attachment资源:
        #先尝试使用正则分隔解析出文件名, 如果不能, 则使用part.get_filename()来获取文件名
def attach_msg(part, mail_num, file_path):
    content_dis = part.get_all('Content-Disposition')
    content_id = part.get_all('Content-ID')

    file_name = str(mail_num) + "_" + "Unknown_file_name"

    if content_id != None:
        file_name = "cid_" + str(mail_num) + "_" + content_id[0] 

    if content_dis != None:
        file_data = re.findall(r'(?<=")[\s\S]*?(?=")', content_dis[0])
        if file_data:
            file_name = file_data[0].strip()
        else:
            file_name =  part.get_filename()

    if file_name:
        file_name = mail_parser(part, file_name)
        logging.info("  -Start to download attachment file.")
        print "Binary Data ...", file_name
        data = part.get_payload(decode=True)
    
        f = open(file_path+file_name, 'wb')
        f.write(data)
        f.close()
        logging.info("  -End to download attachment file.")

    return file_name

# 处理邮件头信息, 包括From, To, Subject, Date
def header_msg(mail_num, msg):
    from_addr = ''
    to_addr = ''
    subject = ''
    date = ''

    if msg['From'] != None:
        from_addr = mail_parser(msg, msg['From'])

    if msg['To'] != None:
        to_addr = mail_parser(msg, msg['To'])

    if msg['Subject'] != None:
        subject = mail_parser(msg, msg['Subject'])

    if msg['Date'] != None:
        date = msg['Date']

    return from_addr, to_addr, subject, date


# 处理邮件正文内容信息, 先判断是否是一个multipart, 如果是, 则for出每一个part的内容(plain, html, attach)
def content_msg(mail_num, msg, file_path):
    txt_plain = []
    txt_html = []
    atta_data = []

    if msg.is_multipart():
        logging.info("  -Multipart Mail.")
        for part in msg.walk():
            if not part.is_multipart():
                if re.search("text", part.get_content_type(), re.I):
                    if re.search("plain", part.get_content_type(), re.I):
                        if text_plain_msg(part):
                            logging.info("  -Text/Plain Multipart.")
                            txt_plain.append(text_plain_msg(part))
                    elif re.search("html", part.get_content_type(), re.I):
                        if text_html_msg(part):
                            logging.info("  -Text/Html Multipart.")
                            txt_html.append(text_html_msg(part))
                    else:
                        if text_plain_msg(part):
                            logging.info("  -Unknown Multipart.")
                            txt_plain.append(text_plain_msg(part))
                else:
                    logging.info("  -Attachment Multipart.")
                    atta_data.append(attach_msg(part, mail_num, file_path))
            #else:
                #logging.info(" --- Multipart no mail message.")

    else:
        logging.info("  -Not Multipart Mail.")
        if re.search("text", msg.get_content_type(), re.I):
            if re.search("plain", msg.get_content_type(), re.I):
                if text_plain_msg(msg):
                    txt_plain.append(text_plain_msg(msg))
            elif re.search("html", msg.get_content_type(), re.I):
                if text_html_msg(msg):
                    txt_html.append(text_html_msg(msg))
            else:
                if text_plain_msg(msg):
                    txt_plain.append(text_plain_msg(msg))

    return txt_plain, txt_html, atta_data
	
# pop.retr()提取邮件
def pop_retr_mail(num, uid, file_path):
    hdr, message, octet = pop.retr(num)
    msg = email.message_from_string(string.join(message, '\n'))
    
    mail_from, mail_to, mail_subject, mail_date = header_msg(num, msg)
#    logging.info("  -End to fetch Header message!")

#   logging.info("  -Start to fetch mail content message.")
    mail_text, mail_html, mail_atta = content_msg(num, msg, file_path)
#   logging.info("  -End to fetch Content message!")

    if len(mail_text):
        mail_text = "\n".join(mail_text)

    if len(mail_html):
        mail_html = "\n".join(mail_html)

    if len(mail_atta):
        for file_name in mail_atta:
			print "got mail", file_name

# imap.uid('fetch', uid, '(RFC822)')提取邮件
def imap_fetch_mail(db, db_name, uid, file_path):
    #typ, msg_data = imap.fetch('403' , '(BODY.PEEK[HEADER])')
    #typ, msg_data = imap.fetch('403' , '(BODY.PEEK[TEXT])')

    result, data = imap.uid('fetch', uid, '(RFC822)')
    raw_email = data[0][1]

    msg = email.message_from_string(raw_email)

    logging.info("  -Start to fetch mail header message.")
    mail_from, mail_to, mail_subject, mail_date = header_msg(uid, msg)
    logging.info("  -End to fetch Header message!")

    logging.info("  -Start to fetch mail content message.")
    mail_text, mail_html, mail_atta = content_msg(uid, msg, file_path)
    logging.info("  -End to fetch Content message!")

    if len(mail_text):
        mail_text = "\n".join(mail_text)

    if len(mail_html):
        mail_html = "\n".join(mail_html)


    # tb_mail_atta表中添加邮件信息
    if len(mail_atta):
        logging.info("  -Start to insert mail attachment to mysql tb_mail_atta.")
        for file_name in mail_atta:
            logging.info("  -Insert Pass!")

# 主程序开始
if __name__ == "__main__":


    if len(sys.argv) < 6:  
		print u'please input the server port username password filepath \n'  

    # hard code file_store_path
    file_path = "/mnt/us/py_email/attachment/"
	
    if not os.path.exists(file_path):
        os.makedirs(file_path)

    # config Mail Server
    print "======== Please Config mail server: server, port, username ,password ,filepath ========"
    server = sys.argv[1]
    port = sys.argv[2]
    pop_user = sys.argv[3]
    pop_pass = sys.argv[4]
    file_path = sys.argv[5]
	
    # if it's 110, using POP3 to get the mail attachment
    if port == "110":
        try:
            pop = poplib.POP3(server, port, timeout = 15)
            pop.set_debuglevel(1)
            pop.user(pop_user)
            pop.pass_(pop_pass)
        except:
            print "please check the mail server and port, also check the username and password again! "
            sys.exit(1)

        # pop.uidl ????uid???        
	result, data, oct = pop.uidl()
        for item in data:
            uid = item.split()
            mail_num = uid[0]
            mail_uid = uid[1]
            #if not db.select_uid(db_name, mail_uid):
#               logging.info("Start to fetch mail, num: %s, uid: %s" %(mail_num, mail_uid))
            pop_retr_mail(mail_num, mail_uid, file_path)
#               logging.info("End to fetch mail, num: %s, uid: %s" %(mail_num, mail_uid))

        print "Mail fetch finished!"


    # IMAP get the mail content
	# port = 143
    elif port == "143":
        try:
            imap = imaplib.IMAP4_SSL(server, port)
            imap.debug = 4
            imap.login(imap_user, imap_pass)
            logging.info("Mail server: %s:%s init pass." %(server,port))
        except:
            print "please check the mail server and port, also check the username and password again! "
            logging.info("Mail server: %s:%s init failed." %(server,port))
            sys.exit(1)

        print imap.select('inbox')
        inbox_result, inbox_data = imap.search(None, "ALL")

        uid_result, uid_data = imap.uid('search' , None, "ALL")
        uid_list = uid_data[0].split()

        for uid in uid_list :
            if not db.select_uid(db_name, uid):
                logging.info("Start to fetch mail, uid: %s" %uid)
                imap_fetch_mail(db, db_name, uid, file_path)
                logging.info("End to fetch mail, passed, uid: %s" %uid)

        print "Mail fetch finished!"

    else:
        print "Don't know mail server."
