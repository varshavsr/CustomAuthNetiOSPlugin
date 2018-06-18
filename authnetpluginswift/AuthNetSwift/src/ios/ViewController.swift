//
//  ViewController.swift
//  AuthorizeNetSwift
//
//  Created by varsha s rao on 29/05/18.
//  Copyright © 2018. All rights reserved.
//

import UIKit
import AcceptSDK

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}

let kTermsAndConditionsLink = "https://www.google.com"
let kClientName = "5KP3u95bQpv"
let kClientKey  = "5FcB6WrfHGS76gHW3v7btBCE3HuuBuke9Pj96Ztfn5R32G5ep42vne7MCWZtAucY"

let kAcceptSDKDemoCreditCardLength:Int = 16
let kAcceptSDKDemoCreditCardLengthPlusSpaces:Int = (kAcceptSDKDemoCreditCardLength + 3)
let kAcceptSDKDemoExpirationLength:Int = 4
let kAcceptSDKDemoExpirationMonthLength:Int = 2
let kAcceptSDKDemoExpirationYearLength:Int = 2
let kAcceptSDKDemoExpirationLengthPlusSlash:Int = kAcceptSDKDemoExpirationLength + 1
let kAcceptSDKDemoCVV2Length:Int = 4

let kAcceptSDKDemoCreditCardObscureLength:Int = (kAcceptSDKDemoCreditCardLength - 4)

let kAcceptSDKDemoSpace:String = " "
let kAcceptSDKDemoSlash:String = "/"

let kCardType = "Credit Card Type"
let kCardNumber = "Card Number"
let kExpiryDate = "Expiry Date"
let kCardVerificationNumber = "CVV"
let kCardHolderName = "Card Holder Name"
let kEmpty = ""

let kInvalidCardType = "Invalid Card Type"
let kInvalidCardNumber = "Invalid Card Number"
let kInvalidExpiryDate = "Invalid Expiry Date"
let kInvalidCVVNumber = "Invalid CVV Number"
let kInvalidCardHolderName = "Invalid Card Holder Name"
let kAlphaNumericRegex = "^[a-zA-Z0-9 ]{1,64}$"

protocol ViewControllerDelegate: class {
    func transactionSuccess(output: String)
    func transactionFailure(output: String)
    func dismissScreen(output: String)
}

class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var activityIndicatorAcceptSDKDemo:UIActivityIndicatorView!
    @IBOutlet weak var headerView:UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var cardTypeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cardTypeSelectionButton: UIButton!
    @IBOutlet weak var cardNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var expiryDateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var expiryDateSelectionButton: UIButton!
    @IBOutlet weak var cardVerificationCodeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cardHolderNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerContainerView:UIView!
    @IBOutlet weak var expiryDatePicker: MonthYearPickerView!
    @IBOutlet weak var expiryDateContainerView:UIView!
    @IBOutlet weak var getTokenButton:UIButton!
    
    weak var paymentDelegate: ViewControllerDelegate?
    
    fileprivate var cardNumber: String!
    fileprivate var cardExpirationMonth: String!
    fileprivate var cardExpirationYear: String!
    fileprivate var cardVerificationCode: String!
    fileprivate var cardNumberBuffer: String!
    fileprivate var allCardTypes: [CardTypes]?
    var selectedCardType: CardTypes?
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        //To enable touch over the tableviewdid select action
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        self.setUIControlsTagValues()
        self.initializeUIControls()
        self.setUIStyles()
        self.initializeMembers()
        self.updateTokenButton(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Initialization Methods
    func setUIControlsTagValues() {
        self.cardTypeTextField.tag = 1
        self.cardNumberTextField.tag = 2
        self.expiryDateTextField.tag = 3
        self.cardVerificationCodeTextField.tag = 4
        self.cardHolderNameTextField.tag = 5
    }
    
    func initializeUIControls() {
        self.cardTypeTextField.text = ""
        self.cardNumberTextField.text = ""
        self.expiryDateTextField.text = ""
        self.cardVerificationCodeTextField.text = ""
        self.cardHolderNameTextField.text = ""
        self.textChangeDelegate(self.cardTypeTextField)
        self.textChangeDelegate(self.cardNumberTextField)
        self.textChangeDelegate(self.expiryDateTextField)
        self.textChangeDelegate(self.cardVerificationCodeTextField)
        self.textChangeDelegate(self.cardHolderNameTextField)
        
        self.cardTypeTextField.delegate = self
        self.cardNumberTextField.delegate = self
        self.expiryDateTextField.delegate = self
        self.expiryDateTextField.isUserInteractionEnabled = false
        self.cardVerificationCodeTextField.delegate = self
        self.cardHolderNameTextField.delegate = self
        
        allCardTypes = CardTypeManager.shared.cardTypeData?.cardTypes
        selectedCardType = allCardTypes?[0]
        self.picker.delegate = self
        self.picker.dataSource = self
        picker.showsSelectionIndicator = true
        pickerContainerView.isHidden = true
        
        expiryDateContainerView.isHidden = true        
    }
   
    func setUIStyles() {
        self.headerView.backgroundColor = UIColor.navBarBackgroundColor()
        self.headerLabel.textColor = UIColor.white
        setTextFieldStyles()
        self.getTokenButton.backgroundColor = UIColor.buttonBackGroundColor()
        self.getTokenButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
    }
    
    func setTextFieldStyles() {
        changeTextFieldStyle(textField: cardTypeTextField)
        cardTypeTextField.placeholder = kCardType
        cardTypeTextField.title = kEmpty
        changeTextFieldStyle(textField: cardNumberTextField)
        cardNumberTextField.placeholder = kCardNumber
        cardNumberTextField.title = kEmpty
        changeTextFieldStyle(textField: expiryDateTextField)
        expiryDateTextField.placeholder = kExpiryDate
        expiryDateTextField.title = kEmpty
        changeTextFieldStyle(textField: cardVerificationCodeTextField)
        cardVerificationCodeTextField.placeholder = kCardVerificationNumber
        cardVerificationCodeTextField.title = kEmpty
        changeTextFieldStyle(textField: cardHolderNameTextField)
        cardHolderNameTextField.placeholder = kCardHolderName
        cardHolderNameTextField.title = kEmpty
    }
    
    func initializeMembers() {
        self.cardNumber = nil
        self.cardExpirationMonth = nil
        self.cardExpirationYear = nil
        self.cardVerificationCode = nil
        self.cardNumberBuffer = ""
    }
    
    func changeTextFieldStyle(textField: SkyFloatingLabelTextField?) {
        textField?.titleFormatter = { $0 }
        textField?.autocorrectionType = .no
        textField?.delegate = self
        textField?.lineHeight = 0.5
        textField?.tintColor = UIColor.secondaryTextColor()
        textField?.selectedLineColor = UIColor.secondaryTextColor()
        textField?.textColor = UIColor.black
        textField?.lineColor = UIColor.secondaryTextColor()
        textField?.errorColor = UIColor.red
        textField?.placeholderColor = UIColor.secondaryTextColor()
        textField?.placeholderFont = UIFont(name: "HelveticaNeue", size: 14)
        textField?.titleLabel.adjustsFontSizeToFitWidth = true
        textField?.titleLabel.minimumScaleFactor = 0.5
    }
    
    //MARK: - Button Actions
    @IBAction func hideKeyBoard(_ sender: AnyObject) {
        if !pickerContainerView.isHidden {
            pickerContainerView.isHidden = true
        }
        if !expiryDateContainerView.isHidden {
            expiryDateContainerView.isHidden = true
        }
        self.view.endEditing(true)
    }
    
    @IBAction func cardTypeSelectionClicked(_ sender: Any) {
        self.view.endEditing(true)
        if !expiryDateContainerView.isHidden {
            expiryDateContainerView.isHidden = true
        }
        if allCardTypes?.count > 0 {
            pickerContainerView.isHidden = false
        }
    }
    
    @IBAction func expiryDateSelectionClicked(_ sender: Any) {
        self.view.endEditing(true)
        if !pickerContainerView.isHidden {
            pickerContainerView.isHidden = true
        }
        expiryDateContainerView.isHidden = false
    }
    
    @IBAction func getTokenButtonTapped(_ sender: AnyObject) {
        self.activityIndicatorAcceptSDKDemo.startAnimating()
        self.updateTokenButton(false)
        
        self.getToken()
    }
    
    @IBAction func backButtonButtonTapped(_ sender: AnyObject) {
        //        self.navigationController?.popViewController(animated: true)
        self.paymentDelegate?.dismissScreen(output: kEmpty)
    }
    
    @IBAction func pickerDoneAction(_ sender: Any) {
        pickerContainerView.isHidden = true
        if let cardTitle = selectedCardType?.idType {
            self.cardTypeTextField.text = cardTitle
            if let cardNum = self.cardNumber, cardNumber != kEmpty {
                if self.validateCardNumbersWithCardType(cardNumber: cardNum) {
                    self.cardTypeTextField.textColor = UIColor.black
                    self.cardTypeTextField.errorMessage = kEmpty
                } else {
                    self.cardTypeTextField.textColor = UIColor.red
                    self.cardTypeTextField.errorMessage = kInvalidCardType
                }
                
                if (self.validInputs()) {
                    self.updateTokenButton(true)
                } else {
                    self.updateTokenButton(false)
                }
            }
        }
    }
    
    @IBAction func expiryDatePickerDoneAction(_ sender: Any) {
        expiryDateContainerView.isHidden = true
        
        if self.expiryDateTextField.text?.count == 0 {
            //Get current month and year when the picker is just opened and closed without scrolling
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let year =  components.year
            let month = components.month
            if let mm = month, let yy = year {
                let monthYear = String(format: "%02d/%d", mm, yy)
                self.cardExpirationMonth = String(mm)
                self.cardExpirationYear = String(yy)
                validateExpiryDate()
                self.expiryDateTextField.text = monthYear
            }
        }
        
        //Below method block is called when picker is scrolled
        expiryDatePicker.onDateSelected = { (month: Int, year: Int) in
            let monthYear = String(format: "%02d/%d", month, year)
            self.cardExpirationMonth = String(month)
            self.cardExpirationYear = String(year)
            self.validateExpiryDate()
            self.expiryDateTextField.text = monthYear //NSLog(monthYear) // should show something like 05/2015
        }
    }
    
    //MARK: - Business Logics
    func updateTokenButton(_ isEnable: Bool) {
        self.getTokenButton.isEnabled = isEnable
        if isEnable {
            self.getTokenButton.backgroundColor = UIColor.buttonBackGroundColor()
        } else {
            self.getTokenButton.backgroundColor = UIColor.buttonDisabledBackGroundColor()
        }
    }
    
    func getToken() {
        let handler = AcceptSDKHandler(environment: AcceptSDKEnvironment.ENV_TEST)
        
        let request = AcceptSDKRequest()
        request.merchantAuthentication.name = kClientName
        request.merchantAuthentication.clientKey = kClientKey
        
        request.securePaymentContainerRequest.webCheckOutDataType.token.cardNumber = self.cardNumberBuffer
        request.securePaymentContainerRequest.webCheckOutDataType.token.expirationMonth = self.cardExpirationMonth
        request.securePaymentContainerRequest.webCheckOutDataType.token.expirationYear = self.cardExpirationYear
        request.securePaymentContainerRequest.webCheckOutDataType.token.cardCode = self.cardVerificationCode
        request.securePaymentContainerRequest.webCheckOutDataType.token.fullName = self.cardHolderNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        handler!.getTokenWithRequest(request, successHandler: { (inResponse:AcceptSDKTokenResponse) -> () in
            DispatchQueue.main.async(execute: {
                self.updateTokenButton(true)
                
                self.activityIndicatorAcceptSDKDemo.stopAnimating()
                //print("Token--->%@", inResponse.getOpaqueData().getDataValue())
                var output = String(format: "Response: %@\nData Value: %@ \nDescription: %@", inResponse.getMessages().getResultCode(), inResponse.getOpaqueData().getDataValue(), inResponse.getOpaqueData().getDataDescriptor())
                output = output + String(format: "\nMessage Code: %@\nMessage Text: %@", inResponse.getMessages().getMessages()[0].getCode(), inResponse.getMessages().getMessages()[0].getText())
                self.paymentDelegate?.transactionSuccess(output: output)
            })
        }) { (inError: AcceptSDKErrorResponse) -> () in
            self.activityIndicatorAcceptSDKDemo.stopAnimating()
            self.updateTokenButton(true)
            
            let output = String(format: "Response:  %@\nError code: %@\nError text:   %@", inError.getMessages().getResultCode(), inError.getMessages().getMessages()[0].getCode(), inError.getMessages().getMessages()[0].getText())
            //            self.paymentDelegate?.transactionFailure(output: output)
            //print(output)
            self.showAlert(message: inError.getMessages().getMessages()[0].getText())
            
        }
    }
    
    func formatCardNumber(_ textField:UITextField) {
        var value = String()
        
        if textField == self.cardNumberTextField {
            let length = self.cardNumberBuffer.count
            
            for (i, _) in self.cardNumberBuffer.enumerated() {
                // Reveal only the last character.
                if (length <= kAcceptSDKDemoCreditCardObscureLength) {
                    if (i == (length - 1)) {
                        let charIndex = self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: i)
                        let tempStr = String(self.cardNumberBuffer.suffix(from: charIndex))
                        //let singleCharacter = String(tempStr.first)
                        
                        value = value + tempStr
                    }
                    else {
                        value = value + ""
                    }
                } else {
                    if (i < kAcceptSDKDemoCreditCardObscureLength) {
                        value = value + "●"
                    } else {
                        let charIndex = self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: i)
                        let tempStr = String(self.cardNumberBuffer.suffix(from: charIndex))
                        //let singleCharacter = String(tempStr.first)
                        //let singleCharacter = String(tempStr.suffix(1))
                        
                        value = value + tempStr
                        break
                    }
                }
                
                //After 4 characters add a space
                if (((i + 1) % 4 == 0) && (value.count < kAcceptSDKDemoCreditCardLengthPlusSpaces)) {
                    value = value + kAcceptSDKDemoSpace
                }
            }
        }
        
        textField.text = value
    }
    
    func isMaxLength(_ textField:UITextField) -> Bool {
        var result = false
        
        if (textField.tag == self.cardNumberTextField.tag && textField.text?.count > kAcceptSDKDemoCreditCardLengthPlusSpaces) {
            result = true
        }
        
        if (textField == self.cardVerificationCodeTextField && textField.text?.count > kAcceptSDKDemoCVV2Length) {
            result = true
        }
        
        return result
    }
    
    func validateCardNumbersWithCardType(cardNumber: String) -> Bool {
        if let rule = selectedCardType?.validationRule {
            if rule == "" {
                return true
            }
            let matches = NSPredicate(format: "SELF MATCHES %@", rule)
            return matches.evaluate(with: cardNumber)
        }
        return false
    }
    
    func validateCardHolderName(name: String) -> Bool {
        let matches = NSPredicate(format: "SELF MATCHES %@", kAlphaNumericRegex)
        return matches.evaluate(with: name)
    }
    
    // MARK: - UITextViewDelegate delegate methods
    func textFieldDidBeginEditing(_ textField:UITextField) {
    }
    
    func textFieldShouldBeginEditing(_ textField:UITextField) -> Bool {
        if !pickerContainerView.isHidden {
            pickerContainerView.isHidden = true
        }
        if !expiryDateContainerView.isHidden {
            expiryDateContainerView.isHidden = true
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = true
        
        switch (textField.tag) {
        case 2:
            if (string.count > 0) {
                if (self.isMaxLength(textField)) {
                    return false
                }
                
                self.cardNumberBuffer = String(format: "%@%@", self.cardNumberBuffer, string)
                
                if let cardNum = self.cardNumber {
                    //Validation of cardnumber for the selected cardtype
                    if self.validateCardNumbersWithCardType(cardNumber: cardNum) {
                        self.cardNumberTextField.textColor = UIColor.black
                        self.cardNumberTextField.errorMessage = kEmpty
                    } else {
                        self.cardNumberTextField.textColor = UIColor.red
                        self.cardNumberTextField.errorMessage = kInvalidCardNumber
                    }
                }
            }
            else {
                if (self.cardNumberBuffer.count > 1) {
                    let length = self.cardNumberBuffer.count - 1
                    self.cardNumberBuffer = String(self.cardNumberBuffer[self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: 0)...self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: length - 1)])
                }
                else {
                    self.cardNumberBuffer = ""
                }
            }
            return true
            //            self.formatCardNumber(textField)
        //            return false
        case 4:
            if (string.count > 0) {
                if (self.isMaxLength(textField)) {
                    return false
                }
            }
            break
        case 5:
            if (string.count > 0) {
                if let cardHolderName = self.cardHolderNameTextField.text, cardHolderName != kEmpty {
                    if self.validateCardHolderName(name: cardHolderName) {
                        self.cardHolderNameTextField.textColor = UIColor.black
                        self.cardHolderNameTextField.errorMessage = kEmpty
                    } else {
                        self.cardHolderNameTextField.textColor = UIColor.red
                        self.cardHolderNameTextField.errorMessage = kInvalidCardHolderName
                    }
                }
            }
            break
        default:
            break
        }
        
        return result
    }
    
    func validInputs() -> Bool {
        var inputsAreOKToProceed = false
        
        let validator = AcceptSDKCardFieldsValidator()
        
        if (validator.validateSecurityCodeWithString(self.cardVerificationCodeTextField.text!) && self.cardExpirationMonth != nil && self.cardExpirationYear != nil && validator.validateExpirationDate(self.cardExpirationMonth, inYear: self.cardExpirationYear) && validator.validateCardWithLuhnAlgorithm(self.cardNumberBuffer) && self.cardTypeTextField.text?.count > 0 && self.cardHolderNameTextField.text?.count > 0 && self.cardNumber != nil && validateCardNumbersWithCardType(cardNumber: self.cardNumber)) {
            inputsAreOKToProceed = true
        }
        
        return inputsAreOKToProceed
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let validator = AcceptSDKCardFieldsValidator()
        
        switch (textField.tag) {
        case 2:
            
            self.cardNumber = self.cardNumberBuffer
            
            let luhnResult = validator.validateCardWithLuhnAlgorithm(self.cardNumberBuffer)
            
            if ((luhnResult == false) || (textField.text?.count < AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardNumberCharacterCountMin)) {
                self.cardNumberTextField.textColor = UIColor.red
                self.cardNumberTextField.errorMessage = kInvalidCardNumber
                
            } else {
                self.cardNumberTextField.textColor = UIColor.black //[UIColor greenColor]
                self.cardNumberTextField.errorMessage = kEmpty
            }
            
            if (self.validInputs()) {
                self.updateTokenButton(true)
            } else {
                self.updateTokenButton(false)
            }
            break
        case 4:
            self.cardVerificationCode = textField.text
            
            if (validator.validateSecurityCodeWithString(self.cardVerificationCodeTextField.text!)) {
                self.cardVerificationCodeTextField.textColor = UIColor.black
                self.cardVerificationCodeTextField.errorMessage = kEmpty
            } else {
                self.cardVerificationCodeTextField.textColor = UIColor.red
                self.cardVerificationCodeTextField.errorMessage = kInvalidCVVNumber
            }
            
            if (self.validInputs()) {
                self.updateTokenButton(true)
            } else {
                self.updateTokenButton(false)
            }
            break
        case 5:
            if (self.validInputs()) {
                self.updateTokenButton(true)
            } else {
                self.updateTokenButton(false)
            }
            break
        default:
            break
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if (textField == self.cardNumberTextField) {
            self.cardNumberBuffer = String()
        }
        
        return true
    }
    
    func validateExpiryDate() {
        let validator = AcceptSDKCardFieldsValidator()
        let newYear = Int(self.cardExpirationYear)
        if ((newYear >= validator.cardExpirationYearMin())  && (newYear <= AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardExpirationYearMax)) {
            self.expiryDateTextField.textColor = UIColor.black
            self.expiryDateTextField.errorMessage = kEmpty
        }
        else {
            self.expiryDateTextField.textColor = UIColor.red
            self.expiryDateTextField.errorMessage = kInvalidExpiryDate
        }
        
        
        if (validator.validateExpirationDate(cardExpirationMonth, inYear: cardExpirationYear)) {
            self.expiryDateTextField.textColor = UIColor.black
            self.expiryDateTextField.errorMessage = kEmpty
        } else {
            self.expiryDateTextField.textColor = UIColor.red
            self.expiryDateTextField.errorMessage = kInvalidExpiryDate
        }
        
        //If all the inputs are valid enable pay button
        if (self.validInputs()) {
            self.updateTokenButton(true)
        } else {
            self.updateTokenButton(false)
        }
    }
    
    func textChangeDelegate(_ textField: UITextField) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: nil, using: { note in
            if (self.validInputs()) {
                self.updateTokenButton(true)
            } else {
                self.updateTokenButton(false)
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - TextView delegate
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL, options: [:])
        } else {
            UIApplication.shared.openURL(URL)
        }
        return false
    }
    
    //MARK: - Helper methods
    func showAlert(message msg: String) {
        let alert = UIAlertController(title: "Authorize.net", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Extensions
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // The number of columns of data
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allCardTypes?.count ?? 0
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let cardTitle = allCardTypes?[row].idType
        return cardTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCardType = allCardTypes?[row]
    }
}

extension NSMutableAttributedString {
    public func setAsLink(textToFind: String, linkURL: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
