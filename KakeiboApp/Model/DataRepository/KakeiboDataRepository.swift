//
//  KakeibDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/13.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

protocol DataRepositoryProtocol {
    func loadData(userId: String, data: @escaping ([KakeiboData]) -> Void)
    func addData(userId: String, data: KakeiboData)
    func deleteData(userId: String, data: KakeiboData)
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

    func loadData(userId: String, data: @escaping ([KakeiboData]) -> Void) {
        db.collection(firstCollectionName).document(userId)
            .collection(secondCollectionName).getDocuments { querySnapshot, error in
                if let error = error {
                    print("----Error getting documents: \(error)----")
                } else if let documents = querySnapshot?.documents {
                    var kakeiboData: [KakeiboData] = []
                    for document in documents {
                        let result = Result {
                            try document.data(as: KakeiboData.self)
                        }
                        switch result {
                        case .success(let data):
                            if let data = data {
                                kakeiboData.append(data)
                            }
                        case .failure(let error):
                            print("----Error decoding item: \(error)----")
                        }
                    }
                    data(kakeiboData)
                }
            }
    }

    func addData(userId: String, data: KakeiboData) {
        do {
            let ref = db.collection(firstCollectionName).document(userId)
                .collection(secondCollectionName).document(data.instantiateTime)
            try ref.setData(from: data)
            print("----dataが追加されました----")
        } catch let error {
            print("----Error writing kakeiboData to Firestore: \(error)----")
        }
    }

    func deleteData(userId: String, data: KakeiboData) {
        db.collection(firstCollectionName).document(userId)
            .collection(secondCollectionName).document(data.instantiateTime).delete { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                }
            }
    }
}
