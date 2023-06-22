require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
OpenTelemetry::SDK.configure do |c|
  c.use_all() # enables all instrumentation!
end

AppTracer = OpenTelemetry.tracer_provider.tracer('unreliable_app')

at_exit do
  puts "🔭 Exiting. 🧹 Cleaning up."
  case OpenTelemetry.tracer_provider.shutdown(timeout: 5)
  when OpenTelemetry::SDK::Trace::Export::SUCCESS ; puts "🔭 Span export successful. 🚀"
  when OpenTelemetry::SDK::Trace::Export::FAILURE ; puts "🔭 Span export failed. 🤷"
  when OpenTelemetry::SDK::Trace::Export::TIMEOUT ; puts "🔭 Span export timed out. ⌛️"
  end
  puts "🦄💬 'I did what I could.' 🫡"
end
