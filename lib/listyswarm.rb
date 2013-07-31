
# Require all first level  files
Dir.glob('./lib/*.rb').each do |filename|
  require filename
end

# Require all n level  files
Dir.glob('./lib/**/*.rb').each do |filename|
  require filename
end
