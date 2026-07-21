# sm-ART-lock

`sm-ART-lock`, MacBook veya harici klavye temizlerken yanlışlıkla tuşlara basılmasını önlemek için geliştirilmiş native bir macOS menü çubuğu uygulamasıdır. SwiftUI ile hazırlanmış sade bir popover arayüzü, AppKit ile yönetilen bir menü bar ikonu ve CoreGraphics event tap tabanlı klavye engelleme mantığı kullanır.

Uygulama aktifken klavye girişlerini geçici olarak engeller. Mouse ve touchpad girişlerine müdahale etmez.

## Ne İşe Yarar?

Klavye veya MacBook ekran çevresini temizlerken bezin yanlışlıkla tuşlara basmasını engeller. Menü çubuğundan Temizleme Modu açılır, mod açıkken normal klavye basışları uygulamalara gitmez.

Temizleme Modu yalnızca `Command + 0` kısayolu ile kapatılır.

## Ekran Davranışı

- Uygulama ana pencere açmaz.
- Dock'ta görünmez.
- Menü çubuğunda kilit ikonu olarak çalışır.
- Temizleme Modu kapalıyken klavyeye müdahale etmez.
- Temizleme Modu açıkken normal tuş basışları uygulamalara iletilmez.

## Özellikler

- Native macOS uygulaması
- SwiftUI arayüz
- AppKit ile menü bar item ve popover yönetimi
- Ana pencere açmadan menü çubuğunda çalışır
- `CGEvent.tapCreate` ile global klavye event tap kullanır
- `.keyDown`, `.keyUp` ve `.flagsChanged` klavye eventlerini yakalar
- Temizleme Modu açıkken klavye inputlarını engeller
- `Command + 0` algılanınca Temizleme Modu kapanır
- Mouse ve touchpad inputlarına dokunmaz
- Menü bar ikonunda açık/kapalı durum anlaşılır
- Uygulama kapanırken event tap temizlenir
- İzin durumunu arayüzde gösterir
- macOS izin ayarlarını açmak için butonlar içerir
- Popover içinden uygulamadan çıkış butonu

## Gereksinimler

- macOS 14.0 veya üzeri
- Xcode 26.4 veya uyumlu yeni bir Xcode sürümü
- Swift 5

## Kurulum

Projeyi klonlayın:

```sh
git clone https://github.com/burakozturk1/sm-ART-lock.git
cd sm-ART-lock
```

## Xcode'da Çalıştırma

1. `sm-ART-lock.xcodeproj` dosyasını Xcode ile açın.
2. Scheme olarak `sm-ART-lock` seçin.
3. Hedef olarak `My Mac` seçin.
4. Run butonuna basın.
5. Uygulama Dock'ta pencere açmadan menü çubuğunda görünür.

## Komut Satırından Derleme

Debug build:

```sh
xcodebuild -project sm-ART-lock.xcodeproj -scheme sm-ART-lock -configuration Debug build
```

Release build:

```sh
xcodebuild -project sm-ART-lock.xcodeproj -scheme sm-ART-lock -configuration Release build
```

Build ürünü Xcode'un `DerivedData` dizini altında oluşur.

## Xcode Olmadan Kullanma

Xcode'dan Run ile açılan uygulama debugger'a bağlı çalışır. Xcode kapanınca uygulamanın da kapanması normaldir. Bağımsız kullanmak için Release build aldıktan sonra `.app` paketini Applications klasörüne kopyalayın:

```sh
cp -R ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Release/sm-ART-lock.app /Applications/
open /Applications/sm-ART-lock.app
```

Bu işlemden sonra uygulama Xcode açık olmadan menü çubuğundan çalışır.

## Kullanım

1. Uygulamayı çalıştırın.
2. Menü çubuğundaki kilit ikonuna tıklayın.
3. `Temizleme Modunu Aç` butonuna basın.
4. Klavyeyi veya MacBook'u temizleyin.
5. Bitince `Command + 0` tuşlarına basarak modu kapatın.
6. Uygulamayı tamamen kapatmak için popover içindeki `Çıkış` butonunu kullanın.

## macOS İzinleri

Global klavye eventlerini yakalamak için macOS izinleri gerekir. Uygulama izin durumunu popover içinde gösterir.

Gerekebilecek izinler:

- System Settings > Privacy & Security > Accessibility
- System Settings > Privacy & Security > Input Monitoring

Popover içindeki izin butonları ilgili macOS ayar ekranlarını açar. İzin verdikten sonra uygulamayı yeniden başlatmanız gerekebilir. Bazı macOS sürümlerinde izin verildikten sonra uygulamanın listede kapatılıp tekrar açılması da gerekebilir.

Önemli: Uygulamayı Xcode'dan çalıştırmak ile `/Applications/sm-ART-lock.app` olarak çalıştırmak macOS izinleri açısından farklı uygulamalar gibi görülebilir. Bağımsız `.app` sürümünü kullanacaksanız izni `/Applications` içindeki uygulamaya verdiğinizden emin olun.

## Çıkış Kısayolu

Temizleme Modu açıkken normal klavye tuşları engellenir. Modu kapatmak için:

```text
Command + 0
```

Bu kısayol algılandığında Temizleme Modu kapanır ve kısayol event'i de uygulamalara gönderilmez.

## Güvenlik Notu

Bu uygulama klavyeyi geçici olarak engelleyebildiği için kilit modu bilinçli kullanılmalıdır. Mod açıkken tek çıkış kısayolu `Command + 0` olarak tasarlanmıştır. Mouse ve touchpad çalışmaya devam ettiği için menü bar popover'ına erişmeye devam edebilirsiniz.

## Proje Yapısı

```text
sm-ART-lock/
├── sm-ART-lock.xcodeproj/
├── sm-ART-lock/
│   ├── sm_ART_lockApp.swift
│   ├── AppDelegate.swift
│   ├── KeyboardBlocker.swift
│   ├── PermissionManager.swift
│   └── LockPopoverView.swift
├── .gitignore
└── README.md
```

## Teknik Notlar

- Uygulama `LSUIElement` olarak ayarlanmıştır; Dock'ta görünmez.
- Klavye engelleme sadece Temizleme Modu açıkken event tap oluşturarak çalışır.
- Mod kapalıyken klavye eventlerine müdahale edilmez.
- Event tap `.cgSessionEventTap` ve `.headInsertEventTap` ile kurulur.
- Klavye eventleri `nil` dönülerek swallow edilir.
- `Command + 0` kısayolu yakalanınca event tap kapatılır.

