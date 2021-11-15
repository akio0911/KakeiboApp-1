# KakeiboApp
家計簿アプリ。　　

![preview](https://user-images.githubusercontent.com/82946608/141708670-5c5ec81f-c967-4106-ac00-200b330cde7f.gif)

# 環境
- Xcode version 13.1 

# 使用言語
- Swift version 5.5.1

# アーキテクチャ
- RxSwift+MVVM

# 使用ライブラリー
- SwiftLint
- RxSwift
- RxCocoa
- Firebase/Firestore
- FirebaseFirestoreSwift
- Firebase/Auth
- Firebase/Crashlytics
- Firebase/Analytics
- Firebase/Messaging

# リリース
- アプリ名: 私の家計簿！
- [https://apps.apple.com/jp/app/apple-store/id1571086397](https://apps.apple.com/jp/app/apple-store/id1571086397)

# アプリについて
- カレンダーで収支を表示
- グラフでカテゴリー別の収支を表示
- 匿名認証を使っているためログインなしで利用可能
- Firebase/Firestoreでデータを保存
- Firebase/Authで認証
  - 匿名認証を使用
  - 新規登録にはメールリンク認証を使用し、ディープリンクでアプリを起動後、匿名認証からメールアドレス・パスワード認証にリンク
  - ログインにはメールアドレス・パスワード認証を使用
- Firebase/Crashlyticsでクラッシュログを取得
- Firebase/Analyticsでアクセス解析
- Firebase/Messagingでリモートプッシュ通知を実装
