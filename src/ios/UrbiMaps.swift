//
//  UrbiMaps.swift
//  UrbiMaps
//
//  Created by Andre Grillo on 10/04/2023.
//

import Foundation
import SwiftUI
import DGis

@objc
class UrbiMaps: CDVPlugin {
    var hostingViewController: UIViewController?
           
    @available(iOS 13.0, *)
    @objc(openMap:)
    func openMap(command: CDVInvokedUrlCommand){
        lazy var container = Container()
        let searchView = container.makeSearchStylesDemoPage()
    
        lazy var hostingViewController = UIHostingController(rootView: searchView)
        hostingViewController.modalPresentationStyle = .fullScreen
        self.viewController.show(hostingViewController, sender: self);
//        lazy var hostingViewController = UIHostingController(rootView: ExampleView(
//          callbackId: command.callbackId,
//          module: self
//        ));
//        self.hostingViewController = hostingViewController;
//        self.hostingViewController!.modalPresentationStyle = .fullScreen
//        self.viewController.show(hostingViewController, sender: self);
       
    }
    
    @objc(open:)
    func open(command: CDVInvokedUrlCommand){
            
        if let action = command.arguments.first as? String {
            switch action {
                case "search":
                self.openSearch(command: command)
                case "myLocation":
                self.myLocation(command: command)
                    
                default: break
            }


        }
        
//            var container = Container()
//            let searchView = container.makeSearchStylesDemoPage()
//
//            var hostingViewController = UIHostingController(rootView: searchView)
//            hostingViewController.modalPresentationStyle = .fullScreen
//
////            var vc = UIHostingController(rootView: searchView)
////            self.viewController.navigationController?.pushViewController(hostingViewController, animated: true)
//
//            self.viewController.show(hostingViewController, sender: self);
            
    }
    
    func myLocation(command: CDVInvokedUrlCommand){
        lazy var container = Container()
        let searchView = container.makeSearchStylesDemoPage()
    
        lazy var hostingViewController = UIHostingController(rootView: searchView)
//        lazy var hostingViewController = UIHostingController(rootView: ExampleView(
//          callbackId: command.callbackId,
//          module: self
//        ));
        hostingViewController.modalPresentationStyle = .fullScreen
    
//            var vc = UIHostingController(rootView: searchView)
//            self.viewController.navigationController?.pushViewController(hostingViewController, animated: true)

        self.viewController.show(hostingViewController, sender: self);
    }
    
    func openSearch(command: CDVInvokedUrlCommand){
        lazy var container = Container()
        let searchView = container.makeSearchStylesDemoPage()
    
        lazy var hostingViewController = UIHostingController(rootView: searchView)
        hostingViewController.modalPresentationStyle = .fullScreen
        self.viewController.show(hostingViewController, sender: self);
    }
}


@available(iOS 13.0, *)
struct ExampleView: View {
    var callbackId: String?
    var module: UrbiMaps?
    
    init(
        callbackId: String?,
        module: UrbiMaps?
    ) {
        self.callbackId = callbackId
        self.module = module
    }
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Text("Example")
            
            Button {
                let pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "Successful"
                );

                module!.commandDelegate!.send(
                    pluginResult,
                    callbackId: callbackId!
                );

                module!.hostingViewController!.dismiss(animated: true, completion: nil);
                
            } label: {
                Text("Close Me")
                    .padding()
            }
            
            Spacer()
            
        }
    }
}
