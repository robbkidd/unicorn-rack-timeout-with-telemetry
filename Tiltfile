local_resource('unreliable app',
    serve_cmd='bundle exec unicorn --config-file config/unicorn.rb',
    links=[
        link('http://localhost:8080/', 'GET'),
        link('http://localhost:8080/sleepy?nap_seconds=10', 'SLEEPY GET'),
    ]
)

# go install github.com/CtrlSpice/otel-desktop-viewer@latest
# it's pretty dope!
local_resource('trace viewer',
    serve_cmd='./bin/otel-desktop-viewer',
    links=[link('http://localhost:8000/', 'View Traces')]
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
