//
//  LoginViewController.swift
//  Instagram
//
//  Created by 西島菜穂子 on 2019/04/11.
//  Copyright © 2019 nahoko.nishijima. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD //半透明の表示

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //ログインボタンをタップしたとこに呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text,
        let password = passwordTextField.text
    {
        //アドレスとパスワード名のいずれかでも入力されていない時は何もしない
        if address.isEmpty || password.isEmpty {
            //エラーの旨を表すHUD dissmissを呼ぶ必要なく自動で消える
            SVProgressHUD.showError(withStatus: "必要項目を入力してください")
            return
        }
        
        //HUDの表示を開始　HUDで処理中を表示
        //showとセットでdismiss
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: address, password: password) { user, error in
            if let error = error {
                print("DEBUG_PRINT: " + error.localizedDescription)
                SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                return
            }
            print("DEBUG_PRINT: ログインに成功しました。")
            
            //HUDを消す
            SVProgressHUD.dismiss()
            
            //画面を閉じてViewControllerに戻る
            self.dismiss(animated: true, completion: nil)
        }
      }
    }
    
    //アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
         if let address = mailAddressTextField.text,
            let password = passwordTextField.text,
            let displayName = displayNameTextField.text
        {
            //アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return //メソッドを抜ける
            }
            
            //HUDで処理中を表示 処理に時間がかかる場合に不安を軽減
            SVProgressHUD.show()
            
            //アドレスとパスワードでユーザー作成。ユーザー作成に成功すると自動的にログインする
            // if let そこにあるのかどうかを判定
            //外部サービスはエラー内容を保持している　errpeに入っている
            Auth.auth().createUser(withEmail: address, password: password) { user, error in
                if let error = error {
                    //エラーがあったら原因をprintしてreturnすることで以降の処理を実行せずに処理を終了する
                    // localizedDescripotion = Firebaseのerror
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に成功しました")
                    return //処理を終了
                }
                //自動的にログイン
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                //表示名を設定する　settingとの関係は？
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            //プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        //HUDを消す
                        SVProgressHUD.dismiss()
                        
                        //画面を閉じてViewControllerに戻る
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
