//
//  AMJpnMapView.swift
//  TestProject
//
//  Created by am10 on 2017/12/29.
//  Copyright © 2017年 am10. All rights reserved.
//

import UIKit

enum AMJMRegion: Int {
    case none = -1
    case hokkaido = 0
    case tohoku = 1
    case kanto = 2
    case chubu = 3
    case kinki = 4
    case chugoku = 5
    case shikoku = 6
    case kyushu = 7
    
    func convert(index: Int) -> AMJMRegion {
        
        if index == AMJMRegion.hokkaido.rawValue {
            
            return .hokkaido
            
        } else if index == AMJMRegion.tohoku.rawValue {
            
            return .tohoku
            
        } else if index == AMJMRegion.kanto.rawValue {
            
            return .kanto
            
        } else if index == AMJMRegion.chubu.rawValue {
            
            return .chubu
            
        } else if index == AMJMRegion.kinki.rawValue {
            
            return .kinki
            
        } else if index == AMJMRegion.chugoku.rawValue {
            
            return .chugoku
            
        } else if index == AMJMRegion.shikoku.rawValue {
            
            return .shikoku
            
        } else if index == AMJMRegion.kyushu.rawValue {
            
            return .kyushu
        }
        
        return .none
    }
}

protocol AMJpnMapViewDelegate: class {
    
    func jpnMapView(jpnMapView: AMJpnMapView, didSelectAtRegion region: AMJMRegion)
    func jpnMapView(jpnMapView: AMJpnMapView, didDeselectAtRegion region: AMJMRegion)
}

@IBDesignable class AMJpnMapView: UIView {

    override var bounds: CGRect {
        
        didSet {
            
            mapSize = (frame.width < frame.height) ? frame.width : frame.height
            clear()
            drawMap()
        }
    }
    
    weak var delegate:AMJpnMapViewDelegate?
    
    @IBInspectable var strokeColor:UIColor = UIColor.green
    
    @IBInspectable var fillColor:UIColor = UIColor.green
    
    @IBInspectable var strokeColorOkinawaLine:UIColor = UIColor.black
    
    /// 地図の大きさ
    private var mapSize:CGFloat = 0
    
    /// 北海道描画用レイヤー
    private var layerHokkaido:CAShapeLayer?
    
    /// 東北描画用レイヤー
    private var layerTohoku:CAShapeLayer?
    
    /// 関東描画用レイヤー
    private var layerKanto:CAShapeLayer?
    
    /// 中部描画用レイヤー
    private var layerChubu:CAShapeLayer?
    
    /// 近畿描画用レイヤー
    private var layerKinki:CAShapeLayer?
    
    /// 中国描画用レイヤー
    private var layerChugoku:CAShapeLayer?
    
    /// 四国描画用レイヤー
    private var layerShikoku:CAShapeLayer?
    
    /// 九州描画用レイヤー
    private var layerKyushu:CAShapeLayer?
    
    /// 沖縄描画用レイヤー（九州レイヤーにのせる）
    private var layerOkinawa:CAShapeLayer?
    
    /// 拡大時の起点リスト
    private var anchorPointList = [CGPoint]()
    
    private var regionLayers = [CAShapeLayer]()
    
    /// 沖縄の区切り線
    private var layerOkinawaLine:CAShapeLayer?
    
    private var preSelectRegion:AMJMRegion = .none
    
    //MARK:Initialize
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder:aDecoder)
        initView()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        initView()
    }
    
    convenience init() {
        
        self.init(frame: CGRect.zero)
    }
    
    private func initView() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(gesture:)))
        addGestureRecognizer(tap)
    }

    override func draw(_ rect: CGRect) {
        
        mapSize = (rect.width < rect.height) ? rect.width : rect.height
        clear()
        drawMap()
    }
    
    //MARK:Gesture Action
    @objc func tapAction(gesture: UITapGestureRecognizer) {
        
        let point = gesture.location(in: self)
        var isMap = false
        for (index, layer) in regionLayers.enumerated() {
            
            let path = UIBezierPath(cgPath: layer.path!)
            if path.contains(point) {
                
                isMap = true
                deselectLayer()
                if preSelectRegion.rawValue == index {
                    
                    preSelectRegion = .none
                    
                } else {
                    
                    preSelectRegion = preSelectRegion.convert(index: index)
                    layer.zPosition = 1
                    if let delegate = delegate {
                        
                        delegate.jpnMapView(jpnMapView: self, didSelectAtRegion: preSelectRegion)
                    }
                }
                break
            }
        }
        
        if !isMap {
            
            deselectLayer()
            preSelectRegion = .none
        }
    }
    
    private func deselectLayer() {
        
        if preSelectRegion == .none {
           
            return
        }
        
        let layer = regionLayers[preSelectRegion.rawValue]
        layer.zPosition = -1
        if let delegate = delegate {
            
            delegate.jpnMapView(jpnMapView: self, didDeselectAtRegion: preSelectRegion)
        }
    }
    
    private func reloadMap() {
        
        clear()
        drawMap()
    }
    
    //MARK:Draw
    private func drawMap() {
        
        drawHokkaido()
        drawTohoku()
        drawKanto()
        drawChubu()
        drawKinki()
        drawChugoku()
        drawShikoku()
        drawKyushu()
        drawOkinawa()
        
        for layer in regionLayers {
            
            layer.strokeColor = strokeColor.cgColor
            layer.fillColor = fillColor.cgColor
            layer.zPosition = -1
        }
        
        guard let layerOkinawa = layerOkinawa else {
            
            return
        }
        
        layerOkinawa.strokeColor = strokeColor.cgColor
        layerOkinawa.fillColor = fillColor.cgColor
    }
    
    private func drawHokkaido() {
        
        var pointList = [CGPoint]()
        pointList.append(createPoint(x: 382, y: 8))
        pointList.append(createPoint(x: 414, y: 45))
        pointList.append(createPoint(x: 450, y: 64))
        pointList.append(createPoint(x: 466, y: 51))
        pointList.append(createPoint(x: 461, y: 69))
        pointList.append(createPoint(x: 466, y: 83))
        pointList.append(createPoint(x: 479, y: 81))
        pointList.append(createPoint(x: 450, y: 96))
        pointList.append(createPoint(x: 434, y: 96))
        pointList.append(createPoint(x: 419, y: 112))
        pointList.append(createPoint(x: 413, y: 131))
        pointList.append(createPoint(x: 374, y: 105))
        pointList.append(createPoint(x: 356, y: 117))
        pointList.append(createPoint(x: 348, y: 104))
        pointList.append(createPoint(x: 348, y: 107))
        pointList.append(createPoint(x: 338, y: 119))
        pointList.append(createPoint(x: 345, y: 121))
        pointList.append(createPoint(x: 360, y: 134))
        pointList.append(createPoint(x: 356, y: 139))
        pointList.append(createPoint(x: 350, y: 136))
        pointList.append(createPoint(x: 346, y: 140))
        pointList.append(createPoint(x: 334, y: 149))
        pointList.append(createPoint(x: 336, y: 127))
        pointList.append(createPoint(x: 327, y: 119))
        pointList.append(createPoint(x: 331, y: 106))
        pointList.append(createPoint(x: 345, y: 95))
        pointList.append(createPoint(x: 342, y: 83))
        pointList.append(createPoint(x: 347, y: 81))
        pointList.append(createPoint(x: 369, y: 85))
        pointList.append(createPoint(x: 365, y: 68))
        pointList.append(createPoint(x: 372, y: 55))
        pointList.append(createPoint(x: 378, y: 36))
        pointList.append(createPoint(x: 372, y: 13))
        pointList.append(createPoint(x: 378, y: 14))
        
        layerHokkaido = createLayer(pointList: pointList)
        guard let layerHokkaido = layerHokkaido else {
            
            return
        }
        
        layer.addSublayer(layerHokkaido)
        regionLayers.append(layerHokkaido)
        let centerPoint = createCenterPoint(point1: createPoint(x: 382, y: 8),
                                            point2: createPoint(x: 413, y: 131))
        anchorPointList.append(centerPoint)
    }
    
    private func drawTohoku() {
        
        var pointList = [CGPoint]()
        pointList.append(createPoint(x: 356, y: 145))
        pointList.append(createPoint(x: 362, y: 151))
        pointList.append(createPoint(x: 371, y: 150))
        pointList.append(createPoint(x: 369, y: 172))
        pointList.append(createPoint(x: 373, y: 179))// 青森・岩手
        pointList.append(createPoint(x: 379, y: 184))
        pointList.append(createPoint(x: 384, y: 206))
        pointList.append(createPoint(x: 378, y: 225))
        pointList.append(createPoint(x: 374, y: 230))// 岩手・宮城
        pointList.append(createPoint(x: 368, y: 236))
        pointList.append(createPoint(x: 369, y: 251))
        pointList.append(createPoint(x: 363, y: 247))
        pointList.append(createPoint(x: 359, y: 249))
        pointList.append(createPoint(x: 356, y: 253))
        pointList.append(createPoint(x: 356, y: 263))// 宮城・福島
        pointList.append(createPoint(x: 358, y: 273))
        /// 関東との接点
        pointList.append(createPoint(x: 355, y: 292))//福島・茨城
        pointList.append(createPoint(x: 347, y: 296))
        pointList.append(createPoint(x: 346, y: 297))
        pointList.append(createPoint(x: 340, y: 296))//福島・茨城・栃木
        pointList.append(createPoint(x: 337, y: 294))
        pointList.append(createPoint(x: 337, y: 290))
        pointList.append(createPoint(x: 329, y: 286))
        pointList.append(createPoint(x: 321, y: 292))//福島・群馬・栃木
        /// 関東・中部との接点
        pointList.append(createPoint(x: 313, y: 292))//福島・群馬・新潟
        /// 中部との接点
        pointList.append(createPoint(x: 312, y: 277))
        pointList.append(createPoint(x: 321, y: 275))
        pointList.append(createPoint(x: 326, y: 266))// 山形・福島・新潟
        pointList.append(createPoint(x: 325, y: 261))
        pointList.append(createPoint(x: 328, y: 249))
        pointList.append(createPoint(x: 322, y: 242))// 山形・新潟
        pointList.append(createPoint(x: 328, y: 230))
        pointList.append(createPoint(x: 328, y: 225))// 秋田・山形
        pointList.append(createPoint(x: 334, y: 207))
        pointList.append(createPoint(x: 332, y: 198))
        pointList.append(createPoint(x: 325, y: 200))
        pointList.append(createPoint(x: 323, y: 196))
        pointList.append(createPoint(x: 329, y: 193))
        pointList.append(createPoint(x: 332, y: 180))// 青森・秋田
        pointList.append(createPoint(x: 331, y: 172))
        pointList.append(createPoint(x: 339, y: 168))
        pointList.append(createPoint(x: 341, y: 154))
        pointList.append(createPoint(x: 344, y: 155))
        pointList.append(createPoint(x: 349, y: 154))
        pointList.append(createPoint(x: 351, y: 168))
        pointList.append(createPoint(x: 353, y: 165))
        pointList.append(createPoint(x: 355, y: 162))
        pointList.append(createPoint(x: 362, y: 166))
        pointList.append(createPoint(x: 363, y: 153))
        pointList.append(createPoint(x: 352, y: 156))
    
        layerTohoku = createLayer(pointList: pointList)
        guard let layerTohoku = layerTohoku else {
            
            return
        }
        layer.addSublayer(layerTohoku)
        regionLayers.append(layerTohoku)
        let centerPoint = createCenterPoint(point1: createPoint(x: 356, y: 145),
                                            point2: createPoint(x: 329, y: 286))
        anchorPointList.append(centerPoint)
    }
    
    private func drawKanto() {
        
        var pointList = [CGPoint]()
        /// 東北・中部との接点
        pointList.append(createPoint(x: 313, y: 292))//福島・群馬・新潟
        /// 東北との接点
        pointList.append(createPoint(x: 321, y: 292))//福島・群馬・栃木
        pointList.append(createPoint(x: 329, y: 286))
        pointList.append(createPoint(x: 337, y: 290))
        pointList.append(createPoint(x: 337, y: 294))
        pointList.append(createPoint(x: 340, y: 296))//福島・茨城・栃木
        pointList.append(createPoint(x: 346, y: 297))
        pointList.append(createPoint(x: 347, y: 296))
        pointList.append(createPoint(x: 355, y: 292))//福島・茨城
        pointList.append(createPoint(x: 345, y: 315))
        pointList.append(createPoint(x: 353, y: 331))
        pointList.append(createPoint(x: 343, y: 335))
        pointList.append(createPoint(x: 343, y: 347))
        pointList.append(createPoint(x: 327, y: 355))
        pointList.append(createPoint(x: 327, y: 343))
        pointList.append(createPoint(x: 334, y: 338))
        pointList.append(createPoint(x: 333, y: 333))
        pointList.append(createPoint(x: 329, y: 334))// 東京・千葉
        pointList.append(createPoint(x: 327, y: 335))// 東京・神奈川
        pointList.append(createPoint(x: 324, y: 342))
        pointList.append(createPoint(x: 326, y: 346))
        pointList.append(createPoint(x: 322, y: 349))
        pointList.append(createPoint(x: 321, y: 345))
        pointList.append(createPoint(x: 312, y: 345))
        /// 中部との接点
        pointList.append(createPoint(x: 308, y: 350))// 神奈川・静岡
        pointList.append(createPoint(x: 308, y: 343))
        pointList.append(createPoint(x: 305, y: 341))
        pointList.append(createPoint(x: 310, y: 334))// 神奈川・静岡・山梨
        pointList.append(createPoint(x: 312, y: 332))// 神奈川・東京・山梨
        pointList.append(createPoint(x: 306, y: 327))// 東京・埼玉・山梨
        pointList.append(createPoint(x: 297, y: 323))// 埼玉・山梨・長野
        pointList.append(createPoint(x: 300, y: 321))// 埼玉・群馬・長野
        pointList.append(createPoint(x: 297, y: 319))
        pointList.append(createPoint(x: 298, y: 309))
        pointList.append(createPoint(x: 292, y: 306))// 群馬・長野・新潟
        pointList.append(createPoint(x: 303, y: 297))
        pointList.append(createPoint(x: 308, y: 291))
        
        layerKanto = createLayer(pointList: pointList)
        guard let layerKanto = layerKanto else {
            
            return
        }
        layer.addSublayer(layerKanto)
        regionLayers.append(layerKanto)
        let centerPoint = createCenterPoint(point1: createPoint(x: 329, y: 286),
                                            point2: createPoint(x: 327, y: 355))
        anchorPointList.append(centerPoint)
    }
    
    private func drawChubu() {
        
        var pointList = [CGPoint]()
        /// 東北との接点
        pointList.append(createPoint(x: 322, y: 242))// 山形・新潟
        pointList.append(createPoint(x: 328, y: 249))
        pointList.append(createPoint(x: 325, y: 261))
        pointList.append(createPoint(x: 326, y: 266))// 山形・福島・新潟
        pointList.append(createPoint(x: 321, y: 275))
        pointList.append(createPoint(x: 312, y: 277))
        /// 東北・中部との接点
        pointList.append(createPoint(x: 313, y: 292))//福島・群馬・新潟
        //// 関東との接点
        pointList.append(createPoint(x: 308, y: 291))
        pointList.append(createPoint(x: 303, y: 297))
        pointList.append(createPoint(x: 292, y: 306))// 群馬・長野・新潟
        pointList.append(createPoint(x: 298, y: 309))
        pointList.append(createPoint(x: 297, y: 319))
        pointList.append(createPoint(x: 300, y: 321))// 埼玉・群馬・長野
        pointList.append(createPoint(x: 297, y: 323))// 埼玉・山梨・長野
        pointList.append(createPoint(x: 306, y: 327))// 東京・埼玉・山梨
        pointList.append(createPoint(x: 312, y: 332))// 神奈川・東京・山梨
        pointList.append(createPoint(x: 310, y: 334))// 神奈川・静岡・山梨
        pointList.append(createPoint(x: 305, y: 341))
        pointList.append(createPoint(x: 308, y: 343))
        pointList.append(createPoint(x: 308, y: 350))// 神奈川・静岡
        pointList.append(createPoint(x: 311, y: 355))
        pointList.append(createPoint(x: 304, y: 365))
        pointList.append(createPoint(x: 300, y: 362))
        pointList.append(createPoint(x: 300, y: 354))
        pointList.append(createPoint(x: 305, y: 351))
        pointList.append(createPoint(x: 297, y: 349))
        pointList.append(createPoint(x: 284, y: 365))
        pointList.append(createPoint(x: 270, y: 364))// 愛知・静岡
        pointList.append(createPoint(x: 258, y: 366))
        pointList.append(createPoint(x: 265, y: 361))
        pointList.append(createPoint(x: 259, y: 360))
        pointList.append(createPoint(x: 256, y: 359))
        pointList.append(createPoint(x: 257, y: 363))
        pointList.append(createPoint(x: 252, y: 360))
        pointList.append(createPoint(x: 253, y: 353))
        pointList.append(createPoint(x: 250, y: 351))// 愛知・三重
        pointList.append(createPoint(x: 244, y: 363))
        pointList.append(createPoint(x: 254, y: 369))
        pointList.append(createPoint(x: 253, y: 375))
        pointList.append(createPoint(x: 240, y: 378))
        pointList.append(createPoint(x: 239, y: 383))
        /// 近畿との接点
        pointList.append(createPoint(x: 231, y: 391))//和歌山・三重
        pointList.append(createPoint(x: 228, y: 387))// 和歌山・三重・奈良
        pointList.append(createPoint(x: 234, y: 381))
        pointList.append(createPoint(x: 233, y: 372))
        pointList.append(createPoint(x: 237, y: 370))
        pointList.append(createPoint(x: 232, y: 361))// 京都・三重・奈良
        pointList.append(createPoint(x: 234, y: 360))// 京都・三重・滋賀
        pointList.append(createPoint(x: 244, y: 347))
        pointList.append(createPoint(x: 242, y: 346))// 岐阜・三重・滋賀
        pointList.append(createPoint(x: 239, y: 333))// 岐阜・福井・滋賀
        pointList.append(createPoint(x: 228, y: 338))
        pointList.append(createPoint(x: 225, y: 343))// 京都・福井・滋賀
        pointList.append(createPoint(x: 222, y: 343))
        pointList.append(createPoint(x: 215, y: 339))// 京都・福井
        pointList.append(createPoint(x: 222, y: 337))
        pointList.append(createPoint(x: 233, y: 330))
        pointList.append(createPoint(x: 228, y: 323))
        pointList.append(createPoint(x: 238, y: 313))// 福井・石川
        pointList.append(createPoint(x: 255, y: 290))
        pointList.append(createPoint(x: 249, y: 282))
        pointList.append(createPoint(x: 265, y: 274))
        pointList.append(createPoint(x: 264, y: 281))
        pointList.append(createPoint(x: 258, y: 284))
        pointList.append(createPoint(x: 258, y: 291))// 石川・富山
        pointList.append(createPoint(x: 258, y: 297))
        pointList.append(createPoint(x: 266, y: 298))
        pointList.append(createPoint(x: 266, y: 293))
        pointList.append(createPoint(x: 274, y: 291))// 新潟・富山
        pointList.append(createPoint(x: 292, y: 282))
        pointList.append(createPoint(x: 302, y: 266))
        pointList.append(createPoint(x: 313, y: 259))
      
        layerChubu = createLayer(pointList: pointList)
        guard let layerChubu = layerChubu else {
            
            return
        }
        layer.addSublayer(layerChubu)
        regionLayers.append(layerChubu)
        let centerPoint = createCenterPoint(point1: createPoint(x: 322, y: 242),
                                            point2: createPoint(x: 231, y: 391))
        anchorPointList.append(centerPoint)
    }
    
    private func drawKinki() {
        
        var pointList = [CGPoint]()
        // 中部との接点
        pointList.append(createPoint(x: 215, y: 339))// 京都・福井
        pointList.append(createPoint(x: 222, y: 343))
        pointList.append(createPoint(x: 225, y: 343))// 京都・福井・滋賀
        pointList.append(createPoint(x: 228, y: 338))
        pointList.append(createPoint(x: 239, y: 333))// 岐阜・福井・滋賀
        pointList.append(createPoint(x: 242, y: 346))// 岐阜・三重・滋賀
        pointList.append(createPoint(x: 244, y: 347))
        pointList.append(createPoint(x: 234, y: 360))// 京都・三重・滋賀
        pointList.append(createPoint(x: 232, y: 361))// 京都・三重・奈良
        pointList.append(createPoint(x: 237, y: 370))
        pointList.append(createPoint(x: 233, y: 372))
        pointList.append(createPoint(x: 234, y: 381))
        pointList.append(createPoint(x: 228, y: 387))// 和歌山・三重・奈良
        pointList.append(createPoint(x: 231, y: 391))//和歌山・三重
        pointList.append(createPoint(x: 225, y: 401))
        pointList.append(createPoint(x: 216, y: 397))
        pointList.append(createPoint(x: 217, y: 390))
        pointList.append(createPoint(x: 209, y: 385))
        pointList.append(createPoint(x: 209, y: 374))
        pointList.append(createPoint(x: 211, y: 372))//和歌山・大阪
        pointList.append(createPoint(x: 217, y: 366))
        pointList.append(createPoint(x: 218, y: 362))//大阪・兵庫
        pointList.append(createPoint(x: 212, y: 362))
        pointList.append(createPoint(x: 205, y: 365))
        pointList.append(createPoint(x: 198, y: 360))
        // 中国との接点
        pointList.append(createPoint(x: 186, y: 360))// 兵庫・岡山
        pointList.append(createPoint(x: 192, y: 345))// 鳥取・兵庫・岡山
        pointList.append(createPoint(x: 194, y: 343))
        pointList.append(createPoint(x: 190, y: 334))// 鳥取・兵庫
        pointList.append(createPoint(x: 203, y: 334))//京都・兵庫
        pointList.append(createPoint(x: 211, y: 329))
        pointList.append(createPoint(x: 215, y: 332))
        pointList.append(createPoint(x: 214, y: 336))

        layerKinki = createLayer(pointList: pointList)
        guard let layerKinki = layerKinki else {
            
            return
        }
        layer.addSublayer(layerKinki)
        regionLayers.append(layerKinki)
        let centerPoint = createCenterPoint(point1: createPoint(x: 215, y: 339),
                                            point2: createPoint(x: 231, y: 391))
        anchorPointList.append(centerPoint)
    }
    
    private func drawChugoku() {
        
        var pointList = [CGPoint]()
        /// 近畿との接点
        pointList.append(createPoint(x: 190, y: 334))// 鳥取・兵庫
        pointList.append(createPoint(x: 194, y: 343))
        pointList.append(createPoint(x: 192, y: 345))// 鳥取・兵庫・岡山
        pointList.append(createPoint(x: 186, y: 360))// 兵庫・岡山
        pointList.append(createPoint(x: 177, y: 370))
        pointList.append(createPoint(x: 169, y: 368))// 岡山・広島
        pointList.append(createPoint(x: 166, y: 369))
        pointList.append(createPoint(x: 145, y: 377))
        pointList.append(createPoint(x: 142, y: 371))
        pointList.append(createPoint(x: 139, y: 377))// 広島・山口
        pointList.append(createPoint(x: 138, y: 376))
        pointList.append(createPoint(x: 137, y: 383))
        pointList.append(createPoint(x: 131, y: 388))
        pointList.append(createPoint(x: 124, y: 381))
        pointList.append(createPoint(x: 112, y: 385))
        pointList.append(createPoint(x: 104, y: 384))
        pointList.append(createPoint(x: 106, y: 370))
        pointList.append(createPoint(x: 114, y: 372))
        pointList.append(createPoint(x: 123, y: 363))// 島根・山口
        pointList.append(createPoint(x: 147, y: 343))
        pointList.append(createPoint(x: 163, y: 335))
        pointList.append(createPoint(x: 164, y: 338))
        pointList.append(createPoint(x: 165, y: 340))// 鳥取・島根
        pointList.append(createPoint(x: 170, y: 337))
        pointList.append(createPoint(x: 182, y: 338))

        layerChugoku = createLayer(pointList: pointList)
        guard let layerChugoku = layerChugoku else {
            
            return
        }
        layer.addSublayer(layerChugoku)
        regionLayers.append(layerChugoku)
        let centerPoint = createCenterPoint(point1: createPoint(x: 194, y: 343),
                                            point2: createPoint(x: 104, y: 384))
        anchorPointList.append(centerPoint)
    }
    
    private func drawShikoku() {
        
        var pointList = [CGPoint]()
        pointList.append(createPoint(x: 184, y: 373))
        pointList.append(createPoint(x: 187, y: 375))
        pointList.append(createPoint(x: 194, y: 377))// 香川・徳島
        pointList.append(createPoint(x: 197, y: 377))
        pointList.append(createPoint(x: 200, y: 389))
        pointList.append(createPoint(x: 189, y: 397))
        pointList.append(createPoint(x: 188, y: 398))// 徳島・高知
        pointList.append(createPoint(x: 186, y: 406))
        pointList.append(createPoint(x: 178, y: 399))
        pointList.append(createPoint(x: 167, y: 400))
        pointList.append(createPoint(x: 151, y: 421))
        pointList.append(createPoint(x: 146, y: 415))// 高知・愛媛
        pointList.append(createPoint(x: 143, y: 417))
        pointList.append(createPoint(x: 143, y: 404))
        pointList.append(createPoint(x: 132, y: 403))
        pointList.append(createPoint(x: 148, y: 393))
        pointList.append(createPoint(x: 155, y: 380))
        pointList.append(createPoint(x: 158, y: 385))
        pointList.append(createPoint(x: 172, y: 382))// 香川・愛媛
        pointList.append(createPoint(x: 171, y: 375))
        
        layerShikoku = createLayer(pointList: pointList)
        guard let layerShikoku = layerShikoku else {
            
            return
        }
        layer.addSublayer(layerShikoku)
        regionLayers.append(layerShikoku)
        let centerPoint = createCenterPoint(point1: createPoint(x: 197, y: 377),
                                            point2: createPoint(x: 143, y: 404))
        anchorPointList.append(centerPoint)
    }
    
    private func drawKyushu() {
        
        var pointList = [CGPoint]()
        pointList.append(createPoint(x: 103, y: 385))
        pointList.append(createPoint(x: 105, y: 391))
        pointList.append(createPoint(x: 111, y: 397))// 福岡・大分
        pointList.append(createPoint(x: 122, y: 393))
        pointList.append(createPoint(x: 127, y: 398))
        pointList.append(createPoint(x: 118, y: 405))
        pointList.append(createPoint(x: 130, y: 407))
        pointList.append(createPoint(x: 133, y: 416))
        pointList.append(createPoint(x: 129, y: 421))// 大分・宮崎
        pointList.append(createPoint(x: 124, y: 425))
        pointList.append(createPoint(x: 119, y: 437))
        pointList.append(createPoint(x: 114, y: 462))
        pointList.append(createPoint(x: 110, y: 457))// 宮崎・鹿児島
        pointList.append(createPoint(x: 98, y: 472))
        pointList.append(createPoint(x: 98, y: 456))
        pointList.append(createPoint(x: 101, y: 456))
        pointList.append(createPoint(x: 101, y: 450))
        pointList.append(createPoint(x: 97, y: 450))
        pointList.append(createPoint(x: 94, y: 462))
        pointList.append(createPoint(x: 98, y: 467))
        pointList.append(createPoint(x: 83, y: 462))
        pointList.append(createPoint(x: 90, y: 458))
        pointList.append(createPoint(x: 85, y: 450))
        pointList.append(createPoint(x: 84, y: 436))
        pointList.append(createPoint(x: 88, y: 437))// 熊本・鹿児島
        pointList.append(createPoint(x: 89, y: 428))
        pointList.append(createPoint(x: 95, y: 420))
        pointList.append(createPoint(x: 96, y: 414))
        pointList.append(createPoint(x: 93, y: 413))// 熊本・福岡
        pointList.append(createPoint(x: 91, y: 411))
        pointList.append(createPoint(x: 88, y: 407))// 福岡・佐賀
        pointList.append(createPoint(x: 85, y: 415))// 佐賀・長崎
        pointList.append(createPoint(x: 83, y: 418))
        pointList.append(createPoint(x: 83, y: 419))
        pointList.append(createPoint(x: 85, y: 420))
        pointList.append(createPoint(x: 91, y: 421))
        pointList.append(createPoint(x: 86, y: 426))
        pointList.append(createPoint(x: 85, y: 422))
        pointList.append(createPoint(x: 76, y: 425))
        pointList.append(createPoint(x: 76, y: 420))
        pointList.append(createPoint(x: 72, y: 410))
        pointList.append(createPoint(x: 69, y: 406))
        pointList.append(createPoint(x: 72, y: 402))
        pointList.append(createPoint(x: 76, y: 402))// 佐賀・長崎
        pointList.append(createPoint(x: 78, y: 397))
        pointList.append(createPoint(x: 83, y: 398))// 福岡・佐賀

        layerKyushu = createLayer(pointList: pointList)
        guard let layerKyushu = layerKyushu else {
            
            return
        }
        layer.addSublayer(layerKyushu)
        regionLayers.append(layerKyushu)
        let centerPoint = createCenterPoint(point1: createPoint(x: 103, y: 385),
                                            point2: createPoint(x: 98, y: 472))
        anchorPointList.append(centerPoint)
    }
    
    private func drawOkinawa() {
        
        var pointList = [CGPoint]()
        pointList.append(createPoint(x: 52, y: 469))
        pointList.append(createPoint(x: 52, y: 473))
        pointList.append(createPoint(x: 38, y: 481))
        pointList.append(createPoint(x: 36, y: 490))
        pointList.append(createPoint(x: 32, y: 491))
        pointList.append(createPoint(x: 31, y: 489))
        pointList.append(createPoint(x: 34, y: 481))
        pointList.append(createPoint(x: 42, y: 477))
        pointList.append(createPoint(x: 39, y: 474))
        pointList.append(createPoint(x: 39, y: 473))
        pointList.append(createPoint(x: 42, y: 472))
        pointList.append(createPoint(x: 43, y: 475))
        pointList.append(createPoint(x: 50, y: 468))

        layerOkinawa = createLayer(pointList: pointList)
        guard let layerOkinawa = layerOkinawa else {
            
            return
        }
        guard let layerKyushu = layerKyushu else {
            
            return
        }
        layerKyushu.addSublayer(layerOkinawa)
     
        let linePath = UIBezierPath()
        linePath.move(to: createPoint(x: 21, y: 456))
        linePath.addLine(to: createPoint(x: 62, y: 456))
        linePath.addLine(to: createPoint(x: 62, y: 496))
        
        layerOkinawaLine = CAShapeLayer()
        guard let layerOkinawaLine = layerOkinawaLine else {
            
            return
        }
        
        layerOkinawaLine.frame = bounds
        layerOkinawaLine.strokeColor = strokeColorOkinawaLine.cgColor
        layerOkinawaLine.fillColor = UIColor.clear.cgColor
        layerOkinawaLine.path = linePath.cgPath
        layerOkinawa.addSublayer(layerOkinawaLine)
    }
    
    private func clear() {
        
        anchorPointList.removeAll()
        regionLayers.removeAll()
        layerHokkaido?.removeFromSuperlayer()
        layerTohoku?.removeFromSuperlayer()
        layerKanto?.removeFromSuperlayer()
        layerChubu?.removeFromSuperlayer()
        layerKinki?.removeFromSuperlayer()
        layerChugoku?.removeFromSuperlayer()
        layerShikoku?.removeFromSuperlayer()
        layerKyushu?.removeFromSuperlayer()
        layerOkinawa?.removeFromSuperlayer()
        layerOkinawaLine?.removeFromSuperlayer()
        
        layerHokkaido = nil
        layerTohoku = nil
        layerKanto = nil
        layerChubu = nil
        layerKinki = nil
        layerChugoku = nil
        layerShikoku = nil
        layerKyushu = nil
        layerOkinawa = nil
        layerOkinawaLine = nil
    }
    
    private func createLayer(pointList: [CGPoint]) -> CAShapeLayer {
        
        let path = UIBezierPath()
        for (index, point) in pointList.enumerated() {
            
            if index == 0 {
                
                path.move(to: point)
                
            } else {
                
                path.addLine(to: point)
            }
        }
        path.close()
    
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.path = path.cgPath
        return layer
    }
    
    private func createPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        
        return CGPoint(x: mapSize * (x/500.0), y: mapSize * (y/500.0))
    }
    
    private func createCenterPoint(point1: CGPoint, point2: CGPoint) -> CGPoint {
        
        let centerX = (point1.x + point2.x)/2
        let centerY = (point1.y + point2.y)/2
        return CGPoint(x: centerX/frame.width, y: centerY/frame.height)
    }
    
    //MARK:Public Method
    func setStrokeColor(color: UIColor, region: AMJMRegion) {
        
        if region == .none {
            
            return
        }
        
        if regionLayers.count == 0 {
            
            return
        }
        
        let layer = regionLayers[region.rawValue]
        layer.strokeColor = color.cgColor
        if region == .kyushu {
            
            layerOkinawa?.strokeColor = color.cgColor
        }
    }
    
    func setFillColor(color: UIColor, region: AMJMRegion) {
        
        if region == .none {
            
            return
        }
        
        if regionLayers.count == 0 {
            
            return
        }
        
        let layer = regionLayers[region.rawValue]
        layer.fillColor = color.cgColor
        if region == .kyushu {
            
            layerOkinawa?.fillColor = color.cgColor
        }
    }
    
    func setScale(scale: CGFloat, region: AMJMRegion) {
        
        if region == .none {
            
            return
        }
        
        if regionLayers.count == 0 {
            
            return
        }
        
        let layer = regionLayers[region.rawValue]
        layer.anchorPoint = (scale == 1.0) ? CGPoint(x: 0.5, y: 0.5) : anchorPointList[region.rawValue]
        layer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
    }
}
