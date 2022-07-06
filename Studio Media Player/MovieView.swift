//
//  MovieView.swift
//  Studio Media Player
//
//  Created by DannyNiu on 2022-07-03.
//

import Foundation
import Cocoa
import Dispatch

import AVFoundation
import CoreVideo

class MovieView : NSView
{
    var asset: AVAsset?
    var player: AVPlayer?
    var item: AVPlayerItem?
    var vout: AVPlayerItemVideoOutput?
    var cvpb: CVPixelBuffer?
    var cii: CIImage?
    var cgi: CGImage?
    var cix: CIContext?
    var vlink: CVDisplayLink?
    
    override var isOpaque: Bool { get { return true } }
    
    var irect: CGRect = .init()
    var srect: CGRect = .init()
    var orect: CGRect = .init()
    var vrect: CGRect = .init()
    
    func setup() -> Bool
    {
        self.canDrawConcurrently = true //
        self.cix = .init()
        
        self.asset = nil
        self.item = nil
        self.player = .init()
        self.vout = .init()
        
        cvpb = nil
        cii = nil
        
        var cvret: CVReturn
        
        cvret = CVDisplayLinkCreateWithActiveCGDisplays(&vlink)
        if( vlink == nil ) { return false }
        
        let me: UnsafeMutableRawPointer =
        Unmanaged.passUnretained(self).toOpaque()
        cvret = CVDisplayLinkSetOutputCallback(
            vlink!, vlink_callback, me)
        
        if( cvret == kCVReturnSuccess ) {
            return true
        } else { return false }
    }
    
    func assign_asset(_ asset: AVAsset)
    {
        self.asset = asset
        item = .init(asset: self.asset!)
        self.player?.replaceCurrentItem(with: item)
        item!.add(vout!)
    }
    
    override func draw(_ rect: NSRect)
    {
        orect = NSRectToCGRect(bounds)
        
        var oy: CGFloat = 0
        
        if( orect.width > 1 && irect.width > 1 )
        {
            oy = (orect.height -
                  irect.height *
                  orect.width /
                  irect.width) / 2
        }
        
        vrect = CGRect(origin: CGPoint(x: 0, y: oy),
                       size: CGSize(width: orect.width,
                                    height: irect.height *
                                        orect.width /
                                        irect.width))

        let ctx: CGContext = NSGraphicsContext.current!.cgContext
        ctx.setFillColor(gray: 0.0, alpha: 1.0)
        ctx.fill(orect)
        if( cgi != nil ) { ctx.draw(cgi!, in: vrect) }
        ctx.flush()
        
        // let ctx:CIContext = NSGraphicsContext.current!.ciContext
        // ctx.draw(CIImage.black, in: orect, from: CGRect(x:0, y:0, width:64, height:64))
        // if( cii != nil ) { ctx.draw(cii!, in: vrect, from: srect) }
    }
    
    // var ts: CMTime? = nil
    
    func video_render(_ d: CVTimeStamp)
    {
        let t: CMTime = player!.currentTime()
        /* if( ts == nil ) { ts = t } else
        {
            print(1 / (t.seconds - ts!.seconds))
            ts = t
        } */
        
        if( vout?.hasNewPixelBuffer(forItemTime: t) ?? false )
        {
            cvpb = vout!.copyPixelBuffer(
                forItemTime: t, itemTimeForDisplay: nil)
            cii = .init(cvPixelBuffer: cvpb!)
            irect = cii!.extent
            
            srect = CGRect(origin: irect.origin,
                           size: CGSize(width: irect.width / 2,
                                        height: irect.height))
            
            if( (d.videoTime * 120) % Int64(d.videoTimeScale * 2) > d.videoTimeScale )
            {
                srect = srect.offsetBy(dx: irect.width / 2, dy: 0)
            }
        
            cgi = cix!.createCGImage(cii!, from: srect)
        }
        
        DispatchQueue.main.async {
            self.needsDisplay = true
            // self.displayIfNeeded()
        }
    }
    
    @IBAction func skipforward(_ sender: Any)
    {
        player!.seek(to: CMTime(seconds: player!.currentTime().seconds + 1,
                                preferredTimescale: 600))
    }
    
    @IBAction func skipbackward(_ sender: Any)
    {
        player!.seek(to: CMTime(seconds: player!.currentTime().seconds - 1,
                                preferredTimescale: 600))
    }
    
    @IBAction func seekforward(_ sender: Any)
    {
        player!.seek(to: CMTime(seconds: player!.currentTime().seconds + 5,
                                preferredTimescale: 600))
    }
    
    @IBAction func seekbackward(_ sender: Any)
    {
        player!.seek(to: CMTime(seconds: player!.currentTime().seconds - 5,
                                preferredTimescale: 600))
    }
    
    @IBAction func rewind(_ sender: Any)
    {
        player!.seek(to: CMTime(seconds: 0,
                                preferredTimescale: 600))
    }
    
    @IBAction func play_or_pause(_ sender: Any)
    {
        if( player!.rate > 0 ) { player!.pause() }
        else { player!.rate = 1.0 }
    }
}

func vlink_callback(
    displayLink: CVDisplayLink,
    inNow: UnsafePointer<CVTimeStamp>,
    inOutputTime: UnsafePointer<CVTimeStamp>,
    flagsIn: CVOptionFlags,
    flagsOut: UnsafeMutablePointer<CVOptionFlags>,
    arg_mvview: UnsafeMutableRawPointer?
) -> CVReturn
{
    let mvview: MovieView =
    Unmanaged.fromOpaque(arg_mvview!).takeUnretainedValue()
    mvview.video_render(inNow.pointee)
    
    return kCVReturnSuccess
}
