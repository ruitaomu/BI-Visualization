# This is run on deployments so must be idempotent

unless  Role.any?
  admin_role = Role.create!(name: 'first_admin')
  # Bypass validations and readonly?
  Role.connection.execute("UPDATE roles SET name = 'admin' WHERE id = #{admin_role.id}")
end

unless User.any?
  User.create!(email: 'admin@example.com',
               password: 'password',
               password_confirmation: 'password',
               roles: [Role.find_by(name: 'admin')])
end

unless Setting.any?
  Setting.create!(name: 'tester_attributes', value: 'age, game_level, personality_type')
end
