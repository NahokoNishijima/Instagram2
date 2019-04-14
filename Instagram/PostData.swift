//
//  PostData.swift
//  Instagram
//
//  Created by 西島菜穂子 on 2019/04/13.
//  Copyright © 2019 nahoko.nishijima. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

//投稿データ用のクラス　NSObjectクラスを継承したクラスを作成
class PostData: NSObject {
    var id: String?
    var image: UIImage?
    //Base64のまま
    var imageString: String?
    var name: String?
    var caption: String?
    var date: Date?
    //いいねをした人のIDの配列
    var likes: [String] = []
    //自分がいいねしたかどうかのフラグ
    var isLiked: Bool = false
    
    
    //Firebaseはデータの追加や更新があるとDatasnapshotクラスのデータが渡されてくる
    //isLikedプロパティはDataSnapshotでは取り出さない
    init(snapshot: DataSnapshot, myID: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        imageString = valueDictionary["image"] as? String
        image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
        
        self.name = valueDictionary["name"] as? String
        
        self.caption = valueDictionary["image"] as? String
        
        let time = valueDictionary["time"] as? String
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
        
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        
        for likeId in self.likes {
            if likeId == myID {
                self.isLiked = true
                break
            }
        }
    }

}
