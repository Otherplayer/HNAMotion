//
//  ViewController.swift
//  HNAAltimeter
//
//  Created by __无邪_ on 2017/8/18.
//  Copyright © 2017年 __无邪_. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var btnAltimeter: UIButton!
    @IBOutlet weak var btnAirPressure: UIButton!
    @IBOutlet weak var textViewPedometer: UITextView!
    
    
    //高度计对象
    @IBOutlet weak var textViewActivity: UITextView!
    let altimeter = CMAltimeter()
    //计步器对象
    let pedometer = CMPedometer()
    //用于检查用户当前的活动状态。可以检测到 5 种状态：静止、步行、跑步、自行车、驾车。
    let motionActivityManager = CMMotionActivityManager()
    //获取到加速器，陀螺仪，磁力仪，传感器这4类数据
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.startRelativeAltitudeUpdates()
        self.startPedometerUpdates()
        self.startActivityUpdates()
        
    }
    @IBAction func altimeterAction(_ sender: Any) {
        
    }
    @IBAction func airPressureAction(_ sender: Any) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - 获取高度计数据
    func startRelativeAltitudeUpdates() {
        //判断设备支持情况
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            self.btnAltimeter.setTitle("当前设备不支持获取高度", for: UIControlState.normal)
            self.btnAirPressure.setTitle("当前设备不支持获取压力", for: UIControlState.normal)
            return
        }
        
        //初始化并开始实时获取数据
        let queue = OperationQueue.current
        self.altimeter.startRelativeAltitudeUpdates(to: queue!, withHandler: {
            (altitudeData, error) in
            //错误处理
            guard error == nil else {
                print(error!)
                return
            }
            
            //获取各个数据
            self.btnAltimeter.setTitle("高度: \(altitudeData!.relativeAltitude) 米", for: UIControlState.normal)
            self.btnAirPressure.setTitle("压力: \(altitudeData!.pressure) 千帕", for: UIControlState.normal)
            
        })
    }
    
    //MARK: - 获取步数计数据
    func startPedometerUpdates() {
        //判断设备支持情况
        guard CMPedometer.isStepCountingAvailable() else {
            self.textViewPedometer.text = "当前设备不支持获取步数"
            return
        }
        
        //获取今天凌晨时间
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let midnightOfToday = cal.date(from: comps)!
        
        //初始化并开始实时获取数据
        self.pedometer.startUpdates (from: midnightOfToday, withHandler: { pedometerData, error in
            //错误处理
            guard error == nil else {
                print(error!)
                return
            }
            
            //获取各个数据
            var text = "---今日运动数据---\n"
            if let numberOfSteps = pedometerData?.numberOfSteps {
                text += "步数: \(numberOfSteps)\n"
            }
            if let distance = pedometerData?.distance {
                text += "距离: \(distance)\n"
            }
            if let floorsAscended = pedometerData?.floorsAscended {
                text += "上楼: \(floorsAscended)\n"
            }
            if let floorsDescended = pedometerData?.floorsDescended {
                text += "下楼: \(floorsDescended)\n"
            }
            if let currentPace = pedometerData?.currentPace {
                text += "速度: \(currentPace)m/s\n"
            }
            if let currentCadence = pedometerData?.currentCadence {
                text += "速度: \(currentCadence)步/秒\n"
            }
            
            DispatchQueue.main.async{
                self.textViewPedometer.text = text
            }
        })
    }
    
    //MARK: - 获取活动器数据
    func startActivityUpdates() {
        //判断设备支持情况
        guard CMMotionActivityManager.isActivityAvailable() else {
            self.textViewActivity.text = "当前设备不支持获取当前运动状态"
            return
        }
        
        //初始化并开始实时获取数据
        let queue = OperationQueue.current
        self.motionActivityManager.startActivityUpdates(to: queue!, withHandler: {
            activity in
            //获取各个数据
            var text = "---活动器数据---\n"
            text += "当前状态: \(activity!.getDescription())\n"
            if (activity!.confidence == .low) {
                text += "准确度: 低\n"
            } else if (activity!.confidence == .medium) {
                text += "准确度: 低\n"
            } else if (activity!.confidence == .high) {
                text += "准确度: 高\n"
            }
            text += "\(activity!.description)\n"
            self.textViewActivity.text = text
        })
    }


}


extension CMMotionActivity {
    /// 获取用户设备当前所处环境的描述
    func getDescription() -> String {
        if self.stationary {
            return "静止"
        } else if self.walking {
            return "步行"
        } else if self.running {
            return "跑步"
        } else if self.automotive {
            return "驾车"
        }else if self.cycling {
            return "自行车"
        }
        return "未知"
    }
}

