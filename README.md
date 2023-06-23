# Placating Murderous Unicorn Worker Assassins

The Unicorn project is [pretty adamant about not expanding features around timing out slow request workers](https://yhbt.net/unicorn-public/20180224151559.GA15504@whir/).
I think a little more could be done, but it's their project and they have a point: [timeouts managed from outside the thing taking too long are fraught with peril](https://www.mikeperham.com/2015/05/08/timeout-rubys-most-dangerous-api/), particularly in Ruby.
The general recommendation is to [time out the Right Way](https://github.com/ankane/the-ultimate-guide-to-ruby-timeouts) by using the timeout features built in to components known to take a long time.

What if you don't know what's taking a long time because the main unicorn process comes along and [murders your poor unicorn workers](https://yhbt.net/unicorn.git/tree/lib/unicorn/http_server.rb?h=v6.1.0#n497) just trying to get their job done?
Combing through large code-bases to search for where someone might have forgotten to set a timeout on a long-running call is a lot of work with no guarantee that the stopwatch-wielding unicorn murderer will be appeased.

Yes, you should not rely on unicorn's timeout to save your processes, but you can teach your unicorn workers union members to attempt to write death notes before their demise so that you can get a clue as to where in your application there is some procedure feeling unrestrained by time.

## Running this Repro

You'll need:

* [Tilt](https://tilt.dev/)
* Docker
* curl
* a local Ruby environment

Steps:

1. `bundle install`
1. To see OpenTelemetry tracing at Honeycomb, set an environment variable HONEYCOMB_API_KEY with a key before running the next command.
If you don't have or want Honeycomb, don't.
Trace data will still appear, but not as pretty, in the console output of the `otel collector` service in Tilt.
1. `tilt up`
    * Ruby's tilt might have taken precidence on the PATH, so you may need to `/usr/local/bin/tilt up` or `/opt/homebrew/bin/tilt up`.

## The Steps This Project Took

1. [Add rack-timeout to your project](https://github.com/zombocom/rack-timeout#rails-apps) despite [how it might hose your server](https://www.schneems.com/2017/02/21/the-oldest-bug-in-ruby-why-racktimeout-might-hose-your-server/).
We'll deal with the hosing.
1. [Set rack-timeout](https://github.com/zombocom/rack-timeout#configuring) to what you think is a reasonable wait period for a request (see `Tiltfile` and the `RACK_TIMEOUT_*` environment variables set for the app).
    * At the end of this time, rack-timeout's middleware injects an exception into the current thread.
      [Exceptions injected by outside forces risks your worker processes entering a corrupt state](https://www.schneems.com/2017/02/21/the-oldest-bug-in-ruby-why-racktimeout-might-hose-your-server/).
      These workers _should_ get retired and replaced.
      Keep going for how to do that more humanely.
1. Set unicorn's worker timeout higher than that. (see `config/unicorn.rb`)
1. [Set rack-timeout's `term_on_timeout` option](https://github.com/zombocom/rack-timeout/blob/main/doc/settings.md#term-on-timeout) to a number of times a worker process may timeout before the process is sent a SIGTERM.
Unicorn traps TERM, the worker is _not_ ended gracefully.
    * **Set to 1** and rack-timeout sends TERM right before injecting the thread exception, but the worker process will not have enough time to ship any telemetry about the exception out to you.
    * **Set to higher than 1** and rack-timeout will still inject the thread exception to end the request early, probably returning a 500 response, but TERM won't be sent until the worker process times out again, up to the number set for this option.
With TERM delayed to a future timeout, at least telemetry about the previous allowed exceptions ought to have enough time to transmit.
You'll miss telemetry about the last one, though.
1. Optional, but this increases the gracefulness of a worker's demise:
    * Add an `at_exit` block to your application responsible for shipping whatever telemetry you have; in this app, that's [OpenTelemetry](https://opentelemetry.io/docs/instrumentation/ruby/) traces (see `config/initializers/opentelemetry.rb`).
    * Patch rack-timeout to send SIGQUIT instead of SIGTERM. Unicorn traps QUIT and allows the worker to exit gracefully.
    Your patch should probably live in a fork you maintain, even though fork-maintenance is painful.
    You should _not_ patch it like I did in this problem-reproduction project.
    * With rack-timeout sending SIGQUIT, rack-timeout's `term_on_timeout` can be set to 1, the `at_exit` block will take care of shipping telemetry about the long-running code path, and the worker will be replaced by a fresh process with a clean initialized state.
