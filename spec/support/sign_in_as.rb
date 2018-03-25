module SignInAs
  def sign_in_as(user = FactoryBot.create(:user))
    token = sign_in(user)
    yield token
  end

  def feature_login(user = FactoryBot.create(:user))
    visit root_path
    fill_in('user[email]', with: user.email)
    fill_in('user[password]', with: "1234")
    find('.btn-default').click
  end
end
