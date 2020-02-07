//
//  ViewController.swift
//  RtspClient
//
//  Created by Teocci on 18/05/16.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var busy: UIActivityIndicatorView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var video: RTSPPlayer!
    var urlString = "rtsp://114.32.99.223/v01"
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.cornerRadius = 15

        busy.transform = CGAffineTransform.init(scaleX: 3, y: 3)
        address.text = urlString
        address.delegate = self
    }

    @objc func update(timer: Timer) {
        if(!video.stepFrame()){
            timer.invalidate()
            video.closeAudio()
        }

        imageView.image = video.currentImage

        if busy.isAnimating {
            busy.stopAnimating()
        }
    }

    @IBAction func onPress(_ sender: UIButton) {
        if sender.title(for: .normal) == "Connect" {
            startStreaming()
        } else {
            sender.setTitle("Connect", for: .normal)
            stopStreaming()
        }
    }

    fileprivate func startStreaming() {
        func connectRTSP() {
            video = RTSPPlayer(video: urlString, usesTcp: true)

            guard video != nil else {
                busy.stopAnimating()
                alertMessage(show: "Connect failed")
                return
            }
            button.setTitle("Disconnect", for: .normal)
            video.outputWidth = Int32(1280)
            video.outputHeight = Int32(720)
            video.seekTime(0.0)

            timer = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
            timer?.fire()
        }
        busy.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            connectRTSP()
        }
    }

    fileprivate func stopStreaming(){
        timer?.invalidate()
        video?.closeAudio()
        video = nil
        imageView.image = nil
    }

    fileprivate func alertMessage(show msg: String){
        let alert = UIAlertController(title: "ERROR", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion:  nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        address.endEditing(true)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let url = address.text {
            if urlString != url {
                urlString = url
                if video != nil {
                    stopStreaming()
                    startStreaming()
                }
            }
        }
        print("url = \(urlString)")
    }
}

