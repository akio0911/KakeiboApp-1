//
//  KakeibDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/13.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol DataRepositoryProtocol {
    func loadData(data: @escaping ([KakeiboData]) -> Void)
    func addData(data: KakeiboData)
    func deleteData(data: KakeiboData)
}

final class KakeiboDataRepository: DataRepositoryProtocol {

    let db: Firestore

    init() {
        let setting = FirestoreSettings()
        Firestore.firestore().settings = setting
        db = Firestore.firestore()
    }

    func loadData(data: @escaping ([KakeiboData]) -> Void) {
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("KakeiboData").getDocuments { querySnapshot, error in
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

    func addData(data: KakeiboData) {
        do {
            let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
                .collection("KakeiboData").document(data.instantiateTime)
            try ref.setData(from: data)
            print("----dataが追加されました----")
        } catch let error {
            print("----Error writing kakeiboData to Firestore: \(error)----")
        }
    }

    func deleteData(data: KakeiboData) {
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("KakeiboData").document(data.instantiateTime).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
    }
}
