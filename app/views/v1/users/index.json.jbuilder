json.users @users do |user|
  json.partial! 'v1/users/details', user: user
  json.profile_attributes do
    json.partial! 'v1/users/profile', profile: user.profile.nil? ? Profile.new : user.profile
  end
end

json.total @total
json.total @users.first.total if @users.first && !@total