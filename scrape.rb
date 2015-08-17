require 'open-uri'
require 'nokogiri'

proxy = ["#{ENV['proxy_address']}", "#{ENV['proxy_user']}", "#{ENV['proxy_password']}"]
diaryTopUrl = 'http://rika.ed.jp/diary/'
diaryPageUrl = 'http://rika.ed.jp/diary/page/'

charset = nil
html = open(diaryTopUrl, {:proxy_http_basic_authentication => proxy}) do |f|
  charset = f.charset
  f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)

pageNum = nil
doc.xpath('//div[@class="wp-pagenavi"]/span[@class="pages"]').each do |pageCount|
  pageNum = pageCount.inner_text.split("/")[1].strip!.to_i
  p pageNum
end

for num in 2..pageNum
  pageUrl = diaryPageUrl + num.to_s + "/"
  p pageUrl
  html = open(pageUrl, {:proxy_http_basic_authentication => proxy}) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html, nil, charset)
  doc.xpath('//div[@class="entry-list"]/span[@class="title"]/a').each do |node|
    diaryUrl = node.attribute('href').value
    p diaryUrl
    html = open(diaryUrl, {:proxy_http_basic_authentication => proxy}) do |f|
      charset = f.charset
      f.read
    end
    diaryDoc = Nokogiri::HTML.parse(html, nil, charset)
    diaryDoc.xpath('//div[@class="entry-content"]/p/a').each do |node|
      p(node.attribute('href').value)
    end
  end
end
