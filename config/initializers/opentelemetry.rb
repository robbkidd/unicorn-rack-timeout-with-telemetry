require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
OpenTelemetry::SDK.configure do |c|
  c.use_all() # enables all instrumentation!
end

AppTracer = OpenTelemetry.tracer_provider.tracer('unreliable_app')
