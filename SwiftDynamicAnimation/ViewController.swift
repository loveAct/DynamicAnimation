//
//  ViewController.swift
//  SwiftDynamicAnimation
//
//  Created by apple on 2017/3/21.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    var animator: UIDynamicAnimator?
    var gravity : UIGravityBehavior?
    
    var collision: UICollisionBehavior?
    lazy var starArr: [Any] = [Any]()
    lazy var motionManager = CMMotionManager()
    var snapBehavior: UISnapBehavior?
    var redView: UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator = UIDynamicAnimator(referenceView: self.view)
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer))
        self.view .addGestureRecognizer(pan)
        startAnimation()
    }
    private func startAnimation(){
        for _ in 0..<5 {
            starArr.append(creatStartView())
        }
        starArr.append(addRedView())
        gravity = UIGravityBehavior(items: starArr as! [UIDynamicItem])
        gravity?.magnitude = 0.8
        collision = UICollisionBehavior(items: starArr as! [UIDynamicItem])
     
        setBoundaries()
        animator?.addBehavior(gravity!)
        animator?.addBehavior(collision!)
        
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { (la) in
        self.setDynamicGravity()
        }
    }
    //    动态改变重力   需要不断的调用这个方法
    private func setDynamicGravity(){
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            let rotation = atan2((motion?.gravity.x)!, (motion?.gravity.y)!) - (M_PI/2)
            self.gravity?.setAngle(CGFloat(rotation), magnitude: 0.8)
        }
    }
    private func setBoundaries(){
        let bezierPath = UIBezierPath(roundedRect: CGRect.init(x:0 , y: 100.0, width: 300.0, height: 300.0), cornerRadius: 100.0)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        self.view.layer.mask = shapeLayer
        collision?.addBoundary(withIdentifier: "xx" as NSCopying, for: bezierPath)
    }
    //    添加星星图片
    private func creatStartView() -> UIView{
        let star = UIImageView(image: UIImage(named: "MSRInfo_Main_star_01"))
        let x = arc4random_uniform(50) + 7
        star.frame = CGRect(x: Double(x), y: 200.0, width: 24.0, height: 24.0)
        self.view.addSubview(star)
        return star
    }
    //添加红色视图
    private func addRedView() -> UIView{
        redView = UIView(frame: CGRect(x: 100, y: 200, width: 50, height: 50))
        self.view.addSubview(redView!)
        redView?.backgroundColor = UIColor.red
        return redView!
    }
    //    添加手势
    @objc private func panGestureRecognizer(gesture: UIPanGestureRecognizer){
        let tapPoint = gesture.location(in: self.view)
        if (snapBehavior != nil) {
            animator?.removeBehavior(snapBehavior!)
            snapBehavior = nil
        }
        snapBehavior = UISnapBehavior(item: redView!, snapTo: tapPoint)
        snapBehavior?.action = {
//            print("UISnapBehavior 在执行")
        }
        snapBehavior?.damping = 0.8  //弹性
        animator?.addBehavior(snapBehavior!)
        if gesture.state == UIGestureRecognizerState.ended {
            animator?.removeBehavior(snapBehavior!)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

