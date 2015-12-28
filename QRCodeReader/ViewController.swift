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
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrcodeView: UIView?

    @IBOutlet weak var label: UILabel!
    @IBAction func doScan(sender: UIBarButtonItem) {
        self.captureSession = self.configureVideoCapture()
        if let session = self.captureSession {
            
            self.captureVideoPreviewLayer = self.createVideoPreviewLayer(session)
            if let preview = captureVideoPreviewLayer {
                self.view.layer.addSublayer(preview)
                
                session.startRunning()
                
                let view = self.createQRView()
                self.view.addSubview(view)
                self.view.bringSubviewToFront(view)
                self.qrcodeView = view
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //
    // descovering capture devices and create session
    //
    func configureVideoCapture() -> AVCaptureSession? {
        do {

            let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput

            let session  = AVCaptureSession()
            session.addInput(deviceInput as AVCaptureInput)
            let metadataOutput = AVCaptureMetadataOutput()
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]

            return session

        } catch let error as NSError {
            let alertController: UIAlertController = UIAlertController(title: "Device Error", message: error.localizedFailureReason, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        }
        return nil
        
    }
    //
    // createPreviewLayer for scan
    //
    func createVideoPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer? {
        let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let preview = captureVideoPreviewLayer {
            preview.videoGravity = AVLayerVideoGravityResizeAspectFill
            preview.frame = view.layer.bounds
            return preview
        }
        return nil
    }
    //
    // capture frame
    //
    func createQRView() -> UIView {
        let view = UIView()
        view.layer.borderColor = UIColor.redColor().CGColor
        view.layer.borderWidth = 5
        return view
    }
    //
    // delegate method
    //
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            didnotDetectQRCode();
            return
        }
        let metadata: AVMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        didFindQRCode(metadata)
    }
    func didnotDetectQRCode() {
        qrcodeView!.frame = CGRectZero
        print("NO QRCode text detacted")
        
    }
    func didFindQRCode(metadata: AVMetadataMachineReadableCodeObject) {
        if metadata.type == AVMetadataObjectTypeQRCode {
            let barCode = captureVideoPreviewLayer!.transformedMetadataObjectForMetadataObject(metadata) as! AVMetadataMachineReadableCodeObject
            qrcodeView!.frame = barCode.bounds;
            if metadata.stringValue != nil {
                qrcodeView!.frame = CGRectZero
                let result = metadata.stringValue
                print(result)
                self.label.text = result

                self.captureVideoPreviewLayer!.removeFromSuperlayer()
                self.captureSession!.stopRunning()
            }
        }
    }

}

