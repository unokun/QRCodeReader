//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Masaaki Uno on 2015/12/27.
//  Copyright © 2015年 Masaaki Uno. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrcodeView: UIView?

    
    @IBAction func doScan(sender: UIButton) {
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initializeQRView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configureVideoCapture() {
        let objCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSError?
        let objCaptureDeviceInput: AnyObject!
        do {
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
        }
        if (error != nil) {
            // TODO
            let alertController: UIAlertController = UIAlertController(title: "Device Error", message:"Device not Supported for this Application", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        captureSession = AVCaptureSession()
        if let session = captureSession {
            session.addInput(objCaptureDeviceInput as! AVCaptureInput)
            let metadataOutput = AVCaptureMetadataOutput()
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
        }
    }
    func addVideoPreviewLayer()
    {
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        captureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(captureVideoPreviewLayer!)
        captureSession?.startRunning()
        
    }
    func initializeQRView() {
        qrcodeView = UIView()
        qrcodeView?.layer.borderColor = UIColor.redColor().CGColor
        qrcodeView?.layer.borderWidth = 5
        self.view.addSubview(qrcodeView!)
        self.view.bringSubviewToFront(qrcodeView!)
    }
    //
    // delegateメソッド
    //
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrcodeView?.frame = CGRectZero
            print("NO QRCode text detacted")
            return
        }
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            let objBarCode = captureVideoPreviewLayer?.transformedMetadataObjectForMetadataObject(objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrcodeView?.frame = objBarCode.bounds;
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                let result = objMetadataMachineReadableCodeObject.stringValue
                print(result)
            }
        }
    }


}

