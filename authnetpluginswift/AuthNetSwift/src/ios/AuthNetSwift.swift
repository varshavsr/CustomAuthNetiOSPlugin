import UIKit

@objc(AuthNetSwift) class AuthNetSwift : CDVPlugin {
    fileprivate var callbackID: String = ""
    
    @objc(echo:)
    func echo(command: CDVInvokedUrlCommand) {
        self.callbackID = command.callbackId
        
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        let msg = command.arguments[0] as? String ?? ""
        if msg.count > 0 {
            /* UIAlertController is iOS 8 or newer only. */
            let toastController: UIAlertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)

            self.viewController?.present(toastController, animated: true, completion: nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                toastController.dismiss(animated: true, completion: nil)
            }
            
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: msg)
        }
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(paymentUI:)
    func paymentUI(command: CDVInvokedUrlCommand) {
        self.callbackID = command.callbackId
        
        let msg = command.arguments[0] as? String ?? ""
        if msg.count > 0 {
            loadStoryboard(amount: msg)
        }
    }
    
    func loadStoryboard(amount: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            paymentVC.paymentDelegate = self
            self.viewController?.present(paymentVC, animated: false, completion: nil)
            //        let aObjNavi = UINavigationController(rootViewController: paymentVC)
            //        self.viewController?.present(aObjNavi, animated: true, completion: nil)
        }
    }
    
    func dismissPaymentUI() {
        self.viewController?.dismiss(animated: false, completion: nil)
    }
}

extension AuthNetSwift: ViewControllerDelegate {
    func dismissScreen(output: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: output)
        self.commandDelegate!.send(pluginResult, callbackId: callbackID)
        dismissPaymentUI()
    }
    
    func transactionSuccess(output: String) {
        if output.count > 0 {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: output)
            self.commandDelegate!.send(pluginResult, callbackId: callbackID)
        } else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: output)
            self.commandDelegate!.send(pluginResult, callbackId: callbackID)
        }
        
        dismissPaymentUI()
    }
    
    func transactionFailure(output: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: output)
        self.commandDelegate!.send(pluginResult, callbackId: callbackID)
        dismissPaymentUI()
    }
    
}
