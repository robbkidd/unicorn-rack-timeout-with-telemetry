class SleepyController < ApplicationController
  def index
    @dynamism = compute_dynamism

    @nap_seconds = params['nap_seconds'].to_i
    nap(@nap_seconds)

    render inline: "I had to sleep for a bit (<%= @nap_seconds %> seconds). Randomness: <%= @dynamism %>"
  end

  private

  def nap(seconds)
    AppTracer.in_span('napping', attributes: {"nap.duration_s" => seconds}) do
      puts "🥱 Maybe I could use a nap ..."
      sleep seconds
    end
  end
end
