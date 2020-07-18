//
//  EmailSender.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/07/18.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import MessageUI
import UIKit

class EmailSender: NSObject, MFMailComposeViewControllerDelegate {
  
  func sendEmail(parentController: UIViewController, subject: String?, content: String?) {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      mail.setToRecipients(["easykiip.app@gmail.com"])
      if let s = subject {
        mail.setSubject(s)
      }
      if let c = content {
        mail.setMessageBody(c, isHTML: false)
      }
      parentController.present(mail, animated: true, completion: nil)
    }
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
  
}

