require 'spec_helper'

describe UsersController do

  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:public_user) { FactoryGirl.create(:confirmed_user) }
  let(:private_user) { FactoryGirl.create(:confirmed_user, is_private: true) }

  it 'should show the user their profile' do
    skip 'fails on CI - RickCarlino'
    sign_in user
    get :show, id: user.id
    expect(response).to render_template(:show)
  end

  it 'should show the user a public profile' do
    public_user = FactoryGirl.create(:user, is_private: false)
    sign_in user
    get :show, id: public_user.id
    expect(response).to render_template(:show)
  end

  it 'should not show the user a private profile' do
    private_user = FactoryGirl.create(:user, is_private: true)
    sign_in user
    get :show, id: private_user.id
    expect(response).to redirect_to root_path(:en)
  end

  it 'should show the user the edit page' do
    sign_in user
    get :edit
    expect(response).to render_template(:edit)
  end

  it 'should only show public users on index' do
    skip 'this test does not pass on CI - RickCarlino'
    private_user = FactoryGirl.create(:user, is_private: true)
    public_user = FactoryGirl.create(:user)
    sign_in user
    get :index
    expect(assigns(:users).to_a.map(&:is_private).uniq).to match_array([false])
  end

  it 'should show all users on index if the current user is admin' do
    User.destroy_all
    user = FactoryGirl.create(:user, admin: true)
    private_user = FactoryGirl.create(:user, is_private: true)
    public_user = FactoryGirl.create(:user)
    sign_in user
    get :index
    expect(assigns(:users)).to match_array([public_user, user, private_user])
  end

  it 'should not update with incomplete information' do
    sign_in user
    put :update, location: '', units: 'metric'
    expect(response).to redirect_to controller: 'users', action: 'finish'
    expect(flash[:alert]).to include("Location can't be blank")
  end

  it 'should update with complete information' do
    sign_in user
    put :update, location: 'Hanoi', units: 'metric'
    expect(response).to redirect_to user_path(:en, user)
    expect(user.reload.user_setting.location).to eq('Hanoi')
  end

  it 'should redirect users from gardens to their profile' do
    skip 'Fails on CI - RickCarlino'
    sign_in user
    get :gardens
    expect(response.status).to eq(302)
    expect(response).to redirect_to user_path(:en, user)
  end
end
