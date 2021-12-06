//
//  ViewController.swift
//  soundcloudApp
//
//  Created by pioner on 21.09.2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    let gradient = CAGradientLayer()

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillLayoutSubviews() {
        gradient.frame = view.frame
    }
    
    
    @IBAction func changeLoginTextField(_ sender: UITextField) {
        guard let textLogin = loginTextField.text, let textPassword = passwordTextField.text else { return }
        
        toggleLogInButton(textLogin.count > 0 && textPassword.count > 0)
        
    }
    
    
    @IBAction func changePasswordTextField(_ sender: UITextField) {
        guard let textLogin = loginTextField.text, let textPassword = passwordTextField.text else { return }
        
        toggleLogInButton(textLogin.count > 0 && textPassword.count > 0)
    }
    
    private func toggleLogInButton(_ bool: Bool){
        if bool {
            logInButton.isUserInteractionEnabled = true
            logInButton.alpha = 1
        } else {
            logInButton.isUserInteractionEnabled = false
            logInButton.alpha = 0.2
        }
    }
    
    
    
    private func setupView() {
        setupGradient()
        
        logoImageView.image = logoImageView.image?.withRenderingMode(.alwaysTemplate)
        logoImageView.tintColor = UIColor.label
        
        logInButton.isUserInteractionEnabled = false
        logInButton.alpha = 0.2
    }
    
    private func setupGradient(){
        gradient.type = .axial
        gradient.colors = [
        UIColor(red: 1, green: 0.333, blue: 0, alpha: 0.17).cgColor,

        UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,

        UIColor(red: 0.082, green: 0.027, blue: 0, alpha: 0).cgColor
        ]
        gradient.locations = [0, 0.5, 1]

        gradient.frame = view.frame
        view.layer.addSublayer(gradient)
        
        
    }


}


