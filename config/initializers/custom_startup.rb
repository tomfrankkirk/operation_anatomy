require_relative '../../lib/routing_helpers'

if Rails.env != 'test'
puts "Running custom startup scripts for all environments"
RoutingHelpers::loadLevelNames()
RoutingHelpers::preprocessManualTeachingLinks()
RoutingHelpers::prepareTeachingPaths()

# TODO: use full level names and create them from the folder structure?

end
 