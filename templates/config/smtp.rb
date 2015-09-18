SMTP_SETTINGS = {
  authentication: :plain,
  enable_starttls_auto: true,
  address: ENV.fetch('SMTP_ADDRESS'), # example: "smtp.sendgrid.net"
  domain: ENV.fetch('SMTP_DOMAIN'), # example: "heroku.com"
  port: '587',

  user_name: ENV.fetch('SMTP_USERNAME')
  password: ENV.fetch('SMTP_PASSWORD'),
}
