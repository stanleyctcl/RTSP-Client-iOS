//
//  ViewController.swift
//  RtspClient
//
//  Created by Teocci on 18/05/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var busy: UIActivityIndicatorView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var video: RTSPPlayer!
    let urlForTesting = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
    let urlString = "rtsp://114.32.99.223/v01"
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.cornerRadius = 15

        busy.transform = CGAffineTransform.init(scaleX: 3, y: 3)
    }

    @objc func update(timer: Timer) {
        if(!video.stepFrame()){
            timer.invalidate()
            video.closeAudio()
        }

        DispatchQueue.main.async {
            self.imageView.image = self.video.currentImage

            if self.busy.isAnimating {
                self.busy.stopAnimating()
            }
        }
    }

    @IBAction func onPress(_ sender: UIButton) {
        if sender.title(for: .normal) == "Start" {
            sender.setTitle("Exit", for: .normal)

            busy.startAnimating()
            DispatchQueue(label: "rtspThread").async {
                self.startStreaming()
            }
        } else {
            sender.setTitle("Start", for: .normal)
            stopStreaming()
        }
    }

    fileprivate func startStreaming() {
        video = RTSPPlayer(video: urlString, usesTcp: true)
        video.outputWidth = Int32(1280)
        video.outputHeight = Int32(720)
        video.seekTime(0.0)

        timer = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        timer?.fire()
    }

    fileprivate func stopStreaming(){
        timer?.invalidate()
        video.closeAudio()
        video = nil
        imageView.image = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

