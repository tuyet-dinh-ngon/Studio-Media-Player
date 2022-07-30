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
import AVKit
import CoreVideo

class MovieView : NSView
{
    var asset: AVAsset?
    var item: AVPlayerItem?
    var vlink: CVDisplayLink?
//* #unless USE_AV_PLAYERV_VIEW
    var vout: AVPlayerItemVideoOutput?
    var player: AVPlayer?
    var cgi: CGImage?
    var cix: CIContext?
    var playinglayer: AVPlayerLayer?
//*/
    
    override var isOpaque: Bool { get { return true } }
    
    func setup() -> Bool
    {
        self.asset = nil
        self.item = nil
        self.player = .init()
        self.vout = .init()
        
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
        // return true
    }
    
    func assign_asset(_ asset: AVAsset)
    {
        self.asset = asset
        item = .init(asset: self.asset!)
        self.player?.replaceCurrentItem(with: item)
        item!.add(vout!)
        
        self.playinglayer = .init(player: self.player!)
        self.layer = self.playinglayer
        
    }
    
    var eye_right: Bool = false
    var irect: CGRect = .init()
    var srect: CGRect = .init()
    var orect: CGRect = .init()
    var vrect: CGRect = .init()
    
    func rects_recalc()
    {
        //DispatchQueue.main.sync { orect = NSRectToCGRect(bounds) }
        orect = NSRectToCGRect(bounds)
        
        var oy: CGFloat = 0
        
        if( orect.width > 1 && irect.width > 1 )
        {
            oy = (orect.height -
                  irect.height *
                  orect.width /
                  irect.width) / 2
        }
        
        let oh: CGFloat = irect.height * orect.width / irect.width
        let osize: CGSize = CGSize(width: orect.width * 2,
                                   height: oh)
        
        if( eye_right )
        {
            vrect = CGRect(origin: CGPoint(x: -orect.width, y: oy),
                           size: osize)
        }
        else
        {
            vrect = CGRect(origin: CGPoint(x: 0, y: oy),
                           size: osize)
        }
    }
    
/* #unless USE_AV_PLAYERV_VIEW
    override func draw(_ rect: NSRect)
    {
        rects_recalc()
        
        var nsg: NSGraphicsContext? = nil
        nsg = NSGraphicsContext.current
        
        let ctx: CGContext = nsg!.cgContext
        ctx.setFillColor(gray: 0.0, alpha: 1.0)
        ctx.fill(orect)
        if( cgi != nil ) { ctx.draw(cgi!, in: orect) }
        ctx.flush()
        
        // let ctx:CIContext = NSGraphicsContext.current!.ciContext
        // ctx.draw(CIImage.black, in: orect, from: CGRect(x:0, y:0, width:64, height:64))
        // if( cii != nil ) { ctx.draw(cii!, in: vrect, from: srect) }
    }
*/
    
    // var ts: CMTime? = nil
    
    func video_render(_ d: CVTimeStamp)
    {
        let t: CMTime = player!.currentTime()
        /* if( ts == nil ) { ts = t } else
        {
            print(1 / (t.seconds - ts!.seconds))
            ts = t
        } */
        
        var cvpb: CVPixelBuffer?
        var cii: CIImage?
        
        if( vout?.hasNewPixelBuffer(forItemTime: t) ?? false )
        {
            cvpb = vout!.copyPixelBuffer(
                forItemTime: t, itemTimeForDisplay: nil)
            cii = .init(cvPixelBuffer: cvpb!)
            irect = cii!.extent
        }
        
        if( (d.videoTime * 120) % // should be 120.
            (Int64(d.videoTimeScale) * 2) >=
            Int64(d.videoTimeScale) )
        {
            eye_right = true
        }
        else { eye_right = false }
        
        /* if( cii != nil )
        {
            srect = CGRect(origin: irect.origin,
                           size: CGSize(width: irect.width / 2,
                                        height: irect.height))
            
            if( eye_right )
            {
                srect = srect.offsetBy(dx: irect.width / 2, dy: 0)
            }
        } */
        
        DispatchQueue.main.sync {
            if( self.layer != nil && self.irect.width > 0 )
            {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let tx: CGAffineTransform = .init(scaleX: 2.0, y: 1.0)
                self.layer!.setAffineTransform(tx)
                self.rects_recalc()
                self.layer!.frame = self.vrect
                //print(self.eye_right, self.vrect)
                CATransaction.commit()
            }
            self.needsDisplay = true
            //self.displayIgnoringOpacity(self.bounds)
            self.window!.display()
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

//* #unless USE_AV_PLAYERV_VIEW
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
//*/
