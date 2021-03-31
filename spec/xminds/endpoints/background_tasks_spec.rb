# frozen_string_literal: true

RSpec.describe Xminds::Endpoints::BackgroundTasks do
  subject { described_class.new(endpoint: endpoint, jwt_token: jwt_token) }

  describe '#trigger_background_task' do
    context 'on success' do
      it 'triggers the requested task' do
        resp = subject.trigger_background_task(task_name: 'ml_model_retrain')

        expect(resp).to be_a(Xminds::Response)
        expect(resp.task_id).to be_a(String)
      end
    end
  end

  describe '#list_recent_background_tasks' do
    context 'on success' do
      it 'returns the list of back ground tasks' do
        resp = subject.list_recent_background_tasks(task_name: 'ml_model_retrain')

        expect(resp).to be_a(Xminds::Response)
        expect(resp.tasks).to be_a(Array)
      end
    end
  end
end
