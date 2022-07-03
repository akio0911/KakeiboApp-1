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
        guard let errorCode = AuthErrorCode.Code(rawValue: error._code) else { return nil }
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
            return R.string.localizable.invalidEmailReason()
        case .userDisabled:
            return R.string.localizable.userDisabledReason()
        case .wrongPassword:
            return R.string.localizable.wrongPasswordReason()
        case .userNotFound:
            return R.string.localizable.userNotFoundReason()
        case .tooManyRequests:
            return nil
        case .emailAlreadyInUse:
            return R.string.localizable.emailAlreadyInUseReason()
        case .weakPassword:
            return R.string.localizable.weakPasswordReason()
        case .networkError:
            return R.string.localizable.networkErrorReason()
        case .missingEmail:
            return R.string.localizable.missingEmailReason()
        case .other(_):
            return nil
        }
    }

    var message: String {
        switch self {
        case .invalidEmail:
            return R.string.localizable.invalidEmailMessage()
        case .userDisabled:
            return R.string.localizable.userDisabledMessage()
        case .wrongPassword:
            return R.string.localizable.wrongPasswordMessage()
        case .userNotFound:
            return R.string.localizable.userNotFoundMessage()
        case .tooManyRequests:
            return R.string.localizable.tooManyRequestsMessage()
        case .emailAlreadyInUse:
            return R.string.localizable.emailAlreadyInUseMessage()
        case .weakPassword:
            return R.string.localizable.weakPasswordMessage()
        case .networkError:
            return R.string.localizable.networkErrorMessage()
        case .missingEmail:
            return R.string.localizable.missingEmailMessage()
        case .other(let message):
            return message
        }
    }
}
