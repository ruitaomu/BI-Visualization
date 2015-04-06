# This is run on deployments so must be idempotent

unless User.any?
  User.create!(email: 'admin@example.com',
               password: 'password',
               password_confirmation: 'password')
end
