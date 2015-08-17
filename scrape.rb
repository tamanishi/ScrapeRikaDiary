require 'open-uri'
require 'nokogiri'

proxy = ["#{ENV['proxy_address']}", "#{ENV['proxy_user']}", "#{ENV['proxy_password']}"]
diaryTopUrl = 'http://rika.ed.jp/diary/'
diaryPageUrl = 'http://rika.ed.jp/diary/page/'
baseDir = '.'

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

for num in 1..pageNum
  if num == 1 then
    pageUrl = diaryTopUrl
  else
    pageUrl = diaryPageUrl + num.to_s + "/"
  end
  p 'pageUrl = ' + pageUrl
  html = open(pageUrl, {:proxy_http_basic_authentication => proxy}) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html, nil, charset)
  doc.xpath('//div[@class="entry-list"]/span[@class="title"]/a').each do |node|
    diaryUrl = node.attribute('href').value
    p 'diaryUrl = ' + diaryUrl
    diaryDir = diaryUrl.split("diary")[1]
    p 'diaryDir = ' + diaryDir
    html = open(diaryUrl, {:proxy_http_basic_authentication => proxy}) do |f|
      charset = f.charset
      f.read
    end
    diaryDoc = Nokogiri::HTML.parse(html, nil, charset)
    diaryDoc.xpath('//div[@class="entry-content"]/*/a|//div[@class="entry-content"]/a').each do |node|
      imageUrl = node.attribute('href').value
      p 'imageUrl = ' + imageUrl
      localDiaryDir = baseDir + diaryDir
      FileUtils.mkdir_p(localDiaryDir) unless FileTest.exist?(localDiaryDir)
      open(localDiaryDir + File.basename(imageUrl), "wb") do |output|
        open(imageUrl, {:proxy_http_basic_authentication => proxy}) do |data|
          output.write(data.read)
        end
      end
      exit
    end
  end
end
