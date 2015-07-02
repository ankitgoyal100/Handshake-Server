APN = Houston::Client.production
APN.certificate = File.read('certificates/apple_push_notification.pem')

#APN = Houston::Client.development
#APN.certificate = File.read('certificates/certificate.pem')