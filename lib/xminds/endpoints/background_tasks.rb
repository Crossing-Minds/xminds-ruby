# frozen_string_literal: true

module Xminds
  module Endpoints
    # BackgroundTasks class used for background task related requests with the Crossing Minds API.
    class BackgroundTasks < Request
      def trigger_background_task(task_name:)
        post(path: "tasks/#{task_name}/")
      end

      def list_recent_background_tasks(task_name:)
        get(path: "tasks/#{task_name}/recents/")
      end
    end
  end
end
