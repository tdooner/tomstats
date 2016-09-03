require 'clockwork'

require 'rake'
load 'Rakefile'

module Clockwork
  handler do |job|
    Rake::Task[job].invoke
  end

  on(:after_run) do |job|
    Clockwork.manager.log "Finished: '#{job}'"
  end

  every(1.hour, 'sync:dropbox')
end
