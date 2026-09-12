# Run with: bundle exec ruby tests/site_check.rb
# Requires the site's existing Ruby dependencies and npm install for the JS comparison.
require 'jekyll'
require 'nokogiri'
require 'json'
require 'tmpdir'
require 'uri'
require 'cgi'
require 'open3'
require 'rbconfig'
require 'set'

ROOT = File.expand_path('..', __dir__)
Dir.chdir(ROOT)

CHECKS = []
def check(condition, message)
  raise message unless condition
  CHECKS << message
end

def document(path)
  Nokogiri::HTML(File.read(path))
end

# Resolve actual generated files, including extensionless Jekyll document URLs.
def local_file(destination, reference, current_path, origin, baseurl)
  value = CGI.unescapeHTML(reference.strip)
  return if value.empty? || value.start_with?('data:', 'mailto:', 'tel:', 'javascript:')
  url = URI.parse(value)
  return if url.host && url.host != URI(origin).host
  return if url.scheme && !%w[http https].include?(url.scheme)
  path = URI::DEFAULT_PARSER.unescape(url.path)
  if path.empty?
    path = current_path
  elsif path.start_with?('/')
    return if !baseurl.empty? && !path.start_with?(baseurl + '/') && path != baseurl
    path = path.delete_prefix(baseurl).delete_prefix('/')
  else
    path = File.join(File.dirname(current_path), path)
  end
  candidate = File.expand_path(path, destination)
  check(candidate == destination || candidate.start_with?(destination + '/'), "Resource stays inside the site: #{reference}")
  [candidate, File.join(candidate, 'index.html'), candidate + '.html'].find { |file| File.file?(file) }
end

def valid_fragment?(doc, fragment)
  # Text fragments can follow an ordinary element fragment or stand alone.
  fragment = URI::DEFAULT_PARSER.unescape(fragment.to_s.split(':~:', 2).first.to_s)
  return true if fragment.empty? || fragment.downcase == 'top'
  doc.css('[id], a[name]').any? do |element|
    element['id'] == fragment || (element.name == 'a' && element['name'] == fragment)
  end
end

anchor_fixture = Nokogiri::HTML('<h2 id="章节">Heading</h2><a name="legacy"></a><input id="field" name="missing">')
check(valid_fragment?(anchor_fixture, '%E7%AB%A0%E8%8A%82'), 'Encoded element fragments resolve')
check(valid_fragment?(anchor_fixture, 'legacy'), 'Named anchors resolve')
check(valid_fragment?(anchor_fixture, ':~:text=Heading'), 'Text fragments do not require an element ID')
check(!valid_fragment?(anchor_fixture, 'missing'), 'Missing element fragments are rejected')

config = Jekyll.configuration('source' => ROOT, 'quiet' => true)
site = Jekyll::Site.new(config)
site.read
page_data = (site.pages + site.collections.values.flat_map(&:docs)).to_h { |page| [page.url, page.data] }
origin = config.fetch('url')
baseurl = config.fetch('baseurl', '')

# Reading time counts CJK characters and Latin words, rounds up and selects the archive item.
template = Liquid::Template.parse(File.read('_includes/read-time.html'))
[[0,160,'less than 1 minute read'], [159,160,'1 minute read'],
 [160,160,'1 minute read'], [319,160,'2 minutes read'], [320,160,'2 minutes read'],
 [350,160,'3 minutes read'], [600,200,'3 minutes read'], [320,0,'2 minutes read']].each do |words,wpm,expected|
  result = template.render!({'page' => {'content' => 'word ' * words}, 'site' => {'words_per_minute' => wpm}}, registers: {site: site})
  check(result.strip == expected, "Read-time boundary: #{words} words at #{wpm} WPM")
end
result = template.render!('include' => {'item' => {'content' => 'word ' * 800, 'read_time_minutes' => 25}},
                          'page' => {'read_time_minutes' => 99}, 'site' => {'words_per_minute' => 160})
check(result.strip == '25 minutes read', 'Explicit archive read time overrides page and calculation')
[
  ['汉' * 275, {}, {}, '1 minute read'],
  ['汉' * 276, {}, {}, '2 minutes read'],
  ['汉' * 275 + ' word' * 160, {}, {}, '2 minutes read'],
  ['汉' * 275, {}, {'cjk_characters_per_minute' => 0}, '1 minute read'],
  ['汉' * 500, {}, {'cjk_characters_per_minute' => 250}, '2 minutes read'],
  ['汉' * 275, {'read_time_extra_minutes' => 1}, {}, '2 minutes read'],
  ['汉' * 275, {'read_time_extra_minutes' => -1}, {}, '1 minute read'],
  [('[word](https://example.org/a/very/long/path) ' * 160), {}, {}, '1 minute read']
].each do |content, options, settings, expected|
  result = template.render!({'include' => {'item' => {'content' => content}.merge(options)},
    'page' => {'read_time_minutes' => 99}, 'site' => settings}, registers: {site: site})
  check(result.strip == expected, "Mixed-language read time: #{expected}, #{options}, #{settings}")
end

# Every referenced semantic color must exist in both themes.
sass = Dir['_sass/**/*.scss'].reject { |path| path.include?('/vendor/') }.map { |path| File.read(path) }.join("\n")
variables = sass.scan(/var\((--global-[\w-]+)/).flatten.uniq
%w[light dark].each do |theme|
  source = File.read("_sass/theme/_default_#{theme}.scss")
  variables.each { |name| check(source.include?(name + ':'), "#{theme} defines #{name}") }
end

# The committed JS bundle is the code that the browser executes.
node = ENV.fetch('NODE', 'node')
uglify = 'node_modules/uglify-js/bin/uglifyjs'
check(File.file?(uglify), 'JS build dependency is installed (run npm install first)')
Dir.mktmpdir('academic-site-check-') do |work|
  js = File.join(work, 'main.min.js')
  output, status = Open3.capture2e(node, uglify, 'node_modules/jquery/dist/jquery.min.js',
    'assets/js/plugins/jquery.greedy-navigation.js', 'assets/js/_main.js', '-c', '-m', '-o', js)
  check(status.success?, "JS compilation succeeds: #{output}")
  check(File.binread(js) == File.binread('assets/js/main.min.js'), 'JS bundle matches its sources')

  %w[development production].each do |environment|
    destination = File.join(work, environment)
    output, status = Open3.capture2e({'JEKYLL_ENV' => environment}, RbConfig.ruby, '-S', 'bundle',
      'exec', 'jekyll', 'build', '--destination', destination, '--quiet')
    check(status.success?, "#{environment} build succeeds: #{output}")
    files = Dir[File.join(destination, '**', '*.html')]
    pages = files.to_h { |path| [path.delete_prefix(destination + '/'), document(path)] }
    main_pages = pages.select { |_, doc| doc.at_css('#main') }
    expected_pages = Dir['_pages/*', '_posts/*', '_publications/*'].count { |path| File.file?(path) }
    check(main_pages.size == expected_pages, "#{environment}: every source page is rendered exactly once")
    %w[about.html about/index.html cv/index.html resume/index.html year-archive/index.html
       hobbies/index.html zh_cn/index.html publication/paper-undergraduate.html redirects.json].each do |old|
      check(!File.exist?(File.join(destination, old)), "#{environment}: retired address absent: #{old}")
    end
    %w[AGENTS.md tests docs/superpowers node_modules vendor assets/js/_main.js assets/js/plugins].each do |private_path|
      check(!File.exist?(File.join(destination, private_path)), "#{environment}: build excludes #{private_path}")
    end

    main_pages.each do |path, doc|
      check(doc.css('[id]').map { |e| e['id'] }.uniq.size == doc.css('[id]').size, "#{path}: unique IDs")
      check(doc.css('link[rel="canonical"]').size == 1, "#{path}: one canonical URL")
      check(doc.at_css('meta[name="description"]')['content'].to_s.size > 0, "#{path}: description present")
      check(doc.css('meta[http-equiv="refresh"]').empty?, "#{path}: no redirect shim")
      doc.css('script[type="application/ld+json"]').each { |script| JSON.parse(script.text) }
      check(doc.css('.pagination a.disabled, .pagination a[href="#"]').empty?, "#{path}: disabled pagination is not a link")
      check(doc.css('.sidebar').size == (path == 'index.html' ? 1 : 0), "#{path}: sidebar only on About")
      url = doc.at_css('link[rel="canonical"]')['href'].delete_prefix(origin + baseurl)
      options = page_data.fetch(url, {})
      layout_options = site.layouts[options['layout']]&.data || {}
      check(doc.css('script[src*="mathjax"]').any? == !!(options['mathjax'] || layout_options['mathjax']), "#{path}: MathJax respects page opt-in")
      check(doc.css('script').any? { |script| script.text.include?('mermaid.initialize') } == !!(options['mermaid'] || layout_options['mermaid']), "#{path}: Mermaid respects page opt-in")
      tracking = doc.css('script').any? { |script| script.text.include?('https://gc.zgo.at/count.js') }
      check(tracking == (environment == 'production'), "#{path}: visit tracking is production-only")
      if environment == 'development'
        doc.css('.masthead a[href], script[src], link[rel="stylesheet"], .author__avatar img').each do |element|
          value = element['href'] || element['src']
          check(!value.start_with?(origin), "#{path}: preview navigation and assets stay local")
        end
      end
      check(doc.at_css('.greedy-nav > button')['class'].split.include?('hidden'), "#{path}: overflow button starts hidden")
    end

    # Check every local HTML reference and fragment; external sites are not contacted.
    referenced_assets = Set.new
    pages.each do |path, doc|
      references = doc.css('[href], [src], [srcset]').flat_map do |element|
        [element['href'], element['src'], *element['srcset'].to_s.split(',').map { |entry| entry.strip.split.first }].compact
      end
      references.each do |reference|
        next if reference.empty? || reference.start_with?('data:', 'mailto:', 'tel:', 'javascript:')
        uri = URI.parse(CGI.unescapeHTML(reference))
        next if uri.host && uri.host != URI(origin).host
        target = local_file(destination, reference, path, origin, baseurl)
        check(target, "#{path}: resource exists: #{reference}")
        referenced_assets << target
        if uri.fragment && target.end_with?('.html')
          target_doc = pages.fetch(target.delete_prefix(destination + '/'))
          check(valid_fragment?(target_doc, uri.fragment), "#{path}: fragment exists: #{reference}")
        end
      end
    end
    css = File.read(File.join(destination, 'assets/css/main.css'))
    css.scan(/url\(["']?([^)'"\s]+)["']?\)/).flatten.each do |reference|
      next if reference.start_with?('data:', 'http')
      target = local_file(destination, reference, 'assets/css/main.css', origin, baseurl)
      check(target, "CSS resource exists: #{reference}")
      referenced_assets << target
    end
    manifest = JSON.parse(File.read(File.join(destination, 'images/manifest.json')))
    manifest.fetch('icons').each do |icon|
      target = local_file(destination, icon.fetch('src'), 'images/manifest.json', origin, baseurl)
      check(target, 'Manifest icon exists')
      referenced_assets << target
    end
    media = %w[images files assets/webfonts].flat_map { |folder| Dir[File.join(destination, folder, '**', '*')] }.select { |file| File.file?(file) }
    unused = media.reject { |file| referenced_assets.include?(file) }.map { |file| file.delete_prefix(destination + '/') }
    check(unused.empty?, "#{environment}: no unreferenced published media: #{unused.join(', ')}")
    home = pages.fetch('index.html')
    article = pages.fetch('posts/gp-mpc-reflections/index.html')
    check(local_file(destination, '#main', 'index.html', origin, baseurl) == File.join(destination, 'index.html'), 'Fragment-only links resolve to the current page')
    %w[posts/gp-mpc-reflections/index.html publication/p-norm-filter/index.html].each do |path|
      check(pages.fetch(path).at_css('html')['lang'] == 'zh-CN', "#{path}: Chinese content has the correct document language")
    end
    check(article.css('.paper-map__node').size == 5, 'GP-MPC map renders five linked papers')
    check(article.css('.paper-map__node').all? { |a| a['href'].start_with?('https://doi.org/') }, 'Map links use journal DOIs')
    check(article.at_css('.page__meta').text.include?('10 min read'), 'GP-MPC reading estimate includes Chinese and diagram time')
    entry = pages.fetch('posts/index.html').css('.archive__item').find { |item| item.at_css('a')['href'].end_with?('/posts/gp-mpc-reflections/') }
    check(entry.at_css('.page__meta').text == article.at_css('.page__meta').text, 'Archive and article show the same reading estimate')
    check(home.at_css('button.author__wechat-trigger[aria-expanded="false"][aria-controls="wechat-qr"]'), 'WeChat uses a native disclosure button')
    check(home.at_css('#wechat-qr[hidden]'), 'QR disclosure starts closed')
    check(home.at_css('[data-visit-count]')['data-legacy-count'].to_i == config.dig('visit_counter', 'legacy_count'), 'Visit counter retains configured historical count')
    gallery = pages.fetch('gallery/index.html')
    check(gallery.css('img').all? { |img| img['loading'] == 'lazy' }, 'Gallery media is lazy-loaded')
    %w[mclaren.jpg lh44.jpg].each { |file| check(File.size("images/#{file}") < 600_000, "#{file} stays web-sized") }
    %w[publications posts].each do |collection|
      count = Dir["_#{collection}/*"].count { |file| File.file?(file) }
      check(pages.fetch("#{collection}/index.html").css('.archive__item').size == count, "#{collection}: every entry appears in its index")
    end
    sitemap = Nokogiri::XML(File.read(File.join(destination, 'sitemap.xml')))
    sitemap.remove_namespaces!
    sitemap.css('loc').each do |loc|
      check(local_file(destination, loc.text, 'sitemap.xml', origin, baseurl), "Sitemap entry exists: #{loc.text}")
    end
    puts "#{environment}: #{main_pages.size} pages; HTML, links, assets, metadata and build isolation passed"
  end
end
puts "Passed #{CHECKS.size} checks."
