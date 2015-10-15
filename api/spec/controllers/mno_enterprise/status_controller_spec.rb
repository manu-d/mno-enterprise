require 'rails_helper'

module MnoEnterprise
  describe StatusController, type: :controller do
    routes { MnoEnterprise::Engine.routes }

    describe 'GET #ping' do
      before { get :ping }

      it { is_expected.to respond_with(200) }
      it { expect(response.body).to eq({status: 'Ok'}.to_json) }
    end

    describe 'GET #version' do
      before { get :version }
      let(:data) { JSON.parse(response.body) }

      it { is_expected.to respond_with(200) }

      it 'returns the main app version' do
        puts MnoEnterprise::APP_VERSION
        expect(data['app-version']).to eq(MnoEnterprise::APP_VERSION)
      end

      it 'returns the mnoe-version' do
        expect(data['mno-enteprise-version']).to eq(MnoEnterprise::VERSION)
      end
    end
  end
end
