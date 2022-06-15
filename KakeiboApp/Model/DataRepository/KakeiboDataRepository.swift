//
//  KakeibDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/13.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

protocol DataRepositoryProtocol {
    func loadData(userId: String, completion: @escaping (Result<[KakeiboData], Error>) -> Void)
    func setData(userId: String, data: KakeiboData, completion: @escaping (Error?) -> Void)
    func deleteData(userId: String, data: KakeiboData, completion: @escaping (Error?) -> Void)
}

final class KakeiboDataRepository: DataRepositoryProtocol {
    private let db: Firestore // swiftlint:disable:this identifier_name
    private let firstCollectionName = "users"
    private let secondCollectionName = "KakeiboData"

    init() {
        let setting = FirestoreSettings()
        Firestore.firestore().settings = setting
        db = Firestore.firestore()
    }

    func loadData(userId: String, completion: @escaping (Result<[KakeiboData], Error>) -> Void) {
        db.collection(firstCollectionName).document(userId)
            .collection(secondCollectionName).getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let documents = querySnapshot?.documents {
                    var kakeiboDataArray: [KakeiboData] = []
                    for document in documents {
                        let result = Result {
                            try document.data(as: KakeiboData.self)
                        }
                        switch result {
                        case .success(let data):
                            if let data = data {
                                kakeiboDataArray.append(data)
                            }
                        case .failure(let error):
                            print("----Error decoding item: \(error.localizedDescription)----")
                        }
                    }
                    completion(.success(kakeiboDataArray))
                }
            }
    }

    func setData(userId: String, data: KakeiboData, completion: @escaping (Error?) -> Void) {
        do {
            let ref = db.collection(firstCollectionName).document(userId)
                .collection(secondCollectionName).document(data.instantiateTime)
            try ref.setData(from: data)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }

    func deleteData(userId: String, data: KakeiboData, completion: @escaping (Error?) -> Void) {
        db.collection(firstCollectionName).document(userId)
            .collection(secondCollectionName).document(data.instantiateTime).delete { error in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
    }
}
