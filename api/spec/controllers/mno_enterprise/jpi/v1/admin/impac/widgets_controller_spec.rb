require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::WidgetsController, type: :controller do
    # include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:user) { build(:user, :admin, :with_organizations) }
    let(:org) { build(:organization, users: [user]) }
    let(:template) { build(:impac_dashboard, dashboard_type: 'template') }
    let(:metadata) { { hist_parameters: { from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY' } } }
    let(:widget) { build(:impac_widget, dashboard: template, settings: metadata) }
    let(:kpi) { build(:impac_kpi, widget: widget) }

    let(:hash_for_kpi) do
      {
        "id" => kpi.id,
        "element_watched" => kpi.element_watched,
        "endpoint" => kpi.endpoint
      }
    end
    let(:hash_for_widget) do
      {
        "id" => widget.id,
        "name" => widget.name,
        'metadata' => metadata.deep_stringify_keys,
        "endpoint" => widget.widget_category,
        "width" => widget.width,
        "kpis" => [hash_for_kpi]
      }
    end

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    describe '#create' do
      let(:widget_params) do
        {
          endpoint: widget.endpoint,
          name: widget.name,
          width: widget.width,
          metadata: metadata,
          forbidden: 'param'
        }
      end

      subject { post :create, dashboard_template_id: template.id, widget: widget_params }
      
      before do
        api_stub_for(
          get: "/dashboards/#{template.id}",
          params: { filter: { 'dashboard_type' => 'template' } },
          response: from_api(template)
        )
        api_stub_for(
          post: "dashboards/#{template.id}/widgets",
          response: from_api(widget)
        )
        # Why is Her doing a GET /widgets after doing a POST /widgets?
        api_stub_for(
          get: "dashboards/#{template.id}/widgets",
          response: from_api([widget])
        )
        api_stub_for(
          get: "/widgets/#{widget.id}/kpis",
          response: from_api([kpi])
        )
      end

      it_behaves_like "a jpi v1 admin action"

      it 'returns a widget' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_widget)
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the template cannot be found' do
        xit 'spec to be described'
      end
    end

    describe '#update' do
      let(:widget_params) do
        {
          name: widget.name,
          width: widget.width,
          metadata: metadata,
          forbidden: 'param'
        }
      end

      subject { put :update, id: widget.id, widget: widget_params }
      
      before do
        api_stub_for(
          get: "widgets/#{widget.id}",
          response: from_api(widget)
        )
        api_stub_for(
          put: "/widgets/#{widget.id}",
          response: from_api(widget)
        )
        api_stub_for(
          get: "/widgets/#{widget.id}/kpis",
          response: from_api([kpi])
        )
      end

      it_behaves_like "a jpi v1 admin action"

      it 'returns a widget' do
        subject
        expect(JSON.parse(response.body)).to eq(hash_for_widget)
      end

      # api_stub should be modified to allow this case to be stubbed
      context 'when the widget update is unsuccessful' do
        xit 'spec to be described'
      end
    end

    describe '#destroy' do
      subject { delete :destroy, id: widget.id }
      
      before do
        api_stub_for(
          get: "widgets/#{widget.id}",
          response: from_api(widget)
        )
        api_stub_for(
          delete: "/widgets/#{widget.id}",
          response: from_api(nil)
        )
      end

      it_behaves_like "a jpi v1 admin action"

      # api_stub should be modified to allow this case to be stubbed
      context 'when the widget destruction is invalidunsuccessful' do
        xit 'spec to be described'
      end
    end
  end
end
