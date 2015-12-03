json.id          user.id
json.email       user.email
json.name        user.profile.try(:name)
json.role        user.role
json.company_id  user.company_id
json.outlet_id   user.outlet_id
json.created_at  user.created_at
json.updated_at  user.updated_at