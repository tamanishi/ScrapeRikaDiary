require 'open-uri'
require 'nokogiri'

proxy = ['http://158.213.204.65:8080', '22628671', 'tamanishi3']
diaryTopUrl = 'http://rika.ed.jp/diary/'
diaryPageUrl = 'http://rika.ed.jp/diary/page/'

charset = nil
html = open(diaryTopUrl, {:proxy_http_basic_authentication => proxy}) do |f|
  charset = f.charset
  f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)

# p doc

doc.xpath('//div[@class="wp-pagenavi"]/span[@class="pages"]').each do |pageCount|
  p(pageCount.inner_text.split("/")[1].strip!)
end

# doc.xpath('//div[@class="entry-content"]/p/a').each do |node|
#   p(node.attribute('href').value)
# end
