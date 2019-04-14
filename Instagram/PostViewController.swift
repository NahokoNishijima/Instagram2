//
//  PostViewController.swift
//  Instagram
//
//  Created by 西島菜穂子 on 2019/04/11.
//  Copyright © 2019 nahoko.nishijima. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class PostViewController: UIViewController {
    var image: UIImage!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    //投稿ボタンをタップしたときに呼ばれるメソッド
    //Firebaseに画像とキャプション、その他情報を投稿
    @IBAction func handlePostButton(_ sender: Any) {
        //ImageViewから画像を取得する
        //jpeg形式へ変換
        let imageData = imageView.image!.jpegData(compressionQuality: 0.5)
        //JPEG画像をbase64方式でテキスト形式に変換
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        
        //postDataに必要な情報を取得しておく
        //投稿日時
        let time = Date.timeIntervalSinceReferenceDate
        //表示名
        let name = Auth.auth().currentUser?.displayName
        
        //辞書を作成してFirebaseに保存する
        //databaseクラスを使用してFirebaseサーバ上にある保存先をpostRefに代入
        let postRef = Database.database().reference().child(Const.PostPath)
        let postDic = ["caption": textField.text!, "image": imageString, "time": String(time), "name": name!]
        //Firebaseに保存
        postRef.childByAutoId().setValue(postDic)
        
        //HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        //全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    //キャンセルボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        //画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //受け取った画像をImageViewに設定する
        imageView.image = image
        
    }

}
