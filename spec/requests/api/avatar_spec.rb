require 'rails_helper'

RSpec.describe 'Avatar', type: :request do
  include ActionDispatch::TestProcess

  let!(:avatar) { create(:avatar) }
  let!(:avatar2) { create(:avatar, :other) }
  let(:user) { avatar.user }
  let(:user2) { avatar2.user }

  before do
    login user
  end

  describe 'show' do
    it 'own avatar' do
      get api_avatar_path 0
      expect(response).to have_http_status(200)
      expect(response.body).to eq avatar.image
    end

    it 'other user avatar' do
      get api_avatar_path user2.id
      expect(response).to have_http_status(200)
      expect(response.body).not_to eq(avatar.image)
      expect(response.body).not_to eq(nil)
    end
  end

  describe 'create' do
    it 'complete data' do
      params = {
        "avatar": fixture_file_upload("#{Rails.root}/spec/factories/images/white.jpeg", 'image/jpeg')
      }
      post api_avatar_index_path, params: params, headers: { 'Content-Type': 'multipart/form-data' }
      expect(response).to have_http_status(302)
      expect(user.avatar.filename).to eq avatar.filename
      expect(user.avatar.image).not_to eq nil
      expect(response).to redirect_to(user_page_path(0))
    end

    it 'wrong prefix' do
      params = {
        "avatar": fixture_file_upload("#{Rails.root}/spec/factories/images/flower.jpg", 'image/jpeg')
      }
      post api_avatar_index_path, params: params, headers: { 'Content-Type': 'multipart/form-data' }
      expect(response).to have_http_status(302)
      expect(user.avatar.filename).to eq 'flower.jpeg'
      expect(user.avatar.image).not_to eq nil
    end

    it 'broken data' do
      params = {
        "avatar": fixture_file_upload("#{Rails.root}/spec/factories/images/not-image.jpg", 'image/jpg')
      }
      post api_avatar_index_path, params: params, headers: { 'Content-Type': 'multipart/form-data' }
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, { symbolize_names: true })[:message]).to eq('(Bad Request) image is not selected')
    end
  end
end
