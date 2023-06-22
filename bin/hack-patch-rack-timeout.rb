#!/usr/bin/env ruby

##
# ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
# ⚠️ Not for production patching. ⚠️
# ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
#
# ️Never, ever monkeypatch like this.
# ... Really.
# ... OK?
# ... OK. Here we go! ᕕ( ᐛ )ᕗ
rack_timeout_path = `bundle show rack-timeout`.strip
exit 1 unless rack_timeout_path

rack_timeout_core_path = (rack_timeout_path + '/lib/rack/timeout/core.rb')
exit 2 unless File.exist?(rack_timeout_core_path)

core_contents = File.read(rack_timeout_core_path)
case core_contents
when /Process.kill\("SIGQUIT"/
  puts "QUITing, not TERMing. 👍"
when /Process.kill\("SIGTERM"/
  File.open(rack_timeout_core_path, 'w+') do |f|
    f << core_contents.gsub('SIGTERM', 'SIGQUIT')
  end
else
  puts "rack-timeout core has changed beyond my ken."
end
