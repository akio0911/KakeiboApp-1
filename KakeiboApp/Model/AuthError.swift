//
//  AuthError.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/11/02.
//

import Foundation
import FirebaseAuth

enum AuthError: Error {
    case invalidEmail
    case userDisabled
    case wrongPassword
    case userNotFound
    case tooManyRequests
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case missingEmail
    case other(String)

    // swiftlint:disable:next cyclomatic_complexity
    init?(error: Error) {
        guard let errorCode = AuthErrorCode(rawValue: error._code) else { return nil }
        switch errorCode {
        case .invalidEmail:
            // メールアドレスの形式が正しくないことを示します。
            self = .invalidEmail
        case .userDisabled:
            // ユーザーのアカウントが無効になっていることを示します。
            self = .userDisabled
        case .wrongPassword:
            // ユーザーが間違ったパスワードでログインしようとしたことを示します。
            self = .wrongPassword
        case .userNotFound:
            // ユーザーアカウントが見つからなかったことを示します。
            self = .userNotFound
        case .tooManyRequests:
            /* 呼び出し元の端末から Firebase Authenticationサーバーに
             異常な数のリクエストが行われた後で、リクエストがブロックされたことを示します。*/
            self = .tooManyRequests
        case .emailAlreadyInUse:
            // 登録に使用されたメールアドレスがすでに存在することを示します。
            self = .emailAlreadyInUse
        case .weakPassword:
            // 設定しようとしたパスワードが弱すぎると判断されたことを示します。
            self = .weakPassword
        case .networkError:
            // ネットワークエラーが発生したことを示します。
            self = .networkError
        case .missingEmail:
            // 電子メールアドレスが予期されていたが、提供されなかったことを示します。
            self = .missingEmail
        default:
            self = .other(error.localizedDescription)
        }
    }

    var reason: String? {
        switch self {
        case .invalidEmail:
            return "メールアドレスの形式が正しくありません。"
        case .userDisabled:
            return "無効なアカウントです。"
        case .wrongPassword:
            return "パスワードが一致しません。"
        case .userNotFound:
            return "アカウントが見つかりません。"
        case .tooManyRequests:
            return nil
        case .emailAlreadyInUse:
            return "登録済みのメールアドレスです。"
        case .weakPassword:
            return "パスワードが脆弱です。"
        case .networkError:
            return "ネットワークエラーが発生しました。"
        case .missingEmail:
            return "メールアドレスを認識できませんでした。"
        case .other(_):
            return nil
        }
    }

    var message: String {
        switch self {
        case .invalidEmail:
            return "メールアドレスを正しく入力してください。"
        case .userDisabled:
            return "他のアカウントでログインしてください。"
        case .wrongPassword:
            return "パスワードを正しく入力してください。"
        case .userNotFound:
            return "メールアドレスを正しく入力してください。"
        case .tooManyRequests:
            return "しばらくしてからもう一度お試しください。"
        case .emailAlreadyInUse:
            return "ログイン画面からログインしてください。"
        case .weakPassword:
            return "第三者から判定されづらいパスワードにしてください"
        case .networkError:
            return "電波の良いところでやり直してください。"
        case .missingEmail:
            return "メールアドレスを正しく入力してください。"
        case .other(let message):
            return message
        }
    }
}
