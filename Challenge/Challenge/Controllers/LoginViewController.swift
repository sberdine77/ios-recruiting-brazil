//
//  ViewController.swift
//  Challenge
//
//  Created by Sávio Berdine on 20/10/18.
//  Copyright © 2018 Sávio Berdine. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var movies: [Movie] = []
    
    let alert1 = UIAlertController(title: nil, message: "Wait...", preferredStyle: .alert)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Starting implementation of persistent user session
//        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.style = UIActivityIndicatorView.Style.gray
//        loadingIndicator.startAnimating()
//        self.alert1.view.addSubview(loadingIndicator)
//        present(self.alert1, animated: true, completion: nil)
//        User.fetchUser(completion: {(error) in
//            if error == nil {
//                if let _ = User.user.userId, let _ = User.user.sessionId {
//                    DispatchQueue.main.async {
//                        self.alert1.dismiss(animated: true
//                            , completion: {
//                                self.performSegue(withIdentifier: "loginAccepted", sender: nil)
//                        })
//                    }
//
//                } else {
//                    self.alert1.dismiss(animated: true, completion: nil)
//                }
//            } else {
//                print(String(describing: error))
//                self.alert1.dismiss(animated: true, completion: nil)
//            }
//        })
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.userNameTextField.addBottomBorderWithColor(color: .black, width: 1)
        self.passwordTextField.addBottomBorderWithColor(color: .black, width: 1)
        self.movies = Movie.fetchSortedByDate()
    }
    
    //Unwind from sign view controller
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) { }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Default error alert
    func errorAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    //Trigged when login button pressed
    @IBAction func loginAction(_ sender: Any) {
        
        //loading indicator
        let alert = UIAlertController(title: nil, message: "Wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        //Validating empty fields
        if !(userNameTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)! {
            //Login request
            User.user.login(username: userNameTextField.text!, password: passwordTextField.text!, onSuccess: { (result) in
                User.user.getAccountDetails(onSuccess: { (result) in
                    User.saveUserToCoreData() //saving user to coreData (future implementations of persistent user session)
                    alert.dismiss(animated: true, completion: {
                        self.performSegue(withIdentifier: "loginAccepted", sender: nil)
                    })
                }, onFailure: { (error) in
                    alert.dismiss(animated: true, completion: nil)
                    self.errorAlert(title: "Error", message: "An error ocourred. Please try again.")
                    print(error)
                })
            }) { (error) in
                alert.dismiss(animated: true, completion: nil)
                if error == "Request error generating token" {
                    self.errorAlert(title: "Error", message: "An error ocourred. Check your connection and try again.")
                } else {
                    self.errorAlert(title: "Error", message: "An error ocourred. Please try again.")
                }
                print(error)
            }
        }
    }
    
    //Trigged when signup button is pressed
    @IBAction func signUp(_ sender: Any) {
        
        //loading indicator
        let alert = UIAlertController(title: nil, message: "Wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        //Request token
        User.user.requestToken(onSuccess: { (token) in
            alert.dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "sign", sender: nil) //redirects to TheMovieDB site to create account
            })
        }) { (error) in
            alert.dismiss(animated: true, completion: {
                if error == "Request error generating token" {
                    self.errorAlert(title: "Error", message: "An error ocourred. Check your connection and try again.")
                } else {
                    self.errorAlert(title: "Error", message: "An error ocourred. Please try again.")
                }
            })
            print(error)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sign" {
            if let vc = segue.destination as? SignUpViewController {
                vc.token = User.user.token
            }
        }
    }
    
}

