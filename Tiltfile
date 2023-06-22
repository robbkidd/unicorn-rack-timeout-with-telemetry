local_resource('unreliable app',
    cmd='ruby ./bin/hack-patch-rack-timeout.rb',
    serve_cmd='bundle exec unicorn --config-file config/unicorn.rb',
    serve_env={
        'OTEL_SERVICE_NAME': 'unreliable-app',
        'RACK_TIMEOUT_SERVICE_TIMEOUT': '10',
        'RACK_TIMEOUT_TERM_ON_TIMEOUT': '2',
    },
    links=[
        link('http://localhost:8080/', 'GET'),
        link('http://localhost:8080/sleepy?nap_seconds=10', 'SLEEPY GET'),
    ]
)

local_resource('otel collector',
    serve_cmd='docker run --rm --env HONEYCOMB_API_KEY --volume ./otel-coll-config.yaml:/etc/otelcol-contrib/config.yaml --publish "127.0.0.1:4318:4318" otel/opentelemetry-collector-contrib:0.80.0',
    deps=['otel-coll-config.yaml']
)

local_resource('poke',
    cmd='curl localhost:8080',
    auto_init=False
)

local_resource('sleepy poke',
    cmd='curl localhost:8080/sleepy?nap_seconds=5',
    auto_init=False
)

local_resource('too sleepy poke',
    cmd='curl localhost:8080/sleepy?nap_seconds=20',
    auto_init=False
)

local_resource('update gems',
    cmd='bundle install',
    auto_init=False,
    deps=['Gemfile']
)
