Pod::Spec.new do |s|
  s.name         = "KRFuzzyCMeans"
  s.version      = "1.0"
  s.summary      = "Fuzzy C-Means is clustering algorithm combined fuzzy theory on Machine Learning."
  s.description  = <<-DESC
                   KRFuzzyCMeans has implemented Fuzzy C-Means (FCM) the fuzzy (ファジー理論) clustering / classification algorithm (クラスタリング分類) in Machine Learning (マシンラーニング). It could be used in data mining (データマイニング) and image compression (画像圧縮).
                   DESC
  s.homepage     = "https://github.com/Kalvar/ios-KRFuzzyCMeans-Algorithm"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Kalvar Lin" => "ilovekalvar@gmail.com" }
  s.social_media_url = "https://twitter.com/ilovekalvar"
  s.source       = { :git => "https://github.com/Kalvar/ios-KRFuzzyCMeans-Algorithm.git", :tag => s.version.to_s }
  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.public_header_files = 'FCM/*.h'
  s.source_files = 'FCM/KRFuzzyCMeans.h'
  s.frameworks   = 'Foundation'
end 