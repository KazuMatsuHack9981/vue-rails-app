require 'rails_helper'

RSpec.describe 'Command', type: :request do
  let!(:command) { create(:command) }
  let!(:command2) { create(:command) }
  let(:user) { command.user }
  let(:user2) { command2.user }
  let(:send_index_request) { get api_command_index_path }
  let(:send_new_request) { get new_api_command_path }
  let(:send_show_request) { get api_command_path command.id }
  let(:send_destroy_request) { delete api_command_path command.id }
  let(:send_update_request) { put api_command_path command.id, params: put_params }
  let(:result) { JSON.parse(response.body, { symbolize_names: true }) }
  let(:put_params) do
    {
      title: 'after_update'
    }
  end

  before do
    login user
  end

  describe 'index' do
    it 'own profile' do
      send_index_request
      expect(response).to have_http_status(200)
      expect(result[:command][0][:title]).to eq command.title
    end
  end

  describe 'new' do
    it do
      send_new_request
      expect(response).to have_http_status(200)
      expect(result[:genres][0][:name]).to eq Genre.first.name
      expect(result[:command_types][0][:name]).to eq CommandType.first.name
    end
  end

  describe 'show' do
    it do
      send_show_request
      expect(response).to have_http_status(200)
      expect(result[:filename]).to eq command.command_file.filename
      expect(result[:filetree][:name]).to eq 'test'
      expect(result[:command][:title]).to eq command.title
      expect(result[:filedatas].nil?).to eq false
      expect(result[:owner][:id]).to eq user.id
    end
  end

  describe 'update' do
    it 'check if data is updated' do
      expect do
        send_update_request
        command.reload
      end.to change { command.title }.to('after_update')
    end

    it 'check redirection is correct' do
      send_update_request
      expect(response).to have_http_status(204)
    end
  end

  describe 'destroy' do
    it do
      expect do
        send_destroy_request
      end.to change { CommandFile.count }.by(-1)
    end
  end
end
