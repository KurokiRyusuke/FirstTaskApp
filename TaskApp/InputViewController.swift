//
//  InputViewController.swift
//  TaskApp
//
//  Created by 黒木龍介 on 2018/07/10.
//  Copyright © 2018年 Ryusuke.Kuroki. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

//各部品のアウトレット接続------------------------------------------------------------------
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //Taskの宣言
    var task: Task!
    let realm = try! Realm()
//--------------------------------------------------------------------------------------
    
    
//VIewDidLoad---------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //背景をタップしたらdismissKeyboardメソッドを呼ぶようにする
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
//--------------------------------------------------------------------------------------
    

//dismissKeyboard-----------------------------------------------------------------------
    @objc func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
//--------------------------------------------------------------------------------------
    
    
//MemoryWarning-------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//--------------------------------------------------------------------------------------

    
//画面が非表示になるときに呼ばれるメソッド------------------------------------------------------
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        
        //タスク一覧画面に戻るタイミングでローカル通知設定を合わせて行うことにする
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
//--------------------------------------------------------------------------------------
    
    
//タスクのローカル通知を設定する--------------------------------------------------------------
    func setNotification(task: Task) {
        //UNMutableNotificationContentクラスのインスタンスを使って通知内容を設定
        let content = UNMutableNotificationContent()
        
        //タイトルと内容を設定
        //内容がない場合メッセージ無しで音だけの通知になるので「××なし」と表示する
        if task.title == "" {
            content.title = "(タイトル無し)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容無し)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
    
    
        //ローカル通知を発動するトリガーを設定する
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
    
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")
            // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
    
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
    
            }
        }
    }
//--------------------------------------------------------------------------------------
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
