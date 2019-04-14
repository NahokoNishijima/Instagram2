//
//  HomeViewController.swift
//  Instagram
//
//  Created by 西島菜穂子 on 2019/04/11.
//  Copyright © 2019 nahoko.nishijima. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    
    var postArray: [PostData] = []
    
    //DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    //UITableViewの準備とFirebaseからデータを読み込む設定を行う
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        //xibファイルセルの定義内容をUINibで取得
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        //outletで接続しているTableViewにregisterメソッドで登録
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //テーブル行の高さをAutolayoutで自動調整する
        tableView.rowHeight = UITableView.automaticDimension
        //テーブル行の高さの概算値を設定しておく
        //高さ概算値　＝　「縦横比1:1のUIImageViewの高さ」＋　「いいねボタン、キャプションラベル、その他余白の高さの合計概算」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                //要素が追加されたらpostArrayに追加してTableViewを再表示する
                //Childadded 全然わからない
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe (.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                
                    //PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myID: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        //TableViewを再表示する
                        self.tableView.reloadData()
                    }
            })
            //要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
            //Childchanged
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChngedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        //postDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myID: uid)
                        
                        //保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        //差しかえるため一度削除する
                        self.postArray.remove(at: index)
                        
                        //削除したところに更新すみのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        //TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                //DatabaseのobserveEventが上記コードにより登録されたため
                //trueとする
                observing = true
            }
        } else {
            if observing == true {
                //ログアウトを検出したら一旦テーブルをくクリアしてオブサーバーを削除する
                //テーブルをクリアする
                postArray = []
                tableView.reloadData()
                //オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                //DatabaseのobserveEventが上記コードにより解除されたため
                //falseとする
                observing = false
            }

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
            cell.setPostData(postArray[indexPath.row])
        //セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for:.touchUpInside)
        
        return cell
    }
    
    //セル（xib）内のボタン(いいねボタン)がタップされたときに呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデッkクスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                //すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        //削除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeId)!
                        break
                }
            }
            postData.likes.remove(at: index)
        } else {
            postData.likes.append(uid)
        }
        //増えたlikesをFirebaseに保存する
        let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
        let likes = ["likes": postData.likes]
        postRef.updateChildValues(likes)
        
        }
    }
}


