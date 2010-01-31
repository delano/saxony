@spec = Gem::Specification.new do |s|
  s.name = "saxony"
  s.rubyforge_project = 'bone'
  s.version = "0.1.0"
  s.summary = "Parse gigantic XML files with pleasure and ease."
  s.description = s.summary
  s.author = "Delano Mandelbaum"
  s.email = "delano@solutious.com"
  s.homepage = ""
  
  s.extra_rdoc_files = %w[README.md LICENSE.txt CHANGES.txt]
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--title", s.summary, "--main", "README.md"]
  s.require_paths = %w[lib]
  
  #s.executables = %w[bone]
  
  #s.add_dependency 'boned',    '= 0.2.4'
  
  # = MANIFEST =
  # git ls-files
  s.files = %w(
  
  )

  
end
