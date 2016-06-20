//
//  ZHViewController1.swift
//  WebViewBridge.Swift
//
//  Created by travel on 16/6/20.
//  Copyright © 2016年 travel. All rights reserved.
//

import UIKit

class ZHViewController1: UIViewController, UIWebViewDelegate {
    var webView:UIWebView!
    var bridge:ZHWebViewBridge!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView()
        webView.delegate = self
        webView.frame = view.bounds
        view.addSubview(webView)
        
        bridge = ZHWebViewBridge.bridge(webView)
        
        bridge.registerHandler("Image.updatePlaceHolder") { [weak self](args:[AnyObject]) -> (Bool, AnyObject?) in
            self?.bridge.callHander("Image.updatePlaceHolder", args: ["place_holder.png"], callback: nil)
            return (true, nil)
        }
        bridge.registerHandler("Image.ViewImage") { [weak self](args:[AnyObject]) -> (Bool, AnyObject?) in
            if let index = args.first as? Int where args.count == 1 {
                self?.viewImageAtIndex(index)
                return (true, nil)
            }
            return (false, nil)
        }
        bridge.registerHandler("Image.DownloadImage") { [weak self](args:[AnyObject]) -> (Bool, AnyObject?) in
            if let index = args.first as? Int where args.count == 1 {
                self?.downloadImageAtIndex(index)
                return (true, nil)
            }
            return (false, nil)
        }
        
        
        prepareResources()
        webView.loadHTMLString(ZHData.instance.htmlData, baseURL:  NSURL.init(fileURLWithPath: ZHData.instance.imageFolder))
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        downloadImages()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return !bridge.handlerRequest(request)
    }
    
    
    func prepareResources() {
        let basePath = ZHData.instance.imageFolder
        let resources = ["place_holder.png"]
        for resource in resources {
            if let path = NSBundle.mainBundle().pathForResource(resource, ofType: nil) {
                let targetPath = (basePath as NSString).stringByAppendingPathComponent(resource)
                if !NSFileManager.defaultManager().fileExistsAtPath(targetPath) {
                    _ = try? NSFileManager.defaultManager().copyItemAtPath(path, toPath: targetPath)
                }
            }
        }
    }
    
    func viewImageAtIndex(index:Int) {
        let alert = UIAlertController.init(title: "ViewImage \(index)", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: { [weak self](_:UIAlertAction) in
            self?.dismissViewControllerAnimated(false, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func downloadImageAtIndex(index:Int) {
        let images = ZHData.instance.imageUrls
        if index < images.count {
            let image = images[index]
            ZHData.instance.downloadImage(image, handler: { [weak self](file:String) in
                self?.bridge.callHander("Image.updateImageAtIndex", args: [file, index], callback: nil)
            })
            
        }
    }
    
    func downloadImages() {
        for (index, _) in ZHData.instance.imageUrls.enumerate() {
            downloadImageAtIndex(index)
        }
    }
}
