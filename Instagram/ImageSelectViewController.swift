//
//  ImageSelectViewController.swift
//  Instagram
//
//  Created by 西島菜穂子 on 2019/04/11.
//  Copyright © 2019 nahoko.nishijima. All rights reserved.
//

import UIKit
import CLImageEditor

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    
    //ライブラリボタンを押したら
    @IBAction func handleLibraryButton(_ sender: Any) {
        //ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    //カメラボタンを押したら
    @IBAction func handleCameraButton(_ sender: Any) {
        //カメラを指定してピッカーを開く
        //isSourceTypeAvailableメソッド：利用可能かどうかを確かめるメソッド
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    //キャンセルボタンを押したら
    @IBAction func handleCancelButton(_ sender: Any) {
        //画面を閉じる
        //??閉じたらどこに行くのか？？
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //写真を撮影・ライブラリから選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            //撮影・ライブラリから選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            
            
            //あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            //CLImageEditorにimageを渡して加工画面を起動する
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            //画面遷移する
            picker.pushViewController(editor, animated: true)
        }
    }
    
    //キャンセルしたときに呼ばれるメソッド
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    //CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        //投稿の画面を開く　Postviewcontrollerとつながる
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        postViewController.image = image!
        editor.present(postViewController, animated: true, completion: nil)
    }

}
