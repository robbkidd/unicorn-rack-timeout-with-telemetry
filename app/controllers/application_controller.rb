class ApplicationController < ActionController::Base

  private

  def compute_dynamism
    AppTracer.in_span('compute_dynamism') do
      rand(36**6).to_s(36)
    end
  end
end
